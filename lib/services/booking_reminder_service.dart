// services/booking_reminder_service.dart

import 'dart:async';
import '../models/notification_model.dart';
import './local_notification_service.dart';

class BookingReminderService {
  static final Map<String, Timer> _activeTimers = {};

  // جدولة تذكير تلقائي للحجز
  static void scheduleBookingReminders(Map<String, dynamic> booking) {
    final bookingId = booking['id'] ?? '';
    final studentId = booking['studentId'] ?? '';
    final teacherName = booking['teacherName'] ?? 'المعلم';
    final subject = booking['subject'] ?? 'المادة';
    final sessionTime = booking['sessionTime'] != null
        ? DateTime.parse(booking['sessionTime'])
        : DateTime.now().add(Duration(hours: 1));

    // إلغاء أي تذكيرات سابقة لنفس الحجز
    cancelBookingReminders(bookingId);

    // تذكير قبل 24 ساعة
    _scheduleReminder(
      bookingId: bookingId,
      studentId: studentId,
      teacherName: teacherName,
      subject: subject,
      sessionTime: sessionTime,
      reminderTime: sessionTime.subtract(Duration(hours: 24)),
      reminderType: '24_hours',
    );

    // تذكير قبل ساعة
    _scheduleReminder(
      bookingId: bookingId,
      studentId: studentId,
      teacherName: teacherName,
      subject: subject,
      sessionTime: sessionTime,
      reminderTime: sessionTime.subtract(Duration(hours: 1)),
      reminderType: '1_hour',
    );

    // تذكير قبل 15 دقيقة
    _scheduleReminder(
      bookingId: bookingId,
      studentId: studentId,
      teacherName: teacherName,
      subject: subject,
      sessionTime: sessionTime,
      reminderTime: sessionTime.subtract(Duration(minutes: 15)),
      reminderType: '15_minutes',
    );

    print('⏰ تم جدولة تذكيرات للحجز: $bookingId');
  }

  // دالة مساعدة لجدولة تذكير واحد
  static void _scheduleReminder({
    required String bookingId,
    required String studentId,
    required String teacherName,
    required String subject,
    required DateTime sessionTime,
    required DateTime reminderTime,
    required String reminderType,
  }) {
    final now = DateTime.now();
    final timeUntilReminder = reminderTime.difference(now);

    // إذا كان وقت التذكير في المستقبل
    if (timeUntilReminder > Duration.zero) {
      final timer = Timer(timeUntilReminder, () {
        _triggerReminder(
          bookingId: bookingId,
          studentId: studentId,
          teacherName: teacherName,
          subject: subject,
          sessionTime: sessionTime,
          reminderType: reminderType,
        );
      });

      _activeTimers['$bookingId-$reminderType'] = timer;
    }
  }

  // تشغيل التذكير
  static void _triggerReminder({
    required String bookingId,
    required String studentId,
    required String teacherName,
    required String subject,
    required DateTime sessionTime,
    required String reminderType,
  }) {
    String title = '';
    String body = '';

    switch (reminderType) {
      case '24_hours':
        title = 'تذكير بالجلسة - غداً';
        body =
            'جلسة $subject مع $teacherName غداً في ${_formatTime(sessionTime)}';
        break;
      case '1_hour':
        title = 'تذكير بالجلسة - بعد ساعة';
        body = 'جلسة $subject مع $teacherName تبدأ بعد ساعة';
        break;
      case '15_minutes':
        title = 'تذكير بالجلسة - بعد 15 دقيقة';
        body = 'جلسة $subject مع $teacherName تبدأ بعد 15 دقيقة - استعد للجلسة';
        break;
    }

    // إنشاء الإشعار
    LocalNotificationService.createNotification(
      userId: studentId,
      title: title,
      body: body,
      type: 'reminder',
      data: {
        'bookingId': bookingId,
        'reminderType': reminderType,
        'sessionTime': sessionTime.toIso8601String(),
      },
    );

    print('🔔 تم إرسال تذكير: $title');
  }

  // إلغاء تذكيرات الحجز
  static void cancelBookingReminders(String bookingId) {
    final keysToRemove = <String>[];

    _activeTimers.forEach((key, timer) {
      if (key.startsWith(bookingId)) {
        timer.cancel();
        keysToRemove.add(key);
      }
    });

    keysToRemove.forEach(_activeTimers.remove);

    print('❌ تم إلغاء تذكيرات الحجز: $bookingId');
  }

  // تنسيق الوقت
  static String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  // تنظيف جميع التذكيرات
  static void dispose() {
    _activeTimers.forEach((key, timer) {
      timer.cancel();
    });
    _activeTimers.clear();
    print('🧹 تم تنظيف جميع التذكيرات');
  }
}
