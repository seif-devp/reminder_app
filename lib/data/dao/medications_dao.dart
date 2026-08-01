import 'package:floor/floor.dart';
import 'package:reminder_app/data/entity/medications.dart';

@dao
abstract class MedicationsDao {
  @Query('SELECT * FROM medications WHERE userId = :userId AND isDeleted = "false"')
  Future<List<Medication>> getMedicationsByUser(String userId);

  @Query('SELECT * FROM medications WHERE userId = :userId AND syncStatus = :status AND isDeleted = "false"')
  Future<List<Medication>> getMedicationsByUserWithStatus(String userId, String status);

  @Query('SELECT * FROM medications WHERE isDeleted = "true" AND syncStatus = :status')
  Future<List<Medication>> getDeletedMedicationsWithStatus(String status);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertMedication(Medication medication);

  @Update()
  Future<void> updateMedication(Medication medication);

  @Query('UPDATE medications SET isDeleted = "true", syncStatus = :syncStatus WHERE medId = :medId')
  Future<void> markAsDeleted(int medId, String syncStatus);

  @Query('DELETE FROM medications WHERE medId = :medId')
  Future<void> hardDeleteMedication(int medId);

  @Query('UPDATE medications SET syncStatus = :status WHERE medId = :medId')
  Future<void> updateMedicationSyncStatus(int medId, String status);
}
