import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantmanager/core/date_utils.dart';
import 'package:plantmanager/data/models/watering_log.dart';
import 'package:plantmanager/data/repositories/watering_repository.dart';
import 'package:plantmanager/providers/providers.dart';

class WateringLogsNotifier extends AsyncNotifier<List<WateringLog>> {
  WateringRepository get _repository => ref.read(wateringRepoProvider);

  @override
  Future<List<WateringLog>> build() async => _repository.getAll();

  Future<void> markDone(String plantId, DateTime day) =>
      _update(() => _repository.markDone(plantId, day));

  Future<void> unmark(String plantId, DateTime day) =>
      _update(() => _repository.unmark(plantId, day));

  Future<void> toggle(String plantId, DateTime day) async {
    final marked = _repository.getByPlant(plantId).any(
          (log) => log.done && isSameDay(log.date, day),
        );
    if (marked) {
      await unmark(plantId, day);
    } else {
      await markDone(plantId, day);
    }
  }

  Future<void> _update(Future<void> Function() operation) async {
    state = const AsyncLoading<List<WateringLog>>();
    state = await AsyncValue.guard(() async {
      await operation();
      return _repository.getAll();
    });
  }
}
