class Medications {
  final String? medId;
  final String name;
  final double dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String durationOfUse;
  final String? notes;
  final String? imageUrl;
  final String? userId;

  Medications({
    this.medId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    required this.durationOfUse,
    this.endDate,
    this.notes,
    this.imageUrl,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'duration_of_use': durationOfUse,
      'notes': notes,
      'image_url': imageUrl,
      'user_id': userId,
    };
    if (medId != null) {
      json['med_id'] = medId;
    }
    return json;
  }
}