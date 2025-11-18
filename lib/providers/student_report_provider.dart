import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';
import '../models/analytics_model.dart';

// ⭐ نموذج StudentReport المطلوب للكود الحالي
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

  StudentReport({
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

  // Copy with method
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
}

class StudentReportProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AnalyticsModel _studentAnalytics = AnalyticsModel.empty();
  List<ReportModel> _studentReports = [];
  List<StudentReport> _allStudents = [];
  List<StudentReport> _filteredStudents = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _currentFilter = 'all';

  // Getters للبيانات الجديدة
  List<StudentReport> get filteredStudents => _filteredStudents;
  List<StudentReport> get allStudents => _allStudents;

  // إحصائيات جديدة
  int get totalStudents => _allStudents.length;
  double get averageScore => _allStudents.isEmpty
      ? 0
      : _allStudents.map((s) => s.averageScore).reduce((a, b) => a + b) /
          _allStudents.length;
  double get successRate => _allStudents.isEmpty
      ? 0
      : (_allStudents.where((s) => s.averageScore >= 50).length /
              _allStudents.length) *
          100;

  // Getters الأصلية
  AnalyticsModel get studentAnalytics => _studentAnalytics;
  List<ReportModel> get studentReports => _studentReports;
  bool get isLoading => _isLoading;

  // ✅ وظائف جديدة لإدارة قائمة الطلاب - محدثة لـ Firebase
  Future<void> loadStudentReports() async {
    _isLoading = true;
    notifyListeners();

    try {
      // ⭐ جلب بيانات الطلاب من Firebase
      final querySnapshot = await _firestore.collection('students').get();

      _allStudents = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return StudentReport(
          studentId: doc.id,
          studentName: data['name'] ?? 'طالب',
          averageScore: (data['averageScore'] ?? 0.0).toDouble(),
          performanceLevel: data['performanceLevel'] ?? 'متوسط',
          lastTestScore: (data['lastTestScore'] ?? 0.0).toDouble(),
          lastTestDate:
              (data['lastTestDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          photoUrl: data['photoUrl'] ?? '',
          attendanceRate: (data['attendanceRate'] ?? 0.0).toDouble(),
          completedAssignments: data['completedAssignments'] ?? 0,
          totalAssignments: data['totalAssignments'] ?? 0,
        );
      }).toList();

      // إذا لم توجد بيانات، نستخدم بيانات افتراضية
      if (_allStudents.isEmpty) {
        _allStudents = _getSampleStudentsData();
        // حفظ البيانات الافتراضية في Firebase
        final batch = _firestore.batch();
        for (final student in _allStudents) {
          final docRef =
              _firestore.collection('students').doc(student.studentId);
          batch.set(docRef, {
            'name': student.studentName,
            'averageScore': student.averageScore,
            'performanceLevel': student.performanceLevel,
            'lastTestScore': student.lastTestScore,
            'lastTestDate': Timestamp.fromDate(student.lastTestDate),
            'photoUrl': student.photoUrl,
            'attendanceRate': student.attendanceRate,
            'completedAssignments': student.completedAssignments,
            'totalAssignments': student.totalAssignments,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
      }

      _applyFilters();
    } catch (error) {
      if (kDebugMode) {
        print('❌ خطأ في جلب تقارير الطلاب: $error');
      }
      // استخدام بيانات وهمية كبديل
      _allStudents = _getSampleStudentsData();
      _applyFilters();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchStudents(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByLevel(String level) {
    _currentFilter = level;
    _applyFilters();
  }

  void _applyFilters() {
    List<StudentReport> result = _allStudents;

    // تطبيق البحث
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((student) => student.studentName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // تطبيق التصفية بالمستوى
    if (_currentFilter != 'all') {
      result = result
          .where((student) =>
              student.performanceLevel == _getLevelName(_currentFilter))
          .toList();
    }

    _filteredStudents = result;
    notifyListeners();
  }

  String _getLevelName(String levelKey) {
    switch (levelKey) {
      case 'excellent':
        return 'ممتاز';
      case 'good':
        return 'جيد';
      case 'average':
        return 'متوسط';
      default:
        return 'ضعيف';
    }
  }

  // ✅ بيانات وهمية للطلاب
  List<StudentReport> _getSampleStudentsData() {
    return [
      StudentReport(
        studentId: 'student_1',
        studentName: 'أحمد محمد',
        averageScore: 92.0,
        performanceLevel: 'ممتاز',
        lastTestScore: 95.0,
        lastTestDate: DateTime(2024, 5, 12),
        photoUrl: '',
        attendanceRate: 98.0,
        completedAssignments: 15,
        totalAssignments: 15,
      ),
      StudentReport(
        studentId: 'student_2',
        studentName: 'سارة خالد',
        averageScore: 78.0,
        performanceLevel: 'جيد',
        lastTestScore: 80.0,
        lastTestDate: DateTime(2024, 5, 10),
        photoUrl: '',
        attendanceRate: 92.0,
        completedAssignments: 14,
        totalAssignments: 15,
      ),
      StudentReport(
        studentId: 'student_3',
        studentName: 'محمد علي',
        averageScore: 65.0,
        performanceLevel: 'متوسط',
        lastTestScore: 70.0,
        lastTestDate: DateTime(2024, 5, 8),
        photoUrl: '',
        attendanceRate: 85.0,
        completedAssignments: 12,
        totalAssignments: 15,
      ),
      StudentReport(
        studentId: 'student_4',
        studentName: 'فاطمة إبراهيم',
        averageScore: 45.0,
        performanceLevel: 'ضعيف',
        lastTestScore: 50.0,
        lastTestDate: DateTime(2024, 5, 5),
        photoUrl: '',
        attendanceRate: 75.0,
        completedAssignments: 10,
        totalAssignments: 15,
      ),
    ];
  }

  // ✅ وظيفة للحصول على طالب معين
  StudentReport? getStudentById(String studentId) {
    try {
      return _allStudents
          .firstWhere((student) => student.studentId == studentId);
    } catch (e) {
      return null;
    }
  }

  // ✅ تحديث بيانات طالب - محدث لـ Firebase
  Future<void> updateStudentScore(String studentId, double newScore) async {
    try {
      final index =
          _allStudents.indexWhere((student) => student.studentId == studentId);
      if (index != -1) {
        // تحديث محلي
        _allStudents[index] = _allStudents[index].copyWith(
          averageScore: newScore,
          lastTestScore: newScore,
          lastTestDate: DateTime.now(),
        );

        // تحديث في Firebase
        await _firestore.collection('students').doc(studentId).update({
          'averageScore': newScore,
          'lastTestScore': newScore,
          'lastTestDate': Timestamp.fromDate(DateTime.now()),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _applyFilters();
        notifyListeners();
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ خطأ في تحديث درجة الطالب: $error');
      }
      throw Exception('فشل في تحديث درجة الطالب');
    }
  }

  // 🔄 الوظائف الأصلية - محدثة لـ Firebase
  Future<void> loadStudentAnalytics(String studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final analyticsDoc =
          await _firestore.collection('student_analytics').doc(studentId).get();

      if (analyticsDoc.exists) {
        _studentAnalytics = AnalyticsModel.fromFirestore(analyticsDoc);
      } else {
        _studentAnalytics = AnalyticsModel.mockStudentAnalytics();
        await _firestore
            .collection('student_analytics')
            .doc(studentId)
            .set(_studentAnalytics.toFirestore());
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ خطأ في جلب إحصائيات الطالب: $error');
      }
      _studentAnalytics = AnalyticsModel.mockStudentAnalytics();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<ReportModel> generateStudentProgressReport({
    required String studentId,
    required String period,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final report = ReportModel(
        id: _firestore.collection('student_reports').doc().id,
        userId: studentId,
        userType: 'student',
        title: _getProgressReportTitle(period),
        description: _getProgressReportDescription(period),
        data: _studentAnalytics.toMap(),
        generatedAt: DateTime.now(),
        period: period,
      );

      // حفظ في Firebase
      await _firestore
          .collection('student_reports')
          .doc(report.id)
          .set(report.toFirestore());

      _studentReports.add(report);

      _isLoading = false;
      notifyListeners();
      return report;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      throw Exception('فشل في إنشاء تقرير الطالب: $error');
    }
  }

  Future<void> loadStudentReportsForStudent(String studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('student_reports')
          .where('userId', isEqualTo: studentId)
          .where('userType', isEqualTo: 'student')
          // .orderBy('generatedAt', descending: true) // ⬅️ مؤقتاً معلق
          .get();

      _studentReports = querySnapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc.data(), doc.id))
          .toList();

      // ترتيب محلي
      _studentReports.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    } catch (error) {
      if (kDebugMode) {
        print('❌ خطأ في جلب تقارير الطالب: $error');
      }
      _studentReports = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Helper methods الأصلية
  String _getProgressReportTitle(String period) {
    switch (period) {
      case 'daily':
        return 'تقرير التقدم اليومي';
      case 'weekly':
        return 'تقرير التقدم الأسبوعي';
      case 'monthly':
        return 'تقرير التقدم الشهري';
      default:
        return 'تقرير التقدم الدراسي';
    }
  }

  String _getProgressReportDescription(String period) {
    switch (period) {
      case 'daily':
        return 'ملخص تقدمك في الدراسة خلال اليوم';
      case 'weekly':
        return 'ملخص تقدمك في الدراسة خلال الأسبوع';
      case 'monthly':
        return 'ملخص تقدمك في الدراسة خلال الشهر';
      default:
        return 'ملخص تقدمك في الدراسة';
    }
  }

  // Clear data
  void clearData() {
    _studentAnalytics = AnalyticsModel.empty();
    _studentReports = [];
    _allStudents = [];
    _filteredStudents = [];
    notifyListeners();
  }
}
