/// Возвращает дату без времени.
DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// Проверяет совпадение календарного дня.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
