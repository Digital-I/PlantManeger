import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantmanager/data/models/disease.dart';
import 'package:plantmanager/data/models/plant.dart';
import 'package:plantmanager/data/models/symptom_enum.dart';
import 'package:plantmanager/data/repositories/disease_repository.dart';
import 'package:plantmanager/data/value_objects/watering_interval_days_vo.dart';
import 'package:plantmanager/providers/providers.dart';

class FakeDiseaseRepository extends DiseaseRepository {
  FakeDiseaseRepository(this.diseases);

  final List<Disease> diseases;

  @override
  Future<List<Disease>> load() async => diseases;
}

void main() {
  final diseases = <Disease>[
    const Disease(
      id: 'high',
      name: 'Высокое совпадение',
      latinName: 'High match',
      description: '',
      treatment: '',
      severity: '',
      cause: [],
      symptoms: [Symptom.yellowLeaves, Symptom.brownTips],
      affectedPlantIds: ['monstera'],
    ),
    const Disease(
      id: 'medium',
      name: 'Среднее совпадение',
      latinName: 'Medium match',
      description: '',
      treatment: '',
      severity: '',
      cause: [],
      symptoms: [
        Symptom.yellowLeaves,
        Symptom.brownTips,
        Symptom.wilting,
      ],
      affectedPlantIds: ['monstera'],
    ),
    const Disease(
      id: 'other-plant',
      name: 'Другое растение',
      latinName: 'Other plant',
      description: '',
      treatment: '',
      severity: '',
      cause: [],
      symptoms: [Symptom.yellowLeaves],
      affectedPlantIds: ['ficus'],
    ),
    const Disease(
      id: 'no-match',
      name: 'Нет совпадений',
      latinName: 'No match',
      description: '',
      treatment: '',
      severity: '',
      cause: [],
      symptoms: [Symptom.softStem],
      affectedPlantIds: ['monstera'],
    ),
  ];

  Plant createPlant({String? catalogId}) => Plant(
        id: 'plant-1',
        name: 'Монстера',
        species: 'Monstera deliciosa',
        createdAt: DateTime(2025),
        plantingDate: DateTime(2025),
        wateringIntervalDays: WateringIntervalDaysVo(7),
          catalogId: catalogId,
      );

  Future<ProviderContainer> createContainer() async {
    final container = ProviderContainer(
      overrides: [
        diseaseRepoProvider.overrideWithValue(FakeDiseaseRepository(diseases)),
      ],
    );
    await container.read(diseasesProvider.future);
    return container;
  }

  test('filters diseases by plant catalog id and sorts by match ratio',
      () async {
    final container = await createContainer();
    addTearDown(container.dispose);

    final result = container.read(
      diagnosisProvider((
        plant: createPlant(catalogId: 'monstera'),
        selected: {Symptom.yellowLeaves, Symptom.brownTips},
      )),
    );

    expect(result.map((entry) => entry.$1.id), ['high', 'medium']);
    expect(result.map((entry) => entry.$2), [1.0, 2 / 3]);
  });

  test('includes diseases for any plant when catalog id is absent', () async {
    final container = await createContainer();
    addTearDown(container.dispose);

    final result = container.read(
      diagnosisProvider((
        plant: createPlant(),
        selected: {Symptom.yellowLeaves, Symptom.brownTips},
      )),
    );

    expect(result.map((entry) => entry.$1.id), [
      'high',
      'other-plant',
      'medium',
    ]);
    expect(result.any((entry) => entry.$1.id == 'no-match'), isFalse);
  });
}
