import '../../domain/entities/osu_user.dart';

typedef Json = Map<String, Object?>;

int? _asInt(Object? v) => v is num ? v.toInt() : null;

double? _asDouble(Object? v) => v is num ? v.toDouble() : null;

String? _asString(Object? v) => v?.toString();

class OsuUserDto {
  OsuUserDto(Map<String, dynamic> j) : json = j.cast<String, Object?>();
  final Json json;

  OsuUser toEntity() {
    final Json stats =
        (json['statistics'] as Map?)?.cast<String, Object?>() ?? const {};
    final Json rankMap =
        (stats['rank'] as Map?)?.cast<String, Object?>() ?? const {};
    final Json? countryObj = (json['country'] as Map?)?.cast<String, Object?>();

    final int id = _asInt(json['id']) ?? 0;
    final String username = _asString(json['username']) ?? '';
    final String? avatarUrl = _asString(json['avatar_url']);

    final String? countryCode =
        _asString(countryObj?['code']) ?? _asString(json['country_code']);

    final double? pp = _asDouble(stats['pp']);
    final int? globalRank =
        _asInt(stats['global_rank']) ?? _asInt(rankMap['global']);
    final int? countryRank =
        _asInt(stats['country_rank']) ?? _asInt(rankMap['country']);
    final double? accuracy = _asDouble(stats['hit_accuracy']);
    final int? playCount = _asInt(stats['play_count']);

    return OsuUser(
      id: id,
      username: username,
      avatarUrl: avatarUrl,
      countryCode: countryCode,
      pp: pp,
      globalRank: globalRank,
      countryRank: countryRank,
      accuracy: accuracy,
      playCount: playCount,
    );
  }
}
