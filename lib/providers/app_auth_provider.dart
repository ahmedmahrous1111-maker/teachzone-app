import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

// ✅ نماذج KYC
enum TeacherVerificationStatus {
  notStarted,
  pending,
  underReview,
  approved,
  rejected,
  needsRevision
}

class TeacherKYC {
  final String teacherId;
  final String fullName;
  final String idNumber;
  final String? idImageUrl;
  final String? degreeImageUrl;
  final String? cvUrl;
  final String? personalPhotoUrl;
  final String? videoIntroductionUrl;
  final List<String> specialties;
  final int yearsOfExperience;
  final DateTime submissionDate;
  final TeacherVerificationStatus status;
  final String? adminNotes;
  final String? rejectionReason;

  TeacherKYC({
    required this.teacherId,
    required this.fullName,
    required this.idNumber,
    this.idImageUrl,
    this.degreeImageUrl,
    this.cvUrl,
    this.personalPhotoUrl,
    this.videoIntroductionUrl,
    required this.specialties,
    required this.yearsOfExperience,
    required this.submissionDate,
    required this.status,
    this.adminNotes,
    this.rejectionReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'fullName': fullName,
      'idNumber': idNumber,
      'idImageUrl': idImageUrl,
      'degreeImageUrl': degreeImageUrl,
      'cvUrl': cvUrl,
      'personalPhotoUrl': personalPhotoUrl,
      'videoIntroductionUrl': videoIntroductionUrl,
      'specialties': specialties,
      'yearsOfExperience': yearsOfExperience,
      'submissionDate': submissionDate.millisecondsSinceEpoch,
      'status': status.toString(),
      'adminNotes': adminNotes,
      'rejectionReason': rejectionReason,
    };
  }

  static TeacherKYC fromMap(Map<String, dynamic> map) {
    return TeacherKYC(
      teacherId: map['teacherId'],
      fullName: map['fullName'],
      idNumber: map['idNumber'],
      idImageUrl: map['idImageUrl'],
      degreeImageUrl: map['degreeImageUrl'],
      cvUrl: map['cvUrl'],
      personalPhotoUrl: map['personalPhotoUrl'],
      videoIntroductionUrl: map['videoIntroductionUrl'],
      specialties: List<String>.from(map['specialties'] ?? []),
      yearsOfExperience: map['yearsOfExperience'] ?? 0,
      submissionDate:
          DateTime.fromMillisecondsSinceEpoch(map['submissionDate']),
      status: _parseStatus(map['status']),
      adminNotes: map['adminNotes'],
      rejectionReason: map['rejectionReason'],
    );
  }

  static TeacherVerificationStatus _parseStatus(String status) {
    switch (status) {
      case 'TeacherVerificationStatus.pending':
        return TeacherVerificationStatus.pending;
      case 'TeacherVerificationStatus.underReview':
        return TeacherVerificationStatus.underReview;
      case 'TeacherVerificationStatus.approved':
        return TeacherVerificationStatus.approved;
      case 'TeacherVerificationStatus.rejected':
        return TeacherVerificationStatus.rejected;
      case 'TeacherVerificationStatus.needsRevision':
        return TeacherVerificationStatus.needsRevision;
      default:
        return TeacherVerificationStatus.notStarted;
    }
  }
}

class AppAuthProvider with ChangeNotifier {
  User? _user;
  Map<String, dynamic>? _userData;
  TeacherKYC? _teacherKYC;
  bool _isLoading = false;
  String? _error;

