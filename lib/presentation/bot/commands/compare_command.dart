import 'package:teledart/model.dart'
    show TeleDartMessage, MessageEntity, Message;

import '../../../core/parsing.dart';
import '../../../core/formatting.dart';
import '../../../core/markdown.dart';
import '../../../domain/entities/osu_mode.dart';
import '../../../domain/usecases/get_binding.dart';
import '../../../domain/usecases/fetch_user_map_scores.dart';
import '../../../domain/repositories/osu_repository.dart';
import '../../../core/logger.dart';
import '../bot_api.dart';
import '../command_base.dart';

class CompareCommand extends BotCommand {
  CompareCommand(this.getBinding, this.fetchScores, this.osu);

  final GetBinding getBinding;
  final FetchUserMapScores fetchScores;
  final IOsuRepository osu;

  @override
  List<String> get names => ['compare', 'c', 'с'];

  @override
  Future<void> handle(TeleDartMessage m) async {
    try {
      Log.i("/compare start chat=${m.chat.id} thread=${m.messageThreadId} from=${m.from?.id} text='${m.text}'");
      final parsed = parseArgs(m.text);
      final mode = OsuMode.parse(parsed.mode);

      // Extract beatmap id from own message (entities/links preferred)
      int? beatmapId = _extractBeatmapIdFromMsg(m) ?? extractBeatmapId(m.text);
      if (beatmapId != null) {
        Log.i('/compare beatmapId from own message: $beatmapId');
      }

      // Fallback to replied message text/caption and entities (links)
      if (beatmapId == null) {
        final r = m.replyToMessage;
          if (r != null) {
            Log.i('/compare replying to msgId=${r.messageId} chat=${r.chat.id} thread=${r.messageThreadId}');
            // First try URL entities since MarkdownV2 hides URLs in entities
            beatmapId = _extractBeatmapIdFromMsg(r);
            // Fallback to scanning plain text/caption
            beatmapId ??= extractBeatmapId(r.text ?? r.caption);
            Log.i("/compare beatmapId from reply: ${beatmapId ?? 'null'}");
          }
      }

      if (beatmapId == null) {
          await _safeReply(
            m,
            'Использование: /compare [пользователь] [режим]\nОтветьте на сообщение со ссылкой на карту или отправьте команду вместе со ссылкой на карту.',
          );
          return;
        }

      final tgId = m.from?.id;
        if (tgId == null) {
          await _safeReply(m, 'Не удалось определить ваш Telegram ID.');
          return;
        }

      final bind = await getBinding(tgId);
        if (bind == null && (parsed.user.isEmpty)) {
          await _safeReply(m, 'Нет привязанного osu! аккаунта. Сначала выполните /reg <user>.');
          return;
        }

      int uid;
      String osuNameForPing;
      if (parsed.user.isNotEmpty) {
        uid = await osu.resolveUserId(parsed.user, mode);
        try {
          osuNameForPing = await osu.getUsernameById(uid, mode);
        } on Exception catch (_) {
          osuNameForPing = parsed.user;
        }
        Log.i("/compare target user resolved from input='${parsed.user}': uid=$uid name=$osuNameForPing");
      } else {
        uid = bind!.osuId;
        osuNameForPing = bind.username;
        Log.i('/compare target user from binding: uid=$uid name=$osuNameForPing');
      }

        final scores = await fetchScores(uid, beatmapId, mode);
        Log.i('/compare fetched ${scores.length} scores for uid=$uid map=$beatmapId mode=${mode.name}');
        if (scores.isEmpty) {
          await _safeReply(m, 'Результаты на этой карте не найдены.');
          return;
        }

      final text = formatCompareTable(scores);
      final ping = _mentionOf(m);
      final profileUrl = 'https://osu.ppy.sh/users/$uid';
        final forLine = 'Все результаты для ${linkMdV2(osuNameForPing, profileUrl)}';
      final intro = ping == null ? forLine : '$ping\n\n$forLine';
        final payload = '$intro\n\n$text';
        Log.i('/compare payload length=${payload.length}');
        await _safeReply(m, payload, parseMode: 'MarkdownV2');
        Log.i('/compare replied to chat=${m.chat.id} thread=${m.messageThreadId}');
    } on Exception catch (e) {
      try {
        await _safeReply(m, 'Ошибка: $e');
      } on Exception catch (_) {}
    }
  }

  Future<void> _safeReply(
    TeleDartMessage m,
    String text, {
    String? parseMode,
  }) async {
    try {
      await m.reply(text, allowSendingWithoutReply: true, parseMode: parseMode);
      return;
    } on Exception catch (e1) {
      Log.e('compare reply failed (mdv2)', e1);
      try {
        await m.reply(
          text,
          allowSendingWithoutReply: true,
          withQuote: true,
          parseMode: parseMode,
        );
        return;
      } on Exception catch (e2) {
        Log.e('compare reply failed (mdv2 + quote)', e2);
        // Fallback: send plain text without Markdown parsing
        try {
          await m.reply(text, allowSendingWithoutReply: true);
          return;
        } on Exception catch (e3) {
          Log.e('compare reply failed (plain)', e3);
          // Final fallback: direct send to chat, prefer reply target context
          try {
            final r = m.replyToMessage;
            if (r != null) {
              Log.i('compare final fallback: direct send to reply context');
              await BotApi.sendMessage(
                r.chat.id,
                text,
                messageThreadId: r.messageThreadId,
                parseMode: parseMode,
                replyToMessageId: r.messageId,
              );
            } else {
              Log.i('compare final fallback: direct send to chat without thread');
              await BotApi.sendMessage(
                m.chat.id,
                text,
                parseMode: parseMode,
              );
            }
          } on Exception catch (e4) {
            Log.e('compare final fallback failed', e4);
          }
        }
      }
    }
  }

  String? _mentionOf(TeleDartMessage m) {
    final u = m.from;
    if (u == null) return null;
    final username = u.username;
    if (username != null && username.isNotEmpty) {
      return '@$username';
    }
    final name = (u.firstName);
    return linkMdV2(name, 'tg://user?id=${u.id}');
  }

  int? _extractBeatmapIdFromMsg(Message r) {
    int? fromEntities(String? text, List<MessageEntity>? ents) {
      if (ents == null || ents.isEmpty) return null;
      for (final e in ents) {
        final t = e.type;
        if (t == 'text_link') {
          final url = e.url;
          if (url != null) {
            final id = _parseBeatmapIdFromUrl(url);
            if (id != null) return id;
          }
        } else if (t == 'url') {
          final s = text ?? '';
          final start = e.offset;
          final end = start + (e.length);
          if (start >= 0 && end <= s.length && end > start) {
            final url = s.substring(start, end);
            final id = _parseBeatmapIdFromUrl(url);
            if (id != null) return id;
          }
        }
      }
      return null;
    }

    return fromEntities(r.text, r.entities) ??
        fromEntities(r.caption, r.captionEntities);
  }

  int? _parseBeatmapIdFromUrl(String url) {
    final reSet = RegExp(
      r'beatmapsets/\d+#[^/\s]+/(\d+)',
      caseSensitive: false,
    );
    final mSet = reSet.firstMatch(url);
    if (mSet != null) return int.tryParse(mSet.group(1)!);

    for (final re in [
      RegExp(r'osu\.ppy\.sh/beatmaps/(\d+)', caseSensitive: false),
      RegExp(r'osu\.ppy\.sh/b/(\d+)', caseSensitive: false),
    ]) {
      final m = re.firstMatch(url);
      if (m != null) return int.tryParse(m.group(1)!);
    }
    return null;
  }
}
