import '../entities/osu_mode.dart';
import '../entities/osu_score.dart';
import '../repositories/osu_repository.dart';

class FetchUserMapScores {
  FetchUserMapScores(this.repo);

  final IOsuRepository repo;

  Future<List<OsuScore>> call(
    int userId,
    int beatmapId,
    OsuMode mode,
  ) => repo.userScoresOnBeatmap(userId, beatmapId, mode);
}

