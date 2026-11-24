import 'dart:typed_data';

/// Запись журнала растения: измерения, заметка, фото и текущее состояние болезней.
class PlantNote {
  final String id;
  final String plantId;
  final DateTime date;
  final Uint8List? photo;
  final String? text;
  final double? heightCm;
  final List<String> diseaseIds;

  PlantNote({
    required this.id,
    required this.plantId,
    required this.date,
    this.photo,
    this.text,
    this.heightCm,
    List<String> diseaseIds = const [],
  }) : diseaseIds = List.unmodifiable(diseaseIds);

  Map<String, dynamic> toJson() => {
        'id': id,
        'plantId': plantId,
        'date': date.toIso8601String(),
        'photo': photo,
        'text': text,
        'heightCm': heightCm,
        'diseaseIds': diseaseIds,
      };

  factory PlantNote.fromJson(Map<String, dynamic> json) => PlantNote(
        id: json['id'] as String,
        plantId: json['plantId'] as String,
        date: DateTime.parse(json['date'] as String),
        photo: json['photo'] as Uint8List?,
        text: json['text'] as String?,
        heightCm: (json['heightCm'] as num?)?.toDouble(),
        diseaseIds: (json['diseaseIds'] as List<dynamic>? ?? const [])
            .cast<String>(),
      );

  PlantNote copyWith({
    String? id,
    String? plantId,
    DateTime? date,
    Uint8List? photo,
    bool clearPhoto = false,
    String? text,
    bool clearText = false,
    double? heightCm,
    bool clearHeight = false,
    List<String>? diseaseIds,
  }) =>
      PlantNote(
        id: id ?? this.id,
        plantId: plantId ?? this.plantId,
        date: date ?? this.date,
        photo: clearPhoto ? null : photo ?? this.photo,
        text: clearText ? null : text ?? this.text,
        heightCm: clearHeight ? null : heightCm ?? this.heightCm,
        diseaseIds: diseaseIds ?? this.diseaseIds,
      );
}
