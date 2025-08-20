import '../entities/binding.dart';
import '../repositories/binding_repository.dart';

class GetBinding {

  GetBinding(this.links);
  final IBindingRepository links;

  Future<Binding?> call(int tgId) => links.getByTgId(tgId);
}
