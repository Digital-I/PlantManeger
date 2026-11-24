/// Модель записи полива
class WateringLog {
  final String id;
  final String plantId;
  final DateTime date; // Только день
  final bool done;

  WateringLog({
    required this.id,
    required this.plantId,
    required this.date,
    required this.done,
  });

  /// Преобразование в JSON-карту для Hive
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'date': date.toIso8601String(),
      'done': done,
    };
  }

  /// Создание объекта из JSON-карты
  factory WateringLog.fromJson(Map<String, dynamic> json) {
    return WateringLog(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      date: DateTime.parse(json['date'] as String),
      done: json['done'] as bool,
    );
  }
}
