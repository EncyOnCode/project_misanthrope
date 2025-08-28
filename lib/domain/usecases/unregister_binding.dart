import '../repositories/binding_repository.dart';
import '../../core/logger.dart';

class UnregisterBinding {
  UnregisterBinding(this.links);

  final IBindingRepository links;

  Future<void> call(int tgId) async {
    Log.i('UseCase UnregisterBinding(tgId=$tgId)');
    await links.delete(tgId);
    Log.i('UseCase UnregisterBinding: removed binding for $tgId');
  }
}
