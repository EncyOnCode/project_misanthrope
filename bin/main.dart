import 'dart:async';
import 'dart:io';

import 'package:enclosedbot/data/db/db.dart';
import 'package:enclosedbot/presentation/bot/commands/help_command.dart';
import 'package:enclosedbot/presentation/bot/commands/last_command.dart';
import 'package:enclosedbot/presentation/bot/commands/last_finished_command.dart';
import 'package:enclosedbot/presentation/bot/commands/profile_command.dart';
import 'package:enclosedbot/presentation/bot/commands/register_command.dart';
import 'package:enclosedbot/presentation/bot/commands/top5_command.dart';
import 'package:enclosedbot/presentation/bot/commands/compare_command.dart';
import 'package:enclosedbot/presentation/bot/commands/compare_callback.dart';
import 'package:enclosedbot/presentation/bot/commands/unregister_command.dart';
import 'package:enclosedbot/presentation/bot/commands/whoami_command.dart';
import 'package:enclosedbot/presentation/bot/commands/pp_command.dart';
import 'package:enclosedbot/presentation/bot/commands/roll_command.dart';
import 'package:enclosedbot/presentation/bot/commands/tablet_zone_command.dart';

import 'package:enclosedbot/core/env.dart';
import 'package:enclosedbot/core/logger.dart';
import 'package:enclosedbot/di/wiring.dart';
import 'package:enclosedbot/presentation/bot/teledart_bot.dart';

Future<void> main(List<String> args) async {
  final env = Env.fromPlatform(Platform.environment);
  Log.i('Bot starting. Env loaded.');
  final db = await AppDatabase.open();
  Log.i('Database opened.');
  final deps = await buildDeps(env, db);
  Log.i('Dependencies built.');

  final bot = TeledartBot(
    env.botToken,
    [
      HelpCommand(),
      RegisterCommand(deps.registerBinding),
      UnregisterCommand(deps.unregisterBinding),
      WhoAmICommand(deps.getBinding),
      ProfileCommand(deps.fetchProfile, deps.getBinding),
      Top5Command(deps.fetchTopScores, deps.getBinding, deps.osuRepo),
      LastCommand(deps.fetchRecentScores, deps.getBinding, deps.osuRepo),
      LastFinishedCommand(
        deps.fetchRecentScores,
        deps.getBinding,
        deps.osuRepo,
      ),
      CompareCommand(deps.getBinding, deps.fetchUserMapScores, deps.osuRepo),
      PpCommand(),
      RollCommand(),
      TabletZoneCommand(),
    ],
    callbacks: [CompareCallback(deps.getBinding, deps.fetchUserMapScores)],
  );

  Log.i('Starting TeleDart...');
  await bot.start();
  Log.i('Bot started.');

  void stop() {
    try {
      Log.i('Stopping bot...');
      bot.stop();
    } on Exception catch (_) {
      // ignore
    } finally {
      Log.i('Closing database...');
      unawaited(db.close());
      Log.i('Shutdown complete.');
      exit(0);
    }
  }

  ProcessSignal.sigint.watch().listen((_) {
    Log.w('SIGINT received');
    stop();
  });
  if (!Platform.isWindows) {
    ProcessSignal.sigterm.watch().listen((_) {
      Log.w('SIGTERM received');
      stop();
    });
  }

  await Completer<void>().future;
}
