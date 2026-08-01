import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reminder_app/data/app_database.dart';
import 'package:path/path.dart';
import 'dart:io';


Future<void> initDatabase() async {
  await copyDatabase();

  final dir = await getApplicationDocumentsDirectory();
  final dbPath = join(dir.path, 'medication_data.db');

  database = await $FloorAppDatabase.databaseBuilder(dbPath).build();
}

late final AppDatabase database;

Future<void> copyDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final path = join(dir.path, 'medication_data.db'); 

  if (File(path).existsSync()) return;

  ByteData data = await rootBundle.load('assets/database/medication_data.db');
  List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await File(path).writeAsBytes(bytes);
}