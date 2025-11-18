import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../core/firebase_service.dart';

class FirebaseAuthProvider with ChangeNotifier {
  User? _user;
  Map<String, dynamic> _userData = {};
  bool _isLoading = false;
  String _error = '';

  // ⭐ جديد: بيانات المنهج والمرحلة
  String? _selectedCurriculum;
  String? _selectedLevel;

  // Getters
  User? get user => _user;
  Map<String, dynamic> get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String get error => _error;
  String? get userType => _userData['userType'] as String?;
  String? get userName => _userData['name'] as String?;
  bool get kycCompleted => _userData['kycCompleted'] as bool? ?? false;

  // ✅ الدوال الجديدة المطلوبة
  User? get currentUser => _user;
  String? get currentUserId => _user?.uid;
  Map<String, dynamic>? get currentUserData => _userData;

  // ⭐ جديد: Getters للمنهج والمرحلة
  String? get selectedCurriculum => _selectedCurriculum;
  String? get selectedLevel => _selectedLevel;
  bool get hasSelectedCurriculum =>
      _selectedCurriculum != null && _selectedLevel != null;

  FirebaseAuthProvider() {
    // الاستماع لتغييرات حالة المستخدم
    FirebaseService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        print('👤 مستخدم جديد مسجل: ${user.uid}');
        _loadUserData(user.uid);
        _loadCurriculumSelection(user.uid); // ⭐ جديد: تحميل اختيار المنهج
      } else {
        print('👤 لا يوجد مستخدم مسجل');
        _userData = {};
        _selectedCurriculum = null; // ⭐ جديد: مسح بيانات المنهج
        _selectedLevel = null;
      }
      notifyListeners();
    });

    // تحميل المستخدم الحالي إذا موجود
    _user = FirebaseService.currentUser;
    if (_user != null) {
      _loadUserData(_user!.uid);
      _loadCurriculumSelection(_user!.uid); // ⭐ جديد: تحميل اختيار المنهج
    }
  }

  // 🔐 تسجيل الدخول
  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      print('🔐 محاولة تسجيل دخول: $email');

      User? user = await FirebaseService.signIn(
        email: email,
        password: password,
      );

      if (user != null) {
        print('✅ تسجيل الدخول ناجح: ${user.uid}');
        await _loadUserData(user.uid);
        await _loadCurriculumSelection(user.uid); // ⭐ جديد: تحميل اختيار المنهج
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      print('❌ خطأ في تسجيل الدخول: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 📝 تسجيل مستخدم جديد
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String userType,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      print('📝 محاولة تسجيل مستخدم جديد: $email');

      User? user = await FirebaseService.signUp(
        email: email,
        password: password,
        name: name,
        userType: userType,
      );

      if (user != null) {
        print('✅ تسجيل المستخدم ناجح: ${user.uid}');
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      print('❌ خطأ في تسجيل المستخدم: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🚪 تسجيل الخروج
  Future<void> signOut() async {
    try {
      print('🚪 تسجيل الخروج...');
      await FirebaseService.signOut();
      _user = null;
      _userData = {};
      _selectedCurriculum = null; // ⭐ جديد: مسح بيانات المنهج
      _selectedLevel = null;
      print('✅ تسجيل الخروج ناجح');
    } catch (e) {
      _error = e.toString();
      print('❌ خطأ في تسجيل الخروج: $_error');
    } finally {
      notifyListeners();
    }
  }

  // 📊 تحميل بيانات المستخدم
  Future<void> _loadUserData(String uid) async {
    try {
      print('📊 جلب بيانات المستخدم: $uid');
      Map<String, dynamic>? data = await FirebaseService.getUserData(uid);
      if (data != null) {
        _userData = data;
        print('✅ بيانات المستخدم محملة: ${_userData['name']}');
      } else {
        print('⚠️ لا توجد بيانات للمستخدم: $uid');
      }
    } catch (e) {
      _error = 'فشل في تحميل بيانات المستخدم: $e';
      print('❌ $_error');
    }
    notifyListeners();
  }

  // ⭐ جديد: تحميل اختيار المنهج والمرحلة
  Future<void> _loadCurriculumSelection(String uid) async {
    try {
      print('📚 جلب اختيار المنهج للمستخدم: $uid');

      final doc = await FirebaseService.firestore
          .collection('user_preferences')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          setState(() {
            _selectedCurriculum = data['selectedCurriculum'] as String?;
            _selectedLevel = data['selectedLevel'] as String?;
          });
          print(
              '✅ تم تحميل اختيار المنهج: $_selectedCurriculum - $_selectedLevel');
        }
      } else {
        print('⚠️ لا توجد تفضيلات محفوظة للمستخدم');
      }
    } catch (e) {
      print('❌ خطأ في تحميل اختيار المنهج: $e');
    }
  }

  // ⭐ جديد: حفظ اختيار المنهج والمرحلة
  Future<void> saveCurriculumSelection({
    required String curriculum,
    required String level,
  }) async {
    try {
      if (_user == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      print('💾 حفظ اختيار المنهج: $curriculum - $level');

      // حفظ في Firestore
      await FirebaseService.firestore
          .collection('user_preferences')
          .doc(_user!.uid)
          .set({
        'selectedCurriculum': curriculum,
        'selectedLevel': level,
        'updatedAt': FieldValue.serverTimestamp(),
        'userId': _user!.uid,
      }, SetOptions(merge: true));

      // تحديث الحالة المحلية
      setState(() {
        _selectedCurriculum = curriculum;
        _selectedLevel = level;
      });

      print('✅ تم حفظ اختيار المنهج بنجاح');

      // ⭐ جديد: تحديث بيانات المستخدم أيضاً
      await updateUserData({
        'selectedCurriculum': curriculum,
        'selectedLevel': level,
      });
    } catch (e) {
      print('❌ خطأ في حفظ اختيار المنهج: $e');
      throw e;
    }
  }

  // ⭐ جديد: دالة مساعدة لتحديث الحالة
  void setState(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  // ✏️ تحديث بيانات المستخدم
  Future<void> updateUserData(Map<String, dynamic> data) async {
    if (_user != null) {
      try {
        print('✏️ تحديث بيانات المستخدم: ${_user!.uid}');
        await FirebaseService.updateUserData(_user!.uid, data);
        await _loadUserData(_user!.uid);
        print('✅ تم تحديث بيانات المستخدم');
      } catch (e) {
        _error = 'فشل في تحديث البيانات: $e';
        print('❌ $_error');
      }
    }
  }

  // 🔄 تحديث حالة KYC
  Future<void> updateKYCStatus(bool status) async {
    if (_user != null) {
      await updateUserData({
        'kycCompleted': status,
        'kycStatus': status ? 'approved' : 'pending',
      });
    }
  }

  // 🧹 مسح الخطأ
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // ℹ️ طباعة معلومات المستخدم (للت debug)
  void printUserInfo() {
    print('''
👤 معلومات المستخدم:
   - UID: ${_user?.uid}
   - الاسم: ${_userData['name']}
   - النوع: ${_userData['userType']}
   - البريد: ${_userData['email']}
   - KYC: ${_userData['kycCompleted'] ?? false}
   - المنهج: $_selectedCurriculum
   - المرحلة: $_selectedLevel
   - مسجل: ${_user != null}
''');
  }

  // ✅ الدالة الجديدة: تقديم طلب KYC
  Future<bool> submitKYCRequest({
    required String fullName,
    required String idNumber,
    required XFile idImage,
    required XFile degreeImage,
    required XFile cvFile,
    required XFile personalPhoto,
    required List<String> specialties,
    required int yearsOfExperience,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final user = _user;
      if (user == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      print('📝 بدء تقديم طلب KYC للمستخدم: ${user.uid}');

      // حفظ بيانات KYC في Firestore
      await FirebaseService.firestore
          .collection('kyc_requests')
          .doc(user.uid)
          .set({
        'userId': user.uid,
        'fullName': fullName,
        'idNumber': idNumber,
        'specialties': specialties,
        'yearsOfExperience': yearsOfExperience,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'documents': {
          'idImage': 'uploaded',
          'degreeImage': 'uploaded',
          'cvFile': 'uploaded',
          'personalPhoto': 'uploaded',
        },
      });

      // تحديث حالة المستخدم
      await FirebaseService.updateUserData(user.uid, {
        'kycCompleted': true,
        'kycStatus': 'pending',
        'fullName': fullName,
        'specialties': specialties,
        'yearsOfExperience': yearsOfExperience,
      });

      // تحديث البيانات المحلية
      await _loadUserData(user.uid);

      _isLoading = false;
      notifyListeners();

      print('✅ تم تقديم طلب KYC بنجاح');
      return true;
    } catch (error) {
      _isLoading = false;
      _error = error.toString();
      print('❌ خطأ في تقديم طلب KYC: $_error');
      notifyListeners();
      return false;
    }
  }
}
