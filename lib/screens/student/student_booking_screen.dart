import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/firebase_auth_provider.dart';
import '../../models/booking_model.dart';

class StudentBookingScreen extends StatefulWidget {
  const StudentBookingScreen({Key? key}) : super(key: key);

  @override
  _StudentBookingScreenState createState() => _StudentBookingScreenState();
}

class _StudentBookingScreenState extends State<StudentBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedTeacher = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _sessionType = 'فردي';
  int _duration = 60;
  String _notes = '';

  final List<Map<String, dynamic>> _teachers = [
    {
      'id': '1',
      'name': 'أستاذ أحمد محمد',
      'subject': 'الرياضيات',
      'price': 100
    },
    {
      'id': '2',
      'name': 'أستاذة سارة عبدالله',
      'subject': 'الفيزياء',
      'price': 120
    },
    {'id': '3', 'name': 'أستاذ محمد علي', 'subject': 'الكيمياء', 'price': 90},
    {
      'id': '4',
      'name': 'أستاذة فاطمة حسن',
      'subject': 'اللغة العربية',
      'price': 80
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final authProvider = Provider.of<FirebaseAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('حجز جلسة تعليمية'),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              SizedBox(height: 20),
              _buildTeacherSelection(),
              SizedBox(height: 20),
              _buildDateTimeSelection(),
              SizedBox(height: 20),
              _buildSessionDetails(),
              SizedBox(height: 20),
              _buildNotesField(),
              SizedBox(height: 30),
              _buildBookingSummary(),
              SizedBox(height: 30),
              _buildPaymentButton(bookingProvider, authProvider),

              // 🔥 عرض حالة التحميل أو الخطأ
              if (bookingProvider.error != null)
                _buildErrorWidget(bookingProvider),
            ],
          ),
        ),
      ),
    );
  }

  // 🎯 بطاقة الترحيب
  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.school, size: 40, color: Colors.white),
          SizedBox(height: 8),
          Text(
            'احجز جلسة تعليمية',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'اختر المعلم والوقت المناسب لك',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 👨‍🏫 اختيار المعلم
  Widget _buildTeacherSelection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اختر المعلم',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 12),
            ..._teachers.map((teacher) => _buildTeacherCard(teacher)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
    bool isSelected = _selectedTeacher == teacher['id'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTeacher = teacher['id'];
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                teacher['name'][0],
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teacher['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.blue[800] : Colors.black,
                    ),
                  ),
                  Text(
                    teacher['subject'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${teacher['price']} ر.س/ساعة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📅 اختيار التاريخ والوقت
  Widget _buildDateTimeSelection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الوقت والتاريخ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التاريخ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _selectDate(context),
                        icon: Icon(Icons.calendar_today),
                        label: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[50],
                          foregroundColor: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الوقت',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _selectTime(context),
                        icon: Icon(Icons.access_time),
                        label: Text(
                          _selectedTime.format(context),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[50],
                          foregroundColor: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ⏰ نوع الجلسة والمدة
  Widget _buildSessionDetails() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل الجلسة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 16),

            // نوع الجلسة
            Text(
              'نوع الجلسة',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _sessionType,
              items: ['فردي', 'جماعي', 'استشارة']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _sessionType = value!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            SizedBox(height: 16),

            // مدة الجلسة
            Text(
              'مدة الجلسة (دقائق)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _duration,
              items: [30, 45, 60, 90, 120]
                  .map((duration) => DropdownMenuItem(
                        value: duration,
                        child: Text('$duration دقيقة'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _duration = value!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📝 ملاحظات إضافية
  Widget _buildNotesField() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملاحظات إضافية (اختياري)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'أي ملاحظات تريد إضافتها للمعلم...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _notes = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // 💰 ملخص الحجز
  Widget _buildBookingSummary() {
    if (_selectedTeacher.isEmpty) return SizedBox();

    var selectedTeacher = _teachers.firstWhere(
      (teacher) => teacher['id'] == _selectedTeacher,
    );

    double pricePerHour = selectedTeacher['price'].toDouble();
    double totalPrice = (pricePerHour * _duration) / 60;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص الحجز',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 12),
            _buildSummaryItem('المعلم', selectedTeacher['name']),
            _buildSummaryItem('المادة', selectedTeacher['subject']),
            _buildSummaryItem('نوع الجلسة', _sessionType),
            _buildSummaryItem('المدة', '$_duration دقيقة'),
            _buildSummaryItem('التاريخ',
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
            _buildSummaryItem('الوقت', _selectedTime.format(context)),
            Divider(),
            _buildSummaryItem(
              'السعر الإجمالي',
              '${totalPrice.toStringAsFixed(2)} ر.س',
              isBold: true,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // 💳 زر الدفع - الإصدار المعدل (تم تغيير اللون)
  Widget _buildPaymentButton(
      BookingProvider bookingProvider, FirebaseAuthProvider authProvider) {
    if (_selectedTeacher.isEmpty) return SizedBox();

    var selectedTeacher = _teachers.firstWhere(
      (teacher) => teacher['id'] == _selectedTeacher,
    );

    double pricePerHour = selectedTeacher['price'].toDouble();
    double totalPrice = (pricePerHour * _duration) / 60;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _navigateToPayment(
            context, selectedTeacher, totalPrice, authProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Color(0xFF1976D2), // ⭐ تغيير من أرجواني إلى أزرق داكن
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 24),
            SizedBox(width: 8),
            Text(
              'الدفع والاستمرار - ${totalPrice.toStringAsFixed(2)} ر.س',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ❌ عرض الأخطاء
  Widget _buildErrorWidget(BookingProvider bookingProvider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              bookingProvider.error!,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // 📅 اختيار التاريخ
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // ⏰ اختيار الوقت
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // 💫 الانتقال لشاشة الدفع
  void _navigateToPayment(BuildContext context, Map<String, dynamic> teacher,
      double totalPrice, FirebaseAuthProvider authProvider) {
    if (_selectedTeacher.isEmpty) {
      _showSnackBar('يرجى اختيار معلم', Colors.orange);
      return;
    }

    // ⏰ دمج التاريخ والوقت في DateTime واحد
    final bookingDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // إنشاء نموذج حجز مؤقت
    final tempBooking = {
      'teacher': teacher,
      'dateTime': bookingDateTime,
      'duration': _duration,
      'sessionType': _sessionType,
      'notes': _notes,
      'totalPrice': totalPrice,
      'studentId': authProvider.currentUser?.uid ?? 'unknown',
      'studentName': authProvider.userName ?? 'طالب',
    };

    // حفظ الحجز المؤقت
    Provider.of<BookingProvider>(context, listen: false)
        .setTempBooking(tempBooking);

    // الانتقال لشاشة الدفع
    Navigator.pushNamed(
      context,
      '/payment-method',
      arguments: {
        'course': _createBookingCourse(teacher, totalPrice),
        'teacherId': teacher['id'],
        'teacherName': teacher['name'],
        'bookingData': tempBooking,
      },
    );
  }

  // إنشاء كورس وهمي للحجز
  Map<String, dynamic> _createBookingCourse(
      Map<String, dynamic> teacher, double totalPrice) {
    return {
      'id': 'booking-${DateTime.now().millisecondsSinceEpoch}',
      'title': 'جلسة ${teacher['subject']} - $_sessionType',
      'description': 'جلسة تعليمية مع ${teacher['name']} لمدة $_duration دقيقة',
      'instructor': teacher['name'],
      'teacherId': teacher['id'],
      'subject': teacher['subject'],
      'price': totalPrice,
      'currency': 'SAR',
      'level': 'جميع المستويات',
      'rating': 0,
      'reviewCount': 0,
      'enrolledStudents': 0,
      'progress': 0,
      'imageUrl': '',
      'isPublished': true,
      'isActive': true,
      'createdAt': DateTime.now(),
      'chapters': [],
      'totalLessons': 1,
      'completedLessons': 0,
      'duration': '$_duration دقيقة',
      'category': 'جلسات تعليمية',
    };
  }

  // 💫 عرض رسائل المستخدم
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
