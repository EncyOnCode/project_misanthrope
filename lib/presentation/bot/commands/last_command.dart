import 'package:teledart/model.dart'
    show TeleDartMessage, InlineKeyboardMarkup, InlineKeyboardButton;
import '../../../core/parsing.dart';
import '../../../core/formatting.dart';
import '../../../domain/entities/osu_mode.dart';
import '../../../domain/usecases/fetch_recent_scores.dart';
import '../../../domain/usecases/get_binding.dart';
import '../../../domain/repositories/osu_repository.dart';
import '../command_base.dart';

class LastCommand extends BotCommand {
  LastCommand(this.getRecent, this.getBinding, this.osu);

  final FetchRecentScores getRecent;
  final GetBinding getBinding;
  final IOsuRepository osu;

  @override
  List<String> get names => ['last', 'l'];

  @override
  List<String> get cyrAliases => ['л', 'д', 'дфые', 'ласт'];

  @override
  Future<void> handle(TeleDartMessage m) async {
    try {
      final parsed = parseArgs(m.text);
      final mode = OsuMode.parse(parsed.mode);
      final tgId = m.from?.id;

      int uid;
      if (parsed.user.isEmpty) {
        final bind = tgId == null ? null : await getBinding(tgId);
        if (bind == null) {
          await m.reply(
            'Нет привязки и не указан пользователь. /reg <user> или /last <user> [mode]',
          );
          return;
        }
        uid = bind.osuId;
      } else {
        uid = await osu.resolveUserId(parsed.user, mode);
      }

      final scores = await getRecent(uid, mode, limit: 1, includeFails: true);
      if (scores.isEmpty) {
        await m.reply('Нет недавних успешных скоров.');
        return;
      }
      final s = scores.first;

      int? mapMax =
          (s.mapMaxCombo == null || s.mapMaxCombo == 0) ? null : s.mapMaxCombo;
      if ((mapMax == null || mapMax == 0) && s.beatmapId != null) {
        try {
          mapMax = await osu.beatmapMaxCombo(s.beatmapId!);
        } on Exception catch (_) {
          // ignore
        }
      }

      double? starOverride;
      if (s.beatmapId != null) {
        try {
          final attrs = await osu.beatmapAttributes(s.beatmapId!, mode, s.mods);
          starOverride = attrs.starRating;
          if ((mapMax == null || mapMax == 0) &&
              (attrs.maxCombo != null && attrs.maxCombo! > 0)) {
            mapMax = attrs.maxCombo;
          }
        } on Exception catch (_) {}
      }

      final text = formatLastPrettyFromEntity(
        s,
        mapMaxComboOverride: mapMax,
        starOverride: starOverride,
      );
      InlineKeyboardMarkup? kb;
      if (s.beatmapId != null) {
        final data = 'cmp:${s.beatmapId}:${mode.name}';
        kb = InlineKeyboardMarkup(
          inlineKeyboard: [
            [InlineKeyboardButton(text: 'Compare', callbackData: data)],
          ],
        );
      }
      await m.reply(text, parseMode: 'MarkdownV2', replyMarkup: kb);
    } on Exception catch (e) {
      await m.reply('Ошибка: $e');
    }
  }
}
