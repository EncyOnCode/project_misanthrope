import '../entities/osu_mode.dart';
import '../entities/osu_score.dart';
import '../repositories/osu_repository.dart';
import '../../core/logger.dart';

class FetchTopScores {
  FetchTopScores(this.repo);

  final IOsuRepository repo;

  Future<List<OsuScore>> call(int uid, OsuMode mode, {int limit = 5}) {
    Log.i('UseCase FetchTopScores(uid=$uid, mode=${mode.name}, limit=$limit)');
    return repo.userTop(uid, mode, limit: limit);
  }
}
