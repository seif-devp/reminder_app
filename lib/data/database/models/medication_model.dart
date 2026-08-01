class MedicationModel {
  int? medId;
  int userId;
  String name;
  String dosage;
  String frequency;
  String durationOfUse;
  String startDate;
  String endDate;
  String? notes;
  String? imageUrl;

  MedicationModel({
    this.medId,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.durationOfUse,
    required this.startDate,
    required this.endDate,
    this.notes,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'med_id': medId,
      'user_id': userId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration_of_use': durationOfUse,
      'start_date': startDate,
      'end_date': endDate,
      'notes': notes,
      'image_url': imageUrl,
    };
  }

  factory MedicationModel.fromMap(Map<String, dynamic> map) {
    return MedicationModel(
      medId: map['med_id'],
      userId: map['user_id'],
      name: map['name'],
      dosage: map['dosage'],
      frequency: map['frequency'],
      durationOfUse: map['duration_of_use'],
      startDate: map['start_date'],
      endDate: map['end_date'],
      notes: map['notes'],
      imageUrl: map['image_url'],
    );
  }
}
