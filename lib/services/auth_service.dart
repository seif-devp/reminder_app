import 'package:reminder_app/core/core_exception.dart';
import 'package:reminder_app/core/init_local_db.dart';
import 'package:reminder_app/data/entity/users.dart';
import 'package:reminder_app/data/entity/medications.dart';
import 'package:reminder_app/data/entity/medication_schedule.dart';
import 'package:reminder_app/data/entity/intake_records.dart';
import 'package:reminder_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

class AuthService {
  supabase_flutter.User? get currentUser => cloud.auth.currentUser;
  String? get currentUserId => cloud.auth.currentUser?.id;

  Future<void> logout() async {
    try {
      await cloud.auth.signOut();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  bool get isLoggedIn => currentUser != null;

  Future<void> login(String email, String password) async {
    try {
      await cloud.auth.signInWithPassword(password: password, email: email);
      final supabaseUser = cloud.auth.currentUser;

      if (supabaseUser != null) {
        await saveUserToLocal(supabaseUser, email);
        await syncDataFromSupabase(supabaseUser.id);
      }
    } on supabase_flutter.AuthException catch (e) {
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        throw InvalidCredentialsException();
      } else {
        throw Exception('Authentication error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error occurred: $e');
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    try {
      await cloud.auth.signUp(password: password, email: email);
      final supabaseUser = cloud.auth.currentUser;

      if (supabaseUser != null) {
        await cloud.from('users').insert({
          'user_id': supabaseUser.id,
          'name': fullName,
          'sync_status': 'synced',
        });

        await saveUserToLocal(supabaseUser, email, fullName);
      }
    } on supabase_flutter.AuthException catch (e) {
      if (e.message.toLowerCase().contains('user already registered') ||
          e.message.toLowerCase().contains('email already registered')) {
        throw EmailAlreadyExistsException();
      } else {
        throw Exception('Authentication error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error occurred: $e');
    }
  }

  Future<void> saveUserToLocal(
    supabase_flutter.User supabaseUser,
    String email, [
    String? name,
  ]) async {
    final existingUser = await database.userDao.getUserById(supabaseUser.id);

    if (existingUser == null) {
      try {
        final response = await cloud
            .from('users')
            .select('name, gender, age, blood_type, weight, height')
            .eq('user_id', supabaseUser.id)
            .maybeSingle();

        final user = User(
          userId: supabaseUser.id,
          name: name ?? response?['name'] ?? 'User',
          email: email,
          password: '',
          gender: response?['gender'],
          age: response?['age'],
          bloodType: response?['blood_type'],
          weight: response?['weight'],
          height: response?['height'],
          syncStatus: 'synced',
        );

        await database.userDao.insertUser(user);
      } catch (e) {
        final user = User(
          userId: supabaseUser.id,
          name: name ?? 'User',
          email: email,
          password: '',
          syncStatus: 'synced',
        );
        await database.userDao.insertUser(user);
        print('User saved to local without profile data: $e');
      }
    }
  }

  Future<void> syncDataFromSupabase(String userId) async {
    try {
      // 1. Check if local database is empty
      final localMedications = await database.medicationsDao.getMedicationsByUser(userId);
      
      if (localMedications.isEmpty) {        
        //  2. Sync Medications first
        final medications = await syncMedications(userId);
        
        //  3. Sync Schedules for each medication
        if (medications.isNotEmpty) {
          await syncSchedules(medications);
        }
        
        //  4. Sync Records for each medication
        if (medications.isNotEmpty) {
          await syncRecords(medications);
        }
        
      }
    } catch (e) {
      print('Error syncing data from Supabase: $e');
    }
  }

  // Sync Medications 
  Future<List<Medication>> syncMedications(String userId) async {
    final syncedMedications = <Medication>[];
    
    try {
      final response = await cloud
          .from('medications')
          .select('*')
          .eq('user_id', userId);

      if (response != null && response.isNotEmpty) {
        for (var medData in response) {
          final medication = Medication(
            medId: medData['med_id'],  
            userId: userId,
            name: medData['name'] ?? '',
            dosage: medData['dosage'] ?? '',
            frequency: medData['frequency'] ?? '',
            durationOfUse: medData['duration_of_use'] ?? '',
            notes: medData['notes'],
            imageUrl: medData['image_url'],
            syncStatus: 'synced',
            isDeleted: 'false', 
          );

          await database.medicationsDao.insertMedication(medication);
          syncedMedications.add(medication);
        }

      }
    } catch (e) {
      print('Error syncing medications: $e');
    }
    
    return syncedMedications;
  }

  // Sync Schedules
  Future<void> syncSchedules(List<Medication> medications) async {
    try {

      for (final med in medications) {
        if (med.medId == null) continue;

        final response = await cloud
            .from('medication_schedule')
            .select('*')
            .eq('med_id', med.medId!);

        if (response != null && response.isNotEmpty) {
          for (var scheduleData in response) {
            final schedule = MedicationSchedule(
              scheduleId: scheduleData['schedule_id'], 
              medId: scheduleData['med_id'],
              intakeTime: scheduleData['intake_times'],
              syncStatus: 'synced',
            );

            await database.medicationScheduleDao.insertSchedule(schedule);
          }
        }
      }
    } catch (e) {
      print('Error syncing schedules: $e');
    }
  }

  // Sync Records 
  Future<void> syncRecords(List<Medication> medications) async {
    try {

      for (final med in medications) {
        if (med.medId == null) continue;

        final response = await cloud
            .from('intake_records')
            .select('*')
            .eq('med_id', med.medId!);

        if (response != null && response.isNotEmpty) {
          for (var recordData in response) {
            final record = IntakeRecord(
              recordId: recordData['record_id'], 
              medId: recordData['med_id'],
              scheduledAt: recordData['scheduled_at'],
              takenAt: recordData['taken_at'],
              status: recordData['status'],
              syncStatus: 'synced',
            );

            await database.intakeRecordDao.insertRecord(record);
          }
        }
      }
    } catch (e) {
      print('Error syncing records: $e');
    }
  }
}
