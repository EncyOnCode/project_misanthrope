import '../../domain/entities/osu_mode.dart';
import '../../domain/entities/osu_user.dart';
import '../../domain/entities/osu_score.dart';
import '../../domain/repositories/osu_repository.dart';
import '../datasources/osu_remote_ds.dart';
import '../models/osu_user.dart';
import '../models/osu_score_dto.dart';

class OsuRepositoryImpl implements IOsuRepository {
  OsuRepositoryImpl(this.remote);

  final OsuRemoteDs remote;

  @override
  Future<int> resolveUserId(String userInput, OsuMode mode) async {
    final isDigits = RegExp(r'^\d+$').hasMatch(userInput.trim());
    if (isDigits) return int.parse(userInput);
    final lookup = userInput.startsWith('@') ? userInput : '@$userInput';
    final data = await remote.get('/users/$lookup/${mode.api}');
    return (data['id'] as num).toInt();
  }

  @override
  Future<String> getUsernameById(int userId, OsuMode mode) async {
    final data = await remote.get('/users/$userId/${mode.api}');
    return (data['username'] ?? userId.toString()).toString();
  }

  @override
  Future<OsuUser> getUserAny(String userInput, OsuMode mode) async {
    final lookup =
        userInput.startsWith('@')
            ? userInput
            : userInput; // accepts id or @username
    final data = await remote.get('/users/$lookup/${mode.api}');
    return OsuUserDto(data).toEntity();
  }

  @override
  Future<List<OsuScore>> userTop(
    int userId,
    OsuMode mode, {
    int limit = 5,
  }) async {
    final list = await remote.getList(
      '/users/$userId/scores/best',
      query: {'mode': mode.api, 'limit': '$limit'},
    );
    return list
        .map((e) => OsuScoreDto(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<OsuScore>> userRecent(
    int userId,
    OsuMode mode, {
    int limit = 1,
    bool includeFails = false,
  }) async {
    final list = await remote.getList(
      '/users/$userId/scores/recent',
      query: {
        'mode': mode.api,
        'limit': '$limit',
        'include_fails': includeFails ? '1' : '0',
      },
    );
    return list
        .map((e) => OsuScoreDto(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<int?> beatmapMaxCombo(int beatmapId) async {
    final data = await remote.get('/beatmaps/$beatmapId');
    return (data['max_combo'] as num?)?.toInt();
  }

  @override
  Future<({double? starRating, int? maxCombo})> beatmapAttributes(
    int beatmapId,
    OsuMode mode,
    List<String> mods,
  ) async {
    final body = <String, Object?>{
      'ruleset': mode.api,
      if (mods.isNotEmpty) 'mods': mods.map((m) => m.toUpperCase()).toList(),
    };
    final res = await remote.postJson(
      '/beatmaps/$beatmapId/attributes',
      body: body,
    );
    final attrs =
        (res['attributes'] as Map?)?.cast<String, Object?>() ?? const {};
    final sr = (attrs['star_rating'] as num?)?.toDouble();
    final mc = (attrs['max_combo'] as num?)?.toInt();
    return (starRating: sr, maxCombo: mc);
  }

  @override
  Future<List<OsuScore>> userScoresOnBeatmap(
    int userId,
    int beatmapId,
    OsuMode mode,
  ) async {
    // GET /beatmaps/{beatmap_id}/scores/users/{user_id}/all?mode={mode}
    // Response is a map with key 'scores' containing a list of score objects.
    final data = await remote.get(
      '/beatmaps/$beatmapId/scores/users/$userId/all',
      query: {'mode': mode.api},
    );
    final list = (data['scores'] as List?) ?? const [];
    return list
        .map((e) => OsuScoreDto((e as Map).cast<String, Object?>()).toEntity())
        .toList(growable: false);
  }
}
