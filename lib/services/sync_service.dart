import 'package:get/get.dart';
import 'package:reminder_app/core/init_local_db.dart';
import 'package:reminder_app/services/medications_service.dart';
import 'package:reminder_app/services/schedules_service.dart';
import 'package:reminder_app/services/records_service.dart';
import 'package:reminder_app/services/connectivity_service.dart';
import 'package:reminder_app/services/auth_service.dart';
import 'package:reminder_app/services/profile_service.dart';
import 'package:reminder_app/main.dart';
import 'package:reminder_app/data/entity/medication_schedule.dart';
import 'package:reminder_app/data/entity/intake_records.dart';

class SyncService extends GetxService {
  final MedicationsService medsService = Get.find<MedicationsService>();
  final SchedulesService schedulesService = Get.find<SchedulesService>();
  final RecordsService recordsService = Get.find<RecordsService>();
  final ConnectivityService connectivityService =
      Get.find<ConnectivityService>();
  final AuthService authService = Get.find<AuthService>();
  final ProfileService profileService = Get.find<ProfileService>();

  final isSyncing = false.obs;

  /// Sync not_synced
  Future<void> syncAll() async {
    final connected = await connectivityService.connected();
    if (!connected) {
      return;
    }

    final userId = authService.currentUserId;
    if (userId == null || userId.isEmpty) {
      return;
    }

    if (isSyncing.value) {
      return;
    }
    isSyncing.value = true;

    try {
      await syncUsers();
      await syncMedications(userId);
      await syncSchedules();
      await syncRecords();
    } catch (e) {
      print('Sync error: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  // Sync Users
  Future<void> syncUsers() async {
    final unsyncedUsers = await database.userDao.getUsersWithSyncStatus(
      'not_synced',
    );

    if (unsyncedUsers.isEmpty) {
      return;
    }

    for (final user in unsyncedUsers) {
      try {
        await profileService.updateUserOnSupabase(user);
        await database.userDao.updateUserSyncStatus(user.userId, 'synced');
      } catch (e) {
        print('Failed to sync user ${user.name}: $e');
      }
    }
  }

  // Sync Medications
  Future<void> syncMedications(String userId) async {
    // 1) sync  deleted medications
    await syncDeletedMedications();

    // 2) sync  updated/new medications
    final unsyncedMeds = await database.medicationsDao
        .getMedicationsByUserWithStatus(userId, 'not_synced');

    if (unsyncedMeds.isEmpty) {
      return;
    }

    for (final med in unsyncedMeds) {
      try {
        final existsInSupabase = await medicationExistsInSupabase(med.medId!);

        if (existsInSupabase) {
          await medsService.updateMedicationOnSupabase(med);
        } else {
          await medsService.addMedicationToSupabase(med: med, userId: userId);
        }
        await database.medicationsDao.updateMedicationSyncStatus(
          med.medId!,
          'synced',
        );
      } catch (e) {
        print('Failed to sync medication ${med.name}: $e');
      }
    }
  }

  //Sync deleted medications
  Future<void> syncDeletedMedications() async {
    final deletedMeds = await database.medicationsDao
        .getDeletedMedicationsWithStatus('not_synced');

    if (deletedMeds.isEmpty) {
      return;
    }

    for (final med in deletedMeds) {
      try {
        // حذف من Supabase (cascade delete سيحذف schedules و records)
        await medsService.deleteMedicationFromSupabase(med.medId!);

        // Hard delete من Local
        await database.medicationsDao.hardDeleteMedication(med.medId!);
        print('Removed medication from local DB: ${med.name}');
      } catch (e) {
        print('Failed to delete medication ${med.name}: $e');
      }
    }
  }

  /// Sync Schedules -  محسّن ويدعم الـ offline edits
  Future<void> syncSchedules() async {
    final unsyncedSchedules = await database.medicationScheduleDao
        .getSchedulesBySyncStatus('not_synced');

    if (unsyncedSchedules.isEmpty) {
      return;
    }

    //  نجمّع الـ schedules حسب med_id
    final Map<int, List<MedicationSchedule>> schedulesByMed = {};
    for (final s in unsyncedSchedules) {
      if (!schedulesByMed.containsKey(s.medId)) {
        schedulesByMed[s.medId] = [];
      }
      schedulesByMed[s.medId]!.add(s);
    }

    //  لكل دواء، نتعامل مع schedules بتاعته
    for (final medId in schedulesByMed.keys) {
      final medSchedules = schedulesByMed[medId]!;

      try {
        //  نشوف كام schedule موجود في Supabase لنفس الدواء
        final existingSchedulesInSupabase = await getSchedulesCountInSupabase(
          medId,
        );

        //  لو فيه schedules قديمة في Supabase، احذفها
        if (existingSchedulesInSupabase > 0) {
          await schedulesService.deleteSchedulesForMedFromSupabase(medId);
        }
        // INSERT كل الـ schedules الجديدة
        await schedulesService.addSchedulesToSupabase(medSchedules);

        // تحديث sync status
        for (final s in medSchedules) {
          await database.medicationScheduleDao.updateSyncStatus(
            s.scheduleId!,
            'synced',
          );
        }
      } catch (e) {
        print('Failed to sync schedules for med_id $medId: $e');
      }
    }
  }

  /// Sync Records -  محسّن ويدعم الـ offline edits
  Future<void> syncRecords() async {
    final unsyncedRecords = await database.intakeRecordDao
        .getRecordsBySyncStatus('not_synced');

    if (unsyncedRecords.isEmpty) {
      return;
    }

    //  نفرق بين New Records و Updated Records
    final newRecords = unsyncedRecords
        .where(
          (r) =>
              r.status == 'pending' &&
              (r.takenAt == null || r.takenAt!.isEmpty),
        )
        .toList();

    final updatedRecords = unsyncedRecords
        .where(
          (r) =>
              r.status != 'pending' ||
              (r.takenAt != null && r.takenAt!.isNotEmpty),
        )
        .toList();

    //  1. معالجة الـ NEW RECORDS (pending)
    if (newRecords.isNotEmpty) {
      // نجمّع الـ new records حسب med_id
      final Map<int, List<IntakeRecord>> newRecordsByMed = {};
      for (final r in newRecords) {
        if (!newRecordsByMed.containsKey(r.medId)) {
          newRecordsByMed[r.medId] = [];
        }
        newRecordsByMed[r.medId]!.add(r);
      }

      // لكل دواء، نتعامل مع records بتاعته
      for (final medId in newRecordsByMed.keys) {
        final medRecords = newRecordsByMed[medId]!;

        try {
          //  نشوف كام pending record موجود في Supabase لنفس الدواء
          final existingPendingRecordsInSupabase =
              await getPendingRecordsCountInSupabase(medId);

          //  لو فيه pending records قديمة في Supabase، احذفها
          if (existingPendingRecordsInSupabase > 0) {
            await recordsService.deletePendingRecordsForMedFromSupabase(medId);
          }

          // INSERT كل الـ records الجديدة
          await recordsService.addRecordsToSupabase(medRecords);

          // تحديث sync status
          for (final r in medRecords) {
            await database.intakeRecordDao.updateSyncStatus(
              r.recordId!,
              'synced',
            );
          }
        } catch (e) {
          print('Failed to sync pending records for med_id $medId: $e');
        }
      }
    }

    //  2. UPDATE الـ records المعدلة (taken/missed)
    if (updatedRecords.isNotEmpty) {
      for (final r in updatedRecords) {
        try {
          await recordsService.updateRecordStatusOnSupabase(r);
          await database.intakeRecordDao.updateSyncStatus(
            r.recordId!,
            'synced',
          );
        } catch (e) {
          print('Failed to update record ${r.recordId}: $e');
        }
      }
    }
  }

  ///  دالة مساعدة: تحقق من وجود medication في Supabase
  Future<bool> medicationExistsInSupabase(int medId) async {
    try {
      final response = await cloud
          .from('medications')
          .select('med_id')
          .eq('med_id', medId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  ///  دالة مساعدة: احصل على عدد schedules موجودة في Supabase لدواء معين
  Future<int> getSchedulesCountInSupabase(int medId) async {
    try {
      final response = await cloud
          .from('medication_schedule')
          .select('schedule_id')
          .eq('med_id', medId);

      if (response == null) return 0;
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  ///  دالة مساعدة: احصل على عدد pending records موجودة في Supabase لدواء معين
  Future<int> getPendingRecordsCountInSupabase(int medId) async {
    try {
      final response = await cloud
          .from('intake_records')
          .select('record_id')
          .eq('med_id', medId)
          .eq('status', 'pending');

      if (response == null) return 0;
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }
}
