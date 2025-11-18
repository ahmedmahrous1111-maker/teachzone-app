import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject_model.dart';

class SubjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // الحصول على جميع المواد
  Stream<List<Subject>> getSubjects() {
    return _firestore
        .collection('subjects')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id; // إضافة ID للبيانات
              return Subject.fromMap(data);
            })
            .toList());
  }

  // البحث في المواد
  Stream<List<Subject>> searchSubjects(String query) {
    if (query.isEmpty) {
      return getSubjects();
    }
    
    String searchKey = query.toLowerCase();
    String searchEnd = searchKey + 'z';
    
    return _firestore
        .collection('subjects')
        .where('searchKeywords', arrayContains: searchKey)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Subject.fromMap(data);
            })
            .toList());
  }

  // الحصول على المواد المميزة
  Future<List<Subject>> getFeaturedSubjects() async {
    try {
      final snapshot = await _firestore
          .collection('subjects')
          .where('rating', isGreaterThanOrEqualTo: 4.0)
          .limit(5)
          .get();
      
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Subject.fromMap(data);
          })
          .toList();
    } catch (e) {
      print('Error getting featured subjects: $e');
      return [];
    }
  }

  // الحصول على المواد حسب الفئة
  Stream<List<Subject>> getSubjectsByCategory(String category) {
    return _firestore
        .collection('subjects')
        .where('categories', arrayContains: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Subject.fromMap(data);
            })
            .toList());
  }

  // إضافة مادة جديدة (للمعلمين)
  Future<void> addSubject(Subject subject) async {
    try {
      // إنشاء كلمات البحث
      final searchKeywords = _generateSearchKeywords(subject.name);
      
      final subjectData = subject.toMap();
      subjectData['searchKeywords'] = searchKeywords;
      subjectData['createdAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('subjects').doc(subject.id).set(subjectData);
    } catch (e) {
      print('Error adding subject: $e');
      throw e;
    }
  }

  // تحديث مادة
  Future<void> updateSubject(Subject subject) async {
    try {
      final searchKeywords = _generateSearchKeywords(subject.name);
      
      final subjectData = subject.toMap();
      subjectData['searchKeywords'] = searchKeywords;
      subjectData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('subjects').doc(subject.id).update(subjectData);
    } catch (e) {
      print('Error updating subject: $e');
      throw e;
    }
  }

  // حذف مادة
  Future<void> deleteSubject(String subjectId) async {
    try {
      await _firestore.collection('subjects').doc(subjectId).delete();
    } catch (e) {
      print('Error deleting subject: $e');
      throw e;
    }
  }

  // الحصول على مواد معلم معين
  Stream<List<Subject>> getTeacherSubjects(String teacherId) {
    return _firestore
        .collection('subjects')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Subject.fromMap(data);
            })
            .toList());
  }

  // الحصول على مادة بواسطة ID
  Future<Subject?> getSubjectById(String subjectId) async {
    try {
      final doc = await _firestore.collection('subjects').doc(subjectId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return Subject.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error getting subject by ID: $e');
      return null;
    }
  }

  // زيادة عدد الطلاب في مادة
  Future<void> incrementStudentCount(String subjectId) async {
    try {
      await _firestore.collection('subjects').doc(subjectId).update({
        'totalStudents': FieldValue.increment(1),
        'lastEnrollment': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error incrementing student count: $e');
      throw e;
    }
  }

  // تحديث تقييم المادة
  Future<void> updateSubjectRating(String subjectId, double newRating) async {
    try {
      await _firestore.collection('subjects').doc(subjectId).update({
        'rating': newRating,
        'lastRatingUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating subject rating: $e');
      throw e;
    }
  }

  // الحصول على المواد المشابهة
  Future<List<Subject>> getSimilarSubjects(Subject subject) async {
    try {
      if (subject.categories.isEmpty) {
        return [];
      }

      final snapshot = await _firestore
          .collection('subjects')
          .where('categories', arrayContainsAny: subject.categories)
          .where('id', isNotEqualTo: subject.id)
          .limit(4)
          .get();
      
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Subject.fromMap(data);
          })
          .toList();
    } catch (e) {
      print('Error getting similar subjects: $e');
      return [];
    }
  }

  // الحصول على أحدث المواد
  Stream<List<Subject>> getRecentSubjects({int limit = 10}) {
    return _firestore
        .collection('subjects')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Subject.fromMap(data);
            })
            .toList());
  }

  // الحصول على المواد الأكثر شعبية
  Stream<List<Subject>> getPopularSubjects({int limit = 10}) {
    return _firestore
        .collection('subjects')
        .orderBy('totalStudents', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Subject.fromMap(data);
            })
            .toList());
  }

  // التحقق من وجود مادة بنفس الاسم للمعلم
  Future<bool> isSubjectNameExists(String teacherId, String subjectName) async {
    try {
      final snapshot = await _firestore
          .collection('subjects')
          .where('teacherId', isEqualTo: teacherId)
          .where('name', isEqualTo: subjectName)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking subject name: $e');
      return false;
    }
  }

  // توليد كلمات البحث
  List<String> _generateSearchKeywords(String text) {
    final keywords = <String>[];
    final words = text.toLowerCase().split(' ');
    
    for (int i = 0; i < words.length; i++) {
      for (int j = i + 1; j <= words.length; j++) {
        final keyword = words.sublist(i, j).join(' ');
        if (keyword.length > 1) { // تجاهل الكلمات الأحادية
          keywords.add(keyword);
        }
      }
    }
    
    return keywords.toSet().toList(); // إزالة التكرارات
  }

  // الحصول على إحصائيات المواد للمعلم
  Future<Map<String, dynamic>> getTeacherStats(String teacherId) async {
    try {
      final subjectsSnapshot = await _firestore
          .collection('subjects')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      int totalSubjects = subjectsSnapshot.docs.length;
      int totalStudents = 0;
      double totalRevenue = 0.0;
      double averageRating = 0.0;

      for (final doc in subjectsSnapshot.docs) {
        final subject = Subject.fromMap(doc.data());
        totalStudents += subject.totalStudents;
        totalRevenue += subject.price * subject.totalStudents;
        averageRating += subject.rating;
      }

      if (totalSubjects > 0) {
        averageRating = averageRating / totalSubjects;
      }

      return {
        'totalSubjects': totalSubjects,
        'totalStudents': totalStudents,
        'totalRevenue': totalRevenue,
        'averageRating': double.parse(averageRating.toStringAsFixed(1)),
      };
    } catch (e) {
      print('Error getting teacher stats: $e');
      return {
        'totalSubjects': 0,
        'totalStudents': 0,
        'totalRevenue': 0.0,
        'averageRating': 0.0,
      };
    }
  }

  // تحديث صورة المادة
  Future<void> updateSubjectImage(String subjectId, String imageUrl) async {
    try {
      await _firestore.collection('subjects').doc(subjectId).update({
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating subject image: $e');
      throw e;
    }
  }

  // الحصول على عدد المواد حسب الفئة
  Future<Map<String, int>> getSubjectsCountByCategory() async {
    try {
      final snapshot = await _firestore.collection('subjects').get();
      final categoryCount = <String, int>{};

      for (final doc in snapshot.docs) {
        final subject = Subject.fromMap(doc.data());
        for (final category in subject.categories) {
          categoryCount[category] = (categoryCount[category] ?? 0) + 1;
        }
      }

      return categoryCount;
    } catch (e) {
      print('Error getting subjects count by category: $e');
      return {};
    }
  }
}