// 📁 lib/providers/payment_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_models.dart';

class PaymentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<PaymentTransaction> _transactions = [];
  List<PaymentTransaction> _userTransactions = [];
  List<PaymentTransaction> _teacherTransactions = [];
  WalletBalance? _walletBalance;
  bool _isLoading = false;
  String _error = '';

  List<PaymentTransaction> get transactions => _transactions;
  List<PaymentTransaction> get userTransactions => _userTransactions;
  List<PaymentTransaction> get teacherTransactions => _teacherTransactions;
  WalletBalance? get walletBalance => _walletBalance;
  bool get isLoading => _isLoading;
  String get error => _error;

  // ✅ حساب العمولة
  Map<String, double> calculateCommission(double amount) {
    final studentCommission = amount * 0.05; // 5%
    final teacherCommission = amount * 0.05; // 5%
    final netAmount = amount - teacherCommission;
    final totalCommission = studentCommission + teacherCommission;

    return {
      'studentCommission': studentCommission,
      'teacherCommission': teacherCommission,
      'netAmount': netAmount,
      'totalCommission': totalCommission,
    };
  }

  // ✅ إنشاء معاملة دفع جديدة
  Future<bool> createPaymentTransaction({
    required String studentId,
    required String teacherId,
    required String courseId,
    required double amount,
    required String paymentMethod,
    required String currency,
    required String country,
    String? bookingId,
  }) async {
    try {
      _setLoading(true);
      _setError('');

      final commission = calculateCommission(amount);

      final newTransaction = PaymentTransaction(
        id: '', // سيتم تعبئته من Firebase
        studentId: studentId,
        teacherId: teacherId,
        courseId: courseId,
        amount: amount,
        studentCommission: commission['studentCommission']!,
        teacherCommission: commission['teacherCommission']!,
        netAmount: commission['netAmount']!,
        paymentMethod: paymentMethod,
        currency: currency,
        country: country,
        status: 'completed',
        createdAt: DateTime.now(),
        bookingId: bookingId,
      );

      final transactionData = newTransaction.toFirestore();
      final docRef = await _firestore
          .collection('payment_transactions')
          .add(transactionData);

      // تحديث المعاملة بالمعرّف
      await _firestore
          .collection('payment_transactions')
          .doc(docRef.id)
          .update({
        'id': docRef.id,
      });

      // تحديث رصيد المحفظة
      await _updateWalletBalance(teacherId, commission['netAmount']!);

      _setLoading(false);
      print('✅ تم إنشاء معاملة الدفع: ${docRef.id}');
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('فشل في إنشاء معاملة الدفع: ${e.toString()}');
      return false;
    }
  }

  // ✅ جلب جميع المعاملات (للمشرفين)
  Future<void> loadAllTransactions() async {
    try {
      _setLoading(true);

      final querySnapshot = await _firestore
          .collection('payment_transactions')
          .orderBy('createdAt', descending: true)
          .get();

      _transactions = querySnapshot.docs
          .map((doc) => PaymentTransaction.fromFirestore(doc))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('فشل في جلب المعاملات: ${e.toString()}');
    }
  }

  // ✅ جلب معاملات مستخدم معين
  Future<void> fetchUserTransactions(String userId) async {
    try {
      _setLoading(true);

      final querySnapshot = await _firestore
          .collection('payment_transactions')
          .where('studentId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _userTransactions = querySnapshot.docs
          .map((doc) => PaymentTransaction.fromFirestore(doc))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('فشل في جلب معاملات المستخدم: ${e.toString()}');
    }
  }

  // ✅ جلب معاملات معلم معين
  Future<void> fetchTeacherTransactions(String teacherId) async {
    try {
      _setLoading(true);

      final querySnapshot = await _firestore
          .collection('payment_transactions')
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('createdAt', descending: true)
          .get();

      _teacherTransactions = querySnapshot.docs
          .map((doc) => PaymentTransaction.fromFirestore(doc))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('فشل في جلب معاملات المعلم: ${e.toString()}');
    }
  }

  // ✅ تحديث رصيد المحفظة
  Future<void> updateWalletBalance(String userId) async {
    try {
      final doc =
          await _firestore.collection('wallet_balances').doc(userId).get();

      if (doc.exists) {
        _walletBalance = WalletBalance.fromFirestore(doc);
      } else {
        // إنشاء محفظة جديدة إذا لم تكن موجودة
        _walletBalance = WalletBalance.createNew(userId);
        await _firestore
            .collection('wallet_balances')
            .doc(userId)
            .set(_walletBalance!.toFirestore());
      }

      notifyListeners();
    } catch (e) {
      _setError('فشل في تحديث رصيد المحفظة: ${e.toString()}');
    }
  }

  // ✅ تحديث رصيد المحفظة بعد معاملة ناجحة
  Future<void> _updateWalletBalance(String teacherId, double amount) async {
    try {
      final doc =
          await _firestore.collection('wallet_balances').doc(teacherId).get();

      WalletBalance updatedBalance;
      if (doc.exists) {
        final currentBalance = WalletBalance.fromFirestore(doc);
        updatedBalance = currentBalance.addEarning(amount);
      } else {
        updatedBalance = WalletBalance.createNew(teacherId).addEarning(amount);
      }

      await _firestore
          .collection('wallet_balances')
          .doc(teacherId)
          .set(updatedBalance.toFirestore());

      _walletBalance = updatedBalance;
      notifyListeners();
    } catch (e) {
      print('❌ فشل في تحديث رصيد المحفظة: $e');
    }
  }

  // ✅ إنشاء جدولة سحب
  Future<bool> createPayoutSchedule({
    required String teacherId,
    required double totalAmount,
    required List<String> transactionIds,
  }) async {
    try {
      _setLoading(true);

      final newPayout = PayoutSchedule(
        id: '', // سيتم تعبئته من Firebase
        teacherId: teacherId,
        totalAmount: totalAmount,
        status: 'pending',
        payoutDate: DateTime.now().add(Duration(days: 7)),
        createdAt: DateTime.now(),
        transactionIds: transactionIds,
      );

      final payoutData = newPayout.toFirestore();
      final docRef =
          await _firestore.collection('payout_schedules').add(payoutData);

      // تحديث الجدولة بالمعرّف
      await _firestore.collection('payout_schedules').doc(docRef.id).update({
        'id': docRef.id,
      });

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('فشل في إنشاء جدولة السحب: ${e.toString()}');
      return false;
    }
  }

  // ✅ جلب إحصائيات الدفع
  Future<PaymentStats> getPaymentStats(
      {String? userId, String? userType}) async {
    try {
      Query query = _firestore.collection('payment_transactions');

      if (userId != null && userType != null) {
        final field = userType == 'student' ? 'studentId' : 'teacherId';
        query = query.where(field, isEqualTo: userId);
      }

      final snapshot = await query.get();
      final allTransactions = snapshot.docs
          .map((doc) => PaymentTransaction.fromFirestore(doc))
          .toList();

      final successfulTransactions =
          allTransactions.where((t) => t.isCompleted).length;
      final failedTransactions =
          allTransactions.where((t) => t.isFailed).length;
      final totalRevenue =
          allTransactions.fold(0.0, (sum, t) => sum + t.amount);
      final totalCommission = allTransactions.fold(
          0.0, (sum, t) => sum + t.studentCommission + t.teacherCommission);

      final paymentMethodStats = <String, int>{};
      for (final transaction in allTransactions) {
        paymentMethodStats[transaction.paymentMethod] =
            (paymentMethodStats[transaction.paymentMethod] ?? 0) + 1;
      }

      return PaymentStats(
        totalTransactions: allTransactions.length,
        totalRevenue: totalRevenue,
        totalCommission: totalCommission,
        successfulTransactions: successfulTransactions,
        failedTransactions: failedTransactions,
        paymentMethodStats: paymentMethodStats,
      );
    } catch (e) {
      throw Exception('فشل في جلب إحصائيات الدفع: ${e.toString()}');
    }
  }

  // ✅ تحديث حالة المعاملة
  Future<bool> updateTransactionStatus(
      String transactionId, String newStatus) async {
    try {
      _setLoading(true);

      await _firestore
          .collection('payment_transactions')
          .doc(transactionId)
          .update({
        'status': newStatus,
        'updatedAt': Timestamp.now(),
      });

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('فشل في تحديث حالة المعاملة: ${e.toString()}');
      return false;
    }
  }

  // ✅ البحث في المعاملات
  Future<List<PaymentTransaction>> searchTransactions(String query) async {
    try {
      final snapshot = await _firestore
          .collection('payment_transactions')
          .orderBy('createdAt', descending: true)
          .get();

      final allTransactions = snapshot.docs
          .map((doc) => PaymentTransaction.fromFirestore(doc))
          .toList();

      if (query.isEmpty) {
        return allTransactions;
      }

      return allTransactions
          .where((transaction) =>
              transaction.id.toLowerCase().contains(query.toLowerCase()) ||
              transaction.studentId
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              transaction.teacherId
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              transaction.paymentMethod
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      _setError('فشل في البحث في المعاملات: ${e.toString()}');
      return [];
    }
  }

  // 🔄 دوال مساعدة
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    if (error.isNotEmpty) {
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
