// lib/presentation/navigation/main_navigation.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/navigation_controller.dart';
import 'package:reminder_app/views/home_page.dart';
import 'package:reminder_app/views/medication_log_page.dart';
import 'package:reminder_app/views/medications_page.dart';
import 'package:reminder_app/views/profile_page.dart';

class MainNavigation extends GetView<NavigationController> {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ✅ List of pages (4 tabs only)
    final List<Widget> pages = [
        HomePage(),
        MedicationsPage(),
        MedicationLogPage(),
        ProfilePage(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: pages,
        ),
        
        // ✅ FloatingActionButton (Chatbot)
        // floatingActionButton: Container(
        //   width: 60,
        //   height: 60,
        //   decoration: BoxDecoration(
        //     shape: BoxShape.circle,
        //     gradient: const LinearGradient(
        //       colors: [
        //         Color(0xFF4FC3F7),
        //         Color(0xFF81D4FA),
        //       ],
        //       begin: Alignment.topLeft,
        //       end: Alignment.bottomRight,
        //     ),
        //     boxShadow: [
        //       BoxShadow(
        //         color: const Color(0xFF4FC3F7).withOpacity(0.4),
        //         blurRadius: 12,
        //         offset: const Offset(0, 4),
        //         spreadRadius: 1,
        //       ),
        //     ],
        //   ),
        //   child: Material(
        //     color: Colors.transparent,
        //     child: InkWell(
        //       borderRadius: BorderRadius.circular(30),
        //       onTap: () => Get.toNamed('/chatbot'),
        //       child: const Center(
        //         child: Icon(
        //           Icons.smart_toy_rounded,
        //           color: Colors.white,
        //           size: 28,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        
        // ✅ NavigationBar (4 destinations)
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: NavigationBar(
              selectedIndex: controller.selectedIndex.value,
              onDestinationSelected: controller.navigateToIndex,
              backgroundColor: theme.cardColor,
              indicatorColor: theme.primaryColor.withOpacity(0.15),
              height: 70,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              animationDuration: const Duration(milliseconds: 400),
              destinations: [
                NavigationDestination(
                  icon: Icon(
                    Icons.home_outlined,
                    color: controller.selectedIndex.value == 0
                        ? theme.primaryColor
                        : Colors.grey[500],
                  ),
                  selectedIcon: Icon(
                    Icons.home_rounded,
                    color: theme.primaryColor,
                  ),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.medication_outlined,
                    color: controller.selectedIndex.value == 1
                        ? theme.primaryColor
                        : Colors.grey[500],
                  ),
                  selectedIcon: Icon(
                    Icons.medication_rounded,
                    color: theme.primaryColor,
                  ),
                  label: 'Medications',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.format_list_bulleted_outlined,
                    color: controller.selectedIndex.value == 2
                        ? theme.primaryColor
                        : Colors.grey[500],
                  ),
                  selectedIcon: Icon(
                    Icons.format_list_bulleted_rounded,
                    color: theme.primaryColor,
                  ),
                  label: 'Log',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.person_outline_rounded,
                    color: controller.selectedIndex.value == 3
                        ? theme.primaryColor
                        : Colors.grey[500],
                  ),
                  selectedIcon: Icon(
                    Icons.person_rounded,
                    color: theme.primaryColor,
                  ),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
