import 'package:teledart/model.dart' show TeleDartCallbackQuery;

import '../../../core/formatting.dart';
import '../../../core/logger.dart';
import '../../../core/markdown.dart';
import '../../../domain/entities/osu_mode.dart';
import '../../../domain/usecases/fetch_user_map_scores.dart';
import '../../../domain/usecases/get_binding.dart';
import '../command_base.dart';

class CompareCallback extends BotCallback {
  CompareCallback(this.getBinding, this.fetchScores);

  final GetBinding getBinding;
  final FetchUserMapScores fetchScores;

  static const String prefix = 'cmp:';

  @override
  bool canHandle(String? data) => data != null && data.startsWith(prefix);

  @override
  Future<void> handle(TeleDartCallbackQuery q) async {
    try {
      final String dataStr = q.data?.toString() ?? '';
      final parts = dataStr.substring(prefix.length).split(':');
        if (parts.length < 2) {
          await q.answer(text: 'Некорректные данные кнопки');
          return;
        }
      final beatmapId = int.tryParse(parts[0]);
      final mode = OsuMode.parse(parts[1]);
        if (beatmapId == null) {
          await q.answer(text: 'Некорректный beatmap id');
          return;
        }

      final tgId = q.from.id;
      final bind = await getBinding(tgId);
        if (bind == null) {
          await q.teledartMessage?.reply(
            'Нет привязанного osu! аккаунта. Сначала выполните /reg <user>.',
          );
          await q.answer();
          return;
        }

      final scores = await fetchScores(bind.osuId, beatmapId, mode);
        if (scores.isEmpty) {
          await q.teledartMessage?.reply('Результаты на этой карте не найдены.');
          await q.answer();
          return;
        }

      final text = formatCompareTable(scores);
      final ping = _mentionOf(q);
      final profileUrl = 'https://osu.ppy.sh/users/${bind.osuId}';
        final forLine = 'Все результаты для ${linkMdV2(bind.username, profileUrl)}';
      final intro = ping == null ? forLine : '$ping\n\n$forLine';
      final payload = '$intro\n\n$text';
      Log.i('callback compare payload length=${payload.length}');
      try {
        await q.teledartMessage?.reply(payload, parseMode: 'MarkdownV2');
      } on Exception catch (e1) {
        Log.e('callback compare reply failed (mdv2)', e1);
        // Fallback without Markdown parsing
        try {
          await q.teledartMessage?.reply(payload);
        } on Exception catch (e2) {
          Log.e('callback compare reply failed (plain)', e2);
        }
      }
      await q.answer();
    } on Exception catch (e) {
      try {
        await q.teledartMessage?.reply('Ошибка: $e');
        await q.answer();
      } on Exception catch (_) {}
    }
  }

  String? _mentionOf(TeleDartCallbackQuery q) {
    final u = q.from;
    final username = u.username;
    if (username != null && username.isNotEmpty) {
      return '@$username';
    }
    final name = (u.firstName);
    return linkMdV2(name, 'tg://user?id=${u.id}');
  }
}
