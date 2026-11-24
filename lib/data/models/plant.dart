import 'dart:typed_data';

import 'package:plantmanager/data/value_objects/watering_interval_days_vo.dart';

/// Модель растения
class Plant {
  final String id;
  final String name;
  final String species;
  final Uint8List? photo;
  final DateTime createdAt;
  final DateTime plantingDate;
  final WateringIntervalDaysVo wateringIntervalDays;
  final String? catalogId;

  Plant({
    required this.id,
    required this.name,
    required this.species,
    this.photo,
    required this.createdAt,
    required this.plantingDate,
    required this.wateringIntervalDays,
    this.catalogId,
  });

  /// Создаёт копию растения с указанными изменениями.
  Plant copyWith({
    String? id,
    String? name,
    String? species,
    Uint8List? photo,
    DateTime? createdAt,
    DateTime? plantingDate,
    WateringIntervalDaysVo? wateringIntervalDays,
    String? catalogId,
    bool clearCatalogId = false,
  }) =>
      Plant(
        id: id ?? this.id,
        name: name ?? this.name,
        species: species ?? this.species,
        photo: photo ?? this.photo,
        createdAt: createdAt ?? this.createdAt,
        plantingDate: plantingDate ?? this.plantingDate,
        wateringIntervalDays: wateringIntervalDays ?? this.wateringIntervalDays,
        catalogId: clearCatalogId ? null : catalogId ?? this.catalogId,
      );

  /// Преобразование в JSON-карту для Hive
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'photo': photo, // Uint8List сохраняется как массив байт
      'createdAt': createdAt.toIso8601String(),
      'plantingDate': plantingDate.toIso8601String(),
      'wateringIntervalDays': wateringIntervalDays,
      'catalogId': catalogId,
    };
  }

  /// Создание объекта из JSON-карты
  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      photo: json['photo'] as Uint8List?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      plantingDate: DateTime.parse(json['plantingDate'] as String),
      wateringIntervalDays:
          json['wateringIntervalDays'] as WateringIntervalDaysVo,
      catalogId: json['catalogId'] as String?,
    );
  }
}
