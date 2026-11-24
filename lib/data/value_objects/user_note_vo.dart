/// Ошибка, возникающая при создании слишком длинной заметки.
class UserNoteValidationError implements Exception {
  final int actualLength;
  final int maxLength;
  const UserNoteValidationError(this.actualLength, {this.maxLength = 500});
  @override
  String toString() =>
      'Заметка не должна превышать $maxLength символов. Получено: $actualLength.';
}

/// Текст заметки пользователя длиной не более 500 символов.
class UserNoteVo {
  static const int maxLength = 500;
  final String value;
  UserNoteVo(String value) : value = value.trim() {
    if (this.value.length > maxLength) {
      throw UserNoteValidationError(this.value.length);
    }
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserNoteVo && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => value;
}
