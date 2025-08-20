import '../repositories/binding_repository.dart';

class UnregisterBinding {
  UnregisterBinding(this.links);

  final IBindingRepository links;

  Future<void> call(int tgId) => links.delete(tgId);
}
