import '../../domain/entities/osu_score.dart';

typedef Json = Map<String, Object?>;

int? _asInt(Object? v) => v is num ? v.toInt() : null;

double? _asDouble(Object? v) => v is num ? v.toDouble() : null;

String? _asString(Object? v) => v?.toString();

class OsuScoreDto {
  OsuScoreDto(this.json);

  final Json json;

  OsuScore toEntity() {
    final Json bm =
        (json['beatmap'] as Map?)?.cast<String, Object?>() ?? const {};
    final Json set =
        (json['beatmapset'] as Map?)?.cast<String, Object?>() ?? const {};
    final Json st =
        (json['statistics'] as Map?)?.cast<String, Object?>() ?? const {};

    final List<Object?> modsRaw =
        (json['mods'] as List?)?.cast<Object?>() ?? const [];
    final List<String> mods = modsRaw
        .map((e) => e?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList(growable: false);

    final double acc = (_asDouble(json['accuracy']) ?? 0.0) * 100.0;

    final int cCircles = _asInt(bm['count_circles']) ?? 0;
    final int cSliders = _asInt(bm['count_sliders']) ?? 0;
    final int cSpinners = _asInt(bm['count_spinners']) ?? 0;
    final int totalObjs = cCircles + cSliders + cSpinners;

    final int c300 = _asInt(st['count_300']) ?? 0;
    final int c100 = _asInt(st['count_100']) ?? 0;
    final int c50 = _asInt(st['count_50']) ?? 0;
    final int cX = _asInt(st['count_miss']) ?? 0;
    final int hitDone = c300 + c100 + c50 + cX;
    final double? completion =
        totalObjs > 0 ? (hitDone / totalObjs * 100.0) : null;

    final Json? user = (set['user'] as Map?)?.cast<String, Object?>();
    final String mapper =
        _asString(set['creator']) ?? _asString(user?['username']) ?? '';

    final int? bpm = _asInt(set['bpm'] ?? bm['bpm']);

    final int? mapperId = _asInt(user?['id']) ?? _asInt(set['user_id']);

    return OsuScore(
      artist: _asString(set['artist']) ?? '',
      title: _asString(set['title']) ?? '',
      diff: _asString(bm['version']) ?? '',
      rank: _asString(json['rank']) ?? '',
      accuracy: acc,
      pp: _asDouble(json['pp']),
      mods: mods,

      score: _asInt(json['score']),
      combo: _asInt(json['max_combo']),
      mapMaxCombo: _asInt(bm['max_combo']),
      beatmapId: _asInt(bm['id']),

      count300: c300,
      count100: c100,
      count50: c50,
      countMiss: cX,

      cs: _asDouble(bm['cs']),
      ar: _asDouble(bm['ar']),
      od: _asDouble(bm['accuracy']),
      hp: _asDouble(bm['drain']),
      bpm: bpm,
      stars: _asDouble(bm['difficulty_rating']),
      lengthSec: _asInt(bm['total_length'] ?? bm['hit_length']),

      mapper: mapper,
      status: _asString(set['status']),
      passed: json['passed'] is bool ? json['passed']! as bool : null,
      completion: completion,
      mapperId: mapperId,

      // ppIfFc / ppIfSs
    );
  }
}
