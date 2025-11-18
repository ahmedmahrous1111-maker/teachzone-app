// screens/notifications_screen.dart

import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/local_notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final String currentUserId =
      'user1'; // مؤقت - سيتم استبداله بالمستخدم الحقيقي

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الإشعارات'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: Icon(Icons.mark_email_read),
            onPressed: () {
              LocalNotificationService.markAllAsRead(currentUserId);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم تعليم جميع الإشعارات كمقروءة')),
              );
            },
            tooltip: 'تعليم الكل كمقروء',
          ),
        ],
      ),
      body: _buildNotificationsList(),
    );
  }

  Widget _buildNotificationsList() {
    final notifications =
        LocalNotificationService.getUserNotifications(currentUserId);

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد إشعارات',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // إضافة إشعار تجريبي
                LocalNotificationService.createNotification(
                  userId: currentUserId,
                  title: 'إشعار تجريبي',
                  body: 'هذا إشعار تجريبي لاختبار النظام',
                  type: 'system',
                );
                setState(() {});
              },
              child: Text('إنشاء إشعار تجريبي'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: notification.isRead ? Colors.white : Colors.blue[50],
      child: ListTile(
        leading: _getNotificationIcon(notification.type),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(notification.body),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(notification.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            if (!notification.isRead)
              Container(
                margin: EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            LocalNotificationService.markAsRead(notification.id);
            setState(() {});
          }
          _handleNotificationTap(notification);
        },
        onLongPress: () {
          _showNotificationOptions(notification);
        },
      ),
    );
  }

  Icon _getNotificationIcon(String type) {
    switch (type) {
      case 'booking':
        return Icon(Icons.calendar_today, color: Colors.green);
      case 'reminder':
        return Icon(Icons.access_time, color: Colors.orange);
      case 'video':
        return Icon(Icons.video_call, color: Colors.blue);
      default:
        return Icon(Icons.notifications, color: Colors.grey);
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'الآن';
    if (difference.inMinutes < 60) return '${difference.inMinutes} د';
    if (difference.inHours < 24) return '${difference.inHours} س';
    if (difference.inDays < 7) return '${difference.inDays} ي';
    return '${time.day}/${time.month}';
  }

  void _handleNotificationTap(AppNotification notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم فتح الإشعار: ${notification.title}'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showNotificationOptions(AppNotification notification) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('حذف الإشعار', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  LocalNotificationService.deleteNotification(notification.id);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم حذف الإشعار')),
                  );
                },
              ),
              if (!notification.isRead)
                ListTile(
                  leading: Icon(Icons.mark_email_read, color: Colors.blue),
                  title: Text('تعليم كمقروء'),
                  onTap: () {
                    Navigator.pop(context);
                    LocalNotificationService.markAsRead(notification.id);
                    setState(() {});
                  },
                ),
              ListTile(
                leading: Icon(Icons.cancel, color: Colors.grey),
                title: Text('إلغاء'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
