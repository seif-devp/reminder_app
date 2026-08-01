// lib/controllers/notification_controller.dart

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/core/init_local_db.dart';
import 'package:reminder_app/data/entity/intake_records.dart';
import 'package:reminder_app/services/notification_service.dart';
import 'package:reminder_app/services/connectivity_service.dart';
import 'package:reminder_app/services/records_service.dart';
import 'package:reminder_app/services/tts_service.dart';

/// Main notification action handler (MUST be top-level function)
@pragma("vm:entry-point")
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  print('🔔 Notification action received: ${receivedAction.buttonKeyPressed}');
  print('🔔 Payload: ${receivedAction.payload}');

  // Extract payload
  final recordIdStr = receivedAction.payload?['recordId'];
  final medicationName = receivedAction.payload?['medicationName'] ?? 'medication';

  if (recordIdStr == null) {
    print('❌ Error: recordId not found in payload');
    return;
  }

  final recordId = int.tryParse(recordIdStr);
  if (recordId == null) {
    print('❌ Error: Invalid recordId');
    return;
  }

  print('✅ RecordId: $recordId');

  // Handle action
  try {
    switch (receivedAction.buttonKeyPressed) {
      case 'MARK_TAKEN':
        await markAsTakenFromNotification(recordId, medicationName);
        break;
      // case 'MARK_MISSED':
      //   await markAsMissedFromNotification(recordId, medicationName);
      //   break;
      default:
        // User tapped notification body - Navigate to HomePage
        print('ℹ️ Notification body tapped - Opening app');
        Get.offAllNamed('/home');
        break;
    }
  } catch (e) {
    print('❌ Error handling notification action: $e');
  }
}

/// Mark medication as taken (top-level function)
@pragma("vm:entry-point")
Future<void> markAsTakenFromNotification(int recordId, String medicationName) async {
  try {
    print('📝 Attempting to mark record $recordId as taken');
    
    // Get the record
    final allRecords = await database.intakeRecordDao.getAllRecords();
    print('📊 Total records in DB: ${allRecords.length}');
    
    final record = allRecords.firstWhere(
      (r) => r.recordId == recordId,
      orElse: () => throw Exception('Record not found'),
    );
    
    print('✅ Found record: ${record.recordId}');

    // Update to taken
    final updated = IntakeRecord(
      recordId: record.recordId,
      medId: record.medId,
      scheduledAt: record.scheduledAt,
      takenAt: DateTime.now().toIso8601String(),
      status: 'taken',
      syncStatus: 'not_synced',
    );

    await database.intakeRecordDao.updateRecord(updated);
    print('✅ Updated record in database');

    // Sync with Supabase if online
    try {
      final connectivityService = ConnectivityService();
      final isOnline = await connectivityService.connected();
      
      if (isOnline) {
        final recordsService = RecordsService();
        await recordsService.updateRecordStatusOnSupabase(updated);
        await database.intakeRecordDao.updateSyncStatus(recordId, 'synced');
        print('✅ Synced with Supabase');
      } else {
        print('ℹ️ Offline - will sync later');
      }
    } catch (e) {
      print('⚠️ Failed to sync: $e');
    }

    // Cancel notification
    final notificationService = NotificationService();
    await notificationService.cancelNotification(recordId);
    print('✅ Cancelled notification');

// Show success notification
// Show success notification
await AwesomeNotifications().createNotification(
  content: NotificationContent(
    id: -1,
    channelKey: 'confirmation_channel',
    title: '✓ Marked as Taken', // ✅ English
    body: 'You took $medicationName successfully', // ✅ English
    notificationLayout: NotificationLayout.Default,
    backgroundColor: const Color(0xFF4CAF50),
    autoDismissible: true,
    category: NotificationCategory.Status,
  ),
);



    print('✅ Successfully marked as taken');
  } catch (e) {
    print('❌ Error marking as taken: $e');
    // Show error notification
await AwesomeNotifications().createNotification(
  content: NotificationContent(
    id: -2,
    channelKey: 'confirmation_channel',
    title: '✗ Error', // ✅ English
    body: 'Failed to mark medication: ${e.toString()}', // ✅ English
    notificationLayout: NotificationLayout.Default,
    backgroundColor: const Color(0xFFE57373),
    autoDismissible: true,
    category: NotificationCategory.Error,
  ),
);

  }
}

