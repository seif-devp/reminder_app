import '../data/database/dao/medication_dao.dart';
import '../data/database/models/medication_model.dart';

class MedicationRepository {
  final MedicationDao medicationDao = MedicationDao();

  Future<List<MedicationModel>> fetchUserMedications(int userId) {
    return medicationDao.getMedications(userId);
  }

  Future<void> addMedication(MedicationModel medication) {
    return medicationDao.insertMedication(medication);
  }

  Future<void> updateMedication(MedicationModel medication) {
    return medicationDao.updateMedication(medication);
  }

  Future<void> deleteMedication(int medId) {
    return medicationDao.deleteMedication(medId);
  }
}