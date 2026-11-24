import 'dart:typed_data';

import 'package:plantmanager/data/models/disease.dart';
import 'package:plantmanager/data/value_objects/length_vo.dart';
import 'package:plantmanager/data/value_objects/user_note_vo.dart';

/// Модель измерения роста растения
class UserNotePlant {
  final String id;
  final String plantId;
  final DateTime date;
  final LengthPlantVO? heightCm;
  final int? leavesCount; // ???
  final UserNoteVo? note;
  final Uint8List? photo;
  final List<Disease>? disease;

  UserNotePlant({
    required this.id,
    required this.plantId,
    required this.date,
    this.heightCm,
    this.leavesCount,
    this.note,
    this.photo,
    this.disease,
  });

  /// Преобразование в JSON-карту для Hive
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'date': date.toIso8601String(),
      'heightCm': heightCm,
      'leavesCount': leavesCount,
      'note': note,
      'photo': photo,
      'disease': disease,
    };
  }

  /// Создание объекта из JSON-карты
  factory UserNotePlant.fromJson(Map<String, dynamic> json) {
    return UserNotePlant(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      date: DateTime.parse(json['date'] as String),
      heightCm: (json['heightCm'] as LengthPlantVO),
      leavesCount: json['leavesCount'] as int?,
      note: json['note'] as UserNoteVo,
      photo: json['photo'] as Uint8List?,
    );
  }
}
