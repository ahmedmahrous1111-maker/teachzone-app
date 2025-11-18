// حل مؤقت للويب - بدون FCM
import 'package:flutter/foundation.dart';

class PushNotificationService {
  static Future<void> initialize() async {
    print('🌐 وضع الويب - نظام الإشعارات المتقدم سيتم تفعيله على Android');
    // استخدم النظام الحالي للإشعارات المحلية
  }

  static Future<String?> getDeviceToken() async {
    print('🌐 محاكاة التوكن للويب - النظام الحقيقي على Android فقط');
    return 'web-simulated-token-${DateTime.now().millisecondsSinceEpoch}';
  }

  // محاكاة إرسال إشعار
  static Future<void> sendPushNotification({
    required String title,
    required String body,
    required String userId,
  }) async {
    print('📤 محاكاة إشعار Push: $title - $body');
    // في الويب نستخدم الإشعارات المحلية
  }
}
