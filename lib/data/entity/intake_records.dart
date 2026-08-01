
import 'package:floor/floor.dart';
import 'package:reminder_app/data/entity/medications.dart';

@Entity(
  tableName: 'intake_records',
  foreignKeys: [
    ForeignKey(
      childColumns: ['medId'],
      parentColumns: ['medId'],
      entity: Medication,
      onDelete: ForeignKeyAction.cascade,
      onUpdate: ForeignKeyAction.cascade,
    ),
  ],
)
class IntakeRecord {
  @PrimaryKey(autoGenerate: true)
  final int? recordId;

  final int medId;
  final String? takenAt; 
  final String scheduledAt;
  final String status; // 'taken' or 'missed' or 'pending'
  final String? syncStatus; // ''synced' or 'not_synced'

  IntakeRecord({
    this.recordId,
    required this.medId,
    this.takenAt,
    required this.scheduledAt,
    required this.status,
    this.syncStatus,
  });
}
