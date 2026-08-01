// lib/controllers/navigation_controller.dart

import 'package:flutter/material.dart'; // [ADD THIS LINE] Import Material for PageController
import 'package:get/get.dart';
import 'package:reminder_app/controllers/home_controller.dart';
import 'package:reminder_app/controllers/medication_log_controller.dart';
import 'package:reminder_app/controllers/medications_controller.dart';

class NavigationController extends GetxController {
  // Add a PageController to control the PageView transition
  late PageController pageController; // [ADD THIS LINE]

  // Current selected index (4 tabs only)
  final RxInt selectedIndex = 0.obs;

  // List of navigation destinations (4 routes)
  final List<String> routes = [
    '/home',
    '/medications',
    '/medication-log',
    '/profile',
  ];

  // Initialize the PageController
  @override
  void onInit() { // [ADD THIS METHOD]
    super.onInit();
    pageController = PageController();
  }

  // Dispose of the PageController
  @override
  void onClose() { // [ADD THIS METHOD]
    pageController.dispose();
    super.onClose();
  }

  // Navigate to specific index
  void navigateToIndex(int index) {
    if (index == selectedIndex.value) return; // Prevent unnecessary reloads/nav

    // Use pageController to animate the transition
    pageController.animateToPage( // [UPDATE THIS LINE]
      index,
      duration: const Duration(milliseconds: 300), // [ADD THIS LINE] Short animation duration
      curve: Curves.easeOut, // [ADD THIS LINE] Choose your desired curve
    );

    selectedIndex.value = index; // [MOVE THIS LINE] Update index after animation call

    if(index == 2){
      final c = Get.find<MedicationLogController>();
      c.loadLog();
    }
    if(index == 0){
      final c = Get.find<HomeController>();
      c.loadTodayDoses();
    }
    if(index == 1){
      final c = Get.find<MedicationsController>();
      c.loadMedications();
    }
  }

  // Navigate to specific route
  void navigateToRoute(String route) {
    final index = routes.indexOf(route);
    if (index != -1) {
      // Use pageController to navigate
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 450),
        curve: Curves.bounceOut,

      );
      selectedIndex.value = index; // [UPDATE THIS LINE]
    }
  }

  // Get current route
  String get currentRoute => routes[selectedIndex.value];

  // Get current tab name
  String get currentTabName {
    switch (selectedIndex.value) {
      case 0:
        return 'Home';
      case 1:
        return 'Medications';
      case 2:
        return 'Log';
      case 3:
        return 'Profile';
      default:
        return 'Home';
    }
  }
}