  // ✅ استخدام Firebase مباشرة بدون تهيئة إضافية
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  TeacherKYC? get teacherKYC => _teacherKYC;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TeacherVerificationStatus get teacherVerificationStatus {
    if (_userData?['userType'] != 'teacher') {
      return TeacherVerificationStatus.notStarted;
    }
    return _teacherKYC?.status ?? TeacherVerificationStatus.notStarted;
  }

  Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting auth state changes: $e');
      }
      return const Stream.empty();
    }
  }

  AppAuthProvider() {
    _init();
  }

  void _init() {
    try {
      _auth.authStateChanges().listen((User? user) {
        _user = user;
        if (user != null) {
          _loadUserData(user.uid);
        } else {
          _userData = null;
          _teacherKYC = null;
        }
        notifyListeners();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error in auth init: $e');
      }
      // ✅ استخدام بيانات وهمية في حالة الخطأ
      _setupMockData();
    }
  }

  // ✅ إعداد بيانات وهمية للتجربة
  void _setupMockData() {
    _userData = {
      'name': 'أحمد محمد',
      'email': 'ahmed@example.com',
      'phone': '+966500000000',
      'userType': 'teacher',
      'profileImage': null,
      'createdAt': DateTime.now(),
      'isEmailVerified': true,
      'subjects': ['رياضيات', 'فيزياء'],
      'experience': 5,
      'hourlyRate': 100.0,
      'bio': 'معلم متمرس في الرياضيات والفيزياء',
      'rating': 4.8,
      'totalReviews': 47,
      'kycStatus': TeacherVerificationStatus.notStarted.toString(),
    };

    _teacherKYC = TeacherKYC(
      teacherId: 'mock-teacher-id',
      fullName: 'أحمد محمد',
      idNumber: '',
      specialties: ['رياضيات', 'فيزياء'],
      yearsOfExperience: 5,
      submissionDate: DateTime.now(),
      status: TeacherVerificationStatus.notStarted,
    );
  }

  Future<void> _loadUserData(String uid) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(uid).get();

      if (snapshot.exists) {
        _userData = snapshot.data() as Map<String, dynamic>;

        if (_userData?['userType'] == 'teacher') {
          await _loadTeacherKYC(uid);
        }
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
      // ✅ استخدام بيانات وهمية في حالة الخطأ
      _setupMockData();
      notifyListeners();
    }
  }

  Future<void> _loadTeacherKYC(String teacherId) async {
    try {
      DocumentSnapshot kycSnapshot =
          await _firestore.collection('teacher_kyc').doc(teacherId).get();

      if (kycSnapshot.exists) {
        _teacherKYC =
            TeacherKYC.fromMap(kycSnapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading teacher KYC: $e');
      }
    }
  }

  // ✅ استخدام Mock Data للتجربة
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String userType,
    required String phone,
    String? curriculum,
    String? grade,
    XFile? profileImage,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // ✅ استخدام Mock data مؤقتاً
      await Future.delayed(Duration(seconds: 2));

      // بيانات وهمية للتجربة
      _setupMockData();
      _userData!['name'] = name;
      _userData!['email'] = email;
      _userData!['phone'] = phone;
      _userData!['userType'] = userType;

      if (userType == 'student') {
        _userData!.addAll({
          'curriculum': curriculum,
          'grade': grade,
          'learningGoals': [],
        });
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'حدث خطأ غير متوقع: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ دوال Mock للتجربة
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // ✅ استخدام Mock data مؤقتاً
      await Future.delayed(Duration(seconds: 2));

      // إعداد بيانات وهمية
      _setupMockData();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'حدث خطأ غير متوقع: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // تجاهل الأخطاء في الـ Mock
    }
    _user = null;
    _userData = null;
    _teacherKYC = null;
    notifyListeners();
  }

  // ✅ دوال KYC (Mock)
  Future<bool> submitKYCRequest({
    required String fullName,
    required String idNumber,
    required XFile idImage,
    required XFile degreeImage,
    required XFile cvFile,
    required XFile personalPhoto,
    required List<String> specialties,
    required int yearsOfExperience,
    XFile? videoIntroduction,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // ✅ Mock - محاكاة رفع الملفات
      await Future.delayed(Duration(seconds: 3));

      final kycData = TeacherKYC(
        teacherId: 'mock-teacher-id',
        fullName: fullName,
        idNumber: idNumber,
        idImageUrl: 'mock-url',
        degreeImageUrl: 'mock-url',
        cvUrl: 'mock-url',
        personalPhotoUrl: 'mock-url',
        videoIntroductionUrl: videoIntroduction != null ? 'mock-url' : null,
        specialties: specialties,
        yearsOfExperience: yearsOfExperience,
        submissionDate: DateTime.now(),
        status: TeacherVerificationStatus.pending,
      );

      _teacherKYC = kycData;

      // تحديث حالة المستخدم
      if (_userData != null) {
        _userData!['kycStatus'] = TeacherVerificationStatus.pending.toString();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'فشل في تقديم طلب التحقق: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkKYCStatus() async {
    try {
      // ✅ Mock - محاكاة التحقق من الحالة
      await Future.delayed(Duration(seconds: 1));
      return true;
    } catch (e) {
      _error = 'فشل في التحقق من حالة KYC: $e';
      return false;
    }
  }

  // ✅ دوال إضافية (Mock)
  Future<void> resetPassword(String email) async {
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    await Future.delayed(Duration(seconds: 1));
    if (_userData != null) {
      _userData!.addAll(updates);
      notifyListeners();
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'operation-not-allowed':
        return 'عملية التسجيل غير مسموحة';
      case 'weak-password':
        return 'كلمة المرور ضعيفة';
      case 'user-disabled':
        return 'الحساب معطل';
      case 'user-not-found':
        return 'لا يوجد حساب مرتبط بهذا البريد';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'too-many-requests':
        return 'محاولات كثيرة جداً، يرجى المحاولة لاحقاً';
      default:
        return 'حدث خطأ: ${e.message}';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
