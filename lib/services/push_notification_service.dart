// إصدار مبسط للويب - بدون FCM
import 'package:flutter/foundation.dart';

class PushNotificationService {
  // تهيئة الخدمة للويب
  static Future<void> initialize() async {
    print('🌐 نظام الإشعارات المتقدم - وضع الويب');
    print('✅ الإشعارات المحلية جاهزة للاستخدام');
    print('📱 إشعارات Push ستكون متاحة على تطبيقات Android/iOS');
  }

  // محاكاة الحصول على توكن الجهاز
  static Future<String?> getDeviceToken() async {
    return 'web-simulated-token-${DateTime.now().millisecondsSinceEpoch}';
  }

  // محاكاة إرسال إشعار Push
  static Future<void> sendPushNotification({
    required String title,
    required String body,
    required String userId,
  }) async {
    print('📤 محاكاة إشعار Push:');
    print('   العنوان: $title');
    print('   المحتوى: $body');
    print('   المستخدم: $userId');
    print('   ⚠️ على الويب نستخدم الإشعارات المحلية بدلاً من Push');
  }

  // دالة مساعدة للتحقق من النظام
  static String getPlatformInfo() {
    return kIsWeb ? '🌐 نظام الويب' : '📱 نظام الجوال';
  }
}
