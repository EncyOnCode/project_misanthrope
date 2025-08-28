import '../entities/osu_user.dart';
import '../entities/osu_mode.dart';
import '../repositories/osu_repository.dart';
import '../../core/logger.dart';

class FetchProfile {
  FetchProfile(this.repo);

  final IOsuRepository repo;

  Future<OsuUser> call(String input, OsuMode mode) =>
      (() {
        Log.i('UseCase FetchProfile(input=$input, mode=${mode.name})');
        return repo.getUserAny(input, mode);
      })();
}
