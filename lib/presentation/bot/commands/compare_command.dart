import 'package:teledart/model.dart'
    show TeleDartMessage, TeleDartCallbackQuery, InlineKeyboardButton;
import '../../../core/formatting.dart';
import '../../../domain/entities/osu_mode.dart';
import '../../../domain/usecases/fetch_map_scores.dart';
import '../../../domain/usecases/get_binding.dart';
import '../../../domain/repositories/osu_repository.dart';
import '../command_base.dart';

class CompareCommand extends BotCommand {
  CompareCommand(this.fetchMapScores, this.getBinding, this.osu);

  final FetchMapScores fetchMapScores;
  final GetBinding getBinding;
  final IOsuRepository osu;

  @override
  List<String> get names => ['compare', 'c'];

  @override
  List<String> get cyrAliases => ['с'];

  @override
  List<String> get callbackNames => ['compare'];

  @override
  Future<void> handle(TeleDartMessage m) async {
    try {
      final parsed = _parse(m.text);
      final mode = OsuMode.parse(parsed.mode);
      final tgId = m.from?.id;

      int? beatmapId = parsed.beatmapId;
      beatmapId = beatmapId ?? _extractBeatmapId(m.reply_to_message?.text);
      beatmapId = beatmapId ?? _extractBeatmapId(m.reply_to_message?.caption);
      if (beatmapId == null) {
        await m.reply(
            'Не удалось определить карту. Укажи ID или ответь на сообщение со ссылкой.');
        return;
      }

      int uid;
      if (parsed.user.isEmpty) {
        final bind = tgId == null ? null : await getBinding(tgId);
        if (bind == null) {
          await m.reply(
            'Нет привязки и не указан пользователь. /reg <user> или /compare <user> [mode] [beatmapId]',
          );
          return;
        }
        uid = bind.osuId;
      } else {
        uid = await osu.resolveUserId(parsed.user, mode);
      }

      final scores = await fetchMapScores(uid, beatmapId, mode);
      if (scores.isEmpty) {
        await m.reply('Нет результатов.');
        return;
      }
      final lines = scores.map((e) => '• ${formatScore(e)}').join('\n');
      await m.reply(lines);
    } on Exception catch (e) {
      await m.reply('Ошибка: $e');
    }
  }

  @override
  Future<void> handleCallback(TeleDartCallbackQuery q) async {
    try {
      final data = q.data ?? '';
      final parts = data.split(':');
      if (parts.length < 2) {
        await q.answer();
        return;
      }
      final beatmapId = int.tryParse(parts[1]);
      if (beatmapId == null) {
        await q.answer(text: 'Некорректный ID карты');
        return;
      }
      final mode = parts.length > 2
          ? OsuMode.parse(parts[2])
          : OsuMode.osu;
      final tgId = q.from?.id;
      final bind = tgId == null ? null : await getBinding(tgId);
      if (bind == null) {
        await q.answer(text: 'Нет привязки');
        return;
      }
      final scores = await fetchMapScores(bind.osuId, beatmapId, mode);
      final lines = scores.isEmpty
          ? 'Нет результатов.'
          : scores.map((e) => '• ${formatScore(e)}').join('\n');
      if (q.message != null) {
        await q.message!.reply(lines);
      }
      await q.answer();
    } on Exception catch (e) {
      await q.answer(text: 'Ошибка: $e');
    }
  }

  static InlineKeyboardButton button(int beatmapId, OsuMode mode) {
    return InlineKeyboardButton(
      text: 'Compare',
      callback_data: 'compare:$beatmapId:${mode.name}',
    );
  }
}

({String user, String mode, int? beatmapId}) _parse(String? text) {
  final parts = (text ?? '').trim().split(RegExp(r'\s+'));
  if (parts.isNotEmpty) parts.removeAt(0);
  final modes = {'osu', 'taiko', 'fruits', 'mania'};
  String mode = 'osu';
  int? mapId;
  if (parts.isNotEmpty && RegExp(r'^\d+$').hasMatch(parts.last)) {
    mapId = int.tryParse(parts.removeLast());
  }
  if (parts.isNotEmpty && modes.contains(parts.last.toLowerCase())) {
    mode = parts.removeLast().toLowerCase();
  }
  final user = parts.join(' ').trim();
  return (user: user, mode: mode, beatmapId: mapId);
}

int? _extractBeatmapId(String? text) {
  if (text == null) return null;
  final patterns = [
    RegExp(r'osu\.ppy\.sh/b/(\d+)'),
    RegExp(r'osu\.ppy\.sh/beatmaps/(\d+)'),
    RegExp(r'osu\.ppy\.sh/beatmapsets/\d+#\w+/(\d+)'),
  ];
  for (final r in patterns) {
    final m = r.firstMatch(text);
    if (m != null) {
      return int.tryParse(m.group(1)!);
    }
  }
  return null;
}

