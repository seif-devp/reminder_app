import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/services/auth_service.dart';
import 'package:reminder_app/services/connectivity_service.dart';
import 'package:reminder_app/core/core_exception.dart';

class SignUpController extends GetxController {
  // removed: final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emaillController = TextEditingController();
  final passworddController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordVisible = true.obs;
  final isConfirmPasswordVisible = true.obs;

  final RxDouble passwordStrength = 0.0.obs;
  final RxString strengthLabel = "".obs;
  final Rx<Color> strengthColor = Colors.grey.obs;

  final isLoading = false.obs;

  final authService = Get.find<AuthService>();
  final _connectivityService = Get.find<ConnectivityService>();

  @override
  void onInit() {
    super.onInit();
    passworddController.addListener(onPasswordChanged);
    confirmPasswordController.addListener(onPasswordChanged);
  }

  @override
  void onClose() {
    passworddController.removeListener(onPasswordChanged);
    confirmPasswordController.removeListener(onPasswordChanged);

    nameController.dispose();
    emaillController.dispose();
    passworddController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // ---------- Validation ----------
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
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
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passworddController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ---------- Password helpers ----------
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void onPasswordChanged() {
    checkPasswordStrength();
  }


  void checkPasswordStrength() {
    final password = passworddController.text;

    if (password.isEmpty) {
      passwordStrength.value = 0.0;
      strengthLabel.value = "";
      strengthColor.value = Colors.grey;
      return;
    }

    final regex = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
    );

    if (regex.hasMatch(password)) {
      passwordStrength.value = 1.0;
      strengthLabel.value = "Strong";
      strengthColor.value = Colors.green;
    } else {
      passwordStrength.value = 0.4;
      strengthLabel.value = "Weak";
      strengthColor.value = Colors.red;
    }
  }

  // ---------- Create Account ----------
  Future createAccount() async {

    // optional: منع الضعيف
    if (passwordStrength.value < 0.4) {
      showErrorSnackbar('Password is too weak');
      return;
    }

    final connectedNow = await _connectivityService.connected();
    if (!connectedNow) {
      showErrorSnackbar('No internet connection');
      return;
    }

    isLoading.value = true;

    try {
      await authService.register(
        emaillController.text.trim(),
        passworddController.text,
        nameController.text,
      );

      Get.snackbar(
        'Success',
        'Account created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
      );

      Get.offAllNamed('/login');
    } on EmailAlreadyExistsException catch (e) {
      showErrorSnackbar(e.message ?? 'Email already exists');
    } catch (e) {
      showErrorSnackbar('Something went wrong, please try again');
      print('Error during registration: $e');
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
}
