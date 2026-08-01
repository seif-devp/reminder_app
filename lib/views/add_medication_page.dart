import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/add_medication_controller.dart';
import 'package:reminder_app/controllers/navigation_controller.dart';

import '../theme/app_theme.dart';

class AddMedicationPage extends GetView<AddMedicationController> {
  const AddMedicationPage({super.key});

  static const double appBarHeight = 80.0;
  static const double spacingVertical = 20.0;
  static const double paddingHorizontal = 16.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listen to error and success messages
    ever(controller.errorMessage, (String? message) {
      if (message != null && message.isNotEmpty) {
        Get.snackbar(
          'Error',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
        );
      }
    });
    ever(controller.successMessage, (String? message) {
      if (message != null && message.isNotEmpty) {
        Get.snackbar(
          'Success',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4FC3F7),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: appBarHeight,
        elevation: 0,
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
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Add Medication',
                      maxLines: 2,
                      softWrap: true,
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge!.color,
                        fontSize: 22,
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
      body: Obx(
        () => controller.isLoading.value
            ? Center(
                child: SpinKitPumpingHeart(color: theme.primaryColor, size: 50),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: paddingHorizontal,
                  vertical: spacingVertical,
                ),
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMedicationPhotoCard(controller),
                    const SizedBox(height: spacingVertical),
                    _buildBasicInformationCard(controller),
                    const SizedBox(height: spacingVertical),
                    _buildScheduleTimeCard(controller, context),
                    const SizedBox(height: spacingVertical),
                    _buildAddButton(controller),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  // ======================= UI Helpers =======================

  Widget _buildMedicationPhotoCard(AddMedicationController controller) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.camera_alt_rounded,
                size: 18,
                color: Get.theme.primaryColor,
              ),
              const SizedBox(width: 8),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  'Medication Photo (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Get.theme.textTheme.bodyLarge!.color,
                  ),
                  maxLines: 2,
                  softWrap: true,
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showImageSourcePicker(controller),
            child: Obx(
              () => Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Get.theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: controller.imageFile.value != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: kIsWeb
                                ? Image.network(
                                    controller.imageFile.value!.path,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  )
                                : Image.file(
                                    File(controller.imageFile.value!.path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                          ),
                          // Edit icon overlay
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Get.theme.cardColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: Get.theme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Get.theme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_rounded,
                              color: Get.theme.primaryColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to add a photo',
                            style: TextStyle(
                              fontSize: 14,
                              color: Get.theme.textTheme.bodyLarge!.color,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Helps you recognize pills easily',
                            style: TextStyle(
                              fontSize: 12,
                              color: Get.theme.textTheme.bodyMedium!.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourcePicker(AddMedicationController controller) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Get.theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Camera'),
                onTap: () {
                  controller.takeImageFromCamera();
                  Get.back();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () {
                  controller.pickImageFromGallery();
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInformationCard(AddMedicationController controller) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Get.theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Get.theme.textTheme.bodyLarge!.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15.0),
          _buildInputFieldWithController(
            label: 'Medication Name *',
            hint: 'e.g., Aspirin',
            controller: controller.nameController,
          ),
          const SizedBox(height: 16.0),
          _buildDosageField(controller),
          const SizedBox(height: 16.0),
          _buildFrequencyDropdown(controller),
          const SizedBox(height: 16.0),
          _buildDurationDropdown(controller),
          const SizedBox(height: 16.0),
          _buildInputFieldWithController(
            label: 'Notes (Optional)',
            hint: 'e.g., Take with food',
            controller: controller.notesController,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTimeCard(
    AddMedicationController controller,
    BuildContext context,
  ) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, size: 18, color: Get.theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Dose Times *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Get.theme.textTheme.bodyLarge!.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Add Time Button
          InkWell(
            onTap: () async {
              final selectedTime = await showTimePicker(
                context: context,
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
                        child: FittedBox(fit: BoxFit.scaleDown, child: child!),
                      ),
                    ),
                  );
                },
              );
              if (selectedTime != null) {
                controller.addDoseTime(selectedTime);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Get.theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Dose Time',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Get.theme.primaryColor,
                    ),
                  ),
                  Icon(
                    Icons.add_alarm,
                    color: Get.theme.primaryColor,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14.0),

          // Display added dose times
          Obx(() {
            if (controller.doseTimes.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Get.theme.cardColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No dose times added yet',
                    style: TextStyle(
                      color: Get.theme.textTheme.bodyMedium!.color,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: controller.doseTimes.asMap().entries.map((entry) {
                final index = entry.key;
                final time = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Get.theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.alarm,
                          color: Get.theme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            controller.formatTimeOfDay(time),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Get.theme.textTheme.bodyLarge!.color,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => controller.removeDoseTime(index),
                          icon: const Icon(Icons.close, size: 20),
                          color: Colors.red,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAddButton(AddMedicationController controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () async {
                  // Get.back(); // Close the add medication page
                  final ok = await controller.saveMedication();
                    // Get.back();
                    // Get.back();
                  if (ok == true) {
                    controller.resetForm();
                    
                    // Get.back();
                    // final nav = Get.find<NavigationController>();
                    // // نروح لتبويب الـ Home (index 0)
                    // nav.navigateToIndex(0); // Navigate to main page
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Get.theme.primaryColor,
            disabledBackgroundColor: Get.theme.primaryColor.withOpacity(0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: controller.isLoading.value
              ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Get.theme.colorScheme.onPrimary,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 22,
                      color: Get.theme.colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Add Medication',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Get.theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ======================= Shared Helpers =======================

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInputFieldWithController({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Get.theme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 14,
            color: Get.theme.textTheme.bodyLarge!.color,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Get.theme.textTheme.bodyMedium!.color!.withOpacity(0.5),
              fontSize: 14,
            ),
            filled: true,
            fillColor: Get.theme.scaffoldBackgroundColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Get.theme.textTheme.bodyMedium!.color!.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Get.theme.primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDosageField(AddMedicationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dosage *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Get.theme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.dosageController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 14,
                  color: Get.theme.textTheme.bodyLarge!.color,
                ),
                decoration: InputDecoration(
                  hintText: '100',
                  hintStyle: TextStyle(
                    color: Get.theme.textTheme.bodyMedium!.color!.withOpacity(
                      0.5,
                    ),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Get.theme.scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Get.theme.textTheme.bodyMedium!.color!.withOpacity(
                        0.2,
                      ),
                      width: 1,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Color(0xFF4FC3F7), width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FC3F7), Color(0xFF81D4FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'mg',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFrequencyDropdown(AddMedicationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequency *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Get.theme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => DropdownButtonFormField<String>(
            value: controller.frequency.value == 'Select frequency'
                ? null
                : controller.frequency.value,
            decoration: _dropdownDecoration(),
            hint: Text(
              'Select frequency',
              style: TextStyle(
                color: Get.theme.textTheme.bodyMedium!.color!.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Get.theme.primaryColor,
            ),
            style: TextStyle(
              fontSize: 14,
              color: Get.theme.textTheme.bodyLarge!.color,
            ),
            dropdownColor: Get.theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            items: controller.frequencyOptions
                .where((v) => v != 'Select frequency')
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(
                      v,
                      style: TextStyle(
                        fontSize: 14,
                        color: Get.theme.textTheme.bodyLarge!.color,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                controller.frequency.value = val;
                final max = controller.maxDoseTimesAllowed;
                if (max > 0 && controller.doseTimes.length > max) {
                  controller.doseTimes.value = controller.doseTimes
                      .take(max)
                      .toList();
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDurationDropdown(AddMedicationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration of Use *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Get.theme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => DropdownButtonFormField<String>(
            value: controller.duration.value == 'Select duration'
                ? null
                : controller.duration.value,
            decoration: _dropdownDecoration(),
            hint: Text(
              'Select duration',
              style: TextStyle(
                color: Get.theme.textTheme.bodyMedium!.color!.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Get.theme.primaryColor,
            ),
            style: TextStyle(
              fontSize: 14,
              color: Get.theme.textTheme.bodyLarge!.color,
            ),
            dropdownColor: Get.theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            items: controller.durationOptions
                .where((v) => v != 'Select duration')
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(
                      v,
                      style: TextStyle(
                        fontSize: 14,
                        color: Get.theme.textTheme.bodyLarge!.color,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                controller.duration.value = val;
              }
            },
          ),
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Get.theme.scaffoldBackgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Get.theme.textTheme.bodyMedium!.color!.withOpacity(0.2),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Get.theme.primaryColor, width: 2),
      ),
    );
  }
}
