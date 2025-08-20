import '../../domain/entities/binding.dart';
import '../../domain/repositories/binding_repository.dart';
import '../datasources/binding_local_ds.dart';

class BindingRepositoryImpl implements IBindingRepository {
  BindingRepositoryImpl(this.local);

  final BindingLocalDs local;

  @override
  Future<void> delete(int tgId) => local.delete(tgId);

  @override
  Future<Binding?> getByTgId(int tgId) => local.getByTgId(tgId);

  @override
  Future<void> upsert(Binding b) => local.upsert(b);
}
