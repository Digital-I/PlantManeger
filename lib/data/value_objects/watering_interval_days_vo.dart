/// Ошибка, возникающая при создании некорректного интервала полива.
class WateringIntervalDaysValidationError implements Exception {
  final int value;
  const WateringIntervalDaysValidationError(this.value);
  @override
  String toString() =>
      'Интервал полива должен быть положительным числом дней. Получено: $value.';
}

/// Интервал между поливами в целых днях.
class WateringIntervalDaysVo {
  final int value;
  WateringIntervalDaysVo(this.value) {
    if (value <= 0) throw WateringIntervalDaysValidationError(value);
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WateringIntervalDaysVo && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => '$value дн.';
}
