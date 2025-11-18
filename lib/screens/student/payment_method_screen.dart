import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/firebase_auth_provider.dart';
import '../../models/course_model.dart';

class PaymentMethodScreen extends StatefulWidget {
  final Course course;
  final String teacherId;
  final String teacherName;
  final Map<String, dynamic>? bookingData;

  const PaymentMethodScreen({
    Key? key,
    required this.course,
    required this.teacherId,
    required this.teacherName,
    this.bookingData,
  }) : super(key: key);

  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String? _selectedPaymentMethod;
  bool _isProcessing = false;

  final Map<String, List<PaymentOption>> _paymentOptions = {
    'SA': [
      PaymentOption(
        id: 'mada',
        name: 'مدى',
        icon: Icons.credit_card,
        color: Colors.green,
        description: 'الدفع عبر بطاقة مدى',
      ),
      PaymentOption(
        id: 'stc_pay',
        name: 'STC Pay',
        icon: Icons.phone_android,
        color: Color(0xFF6A1B9A),
        description: 'الدفع عبر STC Pay',
      ),
      PaymentOption(
        id: 'apple_pay',
        name: 'Apple Pay',
        icon: Icons.apple,
        color: Colors.black,
        description: 'الدفع عبر Apple Pay',
      ),
      PaymentOption(
        id: 'credit_card',
        name: 'بطاقة ائتمان',
        icon: Icons.credit_score,
        color: Colors.blue,
        description: 'Visa / Mastercard',
      ),
    ],
    'EG': [
      PaymentOption(
        id: 'fawry',
        name: 'فوري',
        icon: Icons.receipt,
        color: Colors.orange,
        description: 'الدفع عبر فوري',
      ),
      PaymentOption(
        id: 'vodafone_cash',
        name: 'فودافون كاش',
        icon: Icons.phone_iphone,
        color: Color(0xFFE60000),
        description: 'الدفع عبر فودافون كاش',
      ),
      PaymentOption(
        id: 'orange_cash',
        name: 'اورنج كاش',
        icon: Icons.phone_android,
        color: Color(0xFFFF6600),
        description: 'الدفع عبر اورنج كاش',
      ),
      PaymentOption(
        id: 'credit_card',
        name: 'بطاقة ائتمان',
        icon: Icons.credit_score,
        color: Colors.blue,
        description: 'Visa / Mastercard',
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final authProvider = Provider.of<FirebaseAuthProvider>(context);

    final commission = paymentProvider.calculateCommission(widget.course.price);
    final totalAmount = widget.course.price + commission['studentCommission']!;
    final currencySymbol = widget.course.getCurrencySymbol();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookingData != null
            ? 'دفع وتأكيد الحجز'
            : 'اختر طريقة الدفع'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransactionType(),
            SizedBox(height: 20),
            _buildCourseInfo(currencySymbol),
            SizedBox(height: 20),
            _buildPriceDetails(commission, totalAmount, currencySymbol),
            SizedBox(height: 20),
            _buildPaymentMethods(),
            SizedBox(height: 20),
            _buildConfirmButton(paymentProvider, bookingProvider, authProvider,
                totalAmount, currencySymbol),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionType() {
    final isBooking = widget.bookingData != null;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBooking ? Colors.orange[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isBooking ? Colors.orange : Colors.blue,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isBooking ? Icons.calendar_today : Icons.school,
            color: isBooking ? Colors.orange : Colors.blue,
          ),
          SizedBox(width: 8),
          Text(
            isBooking ? 'حجز جلسة تعليمية' : 'شراء كورس',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isBooking ? Colors.orange[800] : Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseInfo(String currencySymbol) {
    final isBooking = widget.bookingData != null;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBooking
                  ? 'جلسة ${widget.course.subject} - ${widget.bookingData?['sessionType'] ?? 'فردي'}'
                  : widget.course.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'المعلم: ${widget.teacherName}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              'المادة: ${widget.course.subject}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            if (isBooking) ...[
              Text(
                'المدة: ${widget.bookingData?['duration'] ?? 60} دقيقة',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                'التاريخ: ${_formatBookingDateTime()}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            Text(
              'السعر: ${widget.course.price} $currencySymbol',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBookingDateTime() {
    if (widget.bookingData == null) return '';

    final dateTime = widget.bookingData!['dateTime'];
    if (dateTime is DateTime) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return '';
  }

  Widget _buildPriceDetails(Map<String, double> commission, double totalAmount,
      String currencySymbol) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPriceRow(
                'السعر الأساسي', '${widget.course.price} $currencySymbol'),
            _buildPriceRow('عمولة المنصة (5%)',
                '${commission['studentCommission']} $currencySymbol'),
            Divider(),
            _buildPriceRow(
              'المبلغ الإجمالي',
              '$totalAmount $currencySymbol',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isTotal ? Colors.blue.shade800 : Colors.grey.shade700,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isTotal ? Colors.blue.shade800 : Colors.grey.shade700,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final country = widget.course.currency == 'SAR' ? 'SA' : 'EG';
    final options = _paymentOptions[country] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر طريقة الدفع:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 12),
        ...options.map((option) => _buildPaymentOption(option)),
      ],
    );
  }

  Widget _buildPaymentOption(PaymentOption option) {
    final isSelected = _selectedPaymentMethod == option.id;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? option.color.withOpacity(0.1) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? option.color : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(option.icon, color: option.color),
        title: Text(
          option.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: option.color,
          ),
        ),
        subtitle: Text(option.description),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: option.color)
            : Icon(Icons.radio_button_unchecked, color: Colors.grey),
        onTap: () {
          setState(() {
            _selectedPaymentMethod = option.id;
          });
        },
      ),
    );
  }

  Widget _buildConfirmButton(
      PaymentProvider paymentProvider,
      BookingProvider bookingProvider,
      FirebaseAuthProvider authProvider,
      double totalAmount,
      String currencySymbol) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedPaymentMethod == null || _isProcessing
            ? null
            : () => _processPayment(
                paymentProvider, bookingProvider, authProvider, totalAmount),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isProcessing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('جاري المعالجة...'),
                ],
              )
            : Text(
                'دفع $totalAmount $currencySymbol',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _processPayment(
      PaymentProvider paymentProvider,
      BookingProvider bookingProvider,
      FirebaseAuthProvider authProvider,
      double totalAmount) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await Future.delayed(Duration(seconds: 2));

      // ⭐ 1. إنشاء معاملة الدفع
      await paymentProvider.createPaymentTransaction(
        studentId: authProvider.currentUser?.uid ?? 'unknown',
        teacherId: widget.teacherId,
        courseId: widget.course.id,
        amount: widget.course.price,
        paymentMethod: _selectedPaymentMethod!,
        currency: widget.course.currency,
        country: widget.course.currency == 'SAR' ? 'SA' : 'EG',
      );

      // ⭐ 2. إذا كان حجزاً، إنشاء الحجز بعد الدفع الناجح
      if (widget.bookingData != null) {
        print('🎯 بدء إنشاء الحجز بعد الدفع الناجح');

        final bookingSuccess =
            await bookingProvider.createBookingAfterPayment();

        if (bookingSuccess) {
          print('✅ تم إنشاء الحجز بنجاح، جاري تحميل الحجوزات المحدثة...');

          // ⭐ جديد: إعادة تحميل حجوزات الطالب بعد إنشاء الحجز
          final studentId = authProvider.currentUser?.uid;
          if (studentId != null) {
            bookingProvider.loadStudentBookings(studentId);
            print('🔄 تم طلب تحديث قائمة الحجوزات للطالب: $studentId');
          }

          _showSuccessDialog(true);
        } else {
          throw Exception('فشل في إنشاء الحجز بعد الدفع');
        }
      } else {
        _showSuccessDialog(false);
      }
    } catch (error) {
      print('❌ خطأ في عملية الدفع: $error');
      _showErrorDialog(error.toString());
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog(bool isBooking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text(isBooking ? 'تم الدفع والحجز بنجاح' : 'تم الدفع بنجاح'),
          ],
        ),
        content: Text(
          isBooking
              ? 'تم حجز الجلسة بنجاح. يمكنك الآن عرض الحجز في قائمة حجوزاتك.'
              : 'تم شراء الكورس بنجاح. يمكنك الآن البدء في التعلم.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              if (isBooking) {
                // ⭐ جديد: العودة مباشرة إلى شاشة الحجوزات
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/student-bookings',
                  (route) => false,
                );
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text('عرض الحجوزات'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('خطأ في الدفع'),
          ],
        ),
        content: Text('حدث خطأ أثناء عملية الدفع: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('حاول مرة أخرى'),
          ),
        ],
      ),
    );
  }
}

class PaymentOption {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  PaymentOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}
