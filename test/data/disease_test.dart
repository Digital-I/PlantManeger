import 'package:flutter_test/flutter_test.dart';
import 'package:plantmanager/data/models/disease.dart';
import 'package:plantmanager/data/models/symptom_enum.dart';

void main() {
  Map<String, dynamic> validDisease() => {
        'id': 'disease-1',
        'name': 'Корневая гниль',
        'latinName': 'Root rot',
        'description': 'Описание',
        'treatment': 'Лечение',
        'severity': 'high',
        'cause': ['Переувлажнение'],
        'symptoms': [Symptom.softStem.tag],
        'affectedPlantIds': ['plant-1'],
      };

  test('wraps a field parse error with disease id, name and field', () {
    final json = validDisease()..['treatment'] = 42;

    expect(
      () => Disease.fromJson(json),
      throwsA(
        isA<DiseaseDataError>()
            .having((error) => error.diseaseId, 'diseaseId', 'disease-1')
            .having(
                (error) => error.diseaseName, 'diseaseName', 'Корневая гниль')
            .having((error) => error.field, 'field', 'treatment'),
      ),
    );
  });

  test('reports an invalid symptom by its indexed field', () {
    final json = validDisease()..['symptoms'] = ['unknown_symptom'];

    expect(
      () => Disease.fromJson(json),
      throwsA(
        isA<DiseaseDataError>()
            .having((error) => error.field, 'field', 'symptoms[0]')
            .having(
              (error) => error.toString(),
              'message',
              contains('Корневая гниль'),
            ),
      ),
    );
  });
}
