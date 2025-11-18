// models/notification_model.dart

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // 'booking', 'reminder', 'video', 'system'
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data = const {},
    this.isRead = false,
    required this.createdAt,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create from Map from Firebase
  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'system',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      isRead: map['isRead'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  // Copy with method for updates
  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Mock data for development
  static List<AppNotification> get mockNotifications => [
        AppNotification(
          id: '1',
          userId: 'user1',
          title: 'حجز جديد',
          body: 'تم حجز جلسة رياضيات مع الأستاذ أحمد محمد',
          type: 'booking',
          createdAt: DateTime.now().subtract(Duration(minutes: 10)),
        ),
        AppNotification(
          id: '2',
          userId: 'user1',
          title: 'تذكير بالجلسة',
          body: 'جلسة اللغة الإنجليزية تبدأ بعد 30 دقيقة',
          type: 'reminder',
          createdAt: DateTime.now().subtract(Duration(hours: 1)),
        ),
        AppNotification(
          id: '3',
          userId: 'user1',
          title: 'جلسة فيديو جاهزة',
          body: 'غرفة الفيديو جاهزة للجلسة مع الأستاذ محمد علي',
          type: 'video',
          createdAt: DateTime.now().subtract(Duration(hours: 2)),
        ),
        AppNotification(
          id: '4',
          userId: 'user1',
          title: 'تحديث النظام',
          body: 'تم إضافة ميزات جديدة في التطبيق',
          type: 'system',
          isRead: true,
          createdAt: DateTime.now().subtract(Duration(days: 1)),
        ),
      ];

  @override
  String toString() {
    return 'AppNotification(id: $id, title: $title, type: $type, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
