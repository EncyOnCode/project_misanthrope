import 'dart:math';

import 'package:teledart/model.dart' show TeleDartMessage;

import '../command_base.dart';

class RollCommand extends BotCommand {
  @override
  List<String> get names => ['roll', 'r'];

  // Cyrillic alias: '/к'
  @override
  List<String> get cyrAliases => ['к'];

  @override
  Future<void> handle(TeleDartMessage m) async {
    final parts = (m.text ?? '').trim().split(RegExp(r'\s+'));

    // Default upper bound if none provided
    var upper = 1000;
    if (parts.length >= 2) {
      final v = int.tryParse(parts[1]);
      if (v != null && v >= 0) {
        upper = v;
      }
    }

    // Generate inclusive roll in [0..upper]
    final rng = Random();
    final roll = rng.nextInt(upper + 1);

    final from = m.from;
    final user = from?.username != null && from!.username!.isNotEmpty
        ? '@${from.username}'
        : '';

    final scope = '0..$upper';
    final who = user.isNotEmpty ? ' для $user' : '';
    await m.reply('🎲 Ролл$who: $roll ($scope)');
  }
}
