import 'package:teledart/teledart.dart';

class BotApi {
  static TeleDart? _td;

  static void init(TeleDart td) => _td = td;

  static TeleDart get _bot {
    final b = _td;
    if (b == null) {
      throw StateError('BotApi not initialized');
    }
    return b;
  }

  static Future<void> sendMessage(
    int chatId,
    String text, {
    int? messageThreadId,
    String? parseMode,
    int? replyToMessageId,
  }) async {
    await _bot.sendMessage(
      chatId,
      text,
      messageThreadId: messageThreadId,
      parseMode: parseMode,
      allowSendingWithoutReply: true,
      replyToMessageId: replyToMessageId,
    );
  }
}

