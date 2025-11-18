import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

// ✅ نماذج KYC المحدثة
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

class MockAuthProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isLoggedIn = false;
  Map<String, dynamic> _userData = {};
  TeacherKYC? _teacherKYC;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic> get userData => _userData;
  TeacherKYC? get teacherKYC => _teacherKYC;
  String? get error => _error;

  // ✅ خاصية جديدة للحصول على حالة التحقق
  TeacherVerificationStatus get teacherVerificationStatus {
    if (_userData['userType'] != 'teacher') {
      return TeacherVerificationStatus.notStarted;
    }
    return _teacherKYC?.status ?? TeacherVerificationStatus.notStarted;
  }

  // بيانات مستخدمين تجريبية
  final List<Map<String, dynamic>> _mockUsers = [
    {
      'name': 'أحمد محمد',
      'email': 'student@test.com',
      'userType': 'student',
      'curriculum': 'saudi',
      'grade': 'أول ثانوي',
      'phone': '0512345678',
      'profileImage': null,
    },
    {
      'name': 'د. محمد أحمد',
      'email': 'teacher@test.com',
      'userType': 'teacher',
      'subjects': ['رياضيات', 'فيزياء'],
      'experience': 5,
      'hourlyRate': 80.0,
      'phone': '0512345679',
      'profileImage': null,
      'kycStatus': TeacherVerificationStatus.notStarted.toString(),
    }
  ];

  // ✅ بيانات KYC تجريبية
  final List<TeacherKYC> _mockKYCSubmissions = [];

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String userType,
    required String phone,
    String? curriculum,
    String? grade,
    dynamic profileImage,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // محاكاة delay الشبكة
      await Future.delayed(Duration(seconds: 2));

      // التحقق إذا البريد مستخدم مسبقاً
      if (_mockUsers.any((user) => user['email'] == email)) {
        _error = 'البريد الإلكتروني مستخدم بالفعل';
        return false;
      }

      // إنشاء مستخدم جديد
      Map<String, dynamic> newUser = {
        'name': name,
        'email': email,
        'userType': userType,
        'phone': phone,
        'profileImage': null,
        'createdAt': DateTime.now().toString(),
      };

      if (userType == 'student') {
        newUser.addAll({
          'curriculum': curriculum,
          'grade': grade,
          'learningGoals': [],
        });
      } else if (userType == 'teacher') {
        newUser.addAll({
          'subjects': [],
          'experience': 0,
          'hourlyRate': 0.0,
          'bio': '',
          'rating': 0.0,
          'totalReviews': 0,
          'kycStatus': TeacherVerificationStatus.notStarted.toString(),
        });
      }

      _mockUsers.add(newUser);
      _userData = newUser;
      _isLoggedIn = true;

      return true;
    } catch (e) {
      _error = 'حدث خطأ غير متوقع: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // محاكاة delay الشبكة
      await Future.delayed(Duration(seconds: 2));

      // البحث عن المستخدم مع التحقق من النوع
      var user = _mockUsers.firstWhere(
        (user) => user['email'] == email && user['userType'] == userType,
        orElse: () => {},
      );

      if (user.isEmpty) {
        _error = 'لا يوجد حساب $userType مرتبط بهذا البريد';
        return false;
      }

      // كلمة المرور دائماً صحيحة في النسخة التجريبية
      _userData = user;
      _isLoggedIn = true;

      // ✅ تحميل بيانات KYC إذا كان معلماً
      if (userType == 'teacher') {
        await _loadTeacherKYC(email);
      }

      return true;
    } catch (e) {
      _error = 'حدث خطأ غير متوقع: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ دالة تحميل بيانات KYC
  Future<void> _loadTeacherKYC(String email) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));

      // البحث عن KYC للمعلم
      final kyc = _mockKYCSubmissions.firstWhere(
        (kyc) => kyc.teacherId == email,
        orElse: () => TeacherKYC(
          teacherId: email,
          fullName: _userData['name'],
          idNumber: '',
          specialties: [],
          yearsOfExperience: 0,
          submissionDate: DateTime.now(),
          status: TeacherVerificationStatus.notStarted,
        ),
      );

      _teacherKYC = kyc;
      notifyListeners();
    } catch (e) {
      print('Error loading KYC: $e');
    }
  }

  Future<void> signOut() async {
    _isLoggedIn = false;
    _userData = {};
    _teacherKYC = null;
    notifyListeners();
  }

  // ✅ دوال KYC الجديدة - معدلة بدون Future.delayed الذي يسبب المشكلة
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

      // محاكاة رفع الملفات
      await Future.delayed(Duration(seconds: 2));

      // إنشاء طلب KYC جديد
      final kycData = TeacherKYC(
        teacherId: _userData['email'],
        fullName: fullName,
        idNumber: idNumber,
        idImageUrl: 'mock-id-image-url',
        degreeImageUrl: 'mock-degree-image-url',
        cvUrl: 'mock-cv-url',
        personalPhotoUrl: 'mock-personal-photo-url',
        videoIntroductionUrl:
            videoIntroduction != null ? 'mock-video-url' : null,
        specialties: specialties,
        yearsOfExperience: yearsOfExperience,
        submissionDate: DateTime.now(),
        status: TeacherVerificationStatus.pending,
      );

      // إضافة للبيانات التجريبية
      _mockKYCSubmissions.add(kycData);
      _teacherKYC = kycData;

      // تحديث حالة المستخدم
      _userData['kycStatus'] = TeacherVerificationStatus.pending.toString();

      _isLoading = false;
      notifyListeners();

      // ✅ تم إزالة Future.delayed التلقائي الذي كان يسبب المشكلة
      // بدلاً من ذلك، سنعتمد على تحديث يدوي من الشاشة

      return true;
    } catch (e) {
      _error = 'فشل في تقديم طلب التحقق: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ دالة جديدة لمحاكاة الموافقة على KYC (يمكن استدعاؤها يدوياً)
  Future<bool> approveKYCRequest(String teacherId) async {
    try {
      final kycIndex =
          _mockKYCSubmissions.indexWhere((kyc) => kyc.teacherId == teacherId);
      if (kycIndex != -1) {
        final updatedKYC = TeacherKYC(
          teacherId: _mockKYCSubmissions[kycIndex].teacherId,
          fullName: _mockKYCSubmissions[kycIndex].fullName,
          idNumber: _mockKYCSubmissions[kycIndex].idNumber,
          idImageUrl: _mockKYCSubmissions[kycIndex].idImageUrl,
          degreeImageUrl: _mockKYCSubmissions[kycIndex].degreeImageUrl,
          cvUrl: _mockKYCSubmissions[kycIndex].cvUrl,
          personalPhotoUrl: _mockKYCSubmissions[kycIndex].personalPhotoUrl,
          videoIntroductionUrl:
              _mockKYCSubmissions[kycIndex].videoIntroductionUrl,
          specialties: _mockKYCSubmissions[kycIndex].specialties,
          yearsOfExperience: _mockKYCSubmissions[kycIndex].yearsOfExperience,
          submissionDate: _mockKYCSubmissions[kycIndex].submissionDate,
          status: TeacherVerificationStatus.approved,
        );

        _mockKYCSubmissions[kycIndex] = updatedKYC;

        if (_userData['email'] == teacherId) {
          _teacherKYC = updatedKYC;
          _userData['kycStatus'] =
              TeacherVerificationStatus.approved.toString();
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'فشل في الموافقة على طلب KYC: $e';
      return false;
    }
  }

  // ✅ دالة التحقق من حالة KYC
  Future<bool> checkKYCStatus() async {
    try {
      await Future.delayed(Duration(seconds: 1));
      return true;
    } catch (e) {
      _error = 'فشل في التحقق من حالة KYC: $e';
      return false;
    }
  }

  // ✅ دوال إضافية
  Future<void> resetPassword(String email) async {
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    await Future.delayed(Duration(seconds: 1));
    _userData.addAll(updates);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
