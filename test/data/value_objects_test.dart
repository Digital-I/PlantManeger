import 'package:flutter_test/flutter_test.dart';
import 'package:plantmanager/data/value_objects/humidity_percent_vo.dart';
import 'package:plantmanager/data/value_objects/length_vo.dart';
import 'package:plantmanager/data/value_objects/temperature_vo.dart';
import 'package:plantmanager/data/value_objects/user_note_vo.dart';
import 'package:plantmanager/data/value_objects/watering_ml_vo.dart';
import 'package:plantmanager/data/value_objects/watering_interval_days_vo.dart';

void main() {
  group('HumidityPercentVo', () {
    test('accepts values from 0 to 100', () {
      expect(HumidityPercentVo(0).value, 0);
      expect(HumidityPercentVo(100).value, 100);
    });
    test('rejects values outside 0 to 100 and non-finite values', () {
      expect(() => HumidityPercentVo(-1),
          throwsA(isA<HumidityPercentValidationError>()));
      expect(() => HumidityPercentVo(101),
          throwsA(isA<HumidityPercentValidationError>()));
      expect(() => HumidityPercentVo(double.nan),
          throwsA(isA<HumidityPercentValidationError>()));
    });
  });

  group('LengthPlantVO', () {
    test(
        'accepts non-negative length', () => expect(LengthPlantVO(0).value, 0));
    test('rejects negative and non-finite lengths', () {
      expect(
          () => LengthPlantVO(-1), throwsA(isA<LengthPlantValidationError>()));
      expect(() => LengthPlantVO(double.infinity),
          throwsA(isA<LengthPlantValidationError>()));
    });
  });

  group('TemperatureVo', () {
    test('accepts finite temperatures, including below zero', () {
      expect(TemperatureVo(-20).value, -20);
    });
    test('rejects non-finite temperatures', () {
      expect(() => TemperatureVo(double.nan),
          throwsA(isA<TemperatureValidationError>()));
    });
  });

  group('UserNoteVo', () {
    test('trims whitespace and accepts up to 500 characters', () {
      expect(UserNoteVo(' note ').value, 'note');
      expect(UserNoteVo('x' * 500).value.length, 500);
    });
    test('rejects notes longer than 500 characters', () {
      expect(
          () => UserNoteVo('x' * 501), throwsA(isA<UserNoteValidationError>()));
    });
  });

  group('WateringMLVo', () {
    test('accepts a positive volume', () => expect(WateringMLVo(1).value, 1));
    test('rejects zero, negative and non-finite volumes', () {
      expect(() => WateringMLVo(0), throwsA(isA<WateringMLValidationError>()));
      expect(() => WateringMLVo(-1), throwsA(isA<WateringMLValidationError>()));
      expect(() => WateringMLVo(double.infinity),
          throwsA(isA<WateringMLValidationError>()));
    });
  });

  group('WateringIntervalDaysVo', () {
    test('accepts a positive integer interval', () {
      expect(WateringIntervalDaysVo(1).value, 1);
    });
    test('rejects zero and negative intervals', () {
      expect(() => WateringIntervalDaysVo(0),
          throwsA(isA<WateringIntervalDaysValidationError>()));
      expect(() => WateringIntervalDaysVo(-1),
          throwsA(isA<WateringIntervalDaysValidationError>()));
    });
  });
}
