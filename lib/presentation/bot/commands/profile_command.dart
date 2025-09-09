import 'package:teledart/model.dart' show TeleDartMessage;
import '../../../core/error_messages.dart';
import '../../../core/parsing.dart';
import '../../../core/formatting.dart';
import '../../../domain/entities/osu_mode.dart';
import '../../../domain/usecases/fetch_profile.dart';
import '../../../domain/usecases/get_binding.dart';
import '../command_base.dart';

class ProfileCommand extends BotCommand {
  ProfileCommand(this.fetch, this.getBinding);

  final FetchProfile fetch;
  final GetBinding getBinding;

  @override
  List<String> get names => ['profile', 'p'];

  @override
  List<String> get cyrAliases => ['профиль', 'п'];

  @override
  Future<void> handle(TeleDartMessage m) async {
    try {
      final parsed = parseArgs(m.text);
      final mode = OsuMode.parse(parsed.mode);
      String input = parsed.user;
      if (input.isEmpty) {
        final tgId = m.from?.id;
        final bind = tgId == null ? null : await getBinding(tgId);
        if (bind == null) {
          await m.reply(
            'Нет привязки и не указан пользователь.\nИспользование: /profile <user> [mode] или /reg <user>',
          );
          return;
        }
        input = '${bind.osuId}';
      } else {
        final t = input.trim();
        final isDigits = RegExp(r'^\d+$').hasMatch(t);
        input = isDigits ? t : (t.startsWith('@') ? t : '@$t');
      }
      final user = await fetch(input, mode);
      final caption = formatProfileCaption(user, mode.name);
      if ((user.avatarUrl ?? '').isNotEmpty) {
        await m.replyPhoto(user.avatarUrl!, caption: caption);
      } else {
        await m.reply(caption);
      }
    } on Exception catch (e) {
      await m.reply(toUserMessage(e));
    }
  }
}
