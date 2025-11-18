import 'dart:async';
import './subject_service_interface.dart';
import '../models/subject_model.dart';

class MockSubjectService implements BaseSubjectService {
  final List<Subject> _subjects = [
    Subject(
      id: '1',
      name: 'الرياضيات للصف الأول الثانوي',
      description: 'شرح كامل لمنهج الرياضيات مع تمارين عملية',
      teacherId: 'teacher1',
      teacherName: 'أستاذ أحمد محمد',
      price: 200.0,
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400',
      categories: ['الرياضيات', 'الثانوي'],
      totalStudents: 150,
      createdAt: DateTime.now(),
    ),
    Subject(
      id: '2',
      name: 'الفيزياء المتقدمة',
      description: 'دورة متقدمة في الفيزياء تشمل الميكانيكا والكهرباء',
      teacherId: 'teacher2',
      teacherName: 'د. سارة عبدالله',
      price: 300.0,
      rating: 4.9,
      imageUrl: 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=400',
      categories: ['الفيزياء', 'الثانوي'],
      totalStudents: 89,
      createdAt: DateTime.now(),
    ),
    Subject(
      id: '3',
      name: 'اللغة العربية - النحو والصرف',
      description: 'دورة شاملة في النحو والصرف للمرحلة الثانوية',
      teacherId: 'teacher3',
      teacherName: 'أ. خالد إبراهيم',
      price: 150.0,
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1589994965851-a8f479c573a9?w=400',
      categories: ['اللغة العربية', 'الثانوي'],
      totalStudents: 203,
      createdAt: DateTime.now(),
    ),
    Subject(
      id: '4',
      name: 'English Conversation',
      description: 'Master English conversation skills with native-like fluency',
      teacherId: 'teacher4',
      teacherName: 'Ms. Emily Johnson',
      price: 250.0,
      rating: 4.9,
      imageUrl: 'https://images.unsplash.com/photo-1523580494863-6f3031224c94?w=400',
      categories: ['اللغة الإنجليزية', 'الثانوي'],
      totalStudents: 178,
      createdAt: DateTime.now(),
    ),
  ];

  final StreamController<List<Subject>> _subjectsController = 
      StreamController<List<Subject>>.broadcast();

  @override
  Stream<List<Subject>> getSubjects() {
    // إرجاع البيانات الحالية فوراً
    _subjectsController.add(List.from(_subjects));
    return _subjectsController.stream;
  }

  @override
  Stream<List<Subject>> searchSubjects(String query) {
    if (query.isEmpty) {
      return getSubjects();
    }
    
    final results = _subjects.where((subject) {
      return subject.name.toLowerCase().contains(query.toLowerCase()) ||
             subject.teacherName.toLowerCase().contains(query.toLowerCase()) ||
             subject.categories.any((cat) => cat.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    return Stream.value(results);
  }

  @override
  Future<List<Subject>> getFeaturedSubjects() async {
    await _simulateDelay();
    return _subjects.where((subject) => subject.rating >= 4.5).toList();
  }

  @override
  Stream<List<Subject>> getSubjectsByCategory(String category) {
    final results = _subjects.where((subject) {
      return subject.categories.contains(category);
    }).toList();

    return Stream.value(results);
  }

  @override
  Future<void> addSubject(Subject subject) async {
    await _simulateDelay();
    _subjects.add(subject);
    _notifyListeners();
  }

  @override
  Future<void> updateSubject(Subject subject) async {
    await _simulateDelay();
    final index = _subjects.indexWhere((s) => s.id == subject.id);
    if (index != -1) {
      _subjects[index] = subject;
      _notifyListeners();
    }
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    await _simulateDelay();
    _subjects.removeWhere((subject) => subject.id == subjectId);
    _notifyListeners();
  }

  @override
  Stream<List<Subject>> getTeacherSubjects(String teacherId) {
    final results = _subjects.where((subject) => subject.teacherId == teacherId).toList();
    return Stream.value(results);
  }

  @override
  Future<Subject?> getSubjectById(String subjectId) async {
    await _simulateDelay();
    try {
      return _subjects.firstWhere((subject) => subject.id == subjectId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> incrementStudentCount(String subjectId) async {
    await _simulateDelay();
    final index = _subjects.indexWhere((s) => s.id == subjectId);
    if (index != -1) {
      final current = _subjects[index];
      final updated = Subject(
        id: current.id,
        name: current.name,
        description: current.description,
        teacherId: current.teacherId,
        teacherName: current.teacherName,
        price: current.price,
        rating: current.rating,
        imageUrl: current.imageUrl,
        categories: current.categories,
        totalStudents: current.totalStudents + 1,
        createdAt: current.createdAt,
      );
      _subjects[index] = updated;
      _notifyListeners();
    }
  }

  @override
  Future<List<Subject>> getSimilarSubjects(Subject subject) async {
    await _simulateDelay();
    return _subjects
        .where((s) => s.id != subject.id && 
            s.categories.any((cat) => subject.categories.contains(cat)))
        .take(2)
        .toList();
  }

  Future<void> _simulateDelay() async {
    await Future.delayed(Duration(milliseconds: 300));
  }

  void _notifyListeners() {
    if (!_subjectsController.isClosed) {
      _subjectsController.add(List.from(_subjects));
    }
  }

  void dispose() {
    _subjectsController.close();
  }
}