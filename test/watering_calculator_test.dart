import 'package:flutter_test/flutter_test.dart';
import 'package:plantmanager/core/watering_calculator.dart';
import 'package:plantmanager/data/models/plant.dart';
import 'package:plantmanager/data/value_objects/watering_interval_days_vo.dart';

Plant createPlant({
  DateTime? createdAt,
  int wateringIntervalDays = 7,
}) =>
    Plant(
      id: 'plant-1',
      name: 'Монстера',
      species: 'Monstera deliciosa',
      createdAt: createdAt ?? DateTime(2025, 1, 1, 15),
      plantingDate: DateTime(2025, 1, 1),
      wateringIntervalDays: WateringIntervalDaysVo(wateringIntervalDays),
    );

void main() {
  group('nextWatering', () {
    test('uses createdAt when there are no watering marks', () {
      expect(
        nextWatering(createPlant(), null),
        DateTime(2025, 1, 8),
      );
    });

    test('uses the last completed watering when available', () {
      expect(
        nextWatering(createPlant(), DateTime(2025, 1, 15, 20)),
        DateTime(2025, 1, 22),
      );
    });
  });

  test('scheduledDays returns due dates in the next 30 days', () {
    final days = scheduledDays(
      createPlant(),
      null,
      DateTime(2025, 1, 1),
      DateTime(2025, 1, 31),
    );

    expect(days, [
      DateTime(2025, 1, 8),
      DateTime(2025, 1, 15),
      DateTime(2025, 1, 22),
      DateTime(2025, 1, 29),
    ]);
  });

  group('isOverdue', () {
    test('is true when the scheduled day has passed', () {
      expect(isOverdue(createPlant(), null, DateTime(2025, 1, 10)), isTrue);
    });

    test('is false on the scheduled day', () {
      expect(isOverdue(createPlant(), null, DateTime(2025, 1, 8)), isFalse);
    });
  });
}
