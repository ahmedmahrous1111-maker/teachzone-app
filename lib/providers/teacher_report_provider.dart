import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher_report_model.dart';
import '../models/analytics_model.dart';

class TeacherReportProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AnalyticsModel _teacherAnalytics = AnalyticsModel.empty();
  List<TeacherReport> _teacherReports = [];
  bool _isLoading = false;

  // Getters
  AnalyticsModel get teacherAnalytics => _teacherAnalytics;
  List<TeacherReport> get teacherReports => _teacherReports;
  bool get isLoading => _isLoading;

  // Load teacher analytics from Firestore
  Future<void> loadTeacherAnalytics(String teacherId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final analyticsDoc =
          await _firestore.collection('teacher_analytics').doc(teacherId).get();

      if (analyticsDoc.exists) {
        _teacherAnalytics = AnalyticsModel.fromFirestore(analyticsDoc);
      } else {
        _teacherAnalytics = AnalyticsModel.mockTeacherAnalytics();
        await _firestore
            .collection('teacher_analytics')
            .doc(teacherId)
            .set(_teacherAnalytics.toFirestore());
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ خطأ في جلب إحصائيات المعلم: $error');
      }
      _teacherAnalytics = AnalyticsModel.mockTeacherAnalytics();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Generate teacher report and save to Firestore
  Future<TeacherReport> generateTeacherReport({
    required String teacherId,
    required String teacherName,
    required String studentName,
    required String courseName,
    required String subject,
    required String reportContent,
    required double rating,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final report = TeacherReport(
        id: _firestore.collection('teacher_reports').doc().id,
        teacherId: teacherId,
        teacherName: teacherName,
        studentName: studentName,
        courseName: courseName,
        subject: subject,
        reportContent: reportContent,
        rating: rating,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('teacher_reports')
          .doc(report.id)
          .set(report.toMap());

      _teacherReports.add(report);

      _isLoading = false;
      notifyListeners();
      return report;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      throw Exception('فشل في إنشاء التقرير: $error');
    }
  }

  // Get reports for specific teacher from Firestore
  Future<void> loadTeacherReports(String teacherId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // ⭐ التعديل: إزالة orderBy مؤقتاً حتى يتفعل الـ Index
      final querySnapshot = await _firestore
          .collection('teacher_reports')
          .where('teacherId', isEqualTo: teacherId)
          // .orderBy('createdAt', descending: true) // ⬅️ مؤقتاً معلق
          .get();

      _teacherReports = querySnapshot.docs
          .map((doc) => TeacherReport.fromFirestore(doc))
          .toList();

      // ⭐ ترتيب محلي بدل orderBy
      _teacherReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (error) {
      if (kDebugMode) {
        print('❌ خطأ في جلب تقارير المعلم: $error');
      }
      _teacherReports = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Real-time listener for teacher reports
  Stream<List<TeacherReport>> getTeacherReportsStream(String teacherId) {
    // ⭐ التعديل: إزالة orderBy مؤقتاً
    return _firestore
        .collection('teacher_reports')
        .where('teacherId', isEqualTo: teacherId)
        // .orderBy('createdAt', descending: true) // ⬅️ مؤقتاً معلق
        .snapshots()
        .map((snapshot) {
      final reports =
          snapshot.docs.map((doc) => TeacherReport.fromFirestore(doc)).toList();
      // ⭐ ترتيب محلي
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reports;
    });
  }

  // Delete report from Firestore
  Future<void> deleteReport(String reportId) async {
    try {
      await _firestore.collection('teacher_reports').doc(reportId).delete();
      _teacherReports.removeWhere((report) => report.id == reportId);
      notifyListeners();
    } catch (error) {
      throw Exception('فشل في حذف التقرير: $error');
    }
  }

  // Clear data
  void clearData() {
    _teacherAnalytics = AnalyticsModel.empty();
    _teacherReports = [];
    notifyListeners();
  }
}
