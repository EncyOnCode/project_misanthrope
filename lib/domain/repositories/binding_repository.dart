import '../entities/binding.dart';

abstract class IBindingRepository {
  Future<void> upsert(Binding b);

  Future<void> delete(int tgId);

  Future<Binding?> getByTgId(int tgId);
}
