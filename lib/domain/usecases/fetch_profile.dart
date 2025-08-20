import '../entities/osu_user.dart';
import '../entities/osu_mode.dart';
import '../repositories/osu_repository.dart';

class FetchProfile {
  FetchProfile(this.repo);

  final IOsuRepository repo;

  Future<OsuUser> call(String input, OsuMode mode) =>
      repo.getUserAny(input, mode);
}
