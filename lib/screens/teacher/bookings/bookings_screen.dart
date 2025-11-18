// 📁 lib/screens/teacher/bookings/bookings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../models/booking_model.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة الحجوزات'),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
        actions: [
          // 🔄 زر تحديث
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<BookingProvider>().fetchBookings();
            },
          ),
        ],
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (bookingProvider.error.isNotEmpty) {
            return _buildErrorWidget(bookingProvider);
          }

          if (bookingProvider.bookings.isEmpty) {
            return _buildEmptyState(bookingProvider);
          }

          return _buildBookingsContent(bookingProvider, context);
        },
      ),
    );
  }

  // 📊 محتوى الشاشة الرئيسي
  Widget _buildBookingsContent(BookingProvider provider, BuildContext context) {
    // 🔍 فلترة حجوزات المعلم الحالي فقط
    final teacherBookings =
        provider.getBookingsByTeacher('teacher_1'); // ⭐ سيتم استبدالها بـ Auth

    return Column(
      children: [
        // 🔹 إحصائيات سريعة
        _buildStatsCard(teacherBookings),

        // 🔹 فلتر الحالات
        _buildStatusFilter(provider),

        // 🔹 قائمة الحجوزات
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.fetchBookings(),
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: teacherBookings.length,
              itemBuilder: (context, index) {
                final booking = teacherBookings[index];
                return _buildBookingCard(booking, provider, context);
              },
            ),
          ),
        ),
      ],
    );
  }

  // 🎴 بطاقة الإحصائيات المحسنة
  Widget _buildStatsCard(List<Booking> bookings) {
    final pending = bookings.where((b) => b.isPending).length;
    final confirmed = bookings.where((b) => b.isConfirmed).length;
    final upcoming = bookings
        .where((b) => b.dateTime.isAfter(DateTime.now()) && !b.isCancelled)
        .length;
    final total = bookings.length;

    return Container(
      margin: EdgeInsets.all(12),
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
          _buildStatItem('في الانتظار', pending, Icons.pending, Colors.orange),
          _buildStatItem('مؤكدة', confirmed, Icons.check_circle, Colors.green),
          _buildStatItem('قادمة', upcoming, Icons.upcoming, Colors.blue),
          _buildStatItem('الإجمالي', total, Icons.bookmark, Colors.white),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, int count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  // 🔘 فلتر الحالات
  Widget _buildStatusFilter(BookingProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('الكل', null, provider),
            _buildFilterChip('في الانتظار', BookingStatus.pending, provider),
            _buildFilterChip('مؤكدة', BookingStatus.confirmed, provider),
            _buildFilterChip('قادمة', null, provider), // سيتم تطبيق الفلتر
            _buildFilterChip('منتهية', BookingStatus.completed, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label, BookingStatus? status, BookingProvider provider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: false, // ⭐ سيتم تطبيق منطق الفلتر لاحقاً
        onSelected: (selected) {
          // ⭐ سيتم تطبيق الفلتر لاحقاً
        },
      ),
    );
  }

  // 💳 بطاقة الحجز المحسنة
  Widget _buildBookingCard(
      Booking booking, BookingProvider provider, BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏷️ رأس البطاقة
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
                // 🏷️ شارة الحالة
                _buildStatusBadge(booking.status),
              ],
            ),

            SizedBox(height: 12),

            // 📅 معلومات الحجز
            _buildInfoRow(Icons.person,
                'الطالب: ${booking.studentName}'), // ⭐ تم التعديل لاستخدام studentName
            _buildInfoRow(Icons.calendar_today,
                '${booking.dateTime.day}/${booking.dateTime.month}/${booking.dateTime.year}'), // ⭐ تم التعديل
            _buildInfoRow(Icons.access_time,
                '${_formatTime(booking.dateTime)} - ${booking.duration} دقيقة'), // ⭐ تم التعديل
            _buildInfoRow(
                Icons.attach_money, '${booking.price.toStringAsFixed(2)} ر.س'),
            _buildInfoRow(Icons.category, booking.sessionType),

            SizedBox(height: 12),

            // 🔘 أزرار الإجراءات
            if (booking.isPending)
              _buildActionButtons(booking, provider, context),
          ],
        ),
      ),
    );
  }

  // ℹ️ سطر معلومات
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
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

  // 🏷️ شارة حالة الحجز
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

  // 🔘 أزرار الإجراءات المحسنة
  Widget _buildActionButtons(
      Booking booking, BookingProvider provider, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _confirmBooking(booking.id, provider, context),
            icon: Icon(Icons.check, size: 18),
            label: Text('قبول الحجز'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _rejectBooking(booking.id, provider, context),
            icon: Icon(Icons.close, size: 18),
            label: Text('رفض الحجز'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ✅ تأكيد الحجز مع dialog
  void _confirmBooking(
      String bookingId, BookingProvider provider, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحجز'),
        content: Text('هل تريد تأكيد هذا الحجز؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('نعم، تأكيد'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.confirmBooking(bookingId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ تم تأكيد الحجز بنجاح')),
        );
      }
    }
  }

  // ❌ رفض الحجز مع dialog
  void _rejectBooking(
      String bookingId, BookingProvider provider, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('رفض الحجز'),
        content: Text('هل تريد رفض هذا الحجز؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('نعم، رفض'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.cancelBooking(bookingId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ تم رفض الحجز')),
        );
      }
    }
  }

  // ⚠️ عرض الأخطاء
  Widget _buildErrorWidget(BookingProvider provider) {
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
            provider.error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.fetchBookings(),
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  // 📭 حالة عدم وجود حجوزات
  Widget _buildEmptyState(BookingProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'لا توجد حجوزات',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'سيظهر هنا حجوزات الطلاب لك',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => provider.fetchBookings(),
            icon: Icon(Icons.refresh),
            label: Text('تحديث الحجوزات'),
          ),
        ],
      ),
    );
  }

  // 🎯 معلومات الحالة
  Map<String, dynamic> _getStatusInfo(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return {'text': 'في الانتظار', 'color': Colors.orange};
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

  // ⏰ دالة مساعدة لتنسيق الوقت
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
