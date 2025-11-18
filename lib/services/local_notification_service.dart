// services/local_notification_service.dart

import 'dart:async'; // ⭐ الإضافة المطلوبة
import '../models/notification_model.dart';

class LocalNotificationService {
  static final List<AppNotification> _notifications = [];
  static final StreamController<List<AppNotification>>
      _notificationStreamController =
      StreamController<List<AppNotification>>.broadcast();

  // دالة لإنشاء إشعار جديد
  static Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic> data = const {},
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      body: body,
      type: type,
      data: data,
      createdAt: DateTime.now(),
    );

    _notifications.add(notification);
    _notifyListeners();

    print('📢 تم إنشاء إشعار جديد: $title');
  }

  // الحصول على إشعارات مستخدم معين
  static List<AppNotification> getUserNotifications(String userId) {
    return _notifications
        .where((notification) => notification.userId == userId)
        .toList()
        .reversed
        .toList(); // الأحدث أولاً
  }

  // ستريم لمتابعة التحديثات
  static Stream<List<AppNotification>> getUserNotificationsStream(
      String userId) {
    return _notificationStreamController.stream.map((allNotifications) {
      return allNotifications
          .where((notification) => notification.userId == userId)
          .toList()
          .reversed
          .toList();
    });
  }

  // تحديث حالة القراءة
  static Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final updatedNotification = _notifications[index].copyWith(isRead: true);
      _notifications[index] = updatedNotification;
      _notifyListeners();
      print('📖 تم تعليم الإشعار كمقروء: ${updatedNotification.title}');
    }
  }

  //标记 جميع الإشعارات كمقروءة
  static Future<void> markAllAsRead(String userId) async {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId && !_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    _notifyListeners();
    print('📚 تم تعليم جميع إشعارات المستخدم كمقروءة');
  }

  // حذف إشعار
  static Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notifyListeners();
    print('🗑️ تم حذف الإشعار: $notificationId');
  }

  // إشعار المستمعين بالتحديثات
  static void _notifyListeners() {
    _notificationStreamController.add(List.from(_notifications));
  }

  // تهيئة ببيانات تجريبية
  static void initializeWithMockData() {
    _notifications.clear();
    _notifications.addAll(AppNotification.mockNotifications);
    _notifyListeners();
    print('🎯 تم تهيئة خدمة الإشعارات ببيانات تجريبية');
  }

  // الحصول على عدد الإشعارات غير المقروءة
  static int getUnreadCount(String userId) {
    return _notifications
        .where((notification) =>
            notification.userId == userId && !notification.isRead)
        .length;
  }

  // تنظيف الموارد
  static void dispose() {
    _notificationStreamController.close();
  }
}
