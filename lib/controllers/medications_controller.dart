import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/core/init_local_db.dart';
import 'package:reminder_app/data/entity/medications.dart';
import 'package:reminder_app/data/entity/medication_schedule.dart';
import 'package:reminder_app/data/entity/intake_records.dart';
import 'package:reminder_app/services/auth_service.dart';
import 'package:reminder_app/services/connectivity_service.dart';
import 'package:reminder_app/services/medications_service.dart';
import 'package:reminder_app/services/notification_service.dart';
import 'package:reminder_app/services/schedules_service.dart';
import 'package:reminder_app/services/records_service.dart';

class MedicationsController extends GetxController {
  final medications = <Medication>[].obs;
  final nextDoseTimes = <int, String>{}.obs;
  final editDoseTimes = <TimeOfDay>[].obs;
  final editFrequency = ''.obs;
  final isLoading = false.obs;
  final AuthService authService = Get.find<AuthService>();
  final connectivityService = Get.find<ConnectivityService>();
  final medicationsService = Get.find<MedicationsService>();
  final schedulesService = Get.find<SchedulesService>();
  final recordsService = Get.find<RecordsService>();



  @override
  void onInit() {
    super.onInit();
    loadMedications();
  }

  Future<void> loadMedications() async {
    final userId = authService.currentUserId;
    if (userId == null || userId.isEmpty) return;

    isLoading.value = true;
    try {
      final list = await database.medicationsDao.getMedicationsByUser(userId);
      medications.assignAll(list);

      nextDoseTimes.clear();
      for (final med in list) {
        if (med.medId == null) continue;
        final schedules =
            await database.medicationScheduleDao.getSchedulesByMedId(med.medId!);
        if (schedules.isNotEmpty) {
          schedules.sort((a, b) => a.intakeTime.compareTo(b.intakeTime));
          nextDoseTimes[med.medId!] = schedules.first.intakeTime;
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

Future<void> deleteMedication(Medication med) async {
  if (med.medId == null) return;
  
  final isOnline = await connectivityService.connected();
  
  if (isOnline) {
    try {
      await medicationsService.deleteMedicationFromSupabase(med.medId!);
      
      // ✅ أضف الكود هنا - قبل hardDelete
      try {
        final notificationService = NotificationService();
        await notificationService.cancelMedicationNotifications(med.medId!);
        print('✓ Cancelled notifications for medication');
      } catch (e) {
        print('Failed to cancel notifications: $e');
      }
      
      // Hard delete Local
      await database.medicationsDao.hardDeleteMedication(med.medId!);
    } catch (e) {
      print('Failed to delete medication from Supabase: $e');
    }
    // Supabase soft delete
    await database.medicationsDao.markAsDeleted(med.medId!, 'not_synced');
  } else {
    // ✅ وأضفه هنا كمان - في الـelse block
    try {
      final notificationService = NotificationService();
      await notificationService.cancelMedicationNotifications(med.medId!);
      print('✓ Cancelled notifications for medication');
    } catch (e) {
      print('Failed to cancel notifications: $e');
    }
    
    // soft delete: mark as deleted
    await database.medicationsDao.markAsDeleted(med.medId!, 'not_synced');
  }
  
  // 2- UI
  if (med.medId != null) nextDoseTimes.remove(med.medId);
  await loadMedications();
  
  Get.snackbar(
    'Success',
    'Medication deleted successfully',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.green,
    colorText: Colors.white,
    duration: const Duration(seconds: 2),
  );
}



  Future<void> updateMedication(
    Medication med, {
    required String name,
    required String dosage,
    required String frequency,
    required String duration,
    required String notes,
  }) async {
    final updated = Medication(
      medId: med.medId,
      userId: med.userId,
      name: name,
      dosage: dosage,
      frequency: frequency,
      durationOfUse: duration,
      notes: notes.isNotEmpty ? notes : null,
      imageUrl: med.imageUrl,
      syncStatus: 'not_synced',
      isDeleted: med.isDeleted,
    );
    
    await database.medicationsDao.updateMedication(updated);
    
    final isOnline = await connectivityService.connected();
    if (isOnline) {
      try {
        await medicationsService.updateMedicationOnSupabase(updated);
        await database.medicationsDao.updateMedicationSyncStatus(
          updated.medId!,
          'synced',
        );
        print('✅ Medication updated on Supabase immediately');
      } catch (e) {
        print('⚠️ Failed to sync medication update: $e');
      }
    }

    await loadMedications();
  }

  Future<void> loadScheduleForEdit(Medication med) async {
    editDoseTimes.clear();
    editFrequency.value = med.frequency;
    if (med.medId == null) return;

    final schedules =
        await database.medicationScheduleDao.getSchedulesByMedId(med.medId!);
    for (final s in schedules) {
      final parts = s.intakeTime.split(':');
      if (parts.length != 2) continue;
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h == null || m == null) continue;
      editDoseTimes.add(TimeOfDay(hour: h, minute: m));
    }

    editDoseTimes.sort((a, b) {
      final aM = a.hour * 60 + a.minute;
      final bM = b.hour * 60 + b.minute;
      return aM.compareTo(bM);
    });
  }

  void addDoseTimeForEdit(TimeOfDay time) {
    final max = maxDoseTimesAllowedForEdit;
    if (max > 0 && editDoseTimes.length >= max) {
      Get.snackbar(
        'Limit reached',
        'You can only add $max dose times for this frequency',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final exists = editDoseTimes.any(
      (t) => t.hour == time.hour && t.minute == time.minute,
    );
    if (!exists) {
      editDoseTimes.add(time);
      editDoseTimes.sort((a, b) {
        final aM = a.hour * 60 + a.minute;
        final bM = b.hour * 60 + b.minute;
        return aM.compareTo(bM);
      });
    }
  }

  void removeDoseTimeForEdit(int index) {
    if (index >= 0 && index < editDoseTimes.length) {
      editDoseTimes.removeAt(index);
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  String formatTimeForDB(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

Future<void> saveEditedSchedule(Medication med) async {
  if (med.medId == null) return;
  
  isLoading.value = true;
  
  try {
    // 1. Update medication with new frequency
    final updated = Medication(
      medId: med.medId,
      userId: med.userId,
      name: med.name,
      dosage: med.dosage,
      frequency: editFrequency.value,
      durationOfUse: med.durationOfUse,
      notes: med.notes,
      imageUrl: med.imageUrl,
      syncStatus: 'not_synced',
      isDeleted: med.isDeleted,
    );
    
    await database.medicationsDao.updateMedication(updated);
    
    // 2. Get services
    final isOnline = await connectivityService.connected();
    
    // 3. Sync with Supabase if online
    if (isOnline) {
      try {
        // Delete old schedules from Supabase
        await schedulesService.deleteSchedulesForMedFromSupabase(med.medId!);
        
        // Update medication on Supabase
        await medicationsService.updateMedicationOnSupabase(updated);
        
        // Update sync status
        await database.medicationsDao.updateMedicationSyncStatus(
          updated.medId!,
          'synced',
        );
      } catch (e) {
        print('Failed to delete old schedules from Supabase: $e');
      }
    }
    
    // 4. Delete old schedules from local DB
    await database.medicationScheduleDao.deleteSchedulesByMedId(med.medId!);
    
    // 5. Insert new schedules
    for (final t in editDoseTimes) {
      final schedule = MedicationSchedule(
        scheduleId: null,
        medId: med.medId!,
        intakeTime: formatTimeForDB(t),
        syncStatus: 'not_synced',
      );
      await database.medicationScheduleDao.insertSchedule(schedule);
    }
    
    // 6. Get saved schedules
    final savedSchedules = await database.medicationScheduleDao
        .getSchedulesByMedId(med.medId!);
    
    // 7. Sync new schedules if online
    if (isOnline && savedSchedules.isNotEmpty) {
      try {
        await schedulesService.addSchedulesToSupabase(savedSchedules);
        
        // Update sync status for each schedule
        for (final s in savedSchedules) {
          await database.medicationScheduleDao.updateSyncStatus(
            s.scheduleId!,
            'synced',
          );
        }
        print('Schedules synced to Supabase immediately');
      } catch (e) {
        print('Failed to sync new schedules: $e');
      }
    }
    
    // 8. Update intake records
    await updateIntakeRecordsForEditedSchedule(
      med.medId!,
      med.durationOfUse,
    );
    
    // 9. Reschedule notifications
try {
  final notificationService = NotificationService();
  
  // Get the updated medication from database...
  final allMeds = await database.medicationsDao.getMedicationsByUser(med.userId!);
  final updatedMed = allMeds.firstWhere(
    (m) => m.medId == med.medId,
    orElse: () => updated,  // ✅ حل المشكلة هنا
  );
  
  // Cancel old notifications and schedule new ones
  await notificationService.rescheduleMedicationNotifications(updatedMed);
  print('✅ Rescheduled notifications after edit');
} catch (e, st) {
  print('Failed to reschedule notifications: $e');
  print(st);
}

    
    // 10. Reload medications
    await loadMedications();
    
  } finally {
    isLoading.value = false;
  }
}


  Future<void> updateIntakeRecordsForEditedSchedule(
    int medId,
    String durationOfUse,
  ) async {
    final isOnline = await connectivityService.connected();

    final allRecords = await database.intakeRecordDao.getRecordsByMedId(medId);
    
    if (allRecords.isEmpty) {
      print('⚠️ No records found for medication $medId');
      return;
    }

    allRecords.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final firstRecord = allRecords.first;
    final startDate = DateTime.parse(firstRecord.scheduledAt);
    final startDay = DateTime(startDate.year, startDate.month, startDate.day);

    final today = DateTime.now();
    final currentDay = DateTime(today.year, today.month, today.day);
    final daysPassed = currentDay.difference(startDay).inDays;

    final totalDays = durationInDays(durationOfUse);
    final remainingDays = totalDays - daysPassed;

    print('📊 Duration: $totalDays days, Passed: $daysPassed days, Remaining: $remainingDays days');

    final pendingRecords = allRecords.where((r) => r.status == 'pending').toList();
    
    if (isOnline && pendingRecords.isNotEmpty) {
      try {
        for (final r in pendingRecords) {
          if (r.recordId != null) {
            await recordsService.deleteRecordByIdFromSupabase(r.recordId!);
          }
        }
        print('✅ Deleted ${pendingRecords.length} pending records from Supabase');
      } catch (e) {
        print('⚠️ Failed to delete pending records from Supabase: $e');
      }
    }

    for (final r in pendingRecords) {
      await database.intakeRecordDao.deleteRecord(r);
    }

    if (remainingDays <= 0) {
      print('✅ Medication duration completed. No new records needed.');
      return;
    }

    final List<IntakeRecord> newRecords = [];

    for (int d = 0; d < remainingDays; d++) {
      final day = currentDay.add(Duration(days: d));
      
      for (final t in editDoseTimes) {
        final scheduled = DateTime(
          day.year,
          day.month,
          day.day,
          t.hour,
          t.minute,
        );
        
        if (scheduled.isBefore(DateTime.now())) {
          continue;
        }

        newRecords.add(
          IntakeRecord(
            recordId: null,
            medId: medId,
            scheduledAt: scheduled.toIso8601String(),
            takenAt: null,
            status: 'pending',
            syncStatus: 'not_synced',
          ),
        );
      }
    }

    if (newRecords.isNotEmpty) {
      await database.intakeRecordDao.insertRecords(newRecords);
      print('✅ Created ${newRecords.length} new records for remaining $remainingDays days');

      if (isOnline) {
        try {
          final savedRecords = await database.intakeRecordDao.getRecordsByMedId(medId);
          final newlyCreatedRecords = savedRecords
              .where((r) => r.status == 'pending' && r.syncStatus == 'not_synced')
              .toList();

          if (newlyCreatedRecords.isNotEmpty) {
            await recordsService.addRecordsToSupabase(newlyCreatedRecords);
            
            for (final r in newlyCreatedRecords) {
              await database.intakeRecordDao.updateSyncStatus(
                r.recordId!,
                'synced',
              );
            }
            print('✅ ${newlyCreatedRecords.length} new records synced to Supabase immediately');
          }
        } catch (e) {
          print('⚠️ Failed to sync new records: $e');
        }
      }
    } else {
      print('ℹ️ No new records to create (all times in the past)');
    }
  }

  int durationInDays(String value) {
    switch (value) {
      case '7 days':
        return 7;
      case '14 days':
        return 14;
      case '30 days':
        return 30;
      case '90 days':
        return 90;
      case 'Ongoing':
        return 90;
      default:
        return 30;
    }
  }

  String formatTimeForDisplay(String hhmm) {
    try {
      final parts = hhmm.split(':');
      if (parts.length != 2) return hhmm;
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final dt = DateTime(2020, 1, 1, h, m);
      final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour < 12 ? 'AM' : 'PM';
      return '$hour12:$minute $period';
    } catch (_) {
      return hhmm;
    }
  }

  int get maxDoseTimesAllowedForEdit {
    switch (editFrequency.value) {
      case 'Once daily':
        return 1;
      case 'Twice daily (2x/day)':
        return 2;
      case 'Three times daily (3x/day)':
        return 3;
      case 'Four times daily (4x/day)':
        return 4;
      case 'As needed':
        return 0;
      default:
        return 0;
    }
  }
}
