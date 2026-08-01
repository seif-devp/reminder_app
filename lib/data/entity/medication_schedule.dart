
import 'package:floor/floor.dart';
import 'package:reminder_app/data/entity/medications.dart';

@Entity(
  tableName: 'medication_schedule',
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
class MedicationSchedule {
  @PrimaryKey(autoGenerate: true)
  final int? scheduleId;
  final int medId;
  final String intakeTime; 
  final String? syncStatus; // 'synced' or 'not_synced'

  MedicationSchedule({
    this.scheduleId,
    required this.medId,
    required this.intakeTime,
    this.syncStatus,
  });
}

