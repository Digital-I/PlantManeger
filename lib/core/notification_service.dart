import 'package:flutter/foundation.dart';

/// Сервис уведомлений с реализацией, совместимой с Android и Web.
class NotificationService {
  /// Планирование уведомления о поливе.
  static Future<void> scheduleWateringNotification({
    required String plantName,
    required DateTime date,
  }) async {
    if (kIsWeb) {
      debugPrint('Web: уведомление о поливе $plantName на $date');
    } else {
      debugPrint('Уведомление о поливе $plantName запланировано на $date');
    }
  }

  /// Отмена уведомления.
  static Future<void> cancelWateringNotification({
    required String plantName,
    required DateTime date,
  }) async {
    if (kIsWeb) {
      debugPrint('Web: уведомление о поливе $plantName на $date отменено');
    } else {
      debugPrint('Уведомление о поливе $plantName на $date отменено');
    }
  }
}
