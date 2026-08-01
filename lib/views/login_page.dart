import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/login_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginPage extends GetView<LoginController> {
  // moved formKey to widget to avoid duplicate GlobalKey across the app
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // removed const to allow non-const field
  LoginPage({Key? key}) : super(key: key);

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
                  key: _formKey, // use widget key
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 1),
                      Image.asset(
                        'assets/images/logo.png',
                        width: screenWidth * 0.5,
                        height: screenWidth * 0.5,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: screenHeight * 0.025),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        'Your Health, Your Schedule',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: screenHeight * 0.035),
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

                      // --- Email ---
                      TextFormField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(fontSize: 14),
                        validator: controller.validateEmail,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (_) {
                          _formKey.currentState?.validate(); // use widget key
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Colors.grey[400],
                            size: 20,
                          ),
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
                            borderSide: const BorderSide(
                              color: Color(0xFF4FC3F7),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1.5,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          errorStyle: const TextStyle(
                            fontSize: 11,
                            height: 0.8,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.018),

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

                      // --- Password ---
                      Obx(
                        () => TextFormField(
                          controller: controller.passController,
                          obscureText: controller.isPasswordHidden.value,
                          textInputAction: TextInputAction.done,
                          validator: controller.validatePassword,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onFieldSubmitted: (_) {
                            if (_formKey.currentState?.validate() ?? false) {
                              controller.login();
                            }
                          },
                          onChanged: (_) {
                            _formKey.currentState?.validate();
                          },
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordHidden.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
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
                              borderSide: const BorderSide(
                                color: Color(0xFF4FC3F7),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1.5,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            errorStyle: const TextStyle(
                              fontSize: 11,
                              height: 0.8,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // Login Button
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
                                      controller.login();
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
                                    'Login',
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

                      // Sign Up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed('/register');
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF4FC3F7),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
}