// /// Mark medication as missed (top-level function)
// @pragma("vm:entry-point")
// Future<void> markAsMissedFromNotification(int recordId, String medicationName) async {
//   try {
//     print('📝 Attempting to mark record $recordId as missed');
    
//     // Get the record
//     final allRecords = await database.intakeRecordDao.getAllRecords();
//     final record = allRecords.firstWhere(
//       (r) => r.recordId == recordId,
//       orElse: () => throw Exception('Record not found'),
//     );

//     // Update to missed
//     final updated = IntakeRecord(
//       recordId: record.recordId,
//       medId: record.medId,
//       scheduledAt: record.scheduledAt,
//       takenAt: record.takenAt,
//       status: 'missed',
//       syncStatus: 'not_synced',
//     );

//     await database.intakeRecordDao.updateRecord(updated);
//     print('✅ Updated record in database');

//     // Sync with Supabase if online
//     try {
//       final connectivityService = ConnectivityService();
//       final isOnline = await connectivityService.connected();
      
//       if (isOnline) {
//         final recordsService = RecordsService();
//         await recordsService.updateRecordStatusOnSupabase(updated);
//         await database.intakeRecordDao.updateSyncStatus(recordId, 'synced');
//         print('✅ Synced with Supabase');
//       } else {
//         print('ℹ️ Offline - will sync later');
//       }
//     } catch (e) {
//       print('⚠️ Failed to sync: $e');
//     }

//     // Cancel notification
//     final notificationService = NotificationService();
//     await notificationService.cancelNotification(recordId);
//     print('✅ Cancelled notification');

//     // Show info notification
// // Show info notification
// await AwesomeNotifications().createNotification(
//   content: NotificationContent(
//     id: -3,
//     channelKey: 'confirmation_channel',
//     title: 'Marked as Missed', // ✅ English
//     body: 'You missed $medicationName', // ✅ English
//     notificationLayout: NotificationLayout.Default,
//     backgroundColor: const Color(0xFFFF9800),
//     autoDismissible: true,
//     category: NotificationCategory.Status,
//   ),
// );


//     print('✅ Successfully marked as missed');
//   } catch (e) {
//     print('❌ Error marking as missed: $e');
//   }
// }

/// Notification created callback
@pragma("vm:entry-point")
Future<void> onNotificationCreatedMethod(ReceivedNotification notification) async {
  print('📩 Notification created: ${notification.id}');
}

@pragma("vm:entry-point")
Future<void> onNotificationDisplayedMethod(ReceivedNotification notification) async {
  print('📱 Notification displayed: ${notification.id}');
  
  try {
    final medicationName = notification.payload?['medicationName'];
    
    if (medicationName != null && medicationName.isNotEmpty) {
      // ✅ Wait for alarm to finish (adjust based on your alarm length)
      // If your alarm is 5 seconds → use Duration(seconds: 6)
      // If your alarm is 10 seconds → use Duration(seconds: 11)
      await Future.delayed(const Duration(seconds: 3));
      
      final ttsService = TtsService();
      
      // ✅ Speak 3 times for emphasis
      await ttsService.speakMedicationReminder(medicationName);
      // await Future.delayed(const Duration(seconds: 3));
      // await ttsService.speakMedicationReminder(medicationName);
      // await Future.delayed(const Duration(seconds: 3));
      // await ttsService.speakMedicationReminder(medicationName);
      // await Future.delayed(const Duration(seconds: 3));
      // await ttsService.speakMedicationReminder(medicationName);
      // await Future.delayed(const Duration(seconds: 3));
      // await ttsService.speakMedicationReminder(medicationName);
      // await Future.delayed(const Duration(seconds: 3));
      // await ttsService.speakMedicationReminder(medicationName);
    }
  } catch (e) {
    print('⚠️ TTS failed: $e');
  }
}



/// Notification dismissed callback
@pragma("vm:entry-point")
Future<void> onDismissActionReceivedMethod(ReceivedAction action) async {
  print('🗑️ Notification dismissed: ${action.id}');
}
