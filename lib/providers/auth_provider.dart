import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

// إضافة نماذج KYC
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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  TeacherKYC? get teacherKYC => _teacherKYC;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // الحصول على حالة التحقق للمعلم
  TeacherVerificationStatus get teacherVerificationStatus {
    if (_userData?['userType'] != 'teacher') {
      return TeacherVerificationStatus.notStarted;
    }
    return _teacherKYC?.status ?? TeacherVerificationStatus.notStarted;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AppAuthProvider() {
    _init();
  }

  void _init() {
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
  }

  Future<void> _loadUserData(String uid) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(uid).get();

      if (snapshot.exists) {
        _userData = snapshot.data() as Map<String, dynamic>;

        // إذا كان المستخدم معلم، نقوم بتحميل بيانات KYC
        if (_userData?['userType'] == 'teacher') {
          await _loadTeacherKYC(uid);
        }
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
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

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? imageUrl;

      if (profileImage != null) {
        imageUrl = await _uploadProfileImage(
          profileImage,
          credential.user!.uid,
        );
      }

      Map<String, dynamic> userData = {
        'name': name,
        'email': email,
        'phone': phone,
        'userType': userType,
        'profileImage': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isEmailVerified': false,
      };

      if (userType == 'student') {
        userData.addAll({
          'curriculum': curriculum,
          'grade': grade,
          'learningGoals': [],
        });
      } else if (userType == 'teacher') {
        userData.addAll({
          'subjects': [],
          'experience': 0,
          'hourlyRate': 0.0,
          'bio': '',
          'rating': 0.0,
          'totalReviews': 0,
          'kycStatus': TeacherVerificationStatus.notStarted.toString(),
        });

        // إنشاء سجل KYC افتراضي للمعلم
        await _createDefaultKYC(credential.user!.uid, name);
      }

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userData);

      await credential.user!.sendEmailVerification();

      _user = credential.user;
      await _loadUserData(credential.user!.uid);

      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e);
      return false;
    } catch (e) {
      _error = 'حدث خطأ غير متوقع: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createDefaultKYC(String teacherId, String fullName) async {
    try {
      final defaultKYC = TeacherKYC(
        teacherId: teacherId,
        fullName: fullName,
        idNumber: '',
        specialties: [],
        yearsOfExperience: 0,
        submissionDate: DateTime.now(),
        status: TeacherVerificationStatus.notStarted,
      );

      await _firestore
          .collection('teacher_kyc')
          .doc(teacherId)
          .set(defaultKYC.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error creating default KYC: $e');
      }
    }
  }

  Future<String?> _uploadProfileImage(XFile imageFile, String userId) async {
    try {
      File file = File(imageFile.path);
      String fileName = 'profile_$userId.jpg';

      Reference ref =
          _storage.ref().child('user_profiles').child(userId).child(fileName);

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      return null;
    }
  }

  // دوال KYC الجديدة
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
      if (_user == null) throw Exception('يجب تسجيل الدخول أولاً');

      _isLoading = true;
      notifyListeners();

      // رفع جميع المستندات
      final String idImageUrl = await _uploadKYCDocument(idImage, 'id_card');
      final String degreeImageUrl =
          await _uploadKYCDocument(degreeImage, 'degree');
      final String cvUrl = await _uploadKYCDocument(cvFile, 'cv');
      final String personalPhotoUrl =
          await _uploadKYCDocument(personalPhoto, 'personal_photo');
      final String? videoUrl = videoIntroduction != null
          ? await _uploadKYCDocument(videoIntroduction, 'video_intro')
          : null;

      // إنشاء سجل KYC
      final kycData = TeacherKYC(
        teacherId: _user!.uid,
        fullName: fullName,
        idNumber: idNumber,
        idImageUrl: idImageUrl,
        degreeImageUrl: degreeImageUrl,
        cvUrl: cvUrl,
        personalPhotoUrl: personalPhotoUrl,
        videoIntroductionUrl: videoUrl,
        specialties: specialties,
        yearsOfExperience: yearsOfExperience,
        submissionDate: DateTime.now(),
        status: TeacherVerificationStatus.pending,
      );

      // حفظ في Firestore
      await _firestore
          .collection('teacher_kyc')
          .doc(_user!.uid)
          .set(kycData.toMap());

      // تحديث حالة المستخدم
      await _firestore.collection('users').doc(_user!.uid).update({
        'kycStatus': TeacherVerificationStatus.pending.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _teacherKYC = kycData;
      await _loadUserData(_user!.uid);

      return true;
    } catch (e) {
      _error = 'فشل في تقديم طلب التحقق: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _uploadKYCDocument(XFile file, String documentType) async {
    try {
      File fileToUpload = File(file.path);
      String extension = file.path.split('.').last;
      String fileName =
          '${documentType}_${_user!.uid}_${DateTime.now().millisecondsSinceEpoch}.$extension';

      Reference ref = _storage
          .ref()
          .child('kyc_documents')
          .child(_user!.uid)
          .child(documentType)
          .child(fileName);

      UploadTask uploadTask = ref.putFile(fileToUpload);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('فشل في رفع المستند: $e');
    }
  }

  Future<bool> checkKYCStatus() async {
    try {
      if (_user == null) return false;

      DocumentSnapshot kycSnapshot =
          await _firestore.collection('teacher_kyc').doc(_user!.uid).get();

      if (kycSnapshot.exists) {
        _teacherKYC =
            TeacherKYC.fromMap(kycSnapshot.data() as Map<String, dynamic>);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'فشل في التحقق من حالة KYC: $e';
      return false;
    }
  }

  // الدوال الأصلية (بدون تعديل)
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = credential.user;
      await _loadUserData(credential.user!.uid);

      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e);
      return false;
    } catch (e) {
      _error = 'حدث خطأ غير متوقع: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _userData = null;
    _teacherKYC = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw FirebaseAuthException(
        code: 'reset_password_failed',
        message: 'فشل في إرسال رابط استعادة كلمة المرور',
      );
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      if (_user != null) {
        await _firestore.collection('users').doc(_user!.uid).update({
          ...updates,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await _loadUserData(_user!.uid);
      }
    } catch (e) {
      throw Exception('فشل في تحديث البيانات: $e');
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
