import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String userId;
  final String userType; // 'teacher' or 'student'
  final String title;
  final String description;
  final Map<String, dynamic> data;
  final DateTime generatedAt;
  final String period; // 'daily', 'weekly', 'monthly', 'custom'

  ReportModel({
    required this.id,
    required this.userId,
    required this.userType,
    required this.title,
    required this.description,
    required this.data,
    required this.generatedAt,
    required this.period,
  });

  // ✅ Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userType': userType,
      'title': title,
      'description': description,
      'data': data,
      'generatedAt': Timestamp.fromDate(generatedAt),
      'period': period,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // ✅ Create from Firestore document
  factory ReportModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ReportModel(
      id: id,
      userId: data['userId'] ?? '',
      userType: data['userType'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      generatedAt: (data['generatedAt'] as Timestamp).toDate(),
      period: data['period'] ?? 'custom',
    );
  }

  // Convert to Map (للتوافق مع الكود القديم)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userType': userType,
      'title': title,
      'description': description,
      'data': data,
      'generatedAt': generatedAt.toIso8601String(),
      'period': period,
    };
  }

  // Create from Map (للتوافق مع الكود القديم)
  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userType: map['userType'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      generatedAt: DateTime.parse(
          map['generatedAt'] ?? DateTime.now().toIso8601String()),
      period: map['period'] ?? 'custom',
    );
  }

  // Copy with method
  ReportModel copyWith({
    String? id,
    String? userId,
    String? userType,
    String? title,
    String? description,
    Map<String, dynamic>? data,
    DateTime? generatedAt,
    String? period,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      title: title ?? this.title,
      description: description ?? this.description,
      data: data ?? this.data,
      generatedAt: generatedAt ?? this.generatedAt,
      period: period ?? this.period,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ✅ StudentReport مع دعم Firebase
class StudentReport {
  final String studentId;
  final String studentName;
  final double averageScore;
  final String performanceLevel;
  final double lastTestScore;
  final DateTime lastTestDate;
  final String photoUrl;
  final double attendanceRate;
  final int completedAssignments;
  final int totalAssignments;

  const StudentReport({
    required this.studentId,
    required this.studentName,
    required this.averageScore,
    required this.performanceLevel,
    required this.lastTestScore,
    required this.lastTestDate,
    required this.photoUrl,
    required this.attendanceRate,
    required this.completedAssignments,
    required this.totalAssignments,
  });

  // ✅ Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'averageScore': averageScore,
      'performanceLevel': performanceLevel,
      'lastTestScore': lastTestScore,
      'lastTestDate': Timestamp.fromDate(lastTestDate),
      'photoUrl': photoUrl,
      'attendanceRate': attendanceRate,
      'completedAssignments': completedAssignments,
      'totalAssignments': totalAssignments,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ✅ Create from Firestore document
  factory StudentReport.fromFirestore(Map<String, dynamic> data) {
    return StudentReport(
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      averageScore: (data['averageScore'] ?? 0).toDouble(),
      performanceLevel: data['performanceLevel'] ?? '',
      lastTestScore: (data['lastTestScore'] ?? 0).toDouble(),
      lastTestDate: (data['lastTestDate'] as Timestamp).toDate(),
      photoUrl: data['photoUrl'] ?? '',
      attendanceRate: (data['attendanceRate'] ?? 0).toDouble(),
      completedAssignments: data['completedAssignments'] ?? 0,
      totalAssignments: data['totalAssignments'] ?? 0,
    );
  }

  StudentReport copyWith({
    String? studentId,
    String? studentName,
    double? averageScore,
    String? performanceLevel,
    double? lastTestScore,
    DateTime? lastTestDate,
    String? photoUrl,
    double? attendanceRate,
    int? completedAssignments,
    int? totalAssignments,
  }) {
    return StudentReport(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      averageScore: averageScore ?? this.averageScore,
      performanceLevel: performanceLevel ?? this.performanceLevel,
      lastTestScore: lastTestScore ?? this.lastTestScore,
      lastTestDate: lastTestDate ?? this.lastTestDate,
      photoUrl: photoUrl ?? this.photoUrl,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      completedAssignments: completedAssignments ?? this.completedAssignments,
      totalAssignments: totalAssignments ?? this.totalAssignments,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'averageScore': averageScore,
      'performanceLevel': performanceLevel,
      'lastTestScore': lastTestScore,
      'lastTestDate': lastTestDate.toIso8601String(),
      'photoUrl': photoUrl,
      'attendanceRate': attendanceRate,
      'completedAssignments': completedAssignments,
      'totalAssignments': totalAssignments,
    };
  }

  factory StudentReport.fromMap(Map<String, dynamic> map) {
    return StudentReport(
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      averageScore: map['averageScore']?.toDouble() ?? 0.0,
      performanceLevel: map['performanceLevel'] ?? '',
      lastTestScore: map['lastTestScore']?.toDouble() ?? 0.0,
      lastTestDate: DateTime.parse(map['lastTestDate']),
      photoUrl: map['photoUrl'] ?? '',
      attendanceRate: map['attendanceRate']?.toDouble() ?? 0.0,
      completedAssignments: map['completedAssignments']?.toInt() ?? 0,
      totalAssignments: map['totalAssignments']?.toInt() ?? 0,
    );
  }
}
