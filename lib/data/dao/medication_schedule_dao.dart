import 'package:floor/floor.dart';
import 'package:reminder_app/data/entity/medication_schedule.dart';

@dao
abstract class MedicationScheduleDao {
  @Query('SELECT * FROM medication_schedule WHERE medId = :medId')
  Future<List<MedicationSchedule>> getSchedulesByMedId(int medId);

  @insert
  Future<void> insertSchedule(MedicationSchedule schedule);

  @Query('DELETE FROM medication_schedule WHERE medId = :medId')
  Future<void> deleteSchedulesByMedId(int medId);

  @Query('SELECT * FROM medication_schedule WHERE syncStatus = :status')
  Future<List<MedicationSchedule>> getSchedulesBySyncStatus(String status);

  @Query('UPDATE medication_schedule SET syncStatus = :status WHERE scheduleId = :id')
  Future<void> updateSyncStatus(int id, String status);
}

