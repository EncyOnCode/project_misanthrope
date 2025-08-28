import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import '../../core/parsing.dart';
import '../../core/logger.dart';
import 'command_base.dart';
import 'bot_api.dart';

class TeledartBot {
  TeledartBot(this.token, this.commands, {this.callbacks = const []});

  final String token;
  final List<BotCommand> commands;
  final List<BotCallback> callbacks;
  late final TeleDart _bot;
  late final String _botName;

  Future<TeleDart> start() async {
    Log.i('Fetching bot info...');
    final me = await Telegram(token).getMe();
    _botName = me.username!;
    _bot = TeleDart(token, Event(_botName));
    Log.i('Authorized as @$_botName');
    BotApi.init(_bot);

    for (final cmd in commands) {
      for (final name in cmd.names) {
        Log.i('Registering command /$name');
        _bot.onCommand(name).listen((m) async {
          try {
            Log.i(
              'Received /$name from ${m.from?.id} in chat ${m.chat.id}: ${m.text}',
            );
            await cmd.handle(m);
            Log.i('Handled /$name for ${m.from?.id}');
          } on Exception catch (e) {
            Log.e('Handler error for /$name', e as Object?);
          }
        });
      }
      for (final alias in cmd.cyrAliases) {
        _bot.onMessage().where((m) => matchAlias(m.text, alias, _botName)).listen((
          m,
        ) async {
          try {
            Log.i(
              "Received alias '$alias' for command from ${m.from?.id}: ${m.text}",
            );
            await cmd.handle(m);
            Log.i("Handled alias '$alias' for ${m.from?.id}");
          } on Exception catch (e) {
            Log.e("Alias handler error ('$alias')", e as Object?);
          }
        });
      }
    }

    if (callbacks.isNotEmpty) {
      Log.i('Registering callback query listener');
    }
    if (callbacks.isNotEmpty) {
      _bot.onCallbackQuery().listen((q) {
        final data = q.data;
        Log.i('Callback received from ${q.from.id}: ${data ?? '(no data)'}');
        for (final h in callbacks) {
          if (h.canHandle(data)) {
            Log.i('Dispatching callback to handler ${h.runtimeType}');
            h
                .handle(q)
                .then((_) {
                  Log.i('Callback handled by ${h.runtimeType}');
                })
                .catchError((e) {
                  Log.e(
                    'Callback handler error in ${h.runtimeType}',
                    e as Object?,
                  );
                });
            break;
          }
        }
      });
    }

    _bot.start();
    Log.i('TeleDart listening for updates');
    return _bot;
  }

  void stop() {
    try {
      Log.i('Stopping TeleDart');
      _bot.stop();
    } on Exception catch (_) {}
  }
}
