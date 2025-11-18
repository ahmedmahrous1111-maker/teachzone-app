import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsModel {
  final int totalSessions;
  final int completedSessions;
  final int cancelledSessions;
  final double totalEarnings;
  final double averageRating;
  final int totalStudents;
  final int activeStudents;
  final Map<String, int> sessionsByDay;
  final Map<String, int> sessionsBySubject;

  AnalyticsModel({
    required this.totalSessions,
    required this.completedSessions,
    required this.cancelledSessions,
    required this.totalEarnings,
    required this.averageRating,
    required this.totalStudents,
    required this.activeStudents,
    required this.sessionsByDay,
    required this.sessionsBySubject,
  });

  // ✅ Convert to Firestore format - **مصحح**
  Map<String, dynamic> toFirestore() {
    return {
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'cancelledSessions': cancelledSessions,
      'totalEarnings': totalEarnings,
      'averageRating': averageRating,
      'totalStudents': totalStudents,
      'activeStudents': activeStudents,
      'sessionsByDay': sessionsByDay,
      'sessionsBySubject': sessionsBySubject,
      'successRate': successRate, // ⬅️ كان ناقص في الكود الأصلي
      'cancellationRate': cancellationRate, // ⬅️ كان ناقص في الكود الأصلي
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ✅ Create from Firestore document - **مصحح**
  factory AnalyticsModel.fromFirestore(DocumentSnapshot doc) {
    // ⬅️ التصحيح
    final data = doc.data() as Map<String, dynamic>;
    return AnalyticsModel(
      totalSessions: data['totalSessions'] ?? 0,
      completedSessions: data['completedSessions'] ?? 0,
      cancelledSessions: data['cancelledSessions'] ?? 0,
      totalEarnings: (data['totalEarnings'] ?? 0).toDouble(),
      averageRating: (data['averageRating'] ?? 0).toDouble(),
      totalStudents: data['totalStudents'] ?? 0,
      activeStudents: data['activeStudents'] ?? 0,
      sessionsByDay: Map<String, int>.from(data['sessionsByDay'] ?? {}),
      sessionsBySubject: Map<String, int>.from(data['sessionsBySubject'] ?? {}),
    );
  }

  // Calculate success rate
  double get successRate {
    if (totalSessions == 0) return 0.0;
    return (completedSessions / totalSessions) * 100;
  }

  // Calculate cancellation rate
  double get cancellationRate {
    if (totalSessions == 0) return 0.0;
    return (cancelledSessions / totalSessions) * 100;
  }

  // Convert to Map (للتوافق مع الكود القديم)
  Map<String, dynamic> toMap() {
    return {
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'cancelledSessions': cancelledSessions,
      'totalEarnings': totalEarnings,
      'averageRating': averageRating,
      'totalStudents': totalStudents,
      'activeStudents': activeStudents,
      'sessionsByDay': sessionsByDay,
      'sessionsBySubject': sessionsBySubject,
      'successRate': successRate, // ⬅️ إضافة
      'cancellationRate': cancellationRate, // ⬅️ إضافة
    };
  }

  // Create from Map (للتوافق مع الكود القديم)
  factory AnalyticsModel.fromMap(Map<String, dynamic> map) {
    return AnalyticsModel(
      totalSessions: map['totalSessions'] ?? 0,
      completedSessions: map['completedSessions'] ?? 0,
      cancelledSessions: map['cancelledSessions'] ?? 0,
      totalEarnings: (map['totalEarnings'] ?? 0).toDouble(),
      averageRating: (map['averageRating'] ?? 0).toDouble(),
      totalStudents: map['totalStudents'] ?? 0,
      activeStudents: map['activeStudents'] ?? 0,
      sessionsByDay: Map<String, int>.from(map['sessionsByDay'] ?? {}),
      sessionsBySubject: Map<String, int>.from(map['sessionsBySubject'] ?? {}),
    );
  }

  // Empty analytics
  factory AnalyticsModel.empty() {
    return AnalyticsModel(
      totalSessions: 0,
      completedSessions: 0,
      cancelledSessions: 0,
      totalEarnings: 0.0,
      averageRating: 0.0,
      totalStudents: 0,
      activeStudents: 0,
      sessionsByDay: {},
      sessionsBySubject: {},
    );
  }

  // Mock data for testing
  factory AnalyticsModel.mockTeacherAnalytics() {
    return AnalyticsModel(
      totalSessions: 45,
      completedSessions: 40,
      cancelledSessions: 5,
      totalEarnings: 2250.0,
      averageRating: 4.7,
      totalStudents: 15,
      activeStudents: 12,
      sessionsByDay: {
        'السبت': 8,
        'الأحد': 7,
        'الإثنين': 6,
        'الثلاثاء': 9,
        'الأربعاء': 7,
        'الخميس': 8,
      },
      sessionsBySubject: {
        'رياضيات': 20,
        'فيزياء': 15,
        'كيمياء': 10,
      },
    );
  }

  factory AnalyticsModel.mockStudentAnalytics() {
    return AnalyticsModel(
      totalSessions: 25,
      completedSessions: 22,
      cancelledSessions: 3,
      totalEarnings: 1250.0,
      averageRating: 4.5,
      totalStudents: 1, // Student himself
      activeStudents: 1,
      sessionsByDay: {
        'السبت': 4,
        'الأحد': 5,
        'الإثنين': 4,
        'الثلاثاء': 6,
        'الأربعاء': 3,
        'الخميس': 3,
      },
      sessionsBySubject: {
        'رياضيات': 12,
        'فيزياء': 8,
        'كيمياء': 5,
      },
    );
  }

  // Copy with method for updates
  AnalyticsModel copyWith({
    int? totalSessions,
    int? completedSessions,
    int? cancelledSessions,
    double? totalEarnings,
    double? averageRating,
    int? totalStudents,
    int? activeStudents,
    Map<String, int>? sessionsByDay,
    Map<String, int>? sessionsBySubject,
  }) {
    return AnalyticsModel(
      totalSessions: totalSessions ?? this.totalSessions,
      completedSessions: completedSessions ?? this.completedSessions,
      cancelledSessions: cancelledSessions ?? this.cancelledSessions,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      averageRating: averageRating ?? this.averageRating,
      totalStudents: totalStudents ?? this.totalStudents,
      activeStudents: activeStudents ?? this.activeStudents,
      sessionsByDay: sessionsByDay ?? this.sessionsByDay,
      sessionsBySubject: sessionsBySubject ?? this.sessionsBySubject,
    );
  }
}
