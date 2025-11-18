// 📁 lib/screens/student/student_bookings_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/firebase_auth_provider.dart';
import '../../models/booking_model.dart';

class StudentBookingsListScreen extends StatefulWidget {
  const StudentBookingsListScreen({Key? key}) : super(key: key);

  @override
  _StudentBookingsListScreenState createState() =>
      _StudentBookingsListScreenState();
}

class _StudentBookingsListScreenState extends State<StudentBookingsListScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<FirebaseAuthProvider>(context);

    if (!authProvider.isLoggedIn) {
      return _buildNotLoggedIn();
    }

    final studentId = authProvider.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('حجوزاتي'),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
      ),
      body: StreamBuilder<List<Booking>>(
        stream: context.read<BookingProvider>().loadStudentBookings(studentId),
        builder: (context, snapshot) {
          print('📊 حالة الـ Stream: ${snapshot.connectionState}');
          print('📊 يوجد بيانات: ${snapshot.hasData}');
          print('📊 يوجد خطأ: ${snapshot.hasError}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('❌ خطأ في الـ Stream: ${snapshot.error}');
            return _buildErrorWidget(snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('📭 لا توجد حجوزات: ${snapshot.data?.length ?? 0}');
            return _buildEmptyState();
          }

          final bookings = snapshot.data!;
          print('✅ عدد الحجوزات المستلمة: ${bookings.length}');

          return _buildBookingsList(bookings);
        },
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings) {
    final sortedBookings = List.of(bookings)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return Column(
      children: [
        _buildStatsCard(bookings),
        SizedBox(height: 16),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              // إعادة تحميل البيانات
              setState(() {});
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: sortedBookings.length,
              itemBuilder: (context, index) {
                final booking = sortedBookings[index];
                return _buildBookingCard(booking);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.teacherName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        booking.subject,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(booking.status),
              ],
            ),
            SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today,
                '${booking.dateTime.day}/${booking.dateTime.month}/${booking.dateTime.year}'),
            _buildInfoRow(Icons.access_time,
                '${_formatTime(booking.dateTime)} - ${booking.duration} دقيقة'),
            _buildInfoRow(Icons.category, booking.sessionType),
            _buildInfoRow(
                Icons.attach_money, '${booking.price.toStringAsFixed(2)} ر.س'),
            SizedBox(height: 12),
            if (booking.isPending || booking.isConfirmed)
              _buildActionButtons(booking),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Booking booking) {
    final bookingProvider = context.read<BookingProvider>();

    return Row(
      children: [
        if (booking.isPending) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _cancelBooking(booking.id, bookingProvider),
              icon: Icon(Icons.cancel, size: 18),
              label: Text('إلغاء الحجز'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
        if (booking.isConfirmed &&
            booking.dateTime.isAfter(DateTime.now())) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _joinSession(booking),
              icon: Icon(Icons.video_call, size: 18),
              label: Text('انضم للجلسة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _cancelBooking(String bookingId, BookingProvider bookingProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الإلغاء'),
        content: Text('هل أنت متأكد من إلغاء هذا الحجز؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('نعم، ألغ الحجز'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await bookingProvider.cancelBooking(bookingId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ تم إلغاء الحجز بنجاح')),
        );
      }
    }
  }

  void _joinSession(Booking booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('🎥 جاري الانضمام لجلسة ${booking.subject}')),
    );
  }

  // باقي الدوال تبقى كما هي بدون تغيير
  Widget _buildStatsCard(List<Booking> bookings) {
    final upcoming = bookings
        .where((b) => b.dateTime.isAfter(DateTime.now()) && !b.isCancelled)
        .length;
    final pending = bookings.where((b) => b.isPending).length;
    final total = bookings.length;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('إجمالي الحجوزات', total, Icons.bookmark),
          _buildStatItem('قادمة', upcoming, Icons.upcoming),
          _buildStatItem('بانتظار التأكيد', pending, Icons.schedule),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'لا توجد حجوزات',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'احجز جلستك الأولى مع معلمك المفضل',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.add),
            label: Text('احجز جلسة جديدة'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Scaffold(
      appBar: AppBar(title: Text('حجوزاتي')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('يجب تسجيل الدخول لعرض الحجوزات'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('تسجيل الدخول'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    final statusInfo = _getStatusInfo(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo['color'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusInfo['text'],
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return {'text': 'بانتظار التأكيد', 'color': Colors.orange};
      case BookingStatus.confirmed:
        return {'text': 'مؤكد', 'color': Colors.green};
      case BookingStatus.completed:
        return {'text': 'منتهي', 'color': Colors.blue};
      case BookingStatus.cancelled:
        return {'text': 'ملغي', 'color': Colors.red};
      default:
        return {'text': 'غير معروف', 'color': Colors.grey};
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
