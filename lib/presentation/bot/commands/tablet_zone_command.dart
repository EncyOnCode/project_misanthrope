import '../../../core/tablet_zone.dart';
import '../bot_api.dart';
import '../command_base.dart';
import 'package:teledart/model.dart' show TeleDartMessage;

class TabletZoneCommand extends BotCommand {
  @override
  List<String> get names => const ['zone', 'tabletzone', 'tz'];

  @override
  List<String> get cyrAliases => const [];

  @override
  Future<void> handle(TeleDartMessage message) async {
    final text = message.text?.trim() ?? '';
    final parts = text.split(RegExp(r'\s+'));
    // Drop '/zone' or alias
    final args =
        parts.where((String p) => !p.startsWith('/')).toList(growable: false);

    if (args.isEmpty) {
      await _usage(message);
      return;
    }

    final mode = args[0].toLowerCase();
    try {
      if (mode == 'match' || mode == 'direct' || mode.startsWith('keep:')) {
        if (args.length != 7) {
          throw const FormatException('Ожидалось 6 чисел: W H w h A B');
        }
        final W = _toDouble(args[1]);
        final H = _toDouble(args[2]);
        final w = _toDouble(args[3]);
        final h = _toDouble(args[4]);
        final A = _toDouble(args[5]);
        final B = _toDouble(args[6]);

        if (mode == 'match') {
          final r = zoneMatchGameEdges(W, H, w, h, A, B);
          await _reply(message, 'Zone: ${_fmt(r.widthMm)} x ${_fmt(r.heightMm)} mm');
          return;
        }
        if (mode == 'direct') {
          final r = zoneMapDirectToGame(W, H, w, h, A, B);
          await _reply(message, 'Zone: ${_fmt(r.widthMm)} x ${_fmt(r.heightMm)} mm');
          return;
        }
        final raw = mode.split(':').last;
        final strategy = switch (raw) {
          'width' => KeepShapeStrategy.width,
          'height' => KeepShapeStrategy.height,
          'geomean' => KeepShapeStrategy.geomean,
          _ => throw const FormatException('Неизвестная стратегия keep:<width|height|geomean>'),
        };
        final r = zoneKeepShape(W, H, w, h, A, B, strategy);
        await _reply(message, 'Zone: ${_fmt(r.widthMm)} x ${_fmt(r.heightMm)} mm');
        return;
      } else if (mode == 'offset') {
        if (args.length != 5) {
          throw const FormatException('Ожидалось 4 числа: W H w h');
        }
        final W = _toDouble(args[1]);
        final H = _toDouble(args[2]);
        final w = _toDouble(args[3]);
        final h = _toDouble(args[4]);
        final off = gameWindowOffset(W, H, w, h);
        await _reply(message, 'Offset: x=${_fmt(off.offsetX)}, y=${_fmt(off.offsetY)} px');
        return;
      } else {
        await _usage(message, error: 'Неизвестный режим: $mode');
      }
    } on FormatException catch (e) {
      await _usage(message, error: e.message);
    } on Object catch (e) {
      await _usage(message, error: e.toString());
    }
  }

  double _toDouble(String s) {
    final v = double.tryParse(s.replaceAll(',', '.'));
    if (v == null || !v.isFinite) {
      throw const FormatException('Неверное число');
    }
    return v;
  }

  String _fmt(num v) => v.toStringAsFixed(4);

  Future<void> _reply(TeleDartMessage message, String text) async {
    await BotApi.sendMessage(
      message.chat.id,
      text,
      messageThreadId: message.messageThreadId,
      replyToMessageId: message.messageId,
    );
  }

  Future<void> _usage(TeleDartMessage message, {String? error}) async {
    final lines = <String>[];
    if (error != null && error.isNotEmpty) {
      lines.add('Ошибка: $error');
    }
    lines.addAll(const [
      'Использование:',
      '/zone match  W H w h A B   → A*=W/w, B*=H/h',
      '/zone direct W H w h A B   → A*=w/W, B*=h/H',
      '/zone keep:width|height|geomean W H w h A B',
      '/zone offset W H w h        → (W-w)/2, (H-h)/2',
      '',
      'Все значения — числа. Условия: > 0; w≤W, h≤H.',
    ]);
    await _reply(message, lines.join('\n'));
  }
}
