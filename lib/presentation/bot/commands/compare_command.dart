import 'package:teledart/model.dart' show TeleDartMessage;

import '../../../core/parsing.dart';
import '../../../core/formatting.dart';
import '../../../domain/entities/osu_mode.dart';
import '../../../domain/usecases/get_binding.dart';
import '../../../domain/usecases/fetch_user_map_scores.dart';
import '../command_base.dart';

class CompareCommand extends BotCommand {
  CompareCommand(this.getBinding, this.fetchScores);

  final GetBinding getBinding;
  final FetchUserMapScores fetchScores;

  @override
  List<String> get names => ['compare'];

  @override
  Future<void> handle(TeleDartMessage m) async {
    try {
      final parsed = parseArgs(m.text);
      final mode = OsuMode.parse(parsed.mode);

      // Extract beatmap id from own text first
      int? beatmapId = extractBeatmapId(m.text);

      // Fallback to replied message text/caption
      if (beatmapId == null) {
        final r = m.replyToMessage;
        if (r != null) {
          final rText = r.text ?? r.caption;
          beatmapId = extractBeatmapId(rText);
        }
      }

      if (beatmapId == null) {
        await _safeReply(
          m,
          'Usage: /compare <beatmap_link_or_id> [mode]\nOr reply to a message containing a map link and send /compare',
        );
        return;
      }

      final tgId = m.from?.id;
      if (tgId == null) {
        await _safeReply(m, 'Cannot determine your Telegram ID.');
        return;
      }

      final bind = await getBinding(tgId);
      if (bind == null) {
        await _safeReply(m, 'No osu! account bound. Use /reg <user> first.');
        return;
      }

      final scores = await fetchScores(bind.osuId, beatmapId, mode);
      if (scores.isEmpty) {
        await _safeReply(m, 'No scores found on this map.');
        return;
      }

      final lines = scores.map((s) => '- ${formatScore(s)}').join('\n');
      await _safeReply(m, lines);
    } on Exception catch (e) {
      try {
        await _safeReply(m, 'Ошибка: $e');
      } catch (_) {}
    }
  }

  Future<void> _safeReply(TeleDartMessage m, String text) async {
    try {
      await m.reply(text, allowSendingWithoutReply: true);
    } on Object {
      await m.reply(text, allowSendingWithoutReply: true, withQuote: true);
    }
  }
}

