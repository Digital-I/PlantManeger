import 'package:hive_ce_flutter/hive_flutter.dart';

/// Инициализация Hive и постоянные имена локальных хранилищ.
class Storage {
  Storage._();

  static const String plantsBoxName = 'plants';
  static const String plantNotesBoxName = 'plant_notes';
  static const String wateringLogsBoxName = 'watering_logs';

  static late Box<Map> plants;
  static late Box<Map> plantNotes;
  static late Box<Map> wateringLogs;

  static Future<void> init() async {
    await Hive.initFlutter();
    plants = await Hive.openBox<Map>(plantsBoxName);
    plantNotes = await Hive.openBox<Map>(plantNotesBoxName);
    wateringLogs = await Hive.openBox<Map>(wateringLogsBoxName);
  }
}
