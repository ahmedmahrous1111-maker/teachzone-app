// models/teacher_report_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherReport {
  final String id;
  final String teacherId;
  final String teacherName;
  final String studentName;
  final String courseName;
  final String subject;
  final String reportContent;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  TeacherReport({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.studentName,
    required this.courseName,
    required this.subject,
    required this.reportContent,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'teacherName': teacherName,
      'studentName': studentName,
      'courseName': courseName,
      'subject': subject,
      'reportContent': reportContent,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firebase Document
  factory TeacherReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeacherReport(
      id: doc.id,
      teacherId: data['teacherId'] ?? '',
      teacherName: data['teacherName'] ?? '',
      studentName: data['studentName'] ?? '',
      courseName: data['courseName'] ?? '',
      subject: data['subject'] ?? '',
      reportContent: data['reportContent'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Create from Map (for mock data transition)
  factory TeacherReport.fromMap(Map<String, dynamic> map) {
    return TeacherReport(
      id: map['id'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      studentName: map['studentName'] ?? '',
      courseName: map['courseName'] ?? '',
      subject: map['subject'] ?? '',
      reportContent: map['reportContent'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
