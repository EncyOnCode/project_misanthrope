import 'package:teledart/model.dart' show TeleDartMessage, TeleDartCallbackQuery;

abstract class BotCommand {
  List<String> get names;

  List<String> get cyrAliases => const [];

  List<String> get callbackNames => const [];

  Future<void> handle(TeleDartMessage m);

  Future<void> handleCallback(TeleDartCallbackQuery q) async {}
}
