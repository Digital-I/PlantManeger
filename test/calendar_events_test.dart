import 'package:flutter_test/flutter_test.dart';
import 'package:plantmanager/data/models/plant.dart';
import 'package:plantmanager/data/models/watering_log.dart';
import 'package:plantmanager/data/value_objects/watering_interval_days_vo.dart';
import 'package:plantmanager/features/calendar/calendar_event.dart';

void main() {
  test('assigns done, overdue and planned statuses to the correct days', () {
    final plant = Plant(
      id: 'plant-1',
      name: 'Монстера',
      species: 'Monstera deliciosa',
      createdAt: DateTime(2025, 1, 1),
      plantingDate: DateTime(2025, 1, 1),
      wateringIntervalDays: WateringIntervalDaysVo(3),
    );
    final logs = [
      WateringLog(
        id: 'plant-1_2025-1-11',
        plantId: plant.id,
        date: DateTime(2025, 1, 11),
        done: true,
      ),
    ];

    final events = buildCalendarEvents(
      plants: [plant],
      logs: logs,
      today: DateTime(2025, 1, 15),
    );

    expect(
      events[DateTime(2025, 1, 11)]!.single.status,
      CalendarEventStatus.done,
    );
    expect(
      events[DateTime(2025, 1, 14)]!.single.status,
      CalendarEventStatus.overdue,
    );
    expect(
      events[DateTime(2025, 1, 17)]!.single.status,
      CalendarEventStatus.planned,
    );
  });
}
