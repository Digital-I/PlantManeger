import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:plantmanager/data/models/plant_info.dart';
import 'package:plantmanager/data/value_objects/humidity_percent_vo.dart';
import 'package:plantmanager/data/value_objects/temperature_vo.dart';
import 'package:plantmanager/data/value_objects/watering_interval_days_vo.dart';
import 'package:plantmanager/data/value_objects/watering_ml_vo.dart';

/// Чтение и поиск по каталогу растений из assets.
class CatalogRepository {
  List<PlantInfo>? _cache;

  Future<List<PlantInfo>> load() async {
    if (_cache != null) return _cache!;
    final source = await rootBundle.loadString('assets/plants_catalog.json');
    final decoded = jsonDecode(source) as List<dynamic>;
    _cache = decoded.map((item) {
      final json = Map<String, dynamic>.from(item as Map);
      json['wateringMl'] = WateringMLVo(json['wateringMl'] as num);
      json['wateringIntervalDays'] =
          WateringIntervalDaysVo(json['wateringIntervalDays'] as int);
      json['humidityPercent'] =
          HumidityPercentVo(json['humidityPercent'] as num);
      json['temperatureMinC'] = TemperatureVo(json['temperatureMinC'] as num);
      json['temperatureMaxC'] = TemperatureVo(json['temperatureMaxC'] as num);
      return PlantInfo.fromJson(json);
    }).toList();
    return _cache!;
  }

  Future<PlantInfo?> getById(String id) async {
    final plants = _cache ?? await load();
    for (final plant in plants) {
      if (plant.id == id) return plant;
    }
    return null;
  }

  Future<List<PlantInfo>> search(String query) async {
    final plants = _cache ?? await load();
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return List.unmodifiable(plants);
    return plants
        .where((plant) =>
            plant.name.toLowerCase().contains(normalizedQuery) ||
            plant.latinName.toLowerCase().contains(normalizedQuery))
        .toList();
  }
}
