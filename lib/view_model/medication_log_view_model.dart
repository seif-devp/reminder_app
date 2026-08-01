import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/core_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/connectivity_service.dart';

class MedicationLogController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final ConnectivityService connectivityService =
  Get.find<ConnectivityService>();

  RxInt takenDoses = 0.obs;
  RxInt missedDoses = 0.obs;
  RxDouble adherence = 0.0.obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLogData();
  }

  Future<void> fetchLogData() async {
    isLoading.value = true;
    try {
      final connected = await connectivityService.connected();
      if (!connected) {
        Get.snackbar(
          'Error',
          'No internet connection',
          backgroundColor: Colors.red,
        );
        isLoading.value = false;
        return;
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Error',
          'User not authenticated',
          backgroundColor: Colors.red,
        );
        isLoading.value = false;
        return;
      }

      // Fetch all medications for this user
      final medsRes = await Supabase.instance.client
          .from('medications')
          .select('med_id')
          .eq('user_id', user.id);

      final List medData = medsRes as List;
      final medIds = medData.map((m) => m['med_id'] as int).toList();

      // Only run the next query if medIds is not empty
      if (medIds.isEmpty) {
        takenDoses.value = 0;
        missedDoses.value = 0;
        adherence.value = 0.0;
        isLoading.value = false;
        return;
      }

      // Fetch intake_records for these medIds and count statuses in Dart
      final recordsList = await Supabase.instance.client
          .from('intake_records')
          .select('status')
          .filter('med_id', 'in', '(${medIds.join(",")})');

      int taken = 0, missed = 0;
      for (final row in recordsList as List) {
        if (row['status'] == 'taken') taken++;
        if (row['status'] == 'missed') missed++;
      }

      takenDoses.value = taken;
      missedDoses.value = missed;
      adherence.value = (taken + missed) > 0
          ? (taken / (taken + missed)) * 100
          : 0;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch log data',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
