import 'package:flutter/foundation.dart';
import 'package:reminder_app/data/database/models/medication_model.dart';
import 'package:reminder_app/repository/medication_repository.dart';

class MedicationViewModel extends ChangeNotifier {
  final MedicationRepository repository = MedicationRepository();

  List<MedicationModel> medications = [];

  Future<void> loadMedications(int userId) async {
    medications = await repository.fetchUserMedications(userId);
    notifyListeners();
  }

  Future<void> addMedication(MedicationModel medication) async {
    await repository.addMedication(medication);
    await loadMedications(medication.userId);
  }

  Future<void> deleteMedication(int id, int userId) async {
    await repository.deleteMedication(id);
    await loadMedications(userId);
  }
}
