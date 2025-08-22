import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import '../../core/parsing.dart';
import 'command_base.dart';

class TeledartBot {
  TeledartBot(this.token, this.commands);

  final String token;
  final List<BotCommand> commands;
  late final TeleDart _bot;
  late final String _botName;

  Future<TeleDart> start() async {
    final me = await Telegram(token).getMe();
    _botName = me.username!;
    _bot = TeleDart(token, Event(_botName));

    for (final cmd in commands) {
      for (final name in cmd.names) {
        _bot.onCommand(name).listen(cmd.handle);
      }
      for (final alias in cmd.cyrAliases) {
        _bot
            .onMessage()
            .where((m) => matchAlias(m.text, alias, _botName))
            .listen(cmd.handle);
      }
    }

    _bot.start();
    return _bot;
  }

  void stop() {
    try {
      _bot.stop();
    } on Object catch (_) {}
  }
}
