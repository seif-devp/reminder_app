import 'package:reminder_app/data/database/app_database.dart';
import 'package:reminder_app/data/database/models/medication_model.dart';

class MedicationDao {
  final db = AppDatabase.instance;

  Future<int> insertMedication(MedicationModel medication) async {
    final database = await db.database;
    return database.insert("medications", medication.toMap());
  }

  Future<List<MedicationModel>> getMedications(int userId) async {
    final database = await db.database;
    final result = await database.query(
      "medications",
      where: "user_id = ?",
      whereArgs: [userId],
    );
    return result.map((e) => MedicationModel.fromMap(e)).toList();
  }

  Future<int> updateMedication(MedicationModel medication) async {
    final database = await db.database;
    return database.update(
      "medications",
      medication.toMap(),
      where: "med_id = ?",
      whereArgs: [medication.medId],
    );
  }

  Future<int> deleteMedication(int medId) async {
    final database = await db.database;
    return database.delete(
      "medications",
      where: "med_id = ?",
      whereArgs: [medId],
    );
  }
}
