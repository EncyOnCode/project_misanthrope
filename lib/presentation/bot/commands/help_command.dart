import 'package:teledart/model.dart' show TeleDartMessage;
import '../command_base.dart';

class HelpCommand extends BotCommand {
  @override
  List<String> get names => ['help', 'h', 'start'];

  @override
  List<String> get cyrAliases => ['помощь', 'хелп'];

  static const _help =
      'Команды и алиасы:\n'
      '• /help (/h, /помощь, /хелп) — список команд\n'
      '• /reg (/r) <user> — привязать osu к Telegram\n'
      '• /unreg — отвязать аккаунт\n'
      '• /whoami — показать привязку\n'
      '• /profile (/p) [user] [mode]\n'
      '• /top5 (/t5) [user] [mode]\n'
      '• /last (/l) [user] [mode]\n'
      '• /last_finished (/lf) [user] [mode]\n'
      '• /compare (/c) [user] [mode] — сравнить результаты на карте; ответьте на сообщение со ссылкой на карту или пришлите ссылку вместе с командой\n'
      '\nЕсли аккаунт привязан через /reg, <user> можно не указывать.\n'
      'mode: osu|taiko|fruits|mania (по умолчанию osu)';

  @override
  Future<void> handle(TeleDartMessage m) async {
    await m.reply(_help);
  }
}

