import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/connectivity_service.dart';
import '../core/core_exception.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;

  final AuthService authService = Get.find<AuthService>();
  final ConnectivityService connectivityService =
  Get.find<ConnectivityService>();

  late final StreamSubscription sub;

  @override
  void onInit() {
    super.onInit();

    sub = connectivityService.checkforInternet().listen((result) async {
      final connectedNow = await connectivityService.connected();
      if (!connectedNow) {
        showErrorSnackbar('No internet connection');
      } else {
        Get.snackbar(
          'Online',
          'Internet connection',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
        );
      }
    });
  }

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

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  Future<void> login() async {
    // Validation should be done by the widget before calling controller.login()

    final connectedNow = await connectivityService.connected();
    if (!connectedNow) {
      showErrorSnackbar('No internet connection');
      return;
    }

    isLoading.value = true;

    try {
      await authService.login(emailController.text.trim(), passController.text);

      Get.offAllNamed('/home');
    } on InvalidCredentialsException catch (e) {
      showErrorSnackbar(e.message ?? 'Invalid credentials');
    } catch (e) {
      showErrorSnackbar('Something went wrong, please try again');
    } finally {
      isLoading.value = false;
    }
  }

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

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  @override
  void onClose() {
    // emailController.dispose();
    // passController.dispose();
    sub.cancel();
    super.onClose();
  }
}
