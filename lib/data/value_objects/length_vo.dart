/// Ошибка, возникающая при создании некорректной длины растения.
class LengthPlantValidationError implements Exception {
  final double value;
  const LengthPlantValidationError(this.value);
  @override
  String toString() =>
      'Длина растения должна быть конечным неотрицательным числом. Получено: $value.';
}

/// Длина растения в сантиметрах.
class LengthPlantVO {
  final double value;
  LengthPlantVO(num value) : value = value.toDouble() {
    if (!this.value.isFinite || this.value < 0) {
      throw LengthPlantValidationError(this.value);
    }
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LengthPlantVO && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => '$valueсм';
}
