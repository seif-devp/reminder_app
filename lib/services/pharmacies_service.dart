import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:reminder_app/model/pharmacy_model.dart';

class PharmaciesService {
  static const url = 'https://overpass-api.de/api/interpreter';
  final Dio dio = Dio();

  Future<Pharmacy?> getNearbyPharmacies({
    required double lat,
    required double lon,
    int radiusMeters = 2000,
  }) async {
    final query = '''
[out:json];
node(around:$radiusMeters,$lat,$lon)[amenity=pharmacy];
out;
''';

    final resp = await dio.post(
      url,
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
      ),
      data: {'data': query},
    );

    if (resp.statusCode == 200) {
      final data = resp.data as Map<String, dynamic>;

      final elements = data['elements'] as List<dynamic>? ?? [];
      if (elements.isEmpty) {
        return null;
      }

      final pharmacyResponse =
          pharmacyFromJson(json.encode(data)); 

      return pharmacyResponse;
    } else {
      throw Exception('Overpass error: ${resp.statusCode}');
    }
  }
}
