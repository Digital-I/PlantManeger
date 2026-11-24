import 'package:plantmanager/core/date_utils.dart';
import 'package:plantmanager/data/models/plant.dart';

/// Рассчитывает ближайшую дату полива после последней отметки или посадки.
DateTime nextWatering(Plant plant, DateTime? lastDone) {
  final base = dateOnly(lastDone ?? plant.createdAt);
  return dateOnly(base.add(Duration(days: plant.wateringIntervalDays.value)));
}

/// Возвращает плановые даты полива в закрытом диапазоне дат.
List<DateTime> scheduledDays(
  Plant plant,
  DateTime? lastDone,
  DateTime from,
  DateTime to,
) {
  final firstDue = nextWatering(plant, lastDone);
  final firstDay = dateOnly(from);
  final lastDay = dateOnly(to);
  if (lastDay.isBefore(firstDay)) return const [];

  final interval = plant.wateringIntervalDays.value;
  var due = firstDue;
  if (due.isBefore(firstDay)) {
    final daysToStart = firstDay.difference(due).inDays;
    final intervalsToSkip = (daysToStart + interval - 1) ~/ interval;
    due = due.add(Duration(days: intervalsToSkip * interval));
  }

  final result = <DateTime>[];
  while (!due.isAfter(lastDay)) {
    result.add(due);
    due = due.add(Duration(days: interval));
  }
  return result;
}

/// Возвращает true, если плановая дата полива уже прошла.
bool isOverdue(Plant plant, DateTime? lastDone, DateTime today) =>
    nextWatering(plant, lastDone).isBefore(dateOnly(today));
