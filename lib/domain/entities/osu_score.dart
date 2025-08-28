class OsuScore {
  OsuScore({
    required this.artist,
    required this.title,
    required this.diff,
    required this.rank,
    required this.accuracy,
    this.pp,
    required this.mods,
    this.score,
    this.combo,
    this.mapMaxCombo,
    this.beatmapId,
    this.count300,
    this.count100,
    this.count50,
    this.countMiss,
    this.cs,
    this.ar,
    this.od,
    this.hp,
    this.bpm,
    this.stars,
    this.lengthSec,
    this.mapper,
    this.mapperId,
    this.status,
    this.passed,
    this.completion,
    this.ppIfFc,
    this.ppIfSs,
    this.createdAt,
  });

  final String artist;
  final String title;
  final String diff;
  final String rank;
  final double accuracy;
  final double? pp;
  final List<String> mods;
  final int? score;
  final int? combo;
  final int? mapMaxCombo;
  final int? beatmapId;
  final int? count300;
  final int? count100;
  final int? count50;
  final int? countMiss;
  final double? cs, ar, od, hp;
  final int? bpm;
  final double? stars;
  final int? lengthSec;
  final String? mapper;

  final int? mapperId;
  final String? status;
  final bool? passed;
  final double? completion;
  final double? ppIfFc;
  final double? ppIfSs;
  final DateTime? createdAt;
}
