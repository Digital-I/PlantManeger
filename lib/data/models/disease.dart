import 'symptom_enum.dart';

/// Ошибка разбора данных болезни с контекстом записи и поля.
class DiseaseDataError implements Exception {
  final String diseaseId;
  final String diseaseName;
  final String field;
  final Object cause;

  const DiseaseDataError({
    required this.diseaseId,
    required this.diseaseName,
    required this.field,
    required this.cause,
  });

  @override
  String toString() =>
      'Не удалось прочитать заболевание "$diseaseName" (id: $diseaseId), '
      'поле "$field": $cause';
}

class Disease {
  final String id, name, latinName, description, treatment, severity;
  final List<String> cause;
  final List<Symptom> symptoms;
  final List<String> affectedPlantIds;

  const Disease({
    required this.id,
    required this.name,
    required this.latinName,
    required this.description,
    required this.treatment,
    required this.severity,
    required this.cause,
    required this.symptoms,
    required this.affectedPlantIds,
  });

  factory Disease.fromJson(Map<String, dynamic> j) {
    final diseaseId = _contextValue(j['id']);
    final diseaseName = _contextValue(j['name']);

    T read<T>(String field, T Function() parse) {
      try {
        return parse();
      } on DiseaseDataError {
        rethrow;
      } catch (error) {
        throw DiseaseDataError(
          diseaseId: diseaseId,
          diseaseName: diseaseName,
          field: field,
          cause: error,
        );
      }
    }

    List<String> readStringList(String field) {
      final values =
          read<List<dynamic>>(field, () => j[field] as List<dynamic>);
      return List.generate(
        values.length,
        (index) => read<String>(
          '$field[$index]',
          () => values[index] as String,
        ),
      );
    }

    List<Symptom> readSymptoms() {
      final values = read<List<dynamic>>(
        'symptoms',
        () => j['symptoms'] as List<dynamic>,
      );
      return List.generate(
        values.length,
        (index) => read<Symptom>(
          'symptoms[$index]',
          () => Symptom.fromTag(values[index] as String),
        ),
      );
    }

    return Disease(
      id: read<String>('id', () => j['id'] as String),
      name: read<String>('name', () => j['name'] as String),
      latinName: read<String>('latinName', () => j['latinName'] as String),
      description:
          read<String>('description', () => j['description'] as String),
      treatment: read<String>('treatment', () => j['treatment'] as String),
      severity: read<String>('severity', () => j['severity'] as String),
      cause: read('cause', () => readStringList('cause')),
      symptoms: read('symptoms', readSymptoms),
      affectedPlantIds: read(
        'affectedPlantIds',
        () => readStringList('affectedPlantIds'),
      ),
    );
  }

  static String _contextValue(Object? value) =>
      value?.toString() ?? '<не указано>';
}
