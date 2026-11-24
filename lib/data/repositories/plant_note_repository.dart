import 'package:hive_ce/hive.dart';
import 'package:plantmanager/data/models/plant_note.dart';
import 'package:plantmanager/data/storage.dart';

class PlantNoteRepository {
  final Box<Map> _box;

  PlantNoteRepository([Box<Map>? box]) : _box = box ?? Storage.plantNotes;

  List<PlantNote> getByPlant(String plantId) => _box.values
      .map((value) => PlantNote.fromJson(Map<String, dynamic>.from(value)))
      .where((note) => note.plantId == plantId)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  Future<void> add(PlantNote note) => _box.put(note.id, note.toJson());

  Future<void> update(PlantNote note) => _box.put(note.id, note.toJson());

  Future<void> delete(String id) => _box.delete(id);

  Future<void> deleteByPlant(String plantId) async {
    final ids = _box.values
        .map((value) => Map<String, dynamic>.from(value))
        .where((json) => json['plantId'] == plantId)
        .map((json) => json['id'] as String)
        .toList();
    await _box.deleteAll(ids);
  }
}
