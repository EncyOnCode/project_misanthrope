import '../entities/osu_mode.dart';
import '../entities/osu_score.dart';
import '../repositories/osu_repository.dart';
import '../../core/logger.dart';

class FetchUserMapScores {
  FetchUserMapScores(this.repo);

  final IOsuRepository repo;

  Future<List<OsuScore>> call(int userId, int beatmapId, OsuMode mode) {
    Log.i(
      'UseCase FetchUserMapScores(userId=$userId, beatmapId=$beatmapId, mode=${mode.name})',
    );

    return repo.userScoresOnBeatmap(userId, beatmapId, mode);
  }
}
