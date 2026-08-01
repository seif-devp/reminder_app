import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:reminder_app/services/auth_service.dart';

class SplashScreenController extends GetxController
  with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> pulseAnimation;
  final AuthService authService = Get.find<AuthService>();

  RxDouble logoOpacity = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    pulseAnimation =
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.2), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
        );

    Future.delayed(const Duration(milliseconds: 200), () {
      logoOpacity.value = 1.0;
      animationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 2600), () {
      logoOpacity.value = 0.0;
    });

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (authService.isLoggedIn) {
        Get.offNamed('/main');
      } else {
        Get.offNamed('/login');
      }
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
