import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_options.dart'; // ⭐ التحديث: استيراد ملف التهيئة التلقائي

class FirebaseService {
  static late FirebaseAuth auth;
  static late FirebaseFirestore firestore;
  static late FirebaseStorage storage;

  static Future<void> initialize() async {
    try {
      print('🔥 بدء تهيئة Firebase...');

      // ⭐ التحديث: استخدام الإعدادات التلقائية من flutterfire configure
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // ⭐ تهيئة الخدمات
      auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;
      storage = FirebaseStorage.instance;

      print('✅ Firebase Services مهيأة بنجاح');
      print('📧 Auth: ${auth.app.name}');
      print('🗄️ Firestore: ${firestore.app.name}');
      print('💾 Storage: ${storage.app.name}');
    } catch (e) {
      print('❌ خطأ في تهيئة Firebase: $e');
      rethrow;
    }
  }

  // ⭐ تسجيل مستخدم جديد
  static Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String userType,
  }) async {
    try {
      print('👤 محاولة تسجيل مستخدم جديد: $email');

      UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      print('✅ تم إنشاء المستخدم: ${credential.user!.uid}');

      // ⭐ حفظ بيانات المستخدم في Firestore
      await firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'name': name,
        'email': email,
        'userType': userType,
        'isVerified': false,
        'kycCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ تم حفظ بيانات المستخدم في Firestore');

      return credential.user;
    } catch (e) {
      print('❌ خطأ في تسجيل المستخدم: $e');
      throw FirebaseAuthException(
        code: _getErrorCode(e.toString()),
        message: _getErrorMessage(e.toString()),
      );
    }
  }

  // ⭐ تسجيل الدخول
  static Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 محاولة تسجيل دخول: $email');

      UserCredential credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      print('✅ تم تسجيل الدخول: ${credential.user!.uid}');
      return credential.user;
    } catch (e) {
      print('❌ خطأ في تسجيل الدخول: $e');
      throw FirebaseAuthException(
        code: _getErrorCode(e.toString()),
        message: _getErrorMessage(e.toString()),
      );
    }
  }

  // ⭐ تسجيل الخروج
  static Future<void> signOut() async {
    try {
      await auth.signOut();
      print('✅ تم تسجيل الخروج بنجاح');
    } catch (e) {
      print('❌ خطأ في تسجيل الخروج: $e');
      rethrow;
    }
  }

  // ⭐ الحصول على بيانات المستخدم
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot snapshot =
          await firestore.collection('users').doc(uid).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        print('✅ تم جلب بيانات المستخدم: $uid');
        return data;
      } else {
        print('⚠️ لم يتم العثور على بيانات المستخدم: $uid');
        return null;
      }
    } catch (e) {
      print('❌ خطأ في جلب بيانات المستخدم: $e');
      return null;
    }
  }

  // ⭐ تحديث بيانات المستخدم
  static Future<void> updateUserData(
      String uid, Map<String, dynamic> data) async {
    try {
      await firestore.collection('users').doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ تم تحديث بيانات المستخدم: $uid');
    } catch (e) {
      print('❌ خطأ في تحديث بيانات المستخدم: $e');
      rethrow;
    }
  }

  // ⭐ التحقق من حالة المصادقة الحالية
  static User? get currentUser => auth.currentUser;

  // ⭐ تيار التغييرات في حالة المصادقة
  static Stream<User?> get authStateChanges => auth.authStateChanges();

  // ⭐ رفع ملف إلى التخزين
  static Future<String> uploadFile(String path, File file) async {
    try {
      Reference ref = storage.ref().child(path);
      await ref.putFile(file);
      String downloadURL = await ref.getDownloadURL();
      print('✅ تم رفع الملف: $downloadURL');
      return downloadURL;
    } catch (e) {
      print('❌ خطأ في رفع الملف: $e');
      rethrow;
    }
  }

  // ⭐ رفع ملف من المسار (بديل)
  static Future<String> uploadFileFromPath(String path, String filePath) async {
    try {
      File file = File(filePath);
      Reference ref = storage.ref().child(path);
      await ref.putFile(file);
      String downloadURL = await ref.getDownloadURL();
      print('✅ تم رفع الملف من المسار: $downloadURL');
      return downloadURL;
    } catch (e) {
      print('❌ خطأ في رفع الملف من المسار: $e');
      rethrow;
    }
  }

  // ⭐ دوال مساعدة لمعالجة الأخطاء
  static String _getErrorCode(String error) {
    if (error.contains('email-already-in-use')) return 'email-already-in-use';
    if (error.contains('invalid-email')) return 'invalid-email';
    if (error.contains('weak-password')) return 'weak-password';
    if (error.contains('user-not-found')) return 'user-not-found';
    if (error.contains('wrong-password')) return 'wrong-password';
    return 'unknown-error';
  }

  static String _getErrorMessage(String error) {
    if (error.contains('email-already-in-use'))
      return 'البريد الإلكتروني مستخدم بالفعل';
    if (error.contains('invalid-email')) return 'بريد إلكتروني غير صالح';
    if (error.contains('weak-password')) return 'كلمة المرور ضعيفة';
    if (error.contains('user-not-found')) return 'المستخدم غير موجود';
    if (error.contains('wrong-password')) return 'كلمة المرور غير صحيحة';
    return 'حدث خطأ غير متوقع';
  }

  // ⭐ دوال Firestore الأساسية
  static Future<void> addDocument(
      String collection, Map<String, dynamic> data) async {
    await firestore.collection(collection).add(data);
  }

  static Future<void> setDocument(
      String collection, String docId, Map<String, dynamic> data) async {
    await firestore.collection(collection).doc(docId).set(data);
  }

  static Future<DocumentSnapshot> getDocument(
      String collection, String docId) async {
    return await firestore.collection(collection).doc(docId).get();
  }

  static Stream<QuerySnapshot> getCollectionStream(String collection) {
    return firestore.collection(collection).snapshots();
  }

  // ⭐ دالة مساعدة للتحقق من اتصال Firebase
  static Future<bool> testConnection() async {
    try {
      // محاولة قراءة بسيطة من Firestore
      await firestore.collection('test').limit(1).get();
      print('✅ اتصال Firebase نشط');
      return true;
    } catch (e) {
      print('❌ فشل في الاتصال بـ Firebase: $e');
      return false;
    }
  }
}
