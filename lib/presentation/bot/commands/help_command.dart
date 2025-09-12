import 'package:teledart/model.dart' show TeleDartMessage;
import '../command_base.dart';

class HelpCommand extends BotCommand {
  @override
  List<String> get names => ['help', 'h', 'start'];

  @override
  List<String> get cyrAliases => const [];

  static const _help = '''
Команды бота:
• /help (/h, /start) — показать эту справку
• /reg (/r) <user> — привязать osu к Telegram
• /unreg — удалить привязку
• /whoami — показать текущую привязку
• /profile (/p) [user] [mode]
• /top5 (/t5) [user] [mode]
• /last (/l) [user] [mode]
• /last_finished (/lf) [user] [mode]
• /compare (/c) [user] [mode]
• /pp <link> [mods] [acc]
• /zone — перерасчёт зоны планшета и смещения окна игры

mode: osu|taiko|fruits|mania (по умолчанию osu)
''';

  @override
  Future<void> handle(TeleDartMessage m) async {
    await m.reply(_help);
    // Кратко про /pp
    await m.reply(
      '- /pp <link> [mods] [accuracy] — быстрый расчёт PP.\n'
      'Примеры: /pp https://osu.ppy.sh/beatmapsets/773995#osu/1622719 HDDT 98.5; '
      '/pp https://osu.ppy.sh/beatmaps/1622719 HR 99%'
    );
    // Подробная справка по /zone
    await m.reply(_zoneHelp);
  }
}

const String _zoneHelp = '''
Команда /zone — перерасчёт рабочей области планшета

Зачем: когда окно игры имеет размер, отличный от экрана, удобнее пересчитать
зону планшета, чтобы сохранить привычную «дотягиваемость» и масштаб.

Синтаксис:
/zone match  W H w h A B
/zone direct W H w h A B
/zone keep:width|height|geomean W H w h A B
/zone offset W H w h

Где:
• W, H — разрешение экрана, пиксели
• w, h — размер окна игры, пиксели
• A, B — текущая активная область планшета, миллиметры

Что вернётся:
• для match/direct/keep — строка вида: Zone: <ширина> x <высота> mm
• для offset — смещение окна: Offset: x=<px>, y=<px> px

Когда что использовать:
• match — если вы настраивали зону под окно w×h и теперь хотите ту же
  «дотягиваемость» на экране W×H. Формулы: A′=A·W/w, B′=B·H/h.
• direct — если мапите планшет напрямую на окно игры (например, захват
  только региона окна). Формулы: A′=A·w/W, B′=B·h/H.
• keep:width|height|geomean — единый масштаб s, зона A′=A·s, B′=B·s.
  s = W/w (width) | H/h (height) | sqrt((W/w)·(H/h)) (geomean).
  Сохраняет пропорции планшета.

Проверки ввода: все числа > 0; w ≤ W и h ≤ H. Допустимы десятичные
значения с запятой или точкой.

Примеры:
• Экран 1920×1080, окно 1600×900, зона 58×43.5 мм:
  /zone match  1920 1080 1600 900 58 43.5  →  Zone: 69.6000 x 52.2000 mm
  /zone direct 1920 1080 1600 900 58 43.5  →  Zone: 48.3333 x 36.2500 mm
  /zone offset 1920 1080 1600 900          →  Offset: x=160.0000, y=90.0000 px
• Экран 1280×1024, окно 1024×768:
  /zone offset 1280 1024 1024 768          →  Offset: x=128.0000, y=128.0000 px

Подсказки:
• match — сохраняет ощущение расстояния до краёв поля при переходе между окнами/экранами.
• direct — полезно при стриме/захвате только окна игры.
• geomean — компромиссный единый коэффициент, если нужен один масштаб по обеим осям.
''';

