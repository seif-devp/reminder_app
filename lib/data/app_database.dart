import 'package:floor/floor.dart';
// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:reminder_app/data/dao/documents_dao.dart';
import 'package:reminder_app/data/dao/intake_record_dao.dart';
import 'package:reminder_app/data/dao/medication_schedule_dao.dart';
import 'package:reminder_app/data/dao/medications_dao.dart';
import 'package:reminder_app/data/dao/user_dao.dart';
import 'package:reminder_app/data/entity/documents.dart';
import 'package:reminder_app/data/entity/intake_records.dart';
import 'package:reminder_app/data/entity/medication_schedule.dart';
import 'package:reminder_app/data/entity/medications.dart';
import 'package:reminder_app/data/entity/users.dart';
part 'app_database.g.dart';

@Database(version: 1, entities: [
  User,
  Medication,
  MedicationSchedule,
  IntakeRecord,
  Document,
])
abstract class AppDatabase extends FloorDatabase {
  UserDao get userDao; 
  MedicationsDao get medicationsDao;
  MedicationScheduleDao get medicationScheduleDao; 
  IntakeRecordDao get intakeRecordDao;
  DocumentsDao get documentsDao; 
}
