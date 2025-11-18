import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject_model.dart';
import '../utils/test_data.dart';

class TestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إضافة جميع البيانات التجريبية
  Future<void> addAllTestData() async {
    try {
      print('🚀 بدء إضافة البيانات التجريبية...');
      
      // إضافة المواد
      await _addTestSubjects();
      
      // إضافة مستخدمين تجريبيين
      await _addTestUsers();
      
      print('✅ تم إضافة جميع البيانات التجريبية بنجاح!');
    } catch (e) {
      print('❌ خطأ في إضافة البيانات: $e');
    }
  }

  Future<void> _addTestSubjects() async {
    final subjects = TestData.getSampleSubjects();
    
    for (final subject in subjects) {
      try {
        // إنشاء كلمات البحث
        final searchKeywords = _generateSearchKeywords(subject.name);
        
        final subjectData = subject.toMap();
        subjectData['searchKeywords'] = searchKeywords;
        subjectData['createdAt'] = Timestamp.fromDate(subject.createdAt);
        
        await _firestore.collection('subjects').doc(subject.id).set(subjectData);
        print('✅ تم إضافة مادة: ${subject.name}');
      } catch (e) {
        print('❌ خطأ في إضافة مادة ${subject.name}: $e');
      }
    }
  }

  Future<void> _addTestUsers() async {
    // إضافة معلم تجريبي
    final teacherData = TestData.getSampleTeacherData();
    await _firestore.collection('users').doc('teacher_ahmed').set({
      ...teacherData,
      'userType': 'teacher',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // إضافة طالب تجريبي  
    final studentData = TestData.getSampleStudentData();
    await _firestore.collection('users').doc('student_mohamed').set({
      ...studentData,
      'userType': 'student', 
      'createdAt': FieldValue.serverTimestamp(),
    });

    print('✅ تم إضافة المستخدمين التجريبيين');
  }

  List<String> _generateSearchKeywords(String text) {
    final keywords = <String>[];
    final words = text.toLowerCase().split(' ');
    
    for (int i = 0; i < words.length; i++) {
      for (int j = i + 1; j <= words.length; j++) {
        final keyword = words.sublist(i, j).join(' ');
        if (keyword.length > 1) {
          keywords.add(keyword);
        }
      }
    }
    
    return keywords.toSet().toList();
  }

  // حذف جميع البيانات التجريبية (للتطوير)
  Future<void> clearTestData() async {
    try {
      // حذف جميع المواد
      final subjectsSnapshot = await _firestore.collection('subjects').get();
      for (final doc in subjectsSnapshot.docs) {
        await doc.reference.delete();
      }

      // حذف المستخدمين التجريبيين
      await _firestore.collection('users').doc('teacher_ahmed').delete();
      await _firestore.collection('users').doc('student_mohamed').delete();

      print('✅ تم حذف جميع البيانات التجريبية');
    } catch (e) {
      print('❌ خطأ في حذف البيانات: $e');
    }
  }

  // التحقق من وجود بيانات
  Future<bool> hasTestData() async {
    final snapshot = await _firestore.collection('subjects').limit(1).get();
    return snapshot.docs.isNotEmpty;
  }
}