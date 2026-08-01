// To parse this JSON data, do
//
// final pharmacy = pharmacyFromJson(jsonString);

import 'dart:convert';

Pharmacy pharmacyFromJson(String str) =>
    Pharmacy.fromJson(json.decode(str) as Map<String, dynamic>);

String pharmacyToJson(Pharmacy data) => json.encode(data.toJson());

class Pharmacy {
  final List<Elements> elements;

  Pharmacy({
    required this.elements,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) => Pharmacy(
        elements: (json["elements"] as List<dynamic>? ?? [])
            .map((x) => Elements.fromJson(x as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        "elements": elements.map((x) => x.toJson()).toList(),
      };
}

class Elements {
  final String type;
  final int id;
  final double lat;
  final double lon;
  final Tags tags;

  Elements({
    required this.type,
    required this.id,
    required this.lat,
    required this.lon,
    required this.tags,
  });

  factory Elements.fromJson(Map<String, dynamic> json) => Elements(
        type: json["type"]?.toString() ?? "",
        id: (json["id"] as num).toInt(),
        lat: (json["lat"] as num).toDouble(),
        lon: (json["lon"] as num).toDouble(),
        tags: Tags.fromJson(json["tags"] as Map<String, dynamic>?),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "id": id,
        "lat": lat,
        "lon": lon,
        "tags": tags.toJson(),
      };
}

class Tags {
  final String? amenity;
  final String? name;
  final String? addrStreet;
  final String? addrHousenumber;
  final String? addrCity;
  final String? phone;
  final String? openingHours;

  Tags({
    this.amenity,
    this.name,
    this.addrStreet,
    this.addrHousenumber,
    this.addrCity,
    this.phone,
    this.openingHours,
  });

  factory Tags.fromJson(Map<String, dynamic>? json) {
    json ??= <String, dynamic>{};
    return Tags(
      amenity: json["amenity"]?.toString(),
      name: json["name"]?.toString(),
      addrStreet: json["addr:street"]?.toString(),
      addrHousenumber: json["addr:housenumber"]?.toString(),
      addrCity: json["addr:city"]?.toString(),
      phone: json["phone"]?.toString(),
      openingHours: json["opening_hours"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "amenity": amenity,
        "name": name,
        "addr:street": addrStreet,
        "addr:housenumber": addrHousenumber,
        "addr:city": addrCity,
        "phone": phone,
        "opening_hours": openingHours,
      };
}
