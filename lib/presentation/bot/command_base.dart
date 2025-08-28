import 'package:teledart/model.dart'
    show TeleDartMessage, TeleDartCallbackQuery;

abstract class BotCommand {
  List<String> get names;

  List<String> get cyrAliases => const [];

  Future<void> handle(TeleDartMessage m);
}

abstract class BotCallback {
  /// Return true if this handler wants to process the callback [data].
  bool canHandle(String? data);

  /// Handle callback query.
  Future<void> handle(TeleDartCallbackQuery q);
}
