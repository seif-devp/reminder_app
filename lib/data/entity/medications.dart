import 'package:floor/floor.dart';
import 'package:reminder_app/data/entity/users.dart';

@Entity(
  tableName: 'medications',
  foreignKeys: [
    ForeignKey(
      childColumns: ['userId'],
      parentColumns: ['userId'],
      entity: User,
      onDelete: ForeignKeyAction.cascade,
      onUpdate: ForeignKeyAction.cascade,
    ),
  ],
)
class Medication {
  @PrimaryKey(autoGenerate: true)
  final int? medId;
  final String userId;
  final String name;
  final String dosage;
  final String frequency;
  final String durationOfUse;
  final String? notes;
  final String? imageUrl;
  final String? syncStatus; // 'synced' or 'not_synced'
  final String? isDeleted; // 'true' or 'false'

  Medication({
    this.medId,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.durationOfUse,
    this.notes,
    this.imageUrl,
    this.syncStatus,
    this.isDeleted,
  });
}
