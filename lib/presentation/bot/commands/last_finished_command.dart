import 'package:teledart/model.dart' show TeleDartMessage;
import '../../../core/parsing.dart';
import '../../../domain/entities/osu_mode.dart';
import '../../../domain/usecases/fetch_recent_scores.dart';
import '../../../domain/usecases/get_binding.dart';
import '../../../domain/repositories/osu_repository.dart';
import '../../../core/pp_calc.dart' as pp;
import '../command_base.dart';

class LastFinishedCommand extends BotCommand {
  LastFinishedCommand(this.getRecent, this.getBinding, this.osu);

  final FetchRecentScores getRecent;
  final GetBinding getBinding;
  final IOsuRepository osu;

  @override
  List<String> get names => ['last_finished', 'lf'];

  @override
  List<String> get cyrAliases => ['лф', 'lf'];

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
            'Нужна привязка: /reg <user> или укажи пользователя: /last_fails <user> [mode]',
          );
          return;
        }
        uid = bind.osuId;
      } else {
        uid = await osu.resolveUserId(parsed.user, mode);
      }
      final scores = await getRecent(uid, mode, limit: 1, includeFails: true);
      if (scores.isEmpty) {
        await m.reply('Недавних фейлов нет.');
        return;
      }

      final s = scores.first;
      double? ppValue = s.pp;
      if (ppValue == null && s.beatmapId != null) {
        try {
          await pp.ensureNativeLibraryAvailable();
          final bytes = await pp.fetchOsuFile(s.beatmapId!);
          final mods = pp.modsFromStrings(s.mods);
          final res = pp.calcFromBytes(
            bytes,
            mods: mods,
            acc: s.accuracy,
            combo: s.combo,
            nMiss: s.countMiss,
            n300: s.count300,
            n100: s.count100,
            n50: s.count50,
          );
          ppValue = res.pp;
        } on Exception catch (_) {}
      }

      final modsStr = s.mods.isEmpty ? '' : ' +${s.mods.join()}';
      final ppStr = ppValue == null ? '-' : ppValue.toStringAsFixed(2);
      final line =
          '${s.artist} - ${s.title} [${s.diff}]  |  ${s.rank}  |  ${s.accuracy.toStringAsFixed(2)}% acc  |  ${ppStr}pp$modsStr';
      await m.reply(line);
    } on Exception catch (e) {
      await m.reply('Ошибка: $e');
    }
  }
}

