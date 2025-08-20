import '../domain/entities/osu_score.dart';
import '../domain/entities/osu_user.dart';
import 'markdown.dart';

String formatScore(OsuScore s) {
  final mods = s.mods.isEmpty ? '' : ' +${s.mods.join()}';
  final pp = s.pp == null ? '-' : s.pp!.toStringAsFixed(2);
  return '${s.artist} - ${s.title} [${s.diff}]  |  ${s.rank}  |  ${s.accuracy.toStringAsFixed(2)}% acc  |  ${pp}pp$mods';
}

String formatProfileCaption(OsuUser u, String mode) {
  String fmtRank(int? v) => v == null ? '-' : '#$v';
  String fmtAcc(double? v) => v == null ? '-' : '${v.toStringAsFixed(2)}%';
  String fmtPp(double? v) => v == null ? '-' : '${v.toStringAsFixed(2)}pp';
  final countryPart =
      (u.countryCode != null && u.countryRank != null)
          ? ' (${u.countryCode} ${fmtRank(u.countryRank)})'
          : '';
  final link = 'https://osu.ppy.sh/users/${u.id}';
  return '${u.username}  [$mode]\n'
      'PP: ${fmtPp(u.pp)}\n'
      'Rank: ${fmtRank(u.globalRank)}$countryPart\n'
      'Accuracy: ${fmtAcc(u.accuracy)}\n'
      'Playcount: ${u.playCount ?? '-'}\n'
      '$link';
}

