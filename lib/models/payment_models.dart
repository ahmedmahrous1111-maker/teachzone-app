// 📁 lib/models/payment_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentTransaction {
  final String id;
  final String studentId;
  final String teacherId;
  final String courseId;
  final double amount;
  final double studentCommission;
  final double teacherCommission;
  final double netAmount;
  final String paymentMethod;
  final String currency;
  final String country;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? bookingId;

  PaymentTransaction({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.courseId,
    required this.amount,
    required this.studentCommission,
    required this.teacherCommission,
    required this.netAmount,
    required this.paymentMethod,
    required this.currency,
    required this.country,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.bookingId,
  });

  // تحويل إلى Map لـ Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'teacherId': teacherId,
      'courseId': courseId,
      'amount': amount,
      'studentCommission': studentCommission,
      'teacherCommission': teacherCommission,
      'netAmount': netAmount,
      'paymentMethod': paymentMethod,
      'currency': currency,
      'country': country,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'bookingId': bookingId,
    };
  }

  // إنشاء من Firestore
  factory PaymentTransaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PaymentTransaction(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      teacherId: data['teacherId'] ?? '',
      courseId: data['courseId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      studentCommission: (data['studentCommission'] ?? 0).toDouble(),
      teacherCommission: (data['teacherCommission'] ?? 0).toDouble(),
      netAmount: (data['netAmount'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      currency: data['currency'] ?? 'SAR',
      country: data['country'] ?? 'SA',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      bookingId: data['bookingId'],
    );
  }

  // نسخ مع تحديث بعض القيم
  PaymentTransaction copyWith({
    String? id,
    String? studentId,
    String? teacherId,
    String? courseId,
    double? amount,
    double? studentCommission,
    double? teacherCommission,
    double? netAmount,
    String? paymentMethod,
    String? currency,
    String? country,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bookingId,
  }) {
    return PaymentTransaction(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      teacherId: teacherId ?? this.teacherId,
      courseId: courseId ?? this.courseId,
      amount: amount ?? this.amount,
      studentCommission: studentCommission ?? this.studentCommission,
      teacherCommission: teacherCommission ?? this.teacherCommission,
      netAmount: netAmount ?? this.netAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      currency: currency ?? this.currency,
      country: country ?? this.country,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bookingId: bookingId ?? this.bookingId,
    );
  }

  // التحويل إلى JSON
  Map<String, dynamic> toJson() {
    return toFirestore()..['id'] = id;
  }

  // الإنشاء من JSON
  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      teacherId: json['teacherId'] ?? '',
      courseId: json['courseId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      studentCommission: (json['studentCommission'] ?? 0).toDouble(),
      teacherCommission: (json['teacherCommission'] ?? 0).toDouble(),
      netAmount: (json['netAmount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      currency: json['currency'] ?? 'SAR',
      country: json['country'] ?? 'SA',
      status: json['status'] ?? 'pending',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      bookingId: json['bookingId'],
    );
  }

  // الحصول على رمز العملة
  String get currencySymbol {
    switch (currency) {
      case 'SAR':
        return 'ر.س';
      case 'EGP':
        return 'ج.م';
      case 'USD':
        return '\$';
      default:
        return currency;
    }
  }

  // تنسيق المبلغ
  String get formattedAmount {
    return '${amount.toStringAsFixed(2)} $currencySymbol';
  }

  // تنسيق العمولة
  String get formattedStudentCommission {
    return '${studentCommission.toStringAsFixed(2)} $currencySymbol';
  }

  String get formattedTeacherCommission {
    return '${teacherCommission.toStringAsFixed(2)} $currencySymbol';
  }

  // تنسيق الصافي
  String get formattedNetAmount {
    return '${netAmount.toStringAsFixed(2)} $currencySymbol';
  }

  // التحقق من الحالة
  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';

  @override
  String toString() {
    return 'PaymentTransaction(id: $id, amount: $formattedAmount, status: $status)';
  }
}

class PayoutSchedule {
  final String id;
  final String teacherId;
  final double totalAmount;
  final String status;
  final DateTime payoutDate;
  final DateTime createdAt;
  final List<String> transactionIds;

  PayoutSchedule({
    required this.id,
    required this.teacherId,
    required this.totalAmount,
    required this.status,
    required this.payoutDate,
    required this.createdAt,
    this.transactionIds = const [],
  });

  // تحويل إلى Map لـ Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'teacherId': teacherId,
      'totalAmount': totalAmount,
      'status': status,
      'payoutDate': Timestamp.fromDate(payoutDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'transactionIds': transactionIds,
    };
  }

  // إنشاء من Firestore
  factory PayoutSchedule.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PayoutSchedule(
      id: doc.id,
      teacherId: data['teacherId'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      payoutDate: (data['payoutDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      transactionIds: List<String>.from(data['transactionIds'] ?? []),
    );
  }

  // التحقق من الحالة
  bool get isPending => status == 'pending';
  bool get isProcessed => status == 'processed';
  bool get isPaid => status == 'paid';

  // تنسيق المبلغ
  String get formattedAmount {
    return '${totalAmount.toStringAsFixed(2)} ر.س';
  }

  // تنسيق التاريخ
  String get formattedPayoutDate {
    return '${payoutDate.day}/${payoutDate.month}/${payoutDate.year}';
  }

  @override
  String toString() {
    return 'PayoutSchedule(id: $id, teacherId: $teacherId, amount: $formattedAmount, status: $status)';
  }
}

class WalletBalance {
  final String userId;
  final double availableBalance;
  final double pendingBalance;
  final double totalEarnings;
  final DateTime lastUpdated;

  WalletBalance({
    required this.userId,
    required this.availableBalance,
    required this.pendingBalance,
    required this.totalEarnings,
    required this.lastUpdated,
  });

  // تحويل إلى Map لـ Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'availableBalance': availableBalance,
      'pendingBalance': pendingBalance,
      'totalEarnings': totalEarnings,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  // إنشاء من Firestore
  factory WalletBalance.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return WalletBalance(
      userId: doc.id,
      availableBalance: (data['availableBalance'] ?? 0).toDouble(),
      pendingBalance: (data['pendingBalance'] ?? 0).toDouble(),
      totalEarnings: (data['totalEarnings'] ?? 0).toDouble(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  // إنشاء جديد
  factory WalletBalance.createNew(String userId) {
    return WalletBalance(
      userId: userId,
      availableBalance: 0.0,
      pendingBalance: 0.0,
      totalEarnings: 0.0,
      lastUpdated: DateTime.now(),
    );
  }

  // نسخ مع تحديث بعض القيم
  WalletBalance copyWith({
    String? userId,
    double? availableBalance,
    double? pendingBalance,
    double? totalEarnings,
    DateTime? lastUpdated,
  }) {
    return WalletBalance(
      userId: userId ?? this.userId,
      availableBalance: availableBalance ?? this.availableBalance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // تنسيق الأرصدة
  String get formattedAvailableBalance {
    return '${availableBalance.toStringAsFixed(2)} ر.س';
  }

  String get formattedPendingBalance {
    return '${pendingBalance.toStringAsFixed(2)} ر.س';
  }

  String get formattedTotalEarnings {
    return '${totalEarnings.toStringAsFixed(2)} ر.س';
  }

  // إضافة رصيد
  WalletBalance addEarning(double amount) {
    return copyWith(
      availableBalance: availableBalance + amount,
      totalEarnings: totalEarnings + amount,
      lastUpdated: DateTime.now(),
    );
  }

  // إضافة رصيد معلق
  WalletBalance addPending(double amount) {
    return copyWith(
      pendingBalance: pendingBalance + amount,
      lastUpdated: DateTime.now(),
    );
  }

  // تحويل من معلق إلى متاح
  WalletBalance releasePending(double amount) {
    return copyWith(
      pendingBalance: pendingBalance - amount,
      availableBalance: availableBalance + amount,
      lastUpdated: DateTime.now(),
    );
  }

  // السحب
  WalletBalance withdraw(double amount) {
    return copyWith(
      availableBalance: availableBalance - amount,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'WalletBalance(userId: $userId, available: $formattedAvailableBalance, pending: $formattedPendingBalance, total: $formattedTotalEarnings)';
  }
}

// ⭐ نموذج لإحصائيات الدفع
class PaymentStats {
  final int totalTransactions;
  final double totalRevenue;
  final double totalCommission;
  final int successfulTransactions;
  final int failedTransactions;
  final Map<String, int> paymentMethodStats;

  PaymentStats({
    required this.totalTransactions,
    required this.totalRevenue,
    required this.totalCommission,
    required this.successfulTransactions,
    required this.failedTransactions,
    required this.paymentMethodStats,
  });

  // حساب نسبة النجاح
  double get successRate {
    return totalTransactions > 0
        ? (successfulTransactions / totalTransactions) * 100
        : 0;
  }

  // تنسيق الإحصائيات
  String get formattedTotalRevenue {
    return '${totalRevenue.toStringAsFixed(2)} ر.س';
  }

  String get formattedTotalCommission {
    return '${totalCommission.toStringAsFixed(2)} ر.س';
  }

  String get formattedSuccessRate {
    return '${successRate.toStringAsFixed(1)}%';
  }

  @override
  String toString() {
    return 'PaymentStats(transactions: $totalTransactions, revenue: $formattedTotalRevenue, successRate: $formattedSuccessRate)';
  }
}

// ⭐ نموذج لإعدادات الدفع
class PaymentSettings {
  final double studentCommissionRate;
  final double teacherCommissionRate;
  final double minimumPayoutAmount;
  final int payoutScheduleDays;
  final List<String> supportedCurrencies;
  final Map<String, List<String>> supportedPaymentMethods;

  PaymentSettings({
    this.studentCommissionRate = 0.05, // 5%
    this.teacherCommissionRate = 0.05, // 5%
    this.minimumPayoutAmount = 100.0,
    this.payoutScheduleDays = 7,
    this.supportedCurrencies = const ['SAR', 'EGP', 'USD'],
    this.supportedPaymentMethods = const {
      'SA': ['mada', 'stc_pay', 'apple_pay', 'credit_card'],
      'EG': ['fawry', 'vodafone_cash', 'orange_cash', 'credit_card'],
    },
  });

  // تحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      'studentCommissionRate': studentCommissionRate,
      'teacherCommissionRate': teacherCommissionRate,
      'minimumPayoutAmount': minimumPayoutAmount,
      'payoutScheduleDays': payoutScheduleDays,
      'supportedCurrencies': supportedCurrencies,
      'supportedPaymentMethods': supportedPaymentMethods,
    };
  }

  // إنشاء من Map
  factory PaymentSettings.fromMap(Map<String, dynamic> map) {
    return PaymentSettings(
      studentCommissionRate: (map['studentCommissionRate'] ?? 0.05).toDouble(),
      teacherCommissionRate: (map['teacherCommissionRate'] ?? 0.05).toDouble(),
      minimumPayoutAmount: (map['minimumPayoutAmount'] ?? 100.0).toDouble(),
      payoutScheduleDays: map['payoutScheduleDays'] ?? 7,
      supportedCurrencies: List<String>.from(map['supportedCurrencies'] ?? []),
      supportedPaymentMethods:
          Map<String, List<String>>.from(map['supportedPaymentMethods'] ?? {}),
    );
  }

  // حساب العمولة
  Map<String, double> calculateCommission(double amount) {
    final studentCommission = amount * studentCommissionRate;
    final teacherCommission = amount * teacherCommissionRate;
    final netAmount = amount - teacherCommission;
    final totalCommission = studentCommission + teacherCommission;

    return {
      'studentCommission': studentCommission,
      'teacherCommission': teacherCommission,
      'netAmount': netAmount,
      'totalCommission': totalCommission,
    };
  }

  @override
  String toString() {
    return 'PaymentSettings(studentCommission: ${(studentCommissionRate * 100)}%, teacherCommission: ${(teacherCommissionRate * 100)}%, minimumPayout: $minimumPayoutAmount)';
  }
}
