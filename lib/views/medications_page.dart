import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/medications_controller.dart';
import 'package:reminder_app/controllers/navigation_controller.dart';
import 'package:reminder_app/data/entity/medications.dart';
import '../theme/app_theme.dart';

class MedicationsPage extends GetView<MedicationsController> {
  const MedicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MedicationsController>()) {
      Get.put(MedicationsController());
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDark ? AppColors.darkGradient : AppColors.lightGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                    onPressed: () {
  // نجيب NavigationController
  final nav = Get.find<NavigationController>();
  // نروح لتبويب الـ Home (index 0)
  nav.navigateToIndex(0);
},

                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'My Medications',
                      maxLines: 2,
                      softWrap: true,
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge!.color,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: theme.iconTheme.color,
                    ),
                    onPressed: () => Get.toNamed('/addMedication'),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Obx(() {
            final count = controller.medications.length;
            return Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 10),
              child: Row(
                children: [
                  Text(
                    '$count active medication${count == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium!.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: SpinKitPumpingHeart(color: theme.primaryColor, size: 50),
          );
        }

        if (controller.medications.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.medication_outlined, size: 64, color: theme.textTheme.bodyMedium!.color),
                const SizedBox(height: 10),
                Text(
                  'No active medications yet',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium!.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap + to add your first medication',
                  style: TextStyle(color: theme.textTheme.bodyMedium!.color, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.medications.length,
          itemBuilder: (context, index) {
            final med = controller.medications[index];
            return _buildMedicationCard(context, med);
          },
        );
      }),
    );
  }

  Widget _buildMedicationCard(BuildContext context, Medication med) {
    final c = Get.find<MedicationsController>();
    final nextRaw = (med.medId != null) ? c.nextDoseTimes[med.medId!] : null;
    final nextDoseText = nextRaw != null
        ? c.formatTimeForDisplay(nextRaw)
        : '—';

    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== الصورة + الاسم + الجرعة =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة الدواء قابلة للتكبير
              GestureDetector(
                onTap: () {
                  if (med.imageUrl != null && med.imageUrl!.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        return Dialog(
                          insetPadding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: InteractiveViewer(
                              minScale: 1,
                              maxScale: 4,
                              child: Image.file(
                                File(med.imageUrl!),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
                child: Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: theme.primaryColor.withOpacity(0.1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: (med.imageUrl != null && med.imageUrl!.isNotEmpty)
                      ? Image.file(File(med.imageUrl!), fit: BoxFit.cover)
                      : Icon(
                    Icons.medication,
                    color: theme.primaryColor,
                    size: 30,
                  ),
                ),
              ),

              // النصوص (الاسم + الجرعة + التكرار)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.bodyLarge!.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${med.dosage} • ${med.frequency}',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium!.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ===== Next dose + Duration =====
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          color: theme.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Next dose at',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textTheme.bodyMedium!.color,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      nextDoseText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge!.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Duration',
                      style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium!.color),
                    ),
                    Text(
                      med.durationOfUse,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge!.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ===== Notes (لو موجودة) =====
          if (med.notes != null && med.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16, color: theme.primaryColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      med.notes!,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodyMedium!.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ===== أزرار Edit / Delete =====
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditDialog(context, med),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit', overflow: TextOverflow.ellipsis),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                      side: BorderSide(
                        color: theme.primaryColor,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteDialog(context, med),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text(
                      'Delete',
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE57373),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Medication med) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with gradient background
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Delete Medication',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: theme.textTheme.bodyLarge!.color,
                  ),
                ),
                const SizedBox(height: 12),

                // Content
                Text(
                  'Are you sure you want to delete "${med.name}"?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.textTheme.bodyLarge!.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'This will remove all reminders and logs.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium!.color),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: theme.primaryColor,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final c = Get.find<MedicationsController>();
                            await c.deleteMedication(med);
                            Navigator.of(ctx).pop();

                            Get.snackbar(
                              'Deleted',
                              '${med.name} has been removed',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: theme.primaryColor,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Medication med) async {
    await controller.loadScheduleForEdit(med);

    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final w = MediaQuery.of(ctx).size.width;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: w * 0.9,
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Obx(
                      () => SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with gradient background
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4FC3F7), Color(0xFF81D4FA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: theme.colorScheme.onPrimary, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Edit Schedule',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Frequency
                        Text(
                          'Frequency',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: controller.editFrequency.value.isEmpty
                              ? null
                              : controller.editFrequency.value,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            filled: true,
                            fillColor: theme.scaffoldBackgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: theme.textTheme.bodyMedium!.color!.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: theme.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          hint: Text(
                            'Select frequency',
                            style: TextStyle(color: theme.textTheme.bodyMedium!.color, fontSize: 13),
                          ),
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: theme.primaryColor,
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodyLarge!.color,
                          ),
                          dropdownColor: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          items:
                          const [
                            'Once daily',
                            'Twice daily (2x/day)',
                            'Three times daily (3x/day)',
                            'Four times daily (4x/day)',
                            'As needed',
                          ].map((v) {
                            return DropdownMenuItem(
                              value: v,
                              child: Text(
                                v,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.textTheme.bodyLarge!.color,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              controller.editFrequency.value = val;
                              final max = controller.maxDoseTimesAllowedForEdit;
                              if (max > 0 &&
                                  controller.editDoseTimes.length > max) {
                                controller.editDoseTimes.value = controller
                                    .editDoseTimes
                                    .take(max)
                                    .toList();
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Dose Times
                        Text(
                          'Dose Times',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Add Dose Time Button
                        GestureDetector(
                          onTap: () async {
                            final selectedTime = await showTimePicker(
                              context: ctx,
                              initialTime: TimeOfDay.now(),
                              builder: (BuildContext context, Widget? child) {
                                final theme = Theme.of(context);
                                return MediaQuery(
                                  data: MediaQuery.of(
                                    context,
                                  ).copyWith(alwaysUse24HourFormat: false),
                                  child: Theme(
                                    data: theme.copyWith(
                                      colorScheme: theme.colorScheme.copyWith(
                                        primary: theme.primaryColor,
                                        onPrimary: theme.colorScheme.onPrimary,
                                        surface: theme.cardColor,
                                        onSurface: theme.textTheme.bodyLarge!.color,
                                      ),
                                    ),
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: child!,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );

                            if (selectedTime != null) {
                              controller.addDoseTimeForEdit(selectedTime);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: theme.textTheme.bodyMedium!.color!.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Add Dose Time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                Icon(Icons.add_alarm, color: theme.primaryColor),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Dose Times List
                        if (controller.editDoseTimes.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.cardColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'No dose times added yet',
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium!.color,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: controller.editDoseTimes
                                .asMap()
                                .entries
                                .map(
                                  (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.alarm,
                                        color: theme.primaryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          controller.formatTimeOfDay(
                                            entry.value,
                                          ),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: theme.textTheme.bodyLarge!.color,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => controller
                                            .removeDoseTimeForEdit(
                                          entry.key,
                                        ),
                                        icon: const Icon(
                                          Icons.close,
                                          size: 18,
                                        ),
                                        color: Colors.red,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                                .toList(),
                          ),
                        const SizedBox(height: 24),

                        // Save Button
                        Obx(
                              () => SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () async {
                                if (controller
                                    .editFrequency
                                    .value
                                    .isEmpty ||
                                    controller.editDoseTimes.isEmpty) {
                                  Get.snackbar(
                                    'Error',
                                    'Please choose frequency and at least one dose time',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }

                                await controller.saveEditedSchedule(med);

                                // Close dialog after short delay
                                Future.delayed(
                                  const Duration(milliseconds: 500),
                                      () {
                                    if (Navigator.canPop(ctx)) {
                                      Navigator.of(ctx).pop();
                                    }
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                disabledBackgroundColor: theme
                                    .primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: SpinKitPumpingHeart(
                                    color: Colors.white,
                                    size: 25.0,
                                  )
                              )
                                  : FittedBox(
                                // <-- اضيف هذا
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize:
                                  MainAxisSize.min, // <-- واضبط هنا
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Cancel Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: theme.primaryColor,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}