import './subject_service_interface.dart';
import './mock_subject_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // تغيير هذا المتغير لـ true عندما نريد استخدام Firebase
  static bool useFirebase = false;

  BaseSubjectService get subjectService {
    // حالياً نستخدم Mock Service فقط
    return MockSubjectService();
    
    // مستقبلاً:
    // if (useFirebase) {
    //   return FirebaseSubjectService();
    // } else {
    //   return MockSubjectService();
    // }
  }
}