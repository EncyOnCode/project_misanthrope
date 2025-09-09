import 'package:teledart/model.dart' show TeleDartMessage;

import '../../../core/parsing.dart';
import '../../../core/formatting.dart';
import '../../../domain/entities/osu_mode.dart';
import '../../../domain/usecases/get_binding.dart';
import '../../../domain/usecases/fetch_user_map_scores.dart';
import '../../../domain/repositories/osu_repository.dart';
import '../../../core/logger.dart';
import '../../../core/markdown.dart';
import '../../../core/error_messages.dart';
import '../command_base.dart';

class CompareCommand extends BotCommand {
  CompareCommand(this.getBinding, this.fetchScores, this.osu);

  final GetBinding getBinding;
  final FetchUserMapScores fetchScores;
  final IOsuRepository osu;

  @override
  List<String> get names => ['compare', 'c'];

  @override
  Future<void> handle(TeleDartMessage m) async {
    try {
      Log.i("/compare start chat=${m.chat.id} from=${m.from?.id} text='${m.text}'");
      final parsed = parseArgs(m.text);
      final mode = OsuMode.parse(parsed.mode);

      // Beatmap id from own message or reply fallback
      int? beatmapId = extractBeatmapId(m.text);
      beatmapId ??= extractBeatmapId(m.replyToMessage?.text ?? m.replyToMessage?.caption);
      if (beatmapId == null) {
        await m.reply('Укажи ссылку на конкретную сложность. Пример: /compare <link>');
        return;
      }

      // Resolve user
      final tgId = m.from?.id;
      int uid;
      String osuNameForPing;
      if (parsed.user.isNotEmpty) {
        uid = await osu.resolveUserId(parsed.user, mode);
        try {
          osuNameForPing = await osu.getUsernameById(uid, mode);
        } on Exception catch (_) {
          osuNameForPing = parsed.user;
        }
      } else {
        final bind = (tgId == null) ? null : await getBinding(tgId);
        if (bind == null) {
          await m.reply('Нет привязки. Используй /reg <user> или /compare <user> <link>');
          return;
        }
        uid = bind.osuId;
        osuNameForPing = bind.username;
      }

      final scores = await fetchScores(uid, beatmapId, mode);
      if (scores.isEmpty) {
        await m.reply('Нет результатов на этой сложности.');
        return;
      }

      // Use server PP values for compare
      final table = formatCompareTable(scores);
      final profileUrl = 'https://osu.ppy.sh/users/$uid';
      final mention = m.from?.username == null || (m.from!.username?.isEmpty ?? true)
          ? null
          : '@${m.from!.username}';
      final headParts = <String>[];
      if (mention != null) headParts.add(escapeMdV2(mention));
      headParts.add('Сравнение для ${linkMdV2(osuNameForPing, profileUrl)}');
      final head = '${headParts.join('\n')}\n\n';
      await m.reply(head + table, parseMode: 'MarkdownV2');
    } on Exception catch (e) {
      await m.reply(toUserMessage(e));
    }
  }
}

