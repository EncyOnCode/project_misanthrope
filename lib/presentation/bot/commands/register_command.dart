import 'package:teledart/model.dart' show TeleDartMessage;
import '../../../core/error_messages.dart';
import '../../../domain/usecases/register_binding.dart';
import '../command_base.dart';

class RegisterCommand extends BotCommand {
  RegisterCommand(this.register);

  final RegisterBinding register;

  @override
  List<String> get names => ['reg'];

  @override
  List<String> get cyrAliases => ['рег'];

  @override
  Future<void> handle(TeleDartMessage m) async {
    try {
      final parts = (m.text ?? '').trim().split(RegExp(r'\s+'));
      if (parts.length < 2) {
        await m.reply('Использование: /reg <username|id>');
        return;
      }
      final userArg = parts.sublist(1).join(' ');
      final tgId = m.from?.id;
      if (tgId == null) {
        await m.reply('Не удалось определить твой Telegram ID.');
        return;
      }
      final b = await register(tgId: tgId, userInput: userArg);
      await m.reply(
        'Готово! Привязал к osu! пользователю "${b.username}" (id=${b.osuId}).',
      );
    } on Exception catch (e) {
      await m.reply(toUserMessage(e));
    }
  }
}
