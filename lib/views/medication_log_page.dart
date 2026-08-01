import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/medication_log_controller.dart';
import 'package:reminder_app/controllers/navigation_controller.dart';

import '../theme/app_theme.dart';

class MedicationLogPage extends StatelessWidget {
  MedicationLogPage({Key? key}) : super(key: key);

  final MedicationLogController controller =
  Get.put(MedicationLogController());

  static const double appBarHeight = 70.0;
  static const double paddingHorizontal = 14.0;
  static const double spacingVertical = 12.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: appBarHeight,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDark ? AppColors.darkGradient : AppColors.lightGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.iconTheme.color, size: 22),
                    onPressed: () {
  // نجيب NavigationController
  final nav = Get.find<NavigationController>();
  // نروح لتبويب الـ Home (index 0)
  nav.navigateToIndex(0);
},
      
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Medication Log',
                      maxLines: 1,
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge!.color,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: SpinKitPumpingHeart(
              color: theme.primaryColor,
              size: 40,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: spacingVertical,
          ),
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAdherenceCard(),
              const SizedBox(height: 12),
              _buildFilterCard(),
              const SizedBox(height: 12),
              _buildLogsList(),
            ],
          ),
        );
      }),
    );
  }

  // ================== Cards ==================

  Widget _buildAdherenceCard() {
    final theme = Get.theme;
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4FC3F7), Color(0xFF81D4FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Adherence Summary',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodyLarge!.color,
                ),
              ),
              Obx(
                    () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${controller.adherence.value.round()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyLarge!.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Taken & Missed in one row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.onPrimary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: theme.textTheme.bodyLarge!.color,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Obx(
                            () => Text(
                          '${controller.takenDoses.value}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: theme.textTheme.bodyLarge!.color,
                          ),
                        ),
                      ),
                      Text(
                        'Taken',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textTheme.bodyLarge!.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.onPrimary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cancel_rounded,
                        color: theme.textTheme.bodyLarge!.color,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Obx(
                            () => Text(
                          '${controller.missedDoses.value}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: theme.textTheme.bodyLarge!.color,
                          ),
                        ),
                      ),
                      Text(
                        'Missed',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textTheme.bodyLarge!.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    final theme = Get.theme;
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: theme.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Filter Logs',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: theme.textTheme.bodyLarge!.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Medication Filter
          Text(
            'Medication',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 5),
          Obx(
                () => DropdownButtonFormField<int>(
              value: controller.selectedMedId.value == 0
                  ? 0
                  : controller.selectedMedId.value,
              decoration: _inputDecoration(),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.primaryColor,
                size: 20,
              ),
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodyLarge!.color,
              ),
              dropdownColor: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              items: [
                  DropdownMenuItem(
                  value: 0,
                  child: Text(
                    'All Medications',
                    style: TextStyle(fontSize: 13, color: theme.textTheme.bodyLarge!.color),
                  ),
                ),
                ...controller.medsById.entries.map(
                      (e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(
                      e.value.name,
                      style:  TextStyle(fontSize: 13, color: theme.textTheme.bodyLarge!.color),
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.changeMedFilter(value);
                }
              },
            ),
          ),
          const SizedBox(height: 10),

          // Status Filter
          Text(
            'Status',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 5),
          Obx(
                () => DropdownButtonFormField<String>(
              value: controller.selectedStatus.value,
              decoration: _inputDecoration(),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.primaryColor,
                size: 20,
              ),
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodyLarge!.color,
              ),
              dropdownColor: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              items:  [
                DropdownMenuItem(
                  value: 'all',
                  child: Text(
                    'All Status',
                    style: TextStyle(fontSize: 13, color: theme.textTheme.bodyLarge!.color),
                  ),
                ),
                DropdownMenuItem(
                  value: 'pending',
                  child: Text(
                    'Pending',
                    style: TextStyle(fontSize: 13, color: theme.textTheme.bodyLarge!.color),
                  ),
                ),
                DropdownMenuItem(
                  value: 'taken',
                  child: Text(
                    'Taken',
                    style: TextStyle(fontSize: 13, color: theme.textTheme.bodyLarge!.color),
                  ),
                ),
                DropdownMenuItem(
                  value: 'missed',
                  child: Text(
                    'Missed',
                    style: TextStyle(fontSize: 13, color: theme.textTheme.bodyLarge!.color),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.changeStatusFilter(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList() {
    final theme = Get.theme;
    return Obx(() {
      final items = controller.filteredRecords;
      if (items.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: theme.textTheme.bodyLarge!.color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No activity in this period.',
              style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium!.color),
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: theme.textTheme.bodyLarge!.color,
            ),
          ),
          const SizedBox(height: 6),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final r = items[index];
              final medName = controller.medicationNameFor(r);
              final when = controller.formatScheduledAt(r.scheduledAt);
              final color = controller.statusColor(r.status);
              final label = controller.statusLabel(r.status);

              return Card(
                elevation: 0,
                color: theme.cardColor,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: color.withOpacity(0.12),
                        radius: 18,
                        child: Icon(
                          Icons.medication_outlined,
                          color: color,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge!.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              when,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.textTheme.bodyMedium!.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  // ================== Shared ==================

  InputDecoration _inputDecoration() {
    final theme = Get.theme;
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: theme.scaffoldBackgroundColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.textTheme.bodyMedium!.color!.withOpacity(0.2),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: theme.primaryColor,
          width: 1.5,
        ),
      ),
    );
  }
}