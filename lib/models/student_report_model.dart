// models/student_report_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentReport {
  final String id;
  final String studentId;
  final String studentName;
  final String teacherName;
  final String courseName;
  final String subject;
  final String reportContent;
  final double progressPercentage;
  final String grade;
  final String recommendations;
  final DateTime reportDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentReport({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.teacherName,
    required this.courseName,
    required this.subject,
    required this.reportContent,
    required this.progressPercentage,
    required this.grade,
    required this.recommendations,
    required this.reportDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'teacherName': teacherName,
      'courseName': courseName,
      'subject': subject,
      'reportContent': reportContent,
      'progressPercentage': progressPercentage,
      'grade': grade,
      'recommendations': recommendations,
      'reportDate': Timestamp.fromDate(reportDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firebase Document
  factory StudentReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudentReport(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      teacherName: data['teacherName'] ?? '',
      courseName: data['courseName'] ?? '',
      subject: data['subject'] ?? '',
      reportContent: data['reportContent'] ?? '',
      progressPercentage: (data['progressPercentage'] ?? 0.0).toDouble(),
      grade: data['grade'] ?? '',
      recommendations: data['recommendations'] ?? '',
      reportDate: (data['reportDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
