import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/registration_controller.dart';

class SignUpView extends GetView<SignUpController> {
  // widget-local form key to avoid duplicate GlobalKey across screens
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  SignUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenHeight * 0.02,
                ),
                child: Form(
                  key: _formKey, // use widget-local key
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 1),

                      // Logo
                      Image.asset(
                        'assets/images/logo.png',
                        width: screenWidth * 0.5,
                        height: screenWidth * 0.5,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: screenHeight * 0.025),

                      const Text(
                        'Create Your Account',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        'Join us to manage your health better',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: screenHeight * 0.035),

                      // Full Name
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Full Name',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      TextFormField(
                        controller: controller.nameController,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(fontSize: 14),
                        validator: controller.validateName,
                        onChanged: (_) {
                          _formKey.currentState?.validate();
                        },
                        decoration: _inputDecoration(
                          hint: 'Enter your full name',
                          icon: Icons.person_outline,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.018),

                      // Email
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email Address',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      TextFormField(
                        controller: controller.emaillController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(fontSize: 14),
                        validator: controller.validateEmail,
                        onChanged: (_) {
                          _formKey.currentState?.validate();
                        },
                        decoration: _inputDecoration(
                          hint: 'Enter your email',
                          icon: Icons.email_outlined,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.018),

                      // Password
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      Obx(
                        () => TextFormField(
                          controller: controller.passworddController,
                          obscureText: controller.isPasswordVisible.value,
                          textInputAction: TextInputAction.next,
                          validator: controller.validatePassword,
                          onChanged: (_) {
                            _formKey.currentState?.validate();
                          },
                          style: const TextStyle(fontSize: 14),
                          decoration: _inputDecoration(
                            hint: 'Enter your password',
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                controller.isPasswordVisible.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                          ),
                        ),
                      ),

                      // Password strength
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Obx(() {
                          if (controller.strengthLabel.value.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                value: controller.passwordStrength.value,
                                backgroundColor: Colors.grey[300],
                                color: controller.strengthColor.value,
                                minHeight: 6,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.strengthLabel.value,
                                style: TextStyle(
                                  color: controller.strengthColor.value,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),

                      SizedBox(height: screenHeight * 0.010),

                      // Confirm Password
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Confirm Password',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      Obx(
                        () => TextFormField(
                          controller: controller.confirmPasswordController,
                          obscureText:
                              controller.isConfirmPasswordVisible.value,
                          textInputAction: TextInputAction.done,
                          validator: controller.validateConfirmPassword,
                          onFieldSubmitted: (_) {
                            if (_formKey.currentState?.validate() ?? false) {
                              controller.createAccount();
                            }
                          },
                          onChanged: (_) {
                            _formKey.currentState?.validate();
                          },
                          style: const TextStyle(fontSize: 14),
                          decoration: _inputDecoration(
                            hint: 'Confirm your password',
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                controller.isConfirmPasswordVisible.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                              onPressed:
                                  controller.toggleConfirmPasswordVisibility,
                            ),
                          ),
                        ),
                      ),

                      // Error "passwords do not match"


                      SizedBox(height: screenHeight * 0.025),

                      // Create Account Button
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      controller.createAccount();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FC3F7),
                              disabledBackgroundColor: const Color(0xFF4FC3F7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: controller.isLoading.value
                                ? const SpinKitPumpingHeart(
                                    color: Colors.white,
                                    size: 20.0,
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.018),

                      // Login link
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                          children: [
                            const TextSpan(text: "Already have an account? "),
                            TextSpan(
                              text: "Login",
                              style: const TextStyle(
                                color: Color(0xFF4FC3F7),
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.offNamed('/login');
                                },
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      errorStyle: const TextStyle(fontSize: 11, height: 0.8),
    );
  }
}
