import 'package:teledart/model.dart' show TeleDartMessage;
import '../../../domain/usecases/unregister_binding.dart';
import '../command_base.dart';

class UnregisterCommand extends BotCommand {
  UnregisterCommand(this.unreg);

  final UnregisterBinding unreg;

  @override
  List<String> get names => ['unreg'];

  @override
  Future<void> handle(TeleDartMessage m) async {
    final tgId = m.from?.id;
    if (tgId == null) {
      await m.reply('Не удалось определить твой Telegram ID.');
      return;
    }
    await unreg(tgId);
    await m.reply('Привязка удалена.');
  }
}
