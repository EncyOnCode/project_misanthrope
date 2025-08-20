import '../entities/osu_mode.dart';
import '../entities/osu_score.dart';
import '../repositories/osu_repository.dart';

class FetchRecentScores {
  FetchRecentScores(this.repo);

  final IOsuRepository repo;

  Future<List<OsuScore>> call(
    int uid,
    OsuMode mode, {
    int limit = 1,
    bool includeFails = false,
  }) => repo.userRecent(uid, mode, limit: limit, includeFails: includeFails);
}
