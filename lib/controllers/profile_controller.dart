import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/core/init_local_db.dart';
import 'package:reminder_app/data/entity/users.dart';
import 'package:reminder_app/services/auth_service.dart';
import 'package:reminder_app/services/connectivity_service.dart';
import 'package:reminder_app/services/profile_service.dart';

class ProfileController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final connectivityService = Get.find<ConnectivityService>();
  final profileService = Get.find<ProfileService>();
  final isLoading = false.obs;
  final user = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  Future<void> loadUser() async {
    final id = authService.currentUserId;
    if (id == null || id.isEmpty) return;

    isLoading.value = true;
    try {
      final u = await database.userDao.getUserById(id);
      user.value = u;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveUser(User updated) async {
    try {
      isLoading.value = true;
      
      final isOnline = await connectivityService.connected();

      if (isOnline) {
        try {
          await profileService.updateUserOnSupabase(updated);

          final syncedUser = User(
            userId: updated.userId,
            name: updated.name,
            email: updated.email,
            password: updated.password,
            gender: updated.gender,
            age: updated.age,
            bloodType: updated.bloodType,
            weight: updated.weight,
            height: updated.height,
            syncStatus: 'synced',
          );

          await database.userDao.updateUser(syncedUser);
          user.value = syncedUser;
        } catch (e) {
          print('Failed to update profile on Supabase: $e');
          
          // لو فشل، احفظ بـ not_synced
          final unsyncedUser = User(
            userId: updated.userId,
            name: updated.name,
            email: updated.email,
            password: updated.password,
            gender: updated.gender,
            age: updated.age,
            bloodType: updated.bloodType,
            weight: updated.weight,
            height: updated.height,
            syncStatus: 'not_synced',
          );

          await database.userDao.updateUser(unsyncedUser);
          user.value = unsyncedUser;
        }
      } else {
        final unsyncedUser = User(
          userId: updated.userId,
          name: updated.name,
          email: updated.email,
          password: updated.password,
          gender: updated.gender,
          age: updated.age,
          bloodType: updated.bloodType,
          weight: updated.weight,
          height: updated.height,
          syncStatus: 'not_synced',
        );

        await database.userDao.updateUser(unsyncedUser);
        user.value = unsyncedUser;
      }

      // Show success message
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4FC3F7),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
