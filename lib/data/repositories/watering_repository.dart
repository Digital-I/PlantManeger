import 'package:hive_ce/hive.dart';
import 'package:plantmanager/data/models/watering_log.dart';
import 'package:plantmanager/data/storage.dart';
import 'package:plantmanager/core/date_utils.dart';

/// Хранение отметок о поливе.
class WateringRepository {
  final Box<Map> _box;

  WateringRepository([Box<Map>? box]) : _box = box ?? Storage.wateringLogs;

  List<WateringLog> getByPlant(String plantId) =>
      getAll().where((log) => log.plantId == plantId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<WateringLog> getByDay(DateTime day) {
    final normalizedDay = dateOnly(day);
    return getAll().where((log) => isSameDay(log.date, normalizedDay)).toList();
  }

  List<WateringLog> getAll() => _box.values
      .map((value) => WateringLog.fromJson(Map<String, dynamic>.from(value)))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  Future<void> markDone(String plantId, DateTime day) {
    final normalizedDay = dateOnly(day);
    final key = _key(plantId, normalizedDay);
    return _box.put(
      key,
      WateringLog(
        id: key,
        plantId: plantId,
        date: normalizedDay,
        done: true,
      ).toJson(),
    );
  }

  Future<void> unmark(String plantId, DateTime day) =>
      _box.delete(_key(plantId, dateOnly(day)));

  DateTime? lastDone(String plantId) {
    final completed = getByPlant(plantId).where((log) => log.done);
    if (completed.isEmpty) return null;
    return completed.first.date;
  }

  Future<void> deleteByPlant(String plantId) async {
    final ids = _box.values
        .map((value) => Map<String, dynamic>.from(value))
        .where((json) => json['plantId'] == plantId)
        .map((json) => json['id'] as String)
        .toList();
    await _box.deleteAll(ids);
  }

  String _key(String plantId, DateTime day) =>
      '${plantId}_${day.year}-${day.month}-${day.day}';
}
