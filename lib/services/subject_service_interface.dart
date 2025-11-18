import '../models/subject_model.dart';

abstract class BaseSubjectService {
  // الحصول على جميع المواد
  Stream<List<Subject>> getSubjects();
  
  // البحث في المواد
  Stream<List<Subject>> searchSubjects(String query);
  
  // الحصول على المواد المميزة
  Future<List<Subject>> getFeaturedSubjects();
  
  // الحصول على المواد حسب الفئة
  Stream<List<Subject>> getSubjectsByCategory(String category);
  
  // إضافة مادة جديدة (للمعلمين)
  Future<void> addSubject(Subject subject);
  
  // تحديث مادة
  Future<void> updateSubject(Subject subject);
  
  // حذف مادة
  Future<void> deleteSubject(String subjectId);
  
  // الحصول على مواد معلم معين
  Stream<List<Subject>> getTeacherSubjects(String teacherId);
  
  // الحصول على مادة بواسطة ID
  Future<Subject?> getSubjectById(String subjectId);
  
  // زيادة عدد الطلاب في مادة
  Future<void> incrementStudentCount(String subjectId);
  
  // الحصول على المواد المشابهة
  Future<List<Subject>> getSimilarSubjects(Subject subject);
}