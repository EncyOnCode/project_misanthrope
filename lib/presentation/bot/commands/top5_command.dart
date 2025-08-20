import 'package:teledart/model.dart' show TeleDartMessage;
import '../../../core/parsing.dart';
import '../../../core/formatting.dart';
import '../../../domain/entities/osu_mode.dart';
import '../../../domain/usecases/fetch_top_scores.dart';
import '../../../domain/usecases/get_binding.dart';
import '../../../domain/repositories/osu_repository.dart';
import '../command_base.dart';

class Top5Command extends BotCommand {

  Top5Command(this.getTop, this.getBinding, this.osu);
  final FetchTopScores getTop;
  final GetBinding getBinding;
  final IOsuRepository osu;

  @override
  List<String> get names => ['top5', 't5'];

  @override
  List<String> get cyrAliases => ['т5'];

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
            'Укажи игрока: /top5 <user> [mode]\nили сначала привяжись: /reg <user>',
          );
          return;
        }
        uid = bind.osuId;
      } else {
        uid = await osu.resolveUserId(parsed.user, mode);
      }
      final scores = await getTop(uid, mode, limit: 5);
      if (scores.isEmpty) {
        await m.reply('Скоров не найдено.');
        return;
      }
      final lines = scores.take(5).map((e) => '• ${formatScore(e)}').join('\n');
      await m.reply(lines);
    } on Exception catch (e) {
      await m.reply('Ошибка: $e');
    }
  }
}
