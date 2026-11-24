import 'package:plantmanager/core/date_utils.dart';
import 'package:plantmanager/core/watering_calculator.dart';
import 'package:plantmanager/data/models/plant.dart';
import 'package:plantmanager/data/models/watering_log.dart';

/// Состояние полива растения в календаре.
enum CalendarEventStatus { planned, done, overdue }

/// Событие полива для одного растения и календарного дня.
class CalendarEvent {
  const CalendarEvent({required this.plant, required this.status});

  final Plant plant;
  final CalendarEventStatus status;
}

/// Строит события с начала прошлого месяца до конца следующего.
Map<DateTime, List<CalendarEvent>> buildCalendarEvents({
  required List<Plant> plants,
  required List<WateringLog> logs,
  DateTime? today,
}) {
  final normalizedToday = dateOnly(today ?? DateTime.now());
  final firstDay = DateTime(normalizedToday.year, normalizedToday.month - 1, 1);
  final lastDay = DateTime(normalizedToday.year, normalizedToday.month + 2, 0);
  final events = <DateTime, List<CalendarEvent>>{};

  void addEvent(DateTime day, CalendarEvent event) {
    final key = dateOnly(day);
    events.putIfAbsent(key, () => <CalendarEvent>[]).add(event);
  }

  for (final log in logs.where((entry) => entry.done)) {
    final day = dateOnly(log.date);
    if (day.isBefore(firstDay) || day.isAfter(lastDay)) continue;
    final plant = plants.where((item) => item.id == log.plantId).firstOrNull;
    if (plant != null) {
      addEvent(
          day, CalendarEvent(plant: plant, status: CalendarEventStatus.done));
    }
  }

  for (final plant in plants) {
    final lastDone = logs
        .where((entry) => entry.plantId == plant.id && entry.done)
        .fold<DateTime?>(
          null,
          (latest, entry) => latest == null || entry.date.isAfter(latest)
              ? entry.date
              : latest,
        );

    for (final day in scheduledDays(plant, lastDone, firstDay, lastDay)) {
      final key = dateOnly(day);
      final alreadyDone = events[key]?.any(
            (event) =>
                event.plant.id == plant.id &&
                event.status == CalendarEventStatus.done,
          ) ??
          false;
      if (alreadyDone) continue;
      addEvent(
        key,
        CalendarEvent(
          plant: plant,
          status: key.isBefore(normalizedToday)
              ? CalendarEventStatus.overdue
              : CalendarEventStatus.planned,
        ),
      );
    }
  }

  return events;
}
