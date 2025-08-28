import '../entities/osu_mode.dart';
import '../entities/osu_score.dart';
import '../repositories/osu_repository.dart';

class FetchMapScores {
  FetchMapScores(this.repo);

  final IOsuRepository repo;

  Future<List<OsuScore>> call(int uid, int beatmapId, OsuMode mode) =>
      repo.userBeatmapScores(uid, beatmapId, mode);
}
