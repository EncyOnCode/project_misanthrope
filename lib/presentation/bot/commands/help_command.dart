import 'package:teledart/model.dart' show TeleDartMessage;
import '../command_base.dart';

class HelpCommand extends BotCommand {
  @override
  List<String> get names => ['help', 'h', 'start'];

  @override
  List<String> get cyrAliases => ['хелп', 'х'];
  static const _help =
      'Команды и алиасы:\n'
      '• /help (/h, /хелп, /х) — помощь\n'
      '• /reg (/r, /рег) <user> — привязать osu к твоему Telegram\n'
      '• /unreg — удалить привязку\n'
      '• /whoami — показать привязку\n'
      '• /profile (/p, /профиль, /п) [user] [mode]\n'
      '• /top5 (/t5, /т5) [user] [mode]\n'
      '• /last (/l, /л) [user] [mode]\n'
      '• /last_fails (/lf, /лф) [user] [mode]\n'
      '• /compare (/c, /с) [user] [mode] [beatmapId]\n'
      '\nЕсли ты привязан через /reg, <user> можно не указывать.\n'
      'mode: osu|taiko|fruits|mania (по умолчанию osu)\n'
      'Ник может быть с пробелами: /top5 Some User Name mania';

  @override
  Future<void> handle(TeleDartMessage m) async {
    await m.reply(_help);
  }
}
