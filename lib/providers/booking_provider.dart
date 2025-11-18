import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../services/booking_reminder_service.dart';

class BookingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Booking> _bookings = [];
  List<Booking> _studentBookings = [];
  List<Booking> _teacherBookings = [];
  bool _isLoading = false;
  String _error = '';

  // ⭐ جديد: نظام الحجز المؤقت للدفع
  Map<String, dynamic>? _tempBooking;

  List<Booking> get bookings => _bookings;
  List<Booking> get studentBookings => _studentBookings;
  List<Booking> get teacherBookings => _teacherBookings;
  bool get isLoading => _isLoading;
  String get error => _error;
  Map<String, dynamic>? get tempBooking => _tempBooking;

  // ✅ جلب جميع الحجوزات (للمشرفين)
  void loadAllBookings() {
    _firestore
        .collection('bookings')
        .orderBy('dateTime', descending: false)
        .snapshots()
        .listen((snapshot) {
      _bookings =
          snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  // ✅ جلب حجوزات طالب معين - **الكود النهائي مع الفهرس الجديد**
  Stream<List<Booking>> loadStudentBookings(String studentId) {
    print('🔄 جلب حجوزات الطالب من Firebase: $studentId');

    return _firestore
        .collection('bookings')
        .where('studentId', isEqualTo: studentId)
        .orderBy('dateTime', descending: true) // ✅ الفهرس الجديد مفعل الآن!
        .snapshots()
        .map((snapshot) {
      print('📥 تم استلام ${snapshot.docs.length} حجز من Firebase');

      final bookings =
          snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();

      print('✅ تم تحميل ${bookings.length} حجز للطالب $studentId');
      return bookings;
    }).handleError((error) {
      print('❌ خطأ في جلب حجوزات الطالب: $error');
      _setError('فشل في جلب الحجوزات: $error');
      return [];
    });
  }

  // ✅ **طريقة بديلة: جلب حجوزات الطالب كـ Future**
  Future<List<Booking>> fetchStudentBookings(String studentId) async {
    try {
      _setLoading(true);
      _setError('');

      print('🔄 جلب حجوزات الطالب (Future): $studentId');

      final snapshot = await _firestore
          .collection('bookings')
          .where('studentId', isEqualTo: studentId)
          .orderBy('dateTime', descending: true) // ✅ الفهرس الجديد مفعل
          .get();

      _studentBookings =
          snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();

      print('✅ تم تحميل ${_studentBookings.length} حجز للطالب $studentId');
      _setLoading(false);

      return _studentBookings;
    } catch (e) {
      _setLoading(false);
      print('❌ خطأ في جلب حجوزات الطالب: $e');
      _setError('فشل في جلب الحجوزات: $e');
      return [];
    }
  }

  // ✅ **طريقة ثالثة: تحديث القائمة مباشرة**
  void updateStudentBookings(String studentId) {
    print('🔄 تحديث حجوزات الطالب: $studentId');

    _firestore
        .collection('bookings')
        .where('studentId', isEqualTo: studentId)
        .orderBy('dateTime', descending: true) // ✅ الفهرس الجديد مفعل
        .snapshots()
        .listen((snapshot) {
      _studentBookings =
          snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();

      print('✅ تم تحديث ${_studentBookings.length} حجز للطالب $studentId');
      notifyListeners();
    }, onError: (error) {
      print('❌ خطأ في تحديث حجوزات الطالب: $error');
      _setError('فشل في تحديث الحجوزات: $error');
    });
  }

  // ✅ جلب حجوزات معلم معين
  Stream<List<Booking>> loadTeacherBookings(String teacherId) {
    return _firestore
        .collection('bookings')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
      final bookings =
          snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
      return bookings;
    });
  }

  // ✅ جلب الحجوزات القادمة
  List<Booking> getUpcomingBookings() {
    final now = DateTime.now();
    return _bookings
        .where(
            (booking) => booking.dateTime.isAfter(now) && !booking.isCancelled)
        .toList();
  }

  // ✅ جلب الحجوزات المعلقة
  List<Booking> getPendingBookings() {
    return _bookings.where((booking) => booking.isPending).toList();
  }

  // ⭐ جديد: حفظ الحجز المؤقت قبل الدفع
  void setTempBooking(Map<String, dynamic> bookingData) {
    _tempBooking = bookingData;
    notifyListeners();
    print('💾 تم حفظ الحجز المؤقت: ${bookingData['teacher']?['name']}');
  }

  // ⭐ جديد: مسح الحجز المؤقت
  void clearTempBooking() {
    _tempBooking = null;
    notifyListeners();
    print('🧹 تم مسح الحجز المؤقت');
  }

  // ⭐ جديد: إنشاء الحجز بعد الدفع الناجح
  Future<bool> createBookingAfterPayment() async {
    if (_tempBooking == null) {
      _setError('لا يوجد حجز مؤقت لإنشائه');
      return false;
    }

    try {
      _setLoading(true);
      _setError('');

      final temp = _tempBooking!;
      final teacher = temp['teacher'] as Map<String, dynamic>;

      print('🎯 بدء إنشاء الحجز بعد الدفع...');
      print(
          '📋 بيانات الحجز: ${temp['teacher']?['name']} - ${temp['totalPrice']}');

      // إنشاء كائن الحجز
      final newBooking = Booking.createNew(
        studentId: temp['studentId'] ?? 'unknown',
        studentName: temp['studentName'] ?? 'طالب',
        teacherId: teacher['id'] ?? '',
        teacherName: teacher['name'] ?? '',
        subject: teacher['subject'] ?? '',
        dateTime: temp['dateTime'] ?? DateTime.now(),
        duration: temp['duration'] ?? 60,
        price: temp['totalPrice'] ?? 0.0,
        sessionType: temp['sessionType'] ?? 'فردي',
        notes: temp['notes'],
      );

      // التحقق من توفر الموعد
      final isAvailable = await _isTimeSlotAvailable(
        teacher['id'] ?? '',
        temp['dateTime'] ?? DateTime.now(),
        temp['duration'] ?? 60,
      );

      if (!isAvailable) {
        _setError('هذا الموعد محجوز مسبقاً مع المعلم ${teacher['name']}');
        _setLoading(false);
        return false;
      }

      // حفظ في Firebase
      final bookingData = newBooking.toFirestore();
      final docRef = await _firestore.collection('bookings').add(bookingData);

      // تحديث الحجز بالمعرّف
      await _firestore.collection('bookings').doc(docRef.id).update({
        'id': docRef.id,
      });

      // جدولة التذكيرات
      final bookingWithId = newBooking.copyWith(id: docRef.id);
      _scheduleBookingReminders(bookingWithId);

      // مسح الحجز المؤقت بعد النجاح
      clearTempBooking();

      _setLoading(false);
      print('✅ تم إنشاء الحجز بعد الدفع: ${docRef.id}');
      print('👤 الحجز للطالب: ${temp['studentId']}');
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('فشل في إنشاء الحجز بعد الدفع: ${e.toString()}');
      print('❌ فشل في إنشاء الحجز: $e');
      return false;
    }
  }

  // ✅ إنشاء حجز جديد (الطريقة المحسنة)
  Future<bool> createBooking({
    required String studentId,
    required String studentName,
    required String teacherId,
    required String teacherName,
    required String subject,
    required DateTime dateTime,
    required int duration,
    required double price,
    required String sessionType,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _setError('');

      // إنشاء كائن الحجز
      final newBooking = Booking.createNew(
        studentId: studentId,
        studentName: studentName,
        teacherId: teacherId,
        teacherName: teacherName,
        subject: subject,
        dateTime: dateTime,
        duration: duration,
        price: price,
        sessionType: sessionType,
        notes: notes,
      );

      // التحقق من توفر الموعد
      final isAvailable =
          await _isTimeSlotAvailable(teacherId, dateTime, duration);

      if (!isAvailable) {
        _setError('هذا الموعد محجوز مسبقاً مع المعلم $teacherName');
        _setLoading(false);
        return false;
      }

      // حفظ في Firebase
      final bookingData = newBooking.toFirestore();
      final docRef = await _firestore.collection('bookings').add(bookingData);

      // تحديث الحجز بالمعرّف
      await _firestore.collection('bookings').doc(docRef.id).update({
        'id': docRef.id,
      });

      // جدولة التذكيرات
      final bookingWithId = newBooking.copyWith(id: docRef.id);
      _scheduleBookingReminders(bookingWithId);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('فشل في إنشاء الحجز: ${e.toString()}');
      return false;
    }
  }

  // ✅ تحديث حالة الحجز
  Future<bool> updateBookingStatus(
      String bookingId, BookingStatus newStatus) async {
    try {
      _setLoading(true);

      await _firestore.collection('bookings').doc(bookingId).update({
        'status': Booking.statusToString(newStatus),
        'updatedAt': Timestamp.now(),
      });

      if (newStatus == BookingStatus.cancelled) {
        _cancelBookingReminders(bookingId);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('فشل في تحديث الحجز: ${e.toString()}');
      return false;
    }
  }

  // ✅ إلغاء الحجز
  Future<bool> cancelBooking(String bookingId) async {
    final success =
        await updateBookingStatus(bookingId, BookingStatus.cancelled);
    if (success) {
      _cancelBookingReminders(bookingId);
    }
    return success;
  }

  // ✅ تأكيد الحجز
  Future<bool> confirmBooking(String bookingId) async {
    return await updateBookingStatus(bookingId, BookingStatus.confirmed);
  }

  // ✅ حذف الحجز
  Future<bool> deleteBooking(String bookingId) async {
    try {
      _setLoading(true);

      await _firestore.collection('bookings').doc(bookingId).delete();
      _cancelBookingReminders(bookingId);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('فشل في حذف الحجز: ${e.toString()}');
      return false;
    }
  }

  // ✅ البحث في الحجوزات
  Stream<List<Booking>> searchBookings(String query) {
    if (query.isEmpty) {
      return _firestore
          .collection('bookings')
          .orderBy('dateTime', descending: false)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
    }

    return _firestore
        .collection('bookings')
        .orderBy('teacherName')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromFirestore(doc))
            .where((booking) =>
                booking.teacherName
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                booking.subject.toLowerCase().contains(query.toLowerCase()) ||
                booking.sessionType
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                booking.studentName.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }

  // ✅ التحقق من توفر الموعد
  Future<bool> _isTimeSlotAvailable(
      String teacherId, DateTime dateTime, int duration) async {
    final sessionEnd = dateTime.add(Duration(minutes: duration));

    final query = await _firestore
        .collection('bookings')
        .where('teacherId', isEqualTo: teacherId)
        .where('status', whereIn: ['pending', 'confirmed']).get();

    final existingBookings =
        query.docs.map((doc) => Booking.fromFirestore(doc)).toList();

    return !existingBookings.any((existing) {
      final existingEnd =
          existing.dateTime.add(Duration(minutes: existing.duration));

      // التحقق من التداخل
      return (dateTime.isBefore(existingEnd) &&
          sessionEnd.isAfter(existing.dateTime));
    });
  }

  // ✅ الحصول على حجز بواسطة ID
  Future<Booking?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists) {
        return Booking.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _setError('فشل في جلب الحجز: ${e.toString()}');
      return null;
    }
  }

  // ✅ إحصائيات الحجوزات
  Future<Map<String, int>> getBookingStats(
      {String? userId, String? userType}) async {
    Query query = _firestore.collection('bookings');

    if (userId != null && userType != null) {
      final field = userType == 'student' ? 'studentId' : 'teacherId';
      query = query.where(field, isEqualTo: userId);
    }

    final snapshot = await query.get();
    final allBookings =
        snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();

    return {
      'total': allBookings.length,
      'pending': allBookings.where((b) => b.isPending).length,
      'confirmed': allBookings.where((b) => b.isConfirmed).length,
      'cancelled': allBookings.where((b) => b.isCancelled).length,
      'upcoming': allBookings
          .where((b) => b.dateTime.isAfter(DateTime.now()) && !b.isCancelled)
          .length,
    };
  }

  // ✅ جدولة التذكيرات
  void _scheduleBookingReminders(Booking booking) {
    final bookingData = {
      'id': booking.id,
      'studentId': booking.studentId,
      'teacherName': booking.teacherName,
      'subject': booking.subject,
      'sessionTime': booking.dateTime.toIso8601String(),
    };

    BookingReminderService.scheduleBookingReminders(bookingData);
    print('⏰ تم جدولة تذكيرات تلقائية للحجز: ${booking.id}');
  }

  // ✅ إلغاء التذكيرات
  void _cancelBookingReminders(String bookingId) {
    BookingReminderService.cancelBookingReminders(bookingId);
    print('❌ تم إلغاء تذكيرات الحجز: $bookingId');
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

  // ✅ للحفاظ على التوافق مع الكود القديم
  List<Booking> getBookingsByStudent(String studentId) {
    return _bookings
        .where((booking) => booking.studentId == studentId)
        .toList();
  }

  List<Booking> getBookingsByTeacher(String teacherId) {
    return _bookings
        .where((booking) => booking.teacherId == teacherId)
        .toList();
  }

  Future<void> fetchBookings() async {
    loadAllBookings();
  }

  @override
  void dispose() {
    BookingReminderService.dispose();
    super.dispose();
  }
}
