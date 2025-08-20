import 'package:teledart/model.dart' show TeleDartMessage;

abstract class BotCommand {
  List<String> get names;

  List<String> get cyrAliases => const [];

  Future<void> handle(TeleDartMessage m);
}
