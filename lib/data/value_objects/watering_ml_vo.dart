/// Ошибка, возникающая при создании некорректного объёма полива.
class WateringMLValidationError implements Exception {
  final double value;
  const WateringMLValidationError(this.value);
  @override
  String toString() =>
      'Объём воды должен быть конечным числом больше 0 мл. Получено: $value.';
}

/// Объём воды для одного полива в миллилитрах.
class WateringMLVo {
  final double value;
  WateringMLVo(num value) : value = value.toDouble() {
    if (!this.value.isFinite || this.value <= 0) {
      throw WateringMLValidationError(this.value);
    }
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WateringMLVo && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => '$valueмл';
}
