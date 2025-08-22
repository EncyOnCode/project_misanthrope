import 'package:teledart/model.dart' show TeleDartMessage;
import '../../../core/parsing.dart';
import '../../../core/formatting.dart';
import '../../../domain/entities/osu_mode.dart';
import '../../../domain/usecases/fetch_recent_scores.dart';
import '../../../domain/usecases/get_binding.dart';
import '../../../domain/repositories/osu_repository.dart';
import '../command_base.dart';

class LastFinishedCommand extends BotCommand {

  LastFinishedCommand(this.getRecent, this.getBinding, this.osu);
  final FetchRecentScores getRecent;
  final GetBinding getBinding;
  final IOsuRepository osu;

  @override
  List<String> get names => ['last_finished', 'lf'];

  @override
  List<String> get cyrAliases => ['лф', 'да', 'дфые_аштшырув'];

  @override
  Future<void> handle(TeleDartMessage m) async {
    try {
      final parsed = parseArgs(m.text);
      final mode = OsuMode.parse(parsed.mode);
      final tgId = m.from?.id;
      int uid;
      if (parsed.user.isEmpty) {
        final bind = tgId == null ? null : await getBinding(tgId);
        if (bind == null) {
          await m.reply(
            'Нет привязки и не указан пользователь. /reg <user> или /last_fails <user> [mode]',
          );
          return;
        }
        uid = bind.osuId;
      } else {
        uid = await osu.resolveUserId(parsed.user, mode);
      }
      final scores = await getRecent(uid, mode, limit: 1, includeFails: true);
      if (scores.isEmpty) {
        await m.reply('Нет недавних попыток.');
        return;
      }
      await m.reply(formatScore(scores.first));
    } on Exception catch (e) {
      await m.reply('Ошибка: $e');
    }
  }
}