/// Формат для /last из доменной сущности.
/// Можно передать [mapMaxComboOverride], если дотянули max combo отдельным запросом.
String formatLastPrettyFromEntity(
  OsuScore s, {
  String server = 'Bancho',
  int? mapMaxComboOverride,
  double? starOverride,
}) {
  String dec(num v, [int f = 2]) => v.toStringAsFixed(f);
  String one(num v) => v.toStringAsFixed(1);
  String two(int v) => v.toString().padLeft(2, '0');
  String dur(int secs) => '${two(secs ~/ 60)}:${two(secs % 60)}';

  String statusWithEmoji(String? raw) {
    final v = (raw ?? '').toLowerCase();
    switch (v) {
      case 'loved':
        return '❤️ Loved';
      case 'qualified':
        return '✅ Qualified';
      case 'ranked':
      case 'approved':
        return '🔷 Ranked';
      default:
        return '❔ Unranked';
    }
  }

  final mods = s.mods.map((m) => m.toUpperCase()).toList(growable: false);
  final hasHR = mods.contains('HR');
  final hasEZ = mods.contains('EZ');
  final hasDT = mods.contains('DT') || mods.contains('NC');
  final hasHT = mods.contains('HT');
  final rate = hasDT ? 1.5 : (hasHT ? 0.75 : 1.0);

  double clamp(double v, double lo, double hi) =>
      v < lo ? lo : (v > hi ? hi : v);
  double arToMs(double ar) => ar < 5 ? 1800 - 120 * ar : 1200 - 150 * (ar - 5);
  double msToAr(double ms) =>
      ms > 1200 ? (1800 - ms) / 120 : 5 + (1200 - ms) / 150;
  double odToMs300(double od) => 79.5 - 6.0 * od;
  double ms300ToOd(double ms) => (79.5 - ms) / 6.0;

  final baseAR = s.ar ?? 0;
  final baseOD = s.od ?? 0;
  final baseCS = s.cs ?? 0;
  final baseHP = s.hp ?? 0;

  final arAfterHrEz = clamp(
    baseAR * (hasHR ? 1.4 : 1.0) * (hasEZ ? 0.5 : 1.0),
    0,
    10,
  );
  final odAfterHrEz = clamp(
    baseOD * (hasHR ? 1.4 : 1.0) * (hasEZ ? 0.5 : 1.0),
    0,
    10,
  );
  final csAfterHrEz = clamp(
    baseCS * (hasHR ? 1.3 : 1.0) * (hasEZ ? 0.5 : 1.0),
    0,
    10,
  );
  final hpAfterHrEz = clamp(
    baseHP * (hasHR ? 1.4 : 1.0) * (hasEZ ? 0.5 : 1.0),
    0,
    10,
  );

  final modAR = msToAr(arToMs(arAfterHrEz) / rate);
  final modOD = ms300ToOd(odToMs300(odAfterHrEz) / rate);
  final modCS = csAfterHrEz;
  final modHP = hpAfterHrEz;
  final modBpm = s.bpm == null ? null : (s.bpm! * rate).round();
  final modLen = s.lengthSec == null ? null : (s.lengthSec! / rate).round();

  final sr = starOverride ?? s.stars;
  final starStr = sr == null ? '-' : '⭐ ${sr.toStringAsFixed(2)}';

  final mapUrl =
      s.beatmapId != null ? 'https://osu.ppy.sh/b/${s.beatmapId}' : null;
  final mapperUrl =
      s.mapperId != null ? 'https://osu.ppy.sh/users/${s.mapperId}' : null;

  final titleText = '${s.artist} - ${s.title} [${s.diff}]';
  final titleMd =
      mapUrl == null ? escapeMdV2(titleText) : linkMdV2(titleText, mapUrl);

  final mapperText = s.mapper ?? '-';
  final mapperMd =
      mapperUrl == null
          ? escapeMdV2(mapperText)
          : linkMdV2(mapperText, mapperUrl);

  final serverLine = escapeMdV2('[Server: $server]');
  final statusLine = escapeMdV2(' <${statusWithEmoji(s.status)}> ');

  final lengthStr = modLen == null ? '--:--' : dur(modLen);
  final arStr = one(modAR),
      csStr = one(modCS),
      odStr = one(modOD),
      hpStr = one(modHP);
  final bpmStr = modBpm == null ? '-' : '${modBpm}BPM';

  final statsHeader = escapeMdV2('Map stats:');
  final statsLine = escapeMdV2(
    '  $lengthStr | AR:$arStr CS:$csStr OD:$odStr HP:$hpStr $bpmStr | $starStr',
  );
  final modsLine = escapeMdV2(
    '  ${mods.isEmpty ? 'Mods: NM' : 'Mods: +${mods.join()}'}',
  );

  final mapMax = mapMaxComboOverride ?? s.mapMaxCombo;
  final comboEsc = escapeMdV2(
    'Score: ${s.score ?? '-'} | Combo: ${s.combo ?? '-'}x/${mapMax ?? '-'}x',
  );
  final accEsc = escapeMdV2('Accuracy: ${dec(s.accuracy)}%');
  final ppEsc = escapeMdV2(
    'PP: ${s.pp == null ? 'НЕ ПОФАРМИЛ :(' : dec(s.pp!)}',
  );
  final hcEsc = escapeMdV2(
    'Hitcounts: ${s.count300 ?? 0}/${s.count100 ?? 0}/${s.count50 ?? 0}/${s.countMiss ?? 0}',
  );
  final gradeEsc = escapeMdV2(
    'Grade: ${s.rank.isEmpty ? '-' : s.rank.toUpperCase()}'
    '${(s.passed == false && s.completion != null) ? ' (${dec(s.completion!, 2)}%)' : ''}',
  );

  final buf =
      StringBuffer()
        ..writeln(serverLine)
        ..writeln()
        ..writeln('$statusLine$titleMd ${escapeMdV2('by')} $mapperMd')
        ..writeln()
        ..writeln(statsHeader)
        ..writeln(statsLine)
        ..writeln(modsLine)
        ..writeln()
        ..writeln(comboEsc)
        ..writeln(accEsc)
        ..writeln(ppEsc)
        ..writeln(hcEsc)
        ..writeln(gradeEsc);

  return buf.toString();
}
