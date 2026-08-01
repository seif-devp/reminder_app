import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../core/location_permission.dart';
import '../data/database/models/pharmacy_model.dart';
import '../services/connectivity_service.dart';
import '../services/pharmacies_service.dart';

class NearbyPharmaciesController extends GetxController {
  final PharmaciesService service = Get.find<PharmaciesService>();
  final ConnectivityService connectivityService =
  Get.find<ConnectivityService>();

  final isLoading = false.obs;
  final errorMessage = RxnString();

  final pharmacies = <Elements>[].obs;

  final searchText = ''.obs;

  Position? userPosition;
  late final StreamSubscription connSub;

  @override
  void onInit() {
    super.onInit();

    connSub = connectivityService.checkforInternet().listen((_) async {
      final connected = await connectivityService.connected();
      if (!connected) {
        Get.snackbar(
          'Offline',
          'No internet connection',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    });

    fetchNearbyPharmacies();
  }

  // ============= جلب الصيدليات =============

  Future<void> fetchNearbyPharmacies() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final pos = await getCurrentPosition();
      userPosition = pos;

      final response = await service.getNearbyPharmacies(
        lat: pos.latitude,
        lon: pos.longitude,
      );

      if (response == null) {
        pharmacies.clear();
        errorMessage.value = 'No pharmacies found nearby';
        return;
      }

      final elements = response.elements;
      pharmacies.assignAll(elements as Iterable<Elements>);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value!,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============= Search =============

  void onSearchChanged(String value) {
    searchText.value = value.toLowerCase();
  }

  List<Elements> get filteredPharmacies {
    final q = searchText.value;
    if (q.isEmpty) return pharmacies;

    return pharmacies.where((e) {
      final name = e.tags.name?.toLowerCase() ?? '';
      return name.contains(q);
    }).toList();
  }

  // ============= حساب المسافة =============

  String distanceTextFor(Elements e) {
    if (userPosition == null) return '';

    final dMeters = Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      e.lat,
      e.lon,
    );

    if (dMeters >= 1000) {
      final km = dMeters / 1000;
      return '${km.toStringAsFixed(1)} km away';
    } else {
      return '${dMeters.toStringAsFixed(0)} m away';
    }
  }

  @override
  void onClose() {
    connSub.cancel();
    super.onClose();
  }
}
