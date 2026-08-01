import 'package:floor/floor.dart';
import 'package:reminder_app/data/entity/intake_records.dart';

@dao
abstract class IntakeRecordDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertRecord(IntakeRecord record);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertRecords(List<IntakeRecord> records);

  @Query('SELECT * FROM intake_records WHERE medId = :medId')
  Future<List<IntakeRecord>> getRecordsByMedId(int medId);

  @Query('SELECT * FROM intake_records')
  Future<List<IntakeRecord>> getAllRecords();

  @Query('SELECT * FROM intake_records WHERE scheduledAt BETWEEN :from AND :to')
  Future<List<IntakeRecord>> getRecordsBetweenDates(
    String from,
    String to,
  );

  @Query('DELETE FROM intake_records WHERE medId = :medId')
  Future<void> deleteRecordsByMedId(int medId);

  @update
  Future<void> updateRecord(IntakeRecord record);

  @delete
  Future<void> deleteRecord(IntakeRecord record);

  
  @Query('SELECT * FROM intake_records WHERE syncStatus = :status')
  Future<List<IntakeRecord>> getRecordsBySyncStatus(String status);

  @Query('UPDATE intake_records SET syncStatus = :status WHERE recordId = :id')
  Future<void> updateSyncStatus(int id, String status);
}
