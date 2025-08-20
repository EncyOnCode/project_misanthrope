// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $UserLinksTable extends UserLinks
    with TableInfo<$UserLinksTable, UserLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tgIdMeta = const VerificationMeta('tgId');
  @override
  late final GeneratedColumn<int> tgId = GeneratedColumn<int>(
    'tg_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _osuIdMeta = const VerificationMeta('osuId');
  @override
  late final GeneratedColumn<int> osuId = GeneratedColumn<int>(
    'osu_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultModeMeta = const VerificationMeta(
    'defaultMode',
  );
  @override
  late final GeneratedColumn<String> defaultMode = GeneratedColumn<String>(
    'default_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('osu'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    tgId,
    osuId,
    username,
    defaultMode,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tg_id')) {
      context.handle(
        _tgIdMeta,
        tgId.isAcceptableOrUnknown(data['tg_id']!, _tgIdMeta),
      );
    }
    if (data.containsKey('osu_id')) {
      context.handle(
        _osuIdMeta,
        osuId.isAcceptableOrUnknown(data['osu_id']!, _osuIdMeta),
      );
    } else if (isInserting) {
      context.missing(_osuIdMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('default_mode')) {
      context.handle(
        _defaultModeMeta,
        defaultMode.isAcceptableOrUnknown(
          data['default_mode']!,
          _defaultModeMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tgId};
  @override
  UserLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserLink(
      tgId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}tg_id'],
          )!,
      osuId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}osu_id'],
          )!,
      username:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}username'],
          )!,
      defaultMode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}default_mode'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $UserLinksTable createAlias(String alias) {
    return $UserLinksTable(attachedDatabase, alias);
  }
}

