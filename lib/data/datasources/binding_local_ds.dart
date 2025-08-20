import '../../domain/entities/binding.dart';
import '../db/db.dart';

class BindingLocalDs {

  BindingLocalDs(this.db);
  final AppDatabase db;

  Future<void> upsert(Binding b) =>
      db.upsertLink(tgId: b.tgId, osuId: b.osuId, username: b.username);

  Future<void> delete(int tgId) => db.unbind(tgId);

  Future<Binding?> getByTgId(int tgId) async {
    final r = await db.getLink(tgId);
    if (r == null) return null;
    return Binding(tgId: tgId, osuId: r.osuId, username: r.username);
    // assumes your DB model exposes osuId/username
  }
}
