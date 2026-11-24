import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantmanager/core/date_utils.dart';
import 'package:plantmanager/core/watering_calculator.dart';
import 'package:plantmanager/data/models/disease.dart';
import 'package:plantmanager/data/models/plant.dart';
import 'package:plantmanager/data/models/plant_note.dart';
import 'package:plantmanager/data/models/plant_info.dart';
import 'package:plantmanager/data/models/symptom_enum.dart';
import 'package:plantmanager/data/models/watering_log.dart';
import 'package:plantmanager/features/calendar/calendar_event.dart';
import 'package:plantmanager/data/repositories/catalog_repository.dart';
import 'package:plantmanager/data/repositories/disease_repository.dart';
import 'package:plantmanager/data/repositories/plant_repository.dart';
import 'package:plantmanager/data/repositories/plant_note_repository.dart';
import 'package:plantmanager/data/repositories/watering_repository.dart';
import 'package:plantmanager/providers/plants_notifier.dart';
import 'package:plantmanager/providers/plant_notes_notifier.dart';
import 'package:plantmanager/providers/watering_logs_notifier.dart';

final plantRepoProvider = Provider<PlantRepository>((ref) => PlantRepository());
final wateringRepoProvider =
    Provider<WateringRepository>((ref) => WateringRepository());
final catalogRepoProvider =
    Provider<CatalogRepository>((ref) => CatalogRepository());
final diseaseRepoProvider =
    Provider<DiseaseRepository>((ref) => DiseaseRepository());

final plantsProvider = AsyncNotifierProvider<PlantsNotifier, List<Plant>>(
  PlantsNotifier.new,
);

final plantProvider = Provider.family<Plant?, String>((ref, id) {
  final plants = ref.watch(plantsProvider).asData?.value ?? const <Plant>[];
  for (final plant in plants) {
    if (plant.id == id) return plant;
  }
  return null;
});

final wateringLogsProvider =
    AsyncNotifierProvider<WateringLogsNotifier, List<WateringLog>>(
  WateringLogsNotifier.new,
);

typedef TodayTask = ({Plant plant, bool overdue});

final todayTasksProvider = Provider<List<TodayTask>>((ref) {
  final plants = ref.watch(plantsProvider).asData?.value ?? const <Plant>[];
  final logs =
      ref.watch(wateringLogsProvider).asData?.value ?? const <WateringLog>[];
  final today = dateOnly(DateTime.now());
  final lastDoneByPlant = <String, DateTime>{};
  final doneToday = <String>{};

  for (final log in logs) {
    if (!log.done) continue;
    if (isSameDay(log.date, today)) doneToday.add(log.plantId);
    final previous = lastDoneByPlant[log.plantId];
    if (previous == null || log.date.isAfter(previous)) {
      lastDoneByPlant[log.plantId] = log.date;
    }
  }

  final tasks = <TodayTask>[];
  for (final plant in plants) {
    if (doneToday.contains(plant.id)) continue;
    final dueDate = nextWatering(plant, lastDoneByPlant[plant.id]);
    if (!dueDate.isAfter(today)) {
      tasks.add((plant: plant, overdue: dueDate.isBefore(today)));
    }
  }
  return tasks;
});

final calendarEventsProvider =
    Provider<Map<DateTime, List<CalendarEvent>>>((ref) {
  final plants = ref.watch(plantsProvider).asData?.value ?? const <Plant>[];
  final logs =
      ref.watch(wateringLogsProvider).asData?.value ?? const <WateringLog>[];
  return buildCalendarEvents(plants: plants, logs: logs);
});

final plantNoteRepoProvider =
    Provider<PlantNoteRepository>((ref) => PlantNoteRepository());

final plantNotesProvider = AsyncNotifierProvider.family<PlantNotesNotifier,
    List<PlantNote>, String>(PlantNotesNotifier.new);

final currentDiseaseIdsProvider = Provider.family<List<String>, String>(
  (ref, plantId) {
    final notes = ref.watch(plantNotesProvider(plantId)).asData?.value ??
        const <PlantNote>[];
    if (notes.isEmpty) return const [];
    final latest = notes.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
    return latest.diseaseIds;
  },
);

typedef PlantHealth = ({bool healthy, List<Disease> diseases});

final plantHealthProvider = Provider.family<PlantHealth, String>((ref, plantId) {
  final ids = ref.watch(currentDiseaseIdsProvider(plantId)).toSet();
  final all = ref.watch(diseasesProvider).asData?.value ?? const <Disease>[];
  final affected = all.where((disease) => ids.contains(disease.id)).toList();
  return (healthy: affected.isEmpty, diseases: affected);
});

final heightPointsProvider =
    Provider.family<List<({DateTime date, double heightCm})>, String>(
  (ref, plantId) {
    final notes = ref.watch(plantNotesProvider(plantId)).asData?.value ??
        const <PlantNote>[];
    final points = notes
        .where((note) => note.heightCm != null)
        .map((note) => (date: note.date, heightCm: note.heightCm!))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return points;
  },
);

enum DiseaseEventType { sick, healed }

typedef DiseaseEvent = ({DateTime date, String diseaseId, DiseaseEventType type});

final diseaseEventsProvider =
    Provider.family<List<DiseaseEvent>, String>((ref, plantId) {
  final notes = [...(ref.watch(plantNotesProvider(plantId)).asData?.value ??
      const <PlantNote>[]) ]
    ..sort((a, b) => a.date.compareTo(b.date));
  final events = <DiseaseEvent>[];
  var previous = <String>{};
  for (final note in notes) {
    final current = note.diseaseIds.toSet();
    for (final id in current.difference(previous)) {
      events.add((date: note.date, diseaseId: id, type: DiseaseEventType.sick));
    }
    for (final id in previous.difference(current)) {
      events.add((date: note.date, diseaseId: id, type: DiseaseEventType.healed));
    }
    previous = current;
  }
  return events;
});

final catalogProvider = FutureProvider<List<PlantInfo>>(
  (ref) => ref.watch(catalogRepoProvider).load(),
);

final catalogSearchProvider = StateProvider<String>((ref) => '');

final filteredCatalogProvider = Provider<List<PlantInfo>>((ref) {
  final catalog =
      ref.watch(catalogProvider).asData?.value ?? const <PlantInfo>[];
  final query = ref.watch(catalogSearchProvider).trim().toLowerCase();
  if (query.isEmpty) return catalog;
  return catalog
      .where((plant) =>
          plant.name.toLowerCase().contains(query) ||
          plant.latinName.toLowerCase().contains(query))
      .toList();
});

final diseasesProvider = FutureProvider<List<Disease>>(
  (ref) => ref.watch(diseaseRepoProvider).load(),
);

typedef DiagnosisInput = ({Plant plant, Set<Symptom> selected});

final diagnosisProvider =
    Provider.family<List<(Disease, double)>, DiagnosisInput>((ref, input) {
  var diseases = ref.watch(diseasesProvider).asData?.value ?? const <Disease>[];
  final catalogId = input.plant.catalogId;
  if (catalogId != null) {
    diseases = diseases
        .where((disease) => disease.affectedPlantIds.contains(catalogId))
        .toList();
  }

  final matches = <(Disease, double)>[];
  for (final disease in diseases) {
    final matchedCount = disease.symptoms
        .where((symptom) => input.selected.contains(symptom))
        .length;
    if (matchedCount == 0 || disease.symptoms.isEmpty) continue;
    matches.add((disease, matchedCount / disease.symptoms.length));
  }
  matches.sort((a, b) => b.$2.compareTo(a.$2));
  return matches;
});
