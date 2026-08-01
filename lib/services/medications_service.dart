import 'package:get/get.dart';
import 'package:reminder_app/main.dart';
import 'package:reminder_app/data/entity/medications.dart';

class MedicationsService extends GetxService {
  // ADD medications
  Future<void> addMedicationToSupabase({
    required Medication med,
    required String userId,
  }) async {
    if (med.medId == null) {
      throw Exception('medId must not be null when syncing to Supabase.');
    }

    await cloud.from('medications').insert({
      'med_id': med.medId,             
      'user_id': userId,
      'name': med.name,
      'dosage': med.dosage,
      'frequency': med.frequency,
      'duration_of_use': med.durationOfUse,
      'notes': med.notes,
      'image_url': med.imageUrl,
    });
  }

  // UPDATE medications
  Future<void> updateMedicationOnSupabase(Medication med) async {
    if (med.medId == null) return;

    await cloud.from('medications').update({
      'name': med.name,
      'dosage': med.dosage,
      'frequency': med.frequency,
      'duration_of_use': med.durationOfUse,
      'notes': med.notes,
      'image_url': med.imageUrl,
    }).eq('med_id', med.medId!);
  }

  // DELETE medications
  Future<void> deleteMedicationFromSupabase(int medId) async {
    await cloud.from('medications').delete().eq('med_id', medId);
  }
}
