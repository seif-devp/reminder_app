// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter/material.dart';


// class NotificationService {
//   Future<void> initialize() async {
//     await AwesomeNotifications().initialize(
//       null,
//       [
//         NotificationChannel(
//           channelKey: 'reminder_channel',
//           channelName: 'Reminders',
//           channelDescription: 'Notification channel for reminders',
//           defaultColor: const Color(0xFF9D50DD),
//           ledColor: Colors.white,
//           importance: NotificationImportance.High,
//           channelShowBadge: true,
//           playSound: true,
//           enableVibration: true,
//         ),
//       ],
//     );
//   }

//   Future<void> takePermission() async {
//     bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
//     if (!isAllowed) {
//       await AwesomeNotifications().requestPermissionToSendNotifications();
//     }
//   }

//   Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime dateTime,
//   }) async {

//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: id, // نستخدم الـ ID القادم من الداتابيز مباشرة
//         channelKey: 'reminder_channel',
//         title: title,
//         body: body,
//         notificationLayout: NotificationLayout.Default,
//         category: NotificationCategory.Reminder,
//         wakeUpScreen: true,
//         autoDismissible: false,
//       ),
//       schedule: NotificationCalendar(
//         year: dateTime.year,
//         month: dateTime.month,
//         day: dateTime.day,
//         hour: dateTime.hour,
//         minute: dateTime.minute,
//         second: 0,
//         millisecond: 0,
//         repeats: false,
//         allowWhileIdle: true,
//         preciseAlarm: true,
//       ),
//     );
//   }
// }


import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:reminder_app/core/init_local_db.dart';
import 'package:reminder_app/data/entity/medications.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  final box=GetStorage();
  final String _dndKey = 'is_dnd_active';

Future<void> initialize() async {
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'reminder_channel',
        channelName: 'Medication Reminders',
        channelDescription: 'Notification channel for medication reminders',
        defaultColor: const Color(0xFF4FC3F7),
        ledColor: Colors.white,
        importance: NotificationImportance.Max,  
        channelShowBadge: true,
        playSound: true,
        soundSource: 'resource://raw/medication_alarm',    
        enableVibration: true,
        enableLights: true,
        criticalAlerts: true,
        locked: true, 
      ),
      NotificationChannel(
        channelKey: 'confirmation_channel',
        channelName: 'Confirmations',
        channelDescription: 'Notification channel for confirmations',
        defaultColor: const Color(0xFF4CAF50),
        ledColor: Colors.white,
        importance: NotificationImportance.Default, // ✅ عادي مش Max
        channelShowBadge: false,
        playSound: true, // ✅ صوت notification عادي
        enableVibration: false, // ✅ بدون vibration
        enableLights: false,
      ),
    ],
  );
}


  Future<void> takePermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

Future<void> scheduleNotification({
  required int id,
  required String title,
  required String body,
  required DateTime dateTime,
  required int medId,
  required String medicationName,
}) async {
  bool isDnd = box.read(_dndKey) ?? false;

  if (isDnd) {
    print('🚫 Notification Skipped: DND mode is ON');
    return;
  }
  print('🔔 Scheduling notification:');
  print('   ID: $id');
  print('   Medication: $medicationName');
  
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: id,
      channelKey: 'reminder_channel',
      title: 'Medication Reminder 💊', // ✅ English
      body: '-$body-', // ✅ English
      notificationLayout: NotificationLayout.Default,
      category: NotificationCategory.Alarm,
      wakeUpScreen: true,
      fullScreenIntent: true,
      autoDismissible: false,
      locked: true,
      criticalAlert: true,
      payload: {
        'recordId': id.toString(),
        'medId': medId.toString(),
        'medicationName': medicationName,
      },
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'MARK_TAKEN',
        label: '✓ Taken', // ✅ English
        actionType: ActionType.SilentAction,
        autoDismissible: true,
        color: const Color(0xFF4CAF50),
      ),
      // NotificationActionButton(
      //   key: 'MARK_MISSED',
      //   label: '✗ Missed', // ✅ English
      //   actionType: ActionType.SilentAction,
      //   autoDismissible: true,
      //   color: const Color(0xFFE57373),
      // ),
    ],
    schedule: NotificationCalendar(
      year: dateTime.year,
      month: dateTime.month,
      day: dateTime.day,
      hour: dateTime.hour,
      minute: dateTime.minute,
      second: 0,
      millisecond: 0,
      repeats: false,
      allowWhileIdle: true,
      preciseAlarm: true,
    ),
  );

  print('✅ Notification scheduled successfully');
}



  /// Cancel single notification by ID
  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  /// Cancel all notifications for a specific medication
  Future<void> cancelMedicationNotifications(int medId) async {
    try {
      final records = await database.intakeRecordDao.getRecordsByMedId(medId);
      for (final record in records) {
        if (record.recordId != null && record.status == 'pending') {
          await cancelNotification(record.recordId!);
        }
      }
    } catch (e) {
      print('Error canceling medication notifications: $e');
    }
  }

  /// Reschedule notifications after editing medication schedule
  Future<void> rescheduleMedicationNotifications(Medication med) async {
    try {
      // 1. Cancel all old pending notifications
      await cancelMedicationNotifications(med.medId!);

      // 2. Get all pending records
      final records = await database.intakeRecordDao.getRecordsByMedId(med.medId!);
      final pendingRecords = records.where((r) => r.status == 'pending').toList();

      // 3. Schedule new notifications
      for (final record in pendingRecords) {
        if (record.recordId != null) {
          final scheduledTime = DateTime.parse(record.scheduledAt);
          
          // Only schedule if in the future
          if (scheduledTime.isAfter(DateTime.now())) {
            await scheduleNotification(
              id: record.recordId!,
              title: 'Medication Reminder 💊',
              body: 'Time to take ${med.name} - ${med.dosage}',
              dateTime: scheduledTime,
              medId: med.medId!,
              medicationName: med.name,
            );
          }
        }
      }
    } catch (e) {
      print('Error rescheduling notifications: $e');
    }
  }

  /// Schedule all notifications for new medication
  Future<void> scheduleAllNotificationsForMedication(
    Medication med,
    List<int> recordIds,
  ) async {
    try {
      final records = await database.intakeRecordDao.getRecordsByMedId(med.medId!);
      
      for (final record in records) {
        if (record.recordId != null && record.status == 'pending') {
          final scheduledTime = DateTime.parse(record.scheduledAt);
          
          // Only schedule if in the future
          if (scheduledTime.isAfter(DateTime.now())) {
            await scheduleNotification(
              id: record.recordId!,
              title: 'Medication Reminder 💊',
              body: 'Time to take ${med.name} - ${med.dosage}',
              dateTime: scheduledTime,
              medId: med.medId!,
              medicationName: med.name,
            );
          }
        }
      }
    } catch (e) {
      print('Error scheduling notifications: $e');
    }
  }

  /// Cancel all app notifications
  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().dismissAllNotifications();
    await AwesomeNotifications().cancelAll();
  }
  bool get currentDndStatus => box.read(_dndKey) ?? false;

  Future<void> enableDonotdisturb()
  async {
  box.write(_dndKey, true);
      await cancelAllNotifications();
    }
    Future<void> disableDonotdisturb(String userId)
    async {
      box.write(_dndKey, false);
      try {
        final allMeds = await database.medicationsDao.getMedicationsByUser(userId);
        for (var med in allMeds) {
          await rescheduleMedicationNotifications(med);
        }
      } catch (e) {
        print("Error restarting reminders: $e");
      }
    }

}
