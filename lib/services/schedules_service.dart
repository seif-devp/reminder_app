import 'package:get/get.dart';
import 'package:reminder_app/main.dart';
import 'package:reminder_app/data/entity/medication_schedule.dart';

class SchedulesService extends GetxService {
  // ADD schedule
  Future<void> addScheduleToSupabase(MedicationSchedule schedule) async {
    if (schedule.scheduleId == null) {
      throw Exception('scheduleId must not be null when syncing to Supabase.');
    }

    await cloud.from('medication_schedule').insert({
      'schedule_id': schedule.scheduleId, 
      'med_id': schedule.medId,
      'intake_times': schedule.intakeTime,
    });
  }

  // ADD multiple schedules
  Future<void> addSchedulesToSupabase(List<MedicationSchedule> schedules) async {
    if (schedules.isEmpty) return;

    for (final s in schedules) {
      if (s.scheduleId == null) {
        throw Exception('All schedules must have scheduleId when syncing.');
      }
    }

    final payload = schedules.map((s) => {
      'schedule_id': s.scheduleId,  
      'med_id': s.medId,
      'intake_times': s.intakeTime,
    }).toList();

    await cloud.from('medication_schedule').insert(payload);
  }

  // DELETE schedules for a medication
  Future<void> deleteSchedulesForMedFromSupabase(int medId) async {
    await cloud.from('medication_schedule').delete().eq('med_id', medId);
  }

}
