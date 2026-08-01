import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/nearby_pharmacies_controller.dart';
import '../model/pharmacy_model.dart';
import '../theme/app_theme.dart';

class NearbyPharmaciesPage extends GetView<NearbyPharmaciesController> {
  const NearbyPharmaciesPage({Key? key}) : super(key: key);

  static const double appBarHeight = 70.0;
  static const double horizontalPadding = 14.0;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenHeight = media.size.height;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.darkGradient : AppColors.lightGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // AppBar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color, size: 22),
                          onPressed: () => Get.back(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Nearby',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge!.color,
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 8,
                    ).copyWith(bottom: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 20, color: theme.textTheme.bodyMedium!.color),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search pharmacies...',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: theme.textTheme.bodyMedium!.color,
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onChanged: controller.onSearchChanged,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: SpinKitPumpingHeart(
                    color: theme.primaryColor,
                    size: 40,
                  ),
                );
              }

              if (controller.errorMessage.value != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller.errorMessage.value!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final elements = controller.filteredPharmacies;
              if (elements.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_pharmacy_outlined,
                        size: 48,
                        color: theme.textTheme.bodyMedium!.color,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No pharmacies found nearby',
                        style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium!.color),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: _mapCard(elements, screenHeight),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_pharmacy_rounded,
                            size: 16,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'All Pharmacies',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.bodyLarge!.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      itemCount: elements.length,
                      itemBuilder: (context, index) {
                        final e = elements[index];
                        return _PharmacyCard(
                          element: e,
                          distanceText: controller.distanceTextFor(e),
                          onDirections: () => _launchDirections(e.lat, e.lon),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _mapCard(List<Elements> elements, double screenHeight) {
    final userPos = controller.userPosition;
    final center = userPos != null
        ? LatLng(userPos.latitude, userPos.longitude)
        : LatLng(elements.first.lat, elements.first.lon);

    final cardHeight = screenHeight * 0.22;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: cardHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 14,
            maxZoom: 18,
            minZoom: 3,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.reminder_app',
            ),
            if (userPos != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(userPos.latitude, userPos.longitude),
                    width: 36,
                    height: 36,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                ],
              ),
            MarkerLayer(
              markers: elements
                  .map(
                    (e) => Marker(
                  point: LatLng(e.lat, e.lon),
                  width: 36,
                  height: 36,
                  child: Icon(
                    Icons.location_on,
                    color: Get.theme.primaryColor,
                    size: 28,
                  ),
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchDirections(double lat, double lon) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _PharmacyCard extends StatelessWidget {
  final Elements element;
  final String distanceText;
  final VoidCallback onDirections;

  const _PharmacyCard({
    Key? key,
    required this.element,
    required this.distanceText,
    required this.onDirections,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tags = element.tags;
    final addressParts = [
      if (tags.addrStreet != null) tags.addrStreet,
      if (tags.addrHousenumber != null) tags.addrHousenumber,
      if (tags.addrCity != null) tags.addrCity,
    ].whereType<String>().toList();

    final address = addressParts.isEmpty ? 'No address' : addressParts.join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tags.name ?? 'Unknown pharmacy',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodyLarge!.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (distanceText.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    distanceText,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: theme.textTheme.bodyMedium!.color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(fontSize: 11, color: theme.textTheme.bodyLarge!.color),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (tags.phone != null && tags.phone!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: theme.textTheme.bodyMedium!.color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    tags.phone!,
                    style: TextStyle(fontSize: 11, color: theme.textTheme.bodyLarge!.color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (tags.openingHours != null && tags.openingHours!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: theme.textTheme.bodyMedium!.color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    tags.openingHours!,
                    style: TextStyle(fontSize: 11, color: theme.textTheme.bodyLarge!.color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onDirections,
              icon: const Icon(Icons.navigation, size: 14, color: Colors.white),
              label: const Text(
                'Directions',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                backgroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(0, 32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}