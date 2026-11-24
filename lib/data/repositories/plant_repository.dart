import 'package:hive_ce/hive.dart';
import 'package:plantmanager/data/models/plant.dart';
import 'package:plantmanager/data/storage.dart';
import 'package:plantmanager/data/value_objects/watering_interval_days_vo.dart';

/// Хранение пользовательских растений.
class PlantRepository {
  final Box<Map> _box;

  PlantRepository([Box<Map>? box]) : _box = box ?? Storage.plants;

  List<Plant> getAll() => _box.values
      .map((value) => _fromMap(Map<String, dynamic>.from(value)))
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  Plant? getById(String id) {
    final value = _box.get(id);
    return value == null ? null : _fromMap(Map<String, dynamic>.from(value));
  }

  Future<void> add(Plant plant) => _box.put(plant.id, _toMap(plant));

  Future<void> update(Plant plant) => _box.put(plant.id, _toMap(plant));

  Future<void> delete(String id) => _box.delete(id);

  Map<String, dynamic> _toMap(Plant plant) {
    final json = plant.toJson();
    json['wateringIntervalDays'] = plant.wateringIntervalDays.value;
    return json;
  }

  Plant _fromMap(Map<String, dynamic> json) {
    json['wateringIntervalDays'] =
        WateringIntervalDaysVo(json['wateringIntervalDays'] as int);
    json.remove('notes');
    json['diseases'] = null;
    return Plant.fromJson(json);
  }
}
