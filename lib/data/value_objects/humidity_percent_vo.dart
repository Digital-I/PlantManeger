/// Ошибка, возникающая при создании некорректного значения влажности.
class HumidityPercentValidationError implements Exception {
  final double value;
  const HumidityPercentValidationError(this.value);
  @override
  String toString() =>
      'Влажность должна быть конечным числом от 0 до 100%. Получено: $value.';
}

/// Влажность воздуха в процентах.
class HumidityPercentVo {
  final double value;
  HumidityPercentVo(num value) : value = value.toDouble() {
    if (!this.value.isFinite || this.value < 0 || this.value > 100) {
      throw HumidityPercentValidationError(this.value);
    }
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HumidityPercentVo && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => '$value%';
}
