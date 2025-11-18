// 📁 lib/models/booking_model.dart - محدث مع Firebase
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { pending, confirmed, cancelled, completed }

class Booking {
  final String id;
  final String studentId;
  final String studentName;
  final String teacherId;
  final String teacherName;
  final String subject;
  final DateTime dateTime;
  final int duration;
  final double price;
  final BookingStatus status;
  final String sessionType;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Booking({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.teacherId,
    required this.teacherName,
    required this.subject,
    required this.dateTime,
    required this.duration,
    required this.price,
    required this.status,
    required this.sessionType,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPending => status == BookingStatus.pending;
  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isCancelled => status == BookingStatus.cancelled;
  bool get isCompleted => status == BookingStatus.completed;

  // ⭐ دوال Firebase الجديدة
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'subject': subject,
      'dateTime': Timestamp.fromDate(dateTime),
      'duration': duration,
      'price': price,
      'status': statusToString(status),
      'sessionType': sessionType,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : Timestamp.now(),
    };
  }

  // ⭐ تحويل من Firestore Document
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Booking(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      teacherId: data['teacherId'] ?? '',
      teacherName: data['teacherName'] ?? '',
      subject: data['subject'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      duration: data['duration'] ?? 60,
      price: (data['price'] ?? 0.0).toDouble(),
      status: stringToStatus(data['status'] ?? 'pending'),
      sessionType: data['sessionType'] ?? 'فردي',
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // ⭐ دوال التحويل بين Enum و String - ✅ أصبحت public
  static String statusToString(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.completed:
        return 'completed';
    }
  }

  static BookingStatus stringToStatus(String status) {
    switch (status) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.pending;
    }
  }

  // دالة مساعدة للحصول على الوقت
  String getFormattedTime() {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // دالة مساعدة للحصول على التاريخ
  String getFormattedDate() {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  // ⭐ دالة لإنشاء حجز جديد (للاستخدام مع Firebase)
  factory Booking.createNew({
    required String studentId,
    required String studentName,
    required String teacherId,
    required String teacherName,
    required String subject,
    required DateTime dateTime,
    required int duration,
    required double price,
    required String sessionType,
    String? notes,
  }) {
    return Booking(
      id: '', // ⭐ سيتم تعبئته من Firebase
      studentId: studentId,
      studentName: studentName,
      teacherId: teacherId,
      teacherName: teacherName,
      subject: subject,
      dateTime: dateTime,
      duration: duration,
      price: price,
      status: BookingStatus.pending,
      sessionType: sessionType,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: null,
    );
  }

  Booking copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? teacherId,
    String? teacherName,
    String? subject,
    DateTime? dateTime,
    int? duration,
    double? price,
    BookingStatus? status,
    String? sessionType,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      subject: subject ?? this.subject,
      dateTime: dateTime ?? this.dateTime,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      status: status ?? this.status,
      sessionType: sessionType ?? this.sessionType,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ✅ الحفاظ على دوال التوافق مع الكود القديم
  Map<String, dynamic> toMap() {
    return toFirestore()
      ..['dateTime'] = dateTime.millisecondsSinceEpoch
      ..['createdAt'] = createdAt.millisecondsSinceEpoch
      ..['updatedAt'] = updatedAt?.millisecondsSinceEpoch;
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      subject: map['subject'] ?? '',
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] ?? 0),
      duration: map['duration'] ?? 60,
      price: (map['price'] ?? 0.0).toDouble(),
      status: stringToStatus(map['status'] ?? 'pending'),
      sessionType: map['sessionType'] ?? 'فردي',
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }

  @override
  String toString() {
    return 'Booking(id: $id, student: $studentName, teacher: $teacherName, date: $dateTime)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Booking && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
