import 'package:plantmanager/data/value_objects/humidity_percent_vo.dart';
import 'package:plantmanager/data/value_objects/watering_ml_vo.dart';
import 'package:plantmanager/data/value_objects/watering_interval_days_vo.dart';
import 'package:plantmanager/data/value_objects/temperature_vo.dart';
import 'soil_enum.dart';
import 'light_enum.dart';

/// Ошибка разбора данных растения с контекстом записи и поля.
class PlantInfoDataError implements Exception {
  final String plantId;
  final String plantName;
  final String field;
  final Object cause;

  const PlantInfoDataError({
    required this.plantId,
    required this.plantName,
    required this.field,
    required this.cause,
  });

  @override
  String toString() =>
      'Не удалось прочитать растение "$plantName" (id: $plantId), '
      'поле "$field": $cause';
}

class PlantInfo {
  final String id, name, latinName, description;
  final List<LightTag> light;
  final List<SoilTag> soil;
  final WateringMLVo wateringMl;
  final WateringIntervalDaysVo wateringIntervalDays;
  final HumidityPercentVo humidityPercent;
  final TemperatureVo temperatureMinC, temperatureMaxC;

  const PlantInfo({
    required this.id,
    required this.name,
    required this.latinName,
    required this.description,
    required this.light,
    required this.soil,
    required this.wateringMl,
    required this.wateringIntervalDays,
    required this.humidityPercent,
    required this.temperatureMinC,
    required this.temperatureMaxC,
  });

  factory PlantInfo.fromJson(Map<String, dynamic> j) {
    final plantId = _contextValue(j['id']);
    final plantName = _contextValue(j['name']);

    T read<T>(String field, T Function() parse) {
      try {
        return parse();
      } on PlantInfoDataError {
        rethrow;
      } catch (error) {
        throw PlantInfoDataError(
          plantId: plantId,
          plantName: plantName,
          field: field,
          cause: error,
        );
      }
    }

    List<LightTag> readLight() {
      final values =
          read<List<dynamic>>('light', () => j['light'] as List<dynamic>);
      return List.generate(
        values.length,
        (index) => read<LightTag>(
          'light[$index]',
          () => LightTag.fromTag(values[index] as String),
        ),
      );
    }

    List<SoilTag> readSoil() {
      final values =
          read<List<dynamic>>('soil', () => j['soil'] as List<dynamic>);
      return List.generate(
        values.length,
        (index) => read<SoilTag>(
          'soil[$index]',
          () => SoilTag.fromTag(values[index] as String),
        ),
      );
    }

    return PlantInfo(
      id: read<String>('id', () => j['id'] as String),
      name: read<String>('name', () => j['name'] as String),
      latinName: read<String>('latinName', () => j['latinName'] as String),
      description:
          read<String>('description', () => j['description'] as String),
      light: read('light', readLight),
      soil: read('soil', readSoil),
      wateringMl: read('wateringMl', () => j['wateringMl'] as WateringMLVo),
      wateringIntervalDays: read(
        'wateringIntervalDays',
        () => j['wateringIntervalDays'] as WateringIntervalDaysVo,
      ),
      humidityPercent: read(
        'humidityPercent',
        () => j['humidityPercent'] as HumidityPercentVo,
      ),
      temperatureMinC: read(
        'temperatureMinC',
        () => j['temperatureMinC'] as TemperatureVo,
      ),
      temperatureMaxC: read(
        'temperatureMaxC',
        () => j['temperatureMaxC'] as TemperatureVo,
      ),
    );
  }

  static String _contextValue(Object? value) {
    if (value == null) return '<не указано>';
    return value.toString();
  }
}
