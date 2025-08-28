import '../entities/osu_user.dart';
import '../entities/osu_score.dart';
import '../entities/osu_mode.dart';

abstract class IOsuRepository {
  Future<int> resolveUserId(String userInput, OsuMode mode);

  Future<String> getUsernameById(int userId, OsuMode mode);

  Future<OsuUser> getUserAny(String userInput, OsuMode mode);

  Future<List<OsuScore>> userTop(int userId, OsuMode mode, {int limit = 5});

  Future<List<OsuScore>> userRecent(
    int userId,
    OsuMode mode, {
    int limit = 1,
    bool includeFails = false,
  });

  Future<List<OsuScore>> userBeatmapScores(
    int userId,
    int beatmapId,
    OsuMode mode,
  );

  /// Дотянуть max_combo карты, если он отсутствует во вложении beatmap у recent.
  Future<int?> beatmapMaxCombo(int beatmapId);

  Future<({double? starRating, int? maxCombo})> beatmapAttributes(
    int beatmapId,
    OsuMode mode,
    List<String> mods,
  );
}
