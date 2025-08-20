import 'package:teledart/model.dart' show TeleDartMessage;
import '../../../domain/usecases/get_binding.dart';
import '../command_base.dart';

class WhoAmICommand extends BotCommand {

  WhoAmICommand(this.getBinding);
  final GetBinding getBinding;

  @override
  List<String> get names => ['whoami'];

  @override
  Future<void> handle(TeleDartMessage m) async {
    final tgId = m.from?.id;
    if (tgId == null) {
      await m.reply('Не удалось определить твой Telegram ID.');
      return;
    }
    final bind = await getBinding(tgId);
    if (bind == null) {
      await m.reply('Нет привязки. Команда: /reg <username>');
      return;
    }
    await m.reply('Привязан к: ${bind.username} (id=${bind.osuId}).');
  }
}
