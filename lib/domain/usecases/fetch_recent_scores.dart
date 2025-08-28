import '../entities/osu_mode.dart';
import '../entities/osu_score.dart';
import '../repositories/osu_repository.dart';
import '../../core/logger.dart';

class FetchRecentScores {
  FetchRecentScores(this.repo);

  final IOsuRepository repo;

  Future<List<OsuScore>> call(
    int uid,
    OsuMode mode, {
    int limit = 1,
    bool includeFails = false,
  }) {
    Log.i(
      'UseCase FetchRecentScores(uid=$uid, mode=${mode.name}, limit=$limit, includeFails=$includeFails)',
    );

    return repo.userRecent(uid, mode, limit: limit, includeFails: includeFails);
  }
}
