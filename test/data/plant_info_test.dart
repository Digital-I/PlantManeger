import 'package:flutter_test/flutter_test.dart';
import 'package:plantmanager/data/models/plant_info.dart';
import 'package:plantmanager/data/models/light_enum.dart';
import 'package:plantmanager/data/models/soil_enum.dart';
import 'package:plantmanager/data/value_objects/humidity_percent_vo.dart';
import 'package:plantmanager/data/value_objects/temperature_vo.dart';
import 'package:plantmanager/data/value_objects/watering_interval_days_vo.dart';
import 'package:plantmanager/data/value_objects/watering_ml_vo.dart';

void main() {
  Map<String, dynamic> validPlantInfo() => {
        'id': 'plant-1',
        'name': 'Монстера',
        'latinName': 'Monstera deliciosa',
        'description': 'Растение',
        'light': [LightTag.brightIndirect.tag],
        'soil': [SoilTag.universal.tag],
        'wateringMl': WateringMLVo(100),
        'wateringIntervalDays': WateringIntervalDaysVo(7),
        'humidityPercent': HumidityPercentVo(60),
        'temperatureMinC': TemperatureVo(18),
        'temperatureMaxC': TemperatureVo(25),
      };

  test('wraps a field parse error with plant id, name and field', () {
    final json = validPlantInfo()..['humidityPercent'] = 'invalid';

    expect(
      () => PlantInfo.fromJson(json),
      throwsA(
        isA<PlantInfoDataError>()
            .having((error) => error.plantId, 'plantId', 'plant-1')
            .having((error) => error.plantName, 'plantName', 'Монстера')
            .having((error) => error.field, 'field', 'humidityPercent'),
      ),
    );
  });

  test('reports an invalid list item by its indexed field', () {
    final json = validPlantInfo()..['light'] = ['unknown_light'];

    expect(
      () => PlantInfo.fromJson(json),
      throwsA(
        isA<PlantInfoDataError>()
            .having((error) => error.field, 'field', 'light[0]')
            .having(
                (error) => error.toString(), 'message', contains('Монстера')),
      ),
    );
  });
}
