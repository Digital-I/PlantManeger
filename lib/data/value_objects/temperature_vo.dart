/// Ошибка, возникающая при создании некорректной температуры.
class TemperatureValidationError implements Exception {
  final double value;
  const TemperatureValidationError(this.value);
  @override
  String toString() =>
      'Температура должна быть конечным числом. Получено: $value.';
}

/// Температура в градусах Цельсия.
class TemperatureVo {
  final double value;
  TemperatureVo(num value) : value = value.toDouble() {
    if (!this.value.isFinite) throw TemperatureValidationError(this.value);
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TemperatureVo && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => '$value°C';
}
