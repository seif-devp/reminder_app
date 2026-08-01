import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/splash_screen_controller.dart';

class SplashScreen extends GetView<SplashScreenController> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Obx(
          () => AnimatedOpacity(
            duration: const Duration(seconds: 1),
            opacity: controller.logoOpacity.value,
            child: ScaleTransition(
              scale: controller.pulseAnimation,
              child: Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
