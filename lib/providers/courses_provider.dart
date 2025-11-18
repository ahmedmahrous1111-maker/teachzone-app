// 📁 lib/providers/courses_provider.dart - معدل
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';

class CoursesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Course> _courses = [];
  List<Course> _teacherCourses = [];
  List<Course> _studentCourses = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  List<Course> get courses => _courses;
  List<Course> get teacherCourses => _teacherCourses;
  List<Course> get studentCourses => _studentCourses;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  // ✅ جلب جميع الكورسات النشطة - معدل بدون orderBy
  Future<void> loadAllCourses() async {
    try {
      _setLoading(true);
      _setError(false, '');

      // ⭐ Query معدل بدون orderBy علشان يشتغل بدون Index
      _firestore
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .where('isPublished', isEqualTo: true)
          // .orderBy('createdAt', descending: true) // ⭐ مؤقتاً معطل
          .snapshots()
          .listen((snapshot) {
        _courses =
            snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
        notifyListeners();
      });

      _setLoading(false);
    } catch (error) {
      _setLoading(false);
      _setError(true, 'فشل في تحميل الكورسات: $error');
    }
  }

  // ✅ جلب كورسات معلم معين - معدل
  void loadTeacherCourses(String teacherId) {
    _firestore
        .collection('courses')
        .where('teacherId', isEqualTo: teacherId)
        .where('isActive', isEqualTo: true)
        // .orderBy('createdAt', descending: true) // ⭐ مؤقتاً معطل
        .snapshots()
        .listen((snapshot) {
      _teacherCourses =
          snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  // ✅ جلب كورسات الطالب المسجل فيها - مصحح
  void loadStudentCourses(String studentId) {
    _firestore
        .collection('user_courses')
        .doc(studentId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final enrolledCourses =
            List<String>.from(data['enrolled_courses'] ?? []);

        if (enrolledCourses.isEmpty) return [];

        final courses = <Course>[];
        for (final courseId in enrolledCourses) {
          final course = await getCourseById(courseId);
          if (course != null) {
            courses.add(course);
          }
        }
        return courses;
      }
      return [];
    }).listen((courses) {
      _studentCourses = List<Course>.from(courses);
      notifyListeners();
    });
  }

  // 🆕 الدوال الناقصة المطلوبة:

  // ✅ جلب كورس بواسطة الـ ID
  Future<Course?> getCourseById(String courseId) async {
    try {
      final doc = await _firestore.collection('courses').doc(courseId).get();
      if (doc.exists) {
        return Course.fromFirestore(doc);
      }
      return null;
    } catch (error) {
      _setError(true, 'فشل في جلب الكورس: $error');
      return null;
    }
  }

  // ✅ إنشاء كورس جديد
  Future<String> createCourse(Course course) async {
    try {
      _setLoading(true);
      _setError(false, '');

      final docRef = _firestore.collection('courses').doc();
      final newCourse = course.copyWith(id: docRef.id);

      await docRef.set(newCourse.toFirestore());

      _setLoading(false);
      return docRef.id;
    } catch (error) {
      _setLoading(false);
      _setError(true, 'فشل في إنشاء الكورس: $error');
      return '';
    }
  }

  // ✅ تحديث كورس موجود
  Future<void> updateCourse(String courseId, Course course) async {
    try {
      _setLoading(true);
      _setError(false, '');

      await _firestore
          .collection('courses')
          .doc(courseId)
          .update(course.toFirestore());

      _setLoading(false);
    } catch (error) {
      _setLoading(false);
      _setError(true, 'فشل في تحديث الكورس: $error');
    }
  }

  // ✅ حذف كورس
  Future<void> deleteCourse(String courseId) async {
    try {
      _setLoading(true);
      _setError(false, '');

      await _firestore.collection('courses').doc(courseId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _setLoading(false);
    } catch (error) {
      _setLoading(false);
      _setError(true, 'فشل في حذف الكورس: $error');
    }
  }

  // ✅ تسجيل طالب في كورس
  Future<void> enrollStudentInCourse(String studentId, String courseId) async {
    try {
      _setLoading(true);
      _setError(false, '');

      // تحديث وثيقة الطالب
      final userCoursesRef =
          _firestore.collection('user_courses').doc(studentId);
      await userCoursesRef.set({
        'enrolled_courses': FieldValue.arrayUnion([courseId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // تحديث إحصائيات الكورس
      await _firestore.collection('courses').doc(courseId).update({
        'enrolledStudents': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _setLoading(false);
    } catch (error) {
      _setLoading(false);
      _setError(true, 'فشل في التسجيل بالكورس: $error');
    }
  }

  // ✅ البحث في الكورسات - معدل
  Future<List<Course>> searchCourses(String query) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .where('isPublished', isEqualTo: true)
          .get();

      final allCourses =
          snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();

      return allCourses
          .where((course) =>
              course.title.toLowerCase().contains(query.toLowerCase()) ||
              course.description.toLowerCase().contains(query.toLowerCase()) ||
              course.subject.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (error) {
      _setError(true, 'فشل في البحث: $error');
      return [];
    }
  }

  // 🔄 دوال مساعدة للإدارة
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(bool hasError, String message) {
    _hasError = hasError;
    _errorMessage = message;
    if (hasError) {
      notifyListeners();
    }
  }

  // ✅ للحفاظ على التوافق مع الكود القديم
  Future<void> fetchCourses() async {
    await loadAllCourses();
  }

  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }
}
