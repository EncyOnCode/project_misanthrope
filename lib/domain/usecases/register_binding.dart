import '../entities/binding.dart';
import '../entities/osu_mode.dart';
import '../repositories/binding_repository.dart';
import '../repositories/osu_repository.dart';
import '../../core/logger.dart';

class RegisterBinding {
  RegisterBinding(this.links, this.osu);

  final IBindingRepository links;
  final IOsuRepository osu;

  Future<Binding> call({required int tgId, required String userInput}) async {
    Log.i('UseCase RegisterBinding(tgId=$tgId, input=$userInput)');
    final id = await osu.resolveUserId(userInput, OsuMode.osu);
    final name = await osu.getUsernameById(id, OsuMode.osu);
    final b = Binding(tgId: tgId, osuId: id, username: name);
    await links.upsert(b);
    Log.i('UseCase RegisterBinding: bound tgId=$tgId to osuId=$id ($name)');
    return b;
  }
}
