// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UserDao? _userDaoInstance;

  MedicationsDao? _medicationsDaoInstance;

  MedicationScheduleDao? _medicationScheduleDaoInstance;

  IntakeRecordDao? _intakeRecordDaoInstance;

  DocumentsDao? _documentsDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `users` (`userId` TEXT NOT NULL, `name` TEXT NOT NULL, `email` TEXT NOT NULL, `password` TEXT NOT NULL, `gender` TEXT, `age` TEXT, `bloodType` TEXT, `weight` TEXT, `height` TEXT, `syncStatus` TEXT, PRIMARY KEY (`userId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `medications` (`medId` INTEGER PRIMARY KEY AUTOINCREMENT, `userId` TEXT NOT NULL, `name` TEXT NOT NULL, `dosage` TEXT NOT NULL, `frequency` TEXT NOT NULL, `durationOfUse` TEXT NOT NULL, `notes` TEXT, `imageUrl` TEXT, `syncStatus` TEXT, `isDeleted` TEXT, FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON UPDATE CASCADE ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `medication_schedule` (`scheduleId` INTEGER PRIMARY KEY AUTOINCREMENT, `medId` INTEGER NOT NULL, `intakeTime` TEXT NOT NULL, `syncStatus` TEXT, FOREIGN KEY (`medId`) REFERENCES `medications` (`medId`) ON UPDATE CASCADE ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `intake_records` (`recordId` INTEGER PRIMARY KEY AUTOINCREMENT, `medId` INTEGER NOT NULL, `takenAt` TEXT, `scheduledAt` TEXT NOT NULL, `status` TEXT NOT NULL, `syncStatus` TEXT, FOREIGN KEY (`medId`) REFERENCES `medications` (`medId`) ON UPDATE CASCADE ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `documents` (`docId` INTEGER PRIMARY KEY AUTOINCREMENT, `userId` TEXT NOT NULL, `fileUrl` TEXT NOT NULL, `fileName` TEXT NOT NULL, `syncStatus` TEXT, FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON UPDATE CASCADE ON DELETE CASCADE)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }

  @override
  MedicationsDao get medicationsDao {
    return _medicationsDaoInstance ??=
        _$MedicationsDao(database, changeListener);
  }

  @override
  MedicationScheduleDao get medicationScheduleDao {
    return _medicationScheduleDaoInstance ??=
        _$MedicationScheduleDao(database, changeListener);
  }

  @override
  IntakeRecordDao get intakeRecordDao {
    return _intakeRecordDaoInstance ??=
        _$IntakeRecordDao(database, changeListener);
  }

  @override
  DocumentsDao get documentsDao {
    return _documentsDaoInstance ??= _$DocumentsDao(database, changeListener);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _userInsertionAdapter = InsertionAdapter(
            database,
            'users',
            (User item) => <String, Object?>{
                  'userId': item.userId,
                  'name': item.name,
                  'email': item.email,
                  'password': item.password,
                  'gender': item.gender,
                  'age': item.age,
                  'bloodType': item.bloodType,
                  'weight': item.weight,
                  'height': item.height,
                  'syncStatus': item.syncStatus
                }),
        _userUpdateAdapter = UpdateAdapter(
            database,
            'users',
            ['userId'],
            (User item) => <String, Object?>{
                  'userId': item.userId,
                  'name': item.name,
                  'email': item.email,
                  'password': item.password,
                  'gender': item.gender,
                  'age': item.age,
                  'bloodType': item.bloodType,
                  'weight': item.weight,
                  'height': item.height,
                  'syncStatus': item.syncStatus
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  final UpdateAdapter<User> _userUpdateAdapter;

  @override
  Future<User?> getUserById(String userId) async {
    return _queryAdapter.query('SELECT * FROM users WHERE userId = ?1',
        mapper: (Map<String, Object?> row) => User(
            userId: row['userId'] as String,
            name: row['name'] as String,
            email: row['email'] as String,
            password: row['password'] as String,
            gender: row['gender'] as String?,
            age: row['age'] as String?,
            bloodType: row['bloodType'] as String?,
            weight: row['weight'] as String?,
            height: row['height'] as String?,
            syncStatus: row['syncStatus'] as String?),
        arguments: [userId]);
  }

  @override
  Future<List<User>> getUsersWithSyncStatus(String status) async {
    return _queryAdapter.queryList('SELECT * FROM users WHERE syncStatus = ?1',
        mapper: (Map<String, Object?> row) => User(
            userId: row['userId'] as String,
            name: row['name'] as String,
            email: row['email'] as String,
            password: row['password'] as String,
            gender: row['gender'] as String?,
            age: row['age'] as String?,
            bloodType: row['bloodType'] as String?,
            weight: row['weight'] as String?,
            height: row['height'] as String?,
            syncStatus: row['syncStatus'] as String?),
        arguments: [status]);
  }

  @override
  Future<void> updateUserSyncStatus(
    String userId,
    String status,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE users SET syncStatus = ?2 WHERE userId = ?1',
        arguments: [userId, status]);
  }

  @override
  Future<List<User>> getAllUsers() async {
    return _queryAdapter.queryList('SELECT * FROM users',
        mapper: (Map<String, Object?> row) => User(
            userId: row['userId'] as String,
            name: row['name'] as String,
            email: row['email'] as String,
            password: row['password'] as String,
            gender: row['gender'] as String?,
            age: row['age'] as String?,
            bloodType: row['bloodType'] as String?,
            weight: row['weight'] as String?,
            height: row['height'] as String?,
            syncStatus: row['syncStatus'] as String?));
  }

  @override
  Future<void> deleteAllUsers() async {
    await _queryAdapter.queryNoReturn('DELETE FROM users');
  }

  @override
  Future<void> insertUser(User user) async {
    await _userInsertionAdapter.insert(user, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateUser(User user) async {
    await _userUpdateAdapter.update(user, OnConflictStrategy.abort);
  }
}

class _$MedicationsDao extends MedicationsDao {
  _$MedicationsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _medicationInsertionAdapter = InsertionAdapter(
            database,
            'medications',
            (Medication item) => <String, Object?>{
                  'medId': item.medId,
                  'userId': item.userId,
                  'name': item.name,
                  'dosage': item.dosage,
                  'frequency': item.frequency,
                  'durationOfUse': item.durationOfUse,
                  'notes': item.notes,
                  'imageUrl': item.imageUrl,
                  'syncStatus': item.syncStatus,
                  'isDeleted': item.isDeleted
                }),
        _medicationUpdateAdapter = UpdateAdapter(
            database,
            'medications',
            ['medId'],
            (Medication item) => <String, Object?>{
                  'medId': item.medId,
                  'userId': item.userId,
                  'name': item.name,
                  'dosage': item.dosage,
                  'frequency': item.frequency,
                  'durationOfUse': item.durationOfUse,
                  'notes': item.notes,
                  'imageUrl': item.imageUrl,
                  'syncStatus': item.syncStatus,
                  'isDeleted': item.isDeleted
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Medication> _medicationInsertionAdapter;

  final UpdateAdapter<Medication> _medicationUpdateAdapter;

  @override
  Future<List<Medication>> getMedicationsByUser(String userId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM medications WHERE userId = ?1 AND isDeleted = \"false\"',
        mapper: (Map<String, Object?> row) => Medication(
            medId: row['medId'] as int?,
            userId: row['userId'] as String,
            name: row['name'] as String,
            dosage: row['dosage'] as String,
            frequency: row['frequency'] as String,
            durationOfUse: row['durationOfUse'] as String,
            notes: row['notes'] as String?,
            imageUrl: row['imageUrl'] as String?,
            syncStatus: row['syncStatus'] as String?,
            isDeleted: row['isDeleted'] as String?),
        arguments: [userId]);
  }

  @override
  Future<List<Medication>> getMedicationsByUserWithStatus(
    String userId,
    String status,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM medications WHERE userId = ?1 AND syncStatus = ?2 AND isDeleted = \"false\"',
        mapper: (Map<String, Object?> row) => Medication(medId: row['medId'] as int?, userId: row['userId'] as String, name: row['name'] as String, dosage: row['dosage'] as String, frequency: row['frequency'] as String, durationOfUse: row['durationOfUse'] as String, notes: row['notes'] as String?, imageUrl: row['imageUrl'] as String?, syncStatus: row['syncStatus'] as String?, isDeleted: row['isDeleted'] as String?),
        arguments: [userId, status]);
  }

  @override
  Future<List<Medication>> getDeletedMedicationsWithStatus(
      String status) async {
    return _queryAdapter.queryList(
        'SELECT * FROM medications WHERE isDeleted = \"true\" AND syncStatus = ?1',
        mapper: (Map<String, Object?> row) => Medication(medId: row['medId'] as int?, userId: row['userId'] as String, name: row['name'] as String, dosage: row['dosage'] as String, frequency: row['frequency'] as String, durationOfUse: row['durationOfUse'] as String, notes: row['notes'] as String?, imageUrl: row['imageUrl'] as String?, syncStatus: row['syncStatus'] as String?, isDeleted: row['isDeleted'] as String?),
        arguments: [status]);
  }

  @override
  Future<void> markAsDeleted(
    int medId,
    String syncStatus,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE medications SET isDeleted = \"true\", syncStatus = ?2 WHERE medId = ?1',
        arguments: [medId, syncStatus]);
  }

  @override
  Future<void> hardDeleteMedication(int medId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM medications WHERE medId = ?1',
        arguments: [medId]);
  }

  @override
  Future<void> updateMedicationSyncStatus(
    int medId,
    String status,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE medications SET syncStatus = ?2 WHERE medId = ?1',
        arguments: [medId, status]);
  }

  @override
  Future<int> insertMedication(Medication medication) {
    return _medicationInsertionAdapter.insertAndReturnId(
        medication, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateMedication(Medication medication) async {
    await _medicationUpdateAdapter.update(medication, OnConflictStrategy.abort);
  }
}

class _$MedicationScheduleDao extends MedicationScheduleDao {
  _$MedicationScheduleDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _medicationScheduleInsertionAdapter = InsertionAdapter(
            database,
            'medication_schedule',
            (MedicationSchedule item) => <String, Object?>{
                  'scheduleId': item.scheduleId,
                  'medId': item.medId,
                  'intakeTime': item.intakeTime,
                  'syncStatus': item.syncStatus
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MedicationSchedule>
      _medicationScheduleInsertionAdapter;

  @override
  Future<List<MedicationSchedule>> getSchedulesByMedId(int medId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM medication_schedule WHERE medId = ?1',
        mapper: (Map<String, Object?> row) => MedicationSchedule(
            scheduleId: row['scheduleId'] as int?,
            medId: row['medId'] as int,
            intakeTime: row['intakeTime'] as String,
            syncStatus: row['syncStatus'] as String?),
        arguments: [medId]);
  }

  @override
  Future<void> deleteSchedulesByMedId(int medId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM medication_schedule WHERE medId = ?1',
        arguments: [medId]);
  }

  @override
  Future<List<MedicationSchedule>> getSchedulesBySyncStatus(
      String status) async {
    return _queryAdapter.queryList(
        'SELECT * FROM medication_schedule WHERE syncStatus = ?1',
        mapper: (Map<String, Object?> row) => MedicationSchedule(
            scheduleId: row['scheduleId'] as int?,
            medId: row['medId'] as int,
            intakeTime: row['intakeTime'] as String,
            syncStatus: row['syncStatus'] as String?),
        arguments: [status]);
  }

  @override
  Future<void> updateSyncStatus(
    int id,
    String status,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE medication_schedule SET syncStatus = ?2 WHERE scheduleId = ?1',
        arguments: [id, status]);
  }

  @override
  Future<void> insertSchedule(MedicationSchedule schedule) async {
    await _medicationScheduleInsertionAdapter.insert(
        schedule, OnConflictStrategy.abort);
  }
}

class _$IntakeRecordDao extends IntakeRecordDao {
  _$IntakeRecordDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _intakeRecordInsertionAdapter = InsertionAdapter(
            database,
            'intake_records',
            (IntakeRecord item) => <String, Object?>{
                  'recordId': item.recordId,
                  'medId': item.medId,
                  'takenAt': item.takenAt,
                  'scheduledAt': item.scheduledAt,
                  'status': item.status,
                  'syncStatus': item.syncStatus
                }),
        _intakeRecordUpdateAdapter = UpdateAdapter(
            database,
            'intake_records',
            ['recordId'],
            (IntakeRecord item) => <String, Object?>{
                  'recordId': item.recordId,
                  'medId': item.medId,
                  'takenAt': item.takenAt,
                  'scheduledAt': item.scheduledAt,
                  'status': item.status,
                  'syncStatus': item.syncStatus
                }),
        _intakeRecordDeletionAdapter = DeletionAdapter(
            database,
            'intake_records',
            ['recordId'],
            (IntakeRecord item) => <String, Object?>{
                  'recordId': item.recordId,
                  'medId': item.medId,
                  'takenAt': item.takenAt,
                  'scheduledAt': item.scheduledAt,
                  'status': item.status,
                  'syncStatus': item.syncStatus
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<IntakeRecord> _intakeRecordInsertionAdapter;

  final UpdateAdapter<IntakeRecord> _intakeRecordUpdateAdapter;

  final DeletionAdapter<IntakeRecord> _intakeRecordDeletionAdapter;

  @override
  Future<List<IntakeRecord>> getRecordsByMedId(int medId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM intake_records WHERE medId = ?1',
        mapper: (Map<String, Object?> row) => IntakeRecord(
            recordId: row['recordId'] as int?,
            medId: row['medId'] as int,
            takenAt: row['takenAt'] as String?,
            scheduledAt: row['scheduledAt'] as String,
            status: row['status'] as String,
            syncStatus: row['syncStatus'] as String?),
        arguments: [medId]);
  }

  @override
  Future<List<IntakeRecord>> getAllRecords() async {
    return _queryAdapter.queryList('SELECT * FROM intake_records',
        mapper: (Map<String, Object?> row) => IntakeRecord(
            recordId: row['recordId'] as int?,
            medId: row['medId'] as int,
            takenAt: row['takenAt'] as String?,
            scheduledAt: row['scheduledAt'] as String,
            status: row['status'] as String,
            syncStatus: row['syncStatus'] as String?));
  }

  @override
  Future<List<IntakeRecord>> getRecordsBetweenDates(
    String from,
    String to,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM intake_records WHERE scheduledAt BETWEEN ?1 AND ?2',
        mapper: (Map<String, Object?> row) => IntakeRecord(
            recordId: row['recordId'] as int?,
            medId: row['medId'] as int,
            takenAt: row['takenAt'] as String?,
            scheduledAt: row['scheduledAt'] as String,
            status: row['status'] as String,
            syncStatus: row['syncStatus'] as String?),
        arguments: [from, to]);
  }

  @override
  Future<void> deleteRecordsByMedId(int medId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM intake_records WHERE medId = ?1',
        arguments: [medId]);
  }

  @override
  Future<List<IntakeRecord>> getRecordsBySyncStatus(String status) async {
    return _queryAdapter.queryList(
        'SELECT * FROM intake_records WHERE syncStatus = ?1',
        mapper: (Map<String, Object?> row) => IntakeRecord(
            recordId: row['recordId'] as int?,
            medId: row['medId'] as int,
            takenAt: row['takenAt'] as String?,
            scheduledAt: row['scheduledAt'] as String,
            status: row['status'] as String,
            syncStatus: row['syncStatus'] as String?),
        arguments: [status]);
  }

  @override
  Future<void> updateSyncStatus(
    int id,
    String status,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE intake_records SET syncStatus = ?2 WHERE recordId = ?1',
        arguments: [id, status]);
  }

  @override
  Future<void> insertRecord(IntakeRecord record) async {
    await _intakeRecordInsertionAdapter.insert(
        record, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertRecords(List<IntakeRecord> records) async {
    await _intakeRecordInsertionAdapter.insertList(
        records, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateRecord(IntakeRecord record) async {
    await _intakeRecordUpdateAdapter.update(record, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteRecord(IntakeRecord record) async {
    await _intakeRecordDeletionAdapter.delete(record);
  }
}

class _$DocumentsDao extends DocumentsDao {
  _$DocumentsDao(
    this.database,
    this.changeListener,
  );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;
}
