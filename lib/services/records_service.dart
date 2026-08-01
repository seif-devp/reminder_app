import 'package:get/get.dart';
import 'package:reminder_app/main.dart';
import 'package:reminder_app/data/entity/intake_records.dart';

class RecordsService extends GetxService {
  // ADD records
  Future<void> addRecordsToSupabase(List<IntakeRecord> records) async {
    if (records.isEmpty) return;

    for (final r in records) {
      if (r.recordId == null) {
        throw Exception('All records must have recordId when syncing.');
      }
    }

    final payload = records.map((r) {
      return {
        'record_id': r.recordId, 
        'med_id': r.medId,
        'scheduled_at': r.scheduledAt,
        'taken_at': r.takenAt,
        'status': r.status,
      };
    }).toList();

    await cloud.from('intake_records').insert(payload);
  }

  // UPDATE records
  Future<void> updateRecordStatusOnSupabase(IntakeRecord record) async {
    if (record.recordId == null) return;

    await cloud.from('intake_records').update({
      'taken_at': record.takenAt,
      'status': record.status,
      'scheduled_at': record.scheduledAt,
      'med_id': record.medId,
    }).eq('record_id', record.recordId!);
  }

  // DELETE pending records 
  Future<void> deletePendingRecordsForMedFromSupabase(int medId) async {
    await cloud
        .from('intake_records')
        .delete()
        .eq('med_id', medId)
        .eq('status', 'pending');
  }

  // DELETE record
  Future<void> deleteRecordByIdFromSupabase(int recordId) async {
    await cloud.from('intake_records').delete().eq('record_id', recordId);
  }
}
