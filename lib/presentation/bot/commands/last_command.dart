import 'package:teledart/model.dart'
    show TeleDartMessage, InlineKeyboardMarkup, InlineKeyboardButton;
import '../../../core/parsing.dart';
import '../../../core/formatting.dart';
import '../../../core/markdown.dart';
import '../../../domain/entities/osu_mode.dart';
import '../../../domain/entities/osu_score.dart';
import '../../../domain/usecases/fetch_recent_scores.dart';
import '../../../domain/usecases/get_binding.dart';
import '../../../domain/repositories/osu_repository.dart';
import '../../../core/pp_calc.dart' as pp;
import '../command_base.dart';

class LastCommand extends BotCommand {
  LastCommand(this.getRecent, this.getBinding, this.osu);

  final FetchRecentScores getRecent;
  final GetBinding getBinding;
  final IOsuRepository osu;

  @override
  List<String> get names => ['last', 'l'];

  @override
  List<String> get cyrAliases => ['л', 'лст', 'последняя', 'последнее'];

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
        await m.reply('Недавних результатов нет.');
        return;
      }
      final s = scores.first;

      int? mapMax = (s.mapMaxCombo == null || s.mapMaxCombo == 0) ? null : s.mapMaxCombo;
      if ((mapMax == null || mapMax == 0) && s.beatmapId != null) {
        try {
          mapMax = await osu.beatmapMaxCombo(s.beatmapId!);
        } catch (_) {}
      }

      double? starOverride;
      if (s.beatmapId != null) {
        try {
          final attrs = await osu.beatmapAttributes(s.beatmapId!, mode, s.mods);
          starOverride = attrs.starRating;
          if ((mapMax == null || mapMax == 0) && (attrs.maxCombo != null && attrs.maxCombo! > 0)) {
            mapMax = attrs.maxCombo;
          }
        } catch (_) {}
      }

      // Local PP calculation (fallback only) + If FC
      double? localPp;
      double? ifFcPp;
      if (s.beatmapId != null) {
        try {
          await pp.ensureNativeLibraryAvailable();
          final bytes = await pp.fetchOsuFile(s.beatmapId!);
          final mods = pp.modsFromStrings(s.mods);
          if (s.pp == null) {
            final res = pp.calcFromBytes(
              bytes,
              mods: mods,
              acc: s.accuracy,
              combo: s.combo,
              nMiss: s.countMiss,
              n300: s.count300,
              n100: s.count100,
              n50: s.count50,
            );
            localPp = res.pp;
          }
          if (mapMax != null && mapMax > 0) {
            final fcRes = pp.calcFromBytes(
              bytes,
              mods: mods,
              acc: s.accuracy,
              combo: mapMax,
              nMiss: 0,
            );
            ifFcPp = fcRes.pp;
          }
        } on Exception catch (_) {}
      }

      final sLocal = OsuScore(
        artist: s.artist,
        title: s.title,
        diff: s.diff,
        rank: s.rank,
        accuracy: s.accuracy,
        pp: localPp ?? s.pp,
        mods: s.mods,
        score: s.score,
        combo: s.combo,
        mapMaxCombo: s.mapMaxCombo,
        beatmapId: s.beatmapId,
        count300: s.count300,
        count100: s.count100,
        count50: s.count50,
        countMiss: s.countMiss,
        cs: s.cs,
        ar: s.ar,
        od: s.od,
        hp: s.hp,
        bpm: s.bpm,
        stars: s.stars,
        lengthSec: s.lengthSec,
        mapper: s.mapper,
        mapperId: s.mapperId,
        status: s.status,
        passed: s.passed,
        completion: s.completion,
        ppIfFc: s.ppIfFc,
        ppIfSs: s.ppIfSs,
        createdAt: s.createdAt,
      );

      var text = formatLastPrettyFromEntity(
        sLocal,
        mapMaxComboOverride: mapMax,
        starOverride: starOverride,
      );
      if (ifFcPp != null) {
        // last uses MarkdownV2; escape the added line
        text +=   '\n${escapeMdV2('If FC: ${ifFcPp.toStringAsFixed(2)}')}';
      }

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
