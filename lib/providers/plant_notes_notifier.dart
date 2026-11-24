import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantmanager/data/models/plant_note.dart';
import 'package:plantmanager/data/repositories/plant_note_repository.dart';
import 'package:plantmanager/providers/providers.dart';

class PlantNotesNotifier extends FamilyAsyncNotifier<List<PlantNote>, String> {
  late String _plantId;
  PlantNoteRepository get _repository => ref.read(plantNoteRepoProvider);

  @override
  Future<List<PlantNote>> build(String arg) async {
    _plantId = arg;
    return _repository.getByPlant(arg);
  }

  Future<void> add(PlantNote note) => _update(() => _repository.add(note));
  Future<void> updateNote(PlantNote note) =>
      _update(() => _repository.update(note));
  Future<void> delete(String id) => _update(() => _repository.delete(id));

  Future<void> _update(Future<void> Function() operation) async {
    state = const AsyncLoading<List<PlantNote>>();
    state = await AsyncValue.guard(() async {
      await operation();
      return _repository.getByPlant(_plantId);
    });
  }
}
