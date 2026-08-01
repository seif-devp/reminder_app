import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeViewModel extends GetxController {
  var currentTime = "".obs;
  var currentDate = "".obs;
  var currentIndex = 0.obs;

  Timer? timer;

  // Medication reactive states
  var aspirinTaken = false.obs;
  var aspirinPending = true.obs;   // Added reactive "pending" state

  @override
  void onInit() {
    super.onInit();
    _updateTime();

    // Update every 30 seconds (to keep time current)
    timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    currentTime.value = DateFormat('hh:mm a').format(DateTime.now());
    currentDate.value = DateFormat('EEEE, MMMM d').format(DateTime.now());
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  // Mark aspirin as taken, update both reactive bools
  void markAspirinAsTaken() {
    aspirinTaken.value = true;
    aspirinPending.value = false;
  }

  // Handle tab change
  void changeTab(int index) {
    currentIndex.value = index;
  }
}