class UserLink extends DataClass implements Insertable<UserLink> {
  final int tgId;
  final int osuId;
  final String username;
  final String defaultMode;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserLink({
    required this.tgId,
    required this.osuId,
    required this.username,
    required this.defaultMode,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tg_id'] = Variable<int>(tgId);
    map['osu_id'] = Variable<int>(osuId);
    map['username'] = Variable<String>(username);
    map['default_mode'] = Variable<String>(defaultMode);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserLinksCompanion toCompanion(bool nullToAbsent) {
    return UserLinksCompanion(
      tgId: Value(tgId),
      osuId: Value(osuId),
      username: Value(username),
      defaultMode: Value(defaultMode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserLink(
      tgId: serializer.fromJson<int>(json['tgId']),
      osuId: serializer.fromJson<int>(json['osuId']),
      username: serializer.fromJson<String>(json['username']),
      defaultMode: serializer.fromJson<String>(json['defaultMode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tgId': serializer.toJson<int>(tgId),
      'osuId': serializer.toJson<int>(osuId),
      'username': serializer.toJson<String>(username),
      'defaultMode': serializer.toJson<String>(defaultMode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserLink copyWith({
    int? tgId,
    int? osuId,
    String? username,
    String? defaultMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserLink(
    tgId: tgId ?? this.tgId,
    osuId: osuId ?? this.osuId,
    username: username ?? this.username,
    defaultMode: defaultMode ?? this.defaultMode,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserLink copyWithCompanion(UserLinksCompanion data) {
    return UserLink(
      tgId: data.tgId.present ? data.tgId.value : this.tgId,
      osuId: data.osuId.present ? data.osuId.value : this.osuId,
      username: data.username.present ? data.username.value : this.username,
      defaultMode:
          data.defaultMode.present ? data.defaultMode.value : this.defaultMode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserLink(')
          ..write('tgId: $tgId, ')
          ..write('osuId: $osuId, ')
          ..write('username: $username, ')
          ..write('defaultMode: $defaultMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(tgId, osuId, username, defaultMode, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserLink &&
          other.tgId == this.tgId &&
          other.osuId == this.osuId &&
          other.username == this.username &&
          other.defaultMode == this.defaultMode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserLinksCompanion extends UpdateCompanion<UserLink> {
  final Value<int> tgId;
  final Value<int> osuId;
  final Value<String> username;
  final Value<String> defaultMode;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UserLinksCompanion({
    this.tgId = const Value.absent(),
    this.osuId = const Value.absent(),
    this.username = const Value.absent(),
    this.defaultMode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserLinksCompanion.insert({
    this.tgId = const Value.absent(),
    required int osuId,
    required String username,
    this.defaultMode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : osuId = Value(osuId),
       username = Value(username);
  static Insertable<UserLink> custom({
    Expression<int>? tgId,
    Expression<int>? osuId,
    Expression<String>? username,
    Expression<String>? defaultMode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (tgId != null) 'tg_id': tgId,
      if (osuId != null) 'osu_id': osuId,
      if (username != null) 'username': username,
      if (defaultMode != null) 'default_mode': defaultMode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserLinksCompanion copyWith({
    Value<int>? tgId,
    Value<int>? osuId,
    Value<String>? username,
    Value<String>? defaultMode,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return UserLinksCompanion(
      tgId: tgId ?? this.tgId,
      osuId: osuId ?? this.osuId,
      username: username ?? this.username,
      defaultMode: defaultMode ?? this.defaultMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tgId.present) {
      map['tg_id'] = Variable<int>(tgId.value);
    }
    if (osuId.present) {
      map['osu_id'] = Variable<int>(osuId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (defaultMode.present) {
      map['default_mode'] = Variable<String>(defaultMode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserLinksCompanion(')
          ..write('tgId: $tgId, ')
          ..write('osuId: $osuId, ')
          ..write('username: $username, ')
          ..write('defaultMode: $defaultMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserLinksTable userLinks = $UserLinksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [userLinks];
}

typedef $$UserLinksTableCreateCompanionBuilder =
    UserLinksCompanion Function({
      Value<int> tgId,
      required int osuId,
      required String username,
      Value<String> defaultMode,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$UserLinksTableUpdateCompanionBuilder =
    UserLinksCompanion Function({
      Value<int> tgId,
      Value<int> osuId,
      Value<String> username,
      Value<String> defaultMode,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$UserLinksTableFilterComposer
    extends Composer<_$AppDatabase, $UserLinksTable> {
  $$UserLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get tgId => $composableBuilder(
    column: $table.tgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get osuId => $composableBuilder(
    column: $table.osuId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultMode => $composableBuilder(
    column: $table.defaultMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $UserLinksTable> {
  $$UserLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get tgId => $composableBuilder(
    column: $table.tgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get osuId => $composableBuilder(
    column: $table.osuId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultMode => $composableBuilder(
    column: $table.defaultMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserLinksTable> {
  $$UserLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get tgId =>
      $composableBuilder(column: $table.tgId, builder: (column) => column);

  GeneratedColumn<int> get osuId =>
      $composableBuilder(column: $table.osuId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get defaultMode => $composableBuilder(
    column: $table.defaultMode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserLinksTable,
          UserLink,
          $$UserLinksTableFilterComposer,
          $$UserLinksTableOrderingComposer,
          $$UserLinksTableAnnotationComposer,
          $$UserLinksTableCreateCompanionBuilder,
          $$UserLinksTableUpdateCompanionBuilder,
          (UserLink, BaseReferences<_$AppDatabase, $UserLinksTable, UserLink>),
          UserLink,
          PrefetchHooks Function()
        > {
  $$UserLinksTableTableManager(_$AppDatabase db, $UserLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$UserLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$UserLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$UserLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> tgId = const Value.absent(),
                Value<int> osuId = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> defaultMode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserLinksCompanion(
                tgId: tgId,
                osuId: osuId,
                username: username,
                defaultMode: defaultMode,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> tgId = const Value.absent(),
                required int osuId,
                required String username,
                Value<String> defaultMode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserLinksCompanion.insert(
                tgId: tgId,
                osuId: osuId,
                username: username,
                defaultMode: defaultMode,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserLinksTable,
      UserLink,
      $$UserLinksTableFilterComposer,
      $$UserLinksTableOrderingComposer,
      $$UserLinksTableAnnotationComposer,
      $$UserLinksTableCreateCompanionBuilder,
      $$UserLinksTableUpdateCompanionBuilder,
      (UserLink, BaseReferences<_$AppDatabase, $UserLinksTable, UserLink>),
      UserLink,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserLinksTableTableManager get userLinks =>
      $$UserLinksTableTableManager(_db, _db.userLinks);
}
