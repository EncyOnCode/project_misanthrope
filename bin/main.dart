import 'dart:async';
import 'dart:io';

import 'package:enclosedbot/data/db/db.dart';
import 'package:enclosedbot/presentation/bot/commands/help_command.dart';
import 'package:enclosedbot/presentation/bot/commands/last_command.dart';
import 'package:enclosedbot/presentation/bot/commands/last_fails_command.dart';
import 'package:enclosedbot/presentation/bot/commands/profile_command.dart';
import 'package:enclosedbot/presentation/bot/commands/register_command.dart';
import 'package:enclosedbot/presentation/bot/commands/top5_command.dart';
import 'package:enclosedbot/presentation/bot/commands/unregister_command.dart';
import 'package:enclosedbot/presentation/bot/commands/whoami_command.dart';

import 'package:enclosedbot/core/env.dart';
import 'package:enclosedbot/di/wiring.dart';
import 'package:enclosedbot/presentation/bot/teledart_bot.dart';

Future<void> main(List<String> args) async {
  final env = Env.fromPlatform(Platform.environment);
  final db = await AppDatabase.open();
  final deps = await buildDeps(env, db);

  final bot = TeledartBot(env.botToken, [
    HelpCommand(),
    RegisterCommand(deps.registerBinding),
    UnregisterCommand(deps.unregisterBinding),
    WhoAmICommand(deps.getBinding),
    ProfileCommand(deps.fetchProfile, deps.getBinding),
    Top5Command(deps.fetchTopScores, deps.getBinding, deps.osuRepo),
    LastCommand(deps.fetchRecentScores, deps.getBinding, deps.osuRepo),
    LastFinishedCommand(deps.fetchRecentScores, deps.getBinding, deps.osuRepo),
  ]);

  await bot.start();

  void stop() {
    try {
      bot.stop();
    } on Exception catch (_) {
      // ignore
    } finally {
      unawaited(db.close());
      exit(0);
    }
  }

  ProcessSignal.sigint.watch().listen((_) => stop());
  if (!Platform.isWindows) {
    ProcessSignal.sigterm.watch().listen((_) => stop());
  }

  await Completer<void>().future;
}
