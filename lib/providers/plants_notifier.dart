import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantmanager/data/models/plant.dart';
import 'package:plantmanager/data/repositories/plant_repository.dart';
import 'package:plantmanager/providers/providers.dart';

class PlantsNotifier extends AsyncNotifier<List<Plant>> {
  PlantRepository get _repository => ref.read(plantRepoProvider);

  @override
  Future<List<Plant>> build() async => _repository.getAll();

  Future<void> add(Plant plant) => _update(() => _repository.add(plant));

  Future<void> updatePlant(Plant plant) =>
      _update(() => _repository.update(plant));

  Future<void> delete(String id) => _update(() async {
        await ref.read(plantNoteRepoProvider).deleteByPlant(id);
        await ref.read(wateringRepoProvider).deleteByPlant(id);
        await _repository.delete(id);
      });

  Future<void> _update(Future<void> Function() operation) async {
    state = const AsyncLoading<List<Plant>>();
    state = await AsyncValue.guard(() async {
      await operation();
      return _repository.getAll();
    });
  }
}
