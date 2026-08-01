import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/services/auth_service.dart';
import 'package:reminder_app/services/connectivity_service.dart';
import 'package:reminder_app/core/core_exception.dart';

class LoginController extends GetxController {
  final  emailController = TextEditingController();
  final  passController = TextEditingController();
  
  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  
  final AuthService authService = Get.find<AuthService>();
  final ConnectivityService _connectivityService = Get.find<ConnectivityService>();
  
  late final StreamSubscription sub;

  @override
  void onInit() {
    super.onInit();
    
    // Listen to connectivity changes
    sub = _connectivityService.checkforInternet().listen((result) async {
      final connectedNow = await _connectivityService.connected();
      
      if (!connectedNow) {
        showErrorSnackbar('No internet connection');
      }
    });
  }

  /// Validate email format
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// Validate password (non-empty check)
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    return null;
  }

  Future<void> login() async {

    final connectedNow = await _connectivityService.connected();
    if (!connectedNow) {
      showErrorSnackbar('No internet connection');
      return;
    }

    isLoading.value = true;
    
    try {
      // Call AuthService login (includes sync automatically)
      await authService.login(
        emailController.text.trim(),
        passController.text,
      );

      // Show success message
      Get.snackbar(
        'Success',
        'Login successful! Your data has been synced.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
      );

      Get.offAllNamed('/main'); // Navigate to main page
      
    } on InvalidCredentialsException catch (e) {
      showErrorSnackbar(e.message ?? 'Invalid credentials');
      
    } catch (e) {
      showErrorSnackbar('Something went wrong, please try again');
      
    } finally {
      isLoading.value = false;
    }
  }

  /// Show error snackbar
  void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
    );
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  @override
  void onClose() {
    // Cancel connectivity subscription
    sub.cancel();
    
    // Note: Controllers are disposed automatically by GetView
    // Uncomment if needed:
    // emailController.dispose();
    // passController.dispose();
    
    super.onClose();
  }
}
