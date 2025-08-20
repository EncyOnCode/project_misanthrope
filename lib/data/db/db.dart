import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

part 'db.g.dart';

@DataClassName('UserLink')
class UserLinks extends Table {
  IntColumn get tgId => integer()();
  IntColumn get osuId => integer()();
  TextColumn get username => text()();
  TextColumn get defaultMode => text().withDefault(const Constant('osu'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {tgId};
}

@DriftDatabase(tables: [UserLinks])
class AppDatabase extends _$AppDatabase {
  AppDatabase._(super.e);

  static Future<AppDatabase> open({String? filePath}) async {
    final dbPath = filePath ?? p.join('data', 'bot.db');
    final dir = Directory(p.dirname(dbPath));
    if (dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return AppDatabase._(NativeDatabase(File(dbPath)));
  }

  @override
  int get schemaVersion => 1;

  Future<UserLink?> getLink(int tgId) =>
      (select(userLinks)..where((t) => t.tgId.equals(tgId))).getSingleOrNull();

  Future<void> upsertLink({
    required int tgId,
    required int osuId,
    required String username,
    String? defaultMode,
  }) async {
    final existing = await getLink(tgId);
    if (existing == null) {
      await into(userLinks).insert(
        UserLinksCompanion(
          tgId: Value(tgId),
          osuId: Value(osuId),
          username: Value(username),
          defaultMode:
              defaultMode != null ? Value(defaultMode) : const Value.absent(),
        ),
      );
    } else {
      await (update(userLinks)..where((t) => t.tgId.equals(tgId))).write(
        UserLinksCompanion(
          osuId: Value(osuId),
          username: Value(username),
          defaultMode:
              defaultMode != null ? Value(defaultMode) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> unbind(int tgId) =>
      (delete(userLinks)..where((t) => t.tgId.equals(tgId))).go();
}
