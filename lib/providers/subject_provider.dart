// 📁 lib/providers/subject_provider.dart - محدث مع Firebase
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject_model.dart';

class SubjectProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Subject> _subjects = [];
  List<Subject> _searchResults = [];
  List<Subject> _featuredSubjects = [];
  List<Subject> _teacherSubjects = [];
  bool _isLoading = false;
  String _error = '';

  List<Subject> get subjects => _subjects;
  List<Subject> get searchResults => _searchResults;
  List<Subject> get featuredSubjects => _featuredSubjects;
  List<Subject> get teacherSubjects => _teacherSubjects;
  bool get isLoading => _isLoading;
  String get error => _error;

  // ✅ جلب جميع المواد
  void loadSubjects() {
    _firestore
        .collection('subjects')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _subjects =
          snapshot.docs.map((doc) => Subject.fromFirestore(doc)).toList();
      _error = '';
      notifyListeners();
    }, onError: (error) {
      _error = 'فشل في تحميل المواد: $error';
      notifyListeners();
    });
  }

  // ✅ البحث في المواد
  void searchSubjects(String query) {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _firestore
        .collection('subjects')
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .listen((snapshot) {
      final allSubjects =
          snapshot.docs.map((doc) => Subject.fromFirestore(doc)).toList();

      _searchResults = allSubjects
          .where((subject) =>
              subject.name.toLowerCase().contains(query.toLowerCase()) ||
              subject.teacherName.toLowerCase().contains(query.toLowerCase()) ||
              subject.description.toLowerCase().contains(query.toLowerCase()))
          .toList();

      _error = '';
      notifyListeners();
    }, onError: (error) {
      _error = 'فشل في البحث: $error';
      notifyListeners();
    });
  }

  // ✅ جلب المواد المميزة
  void loadFeaturedSubjects() {
    _firestore
        .collection('subjects')
        .where('isActive', isEqualTo: true)
        .where('rating', isGreaterThanOrEqualTo: 4.5)
        .orderBy('rating', descending: true)
        .limit(10)
        .snapshots()
        .listen((snapshot) {
      _featuredSubjects =
          snapshot.docs.map((doc) => Subject.fromFirestore(doc)).toList();
      _error = '';
      notifyListeners();
    }, onError: (error) {
      _error = 'فشل في تحميل المواد المميزة: $error';
      notifyListeners();
    });
  }

  // ✅ جلب مواد معلم معين
  void loadTeacherSubjects(String teacherId) {
    _firestore
        .collection('subjects')
        .where('teacherId', isEqualTo: teacherId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _teacherSubjects =
          snapshot.docs.map((doc) => Subject.fromFirestore(doc)).toList();
      _error = '';
      notifyListeners();
    }, onError: (error) {
      _error = 'فشل في تحميل مواد المعلم: $error';
      notifyListeners();
    });
  }

  // ✅ جلب مواد حسب التصنيف
  Stream<List<Subject>> getSubjectsByCategory(String category) {
    return _firestore
        .collection('subjects')
        .where('isActive', isEqualTo: true)
        .where('categories', arrayContains: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Subject.fromFirestore(doc)).toList());
  }

  // ✅ إضافة مادة جديدة
  Future<void> addSubject(Subject subject) async {
    try {
      _setLoading(true);
      _setError('');

      final subjectData = subject.toFirestore();
      final docRef = await _firestore.collection('subjects').add(subjectData);

      // تحديث المادة بالمعرّف
      await _firestore.collection('subjects').doc(docRef.id).update({
        'id': docRef.id,
      });

      _setLoading(false);
    } catch (error) {
      _setLoading(false);
      _setError('فشل في إضافة المادة: $error');
    }
  }

  // ✅ تحديث مادة موجودة
  Future<void> updateSubject(Subject subject) async {
    try {
      _setLoading(true);
      _setError('');

      await _firestore
          .collection('subjects')
          .doc(subject.id)
          .update(subject.toFirestore());

      _setLoading(false);
    } catch (error) {
      _setLoading(false);
      _setError('فشل في تحديث المادة: $error');
    }
  }

  // ✅ حذف مادة (Soft Delete)
  Future<void> deleteSubject(String subjectId) async {
    try {
      _setLoading(true);
      _setError('');

      await _firestore.collection('subjects').doc(subjectId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _setLoading(false);
    } catch (error) {
      _setLoading(false);
      _setError('فشل في حذف المادة: $error');
    }
  }

  // ✅ جلب مادة بواسطة ID
  Future<Subject?> getSubjectById(String subjectId) async {
    try {
      final doc = await _firestore.collection('subjects').doc(subjectId).get();
      if (doc.exists) {
        return Subject.fromFirestore(doc);
      }
      return null;
    } catch (error) {
      _setError('فشل في جلب المادة: $error');
      return null;
    }
  }

  // ✅ زيادة عدد الطلاب المسجلين
  Future<void> incrementStudentCount(String subjectId) async {
    try {
      await _firestore.collection('subjects').doc(subjectId).update({
        'totalStudents': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      _setError('فشل في تحديث عدد الطلاب: $error');
    }
  }

  // ✅ الحصول على مواد مشابهة
  Future<List<Subject>> getSimilarSubjects(Subject subject) async {
    try {
      final snapshot = await _firestore
          .collection('subjects')
          .where('isActive', isEqualTo: true)
          .where('categories', arrayContainsAny: subject.categories)
          .where('id', isNotEqualTo: subject.id)
          .limit(4)
          .get();

      return snapshot.docs.map((doc) => Subject.fromFirestore(doc)).toList();
    } catch (error) {
      _setError('فشل في جلب المواد المشابهة: $error');
      return [];
    }
  }

  // 🔄 دوال مساعدة
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    if (error.isNotEmpty) {
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  // ✅ للحفاظ على التوافق مع الكود القديم
  Future<void> fetchSubjects() async {
    loadSubjects();
  }

  Future<List<Subject>> getFeaturedSubjects() async {
    loadFeaturedSubjects();
    return _featuredSubjects;
  }

  Stream<List<Subject>> getTeacherSubjectsStream(String teacherId) {
    return getSubjectsByCategory(teacherId); // استخدام مؤقت
  }
}
