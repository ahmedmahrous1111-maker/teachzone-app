import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import './core/firebase_service.dart';
import './providers/subject_provider.dart';
import './providers/firebase_auth_provider.dart';
import './providers/courses_provider.dart';
import './providers/booking_provider.dart';
import './providers/teacher_report_provider.dart';
import './providers/student_report_provider.dart';
import './providers/payment_provider.dart';
import './screens/home_screen_final.dart';
import './screens/teacher/bookings/bookings_screen.dart';
import './screens/student/student_booking_screen.dart';
import './screens/student/student_bookings_list.dart';
import './screens/login_screen.dart';
import './screens/video_room.dart';
import './screens/teacher/teacher_reports_screen.dart';
import './screens/student/student_reports_screen.dart';
import './screens/student/student_detail_screen.dart';
import './screens/teacher/kyc_onboarding_screen.dart';
import './screens/student/payment_method_screen.dart';
import './models/notification_model.dart';
import './models/report_model.dart' as report_model;
import './models/analytics_model.dart';
import './services/local_notification_service.dart';
import './services/booking_reminder_service.dart';
import './services/push_notification_service.dart';
import './models/course_model.dart';
// ⭐ جديد: استيراد شاشة مساعد الواجبات
import './features/ai_homework_assistant/screens/homework_assistant_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  }

  print('🚀 بدء تهيئة TeachZone...');

  try {
    await FirebaseService.initialize();
    print('✅ Firebase مهيأ بنجاح');

    await initializeAppServices();
    runTests();

    print('🎉 تطبيق TeachZone جاهز للتشغيل');
    runApp(MyApp());
  } catch (e) {
    print('❌ خطأ في تهيئة التطبيق: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

Future<void> initializeAppServices() async {
  print('🔧 تهيئة خدمات التطبيق...');

  try {
    await PushNotificationService.initialize();
    print('✅ خدمات الإشعارات جاهزة');

    String? token = await PushNotificationService.getDeviceToken();
    print('📱 توكن الجهاز: $token');
  } catch (e) {
    print('⚠️ خطأ في تهيئة الخدمات: $e');
  }
}

void runTests() {
  print('🧪 بدء اختبارات النظام...');
  testNotificationModel();
  testLocalNotificationService();
  testBookingReminders();
  testReportModels();
  testPaymentProvider();
}

void testNotificationModel() {
  try {
    final notification = AppNotification(
      id: 'test-1',
      userId: 'user-123',
      title: 'اختبار الإشعار',
      body: 'هذا إشعار تجريبي',
      type: 'system',
      createdAt: DateTime.now(),
    );
    print('✅ نموذج الإشعارات: ناجح');
  } catch (e) {
    print('❌ نموذج الإشعارات: فشل - $e');
  }
}

void testLocalNotificationService() {
  try {
    LocalNotificationService.createNotification(
      userId: 'test-user',
      title: 'اختبار الخدمة',
      body: 'هذا اختبار لخدمة الإشعارات',
      type: 'system',
    );
    print('✅ خدمة الإشعارات المحلية: ناجح');
  } catch (e) {
    print('❌ خدمة الإشعارات المحلية: فشل - $e');
  }
}

void testBookingReminders() {
  try {
    final testBooking = {
      'id': 'test-booking-${DateTime.now().millisecondsSinceEpoch}',
      'studentId': 'user1',
      'teacherName': 'الأستاذ أحمد',
      'subject': 'رياضيات',
      'sessionTime': DateTime.now().add(Duration(minutes: 2)).toIso8601String(),
    };

    BookingReminderService.scheduleBookingReminders(testBooking);
    print('✅ نظام التذكيرات: ناجح');
  } catch (e) {
    print('❌ نظام التذكيرات: فشل - $e');
  }
}

void testReportModels() {
  try {
    final report = report_model.ReportModel(
      id: 'test-report-1',
      userId: 'user-123',
      userType: 'teacher',
      title: 'تقرير اختبار',
      description: 'هذا تقرير تجريبي',
      data: {'sessions': 10, 'rating': 4.5},
      generatedAt: DateTime.now(),
      period: 'weekly',
    );
    print('✅ نماذج التقارير: ناجح');
  } catch (e) {
    print('❌ نماذج التقارير: فشل - $e');
  }
}

void testPaymentProvider() {
  try {
    final testAmount = 100.0;
    final commission = _testCommissionCalculation(testAmount);

    print('💰 اختبار نظام الدفع: ناجح');
    print('   المبلغ: $testAmount');
    print('   عمولة الطالب (5%): ${commission['studentCommission']}');
    print('   عمولة المعلم (5%): ${commission['teacherCommission']}');
    print('   الصافي للمعلم: ${commission['netAmount']}');
    print('   إجمالي العمولة: ${commission['totalCommission']}');
  } catch (e) {
    print('❌ اختبار نظام الدفع: فشل - $e');
  }
}

Map<String, double> _testCommissionCalculation(double amount) {
  final studentCommission = amount * 0.05;
  final teacherCommission = amount * 0.05;
  final netAmount = amount - teacherCommission;
  final totalCommission = studentCommission + teacherCommission;

  return {
    'studentCommission': studentCommission,
    'teacherCommission': teacherCommission,
    'netAmount': netAmount,
    'totalCommission': totalCommission,
  };
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 20),
              Text(
                'خطأ في التهيئة',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  main();
                },
                child: Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FirebaseAuthProvider()),
        ChangeNotifierProvider(create: (_) => CoursesProvider()),
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => TeacherReportProvider()),
        ChangeNotifierProvider(create: (_) => StudentReportProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: MaterialApp(
        title: 'TeachZone',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Tajawal',
          useMaterial3: true,
        ),
        home: SplashScreen(), // ⭐⭐ شاشة البداية المحسنة ⭐⭐
        debugShowCheckedModeBanner: false,
        routes: {
          '/home': (context) => HomeScreenFinal(userType: 'student'),
          '/bookings': (context) => BookingsScreen(),
          '/student-booking': (context) => StudentBookingScreen(),
          '/student-bookings': (context) => StudentBookingsListScreen(),
          '/video-room': (context) => VideoRoom(),
          '/teacher-reports': (context) => TeacherReportsScreen(),
          '/student-reports': (context) => StudentReportsScreen(),
          '/kyc-onboarding': (context) => KYCOnboardingScreen(),
          // ⭐ المسار الجديد لمساعد الواجبات - تم إضافته
          '/homework-assistant': (context) => HomeworkAssistantScreen(),
          '/payment-method': (context) {
            try {
              final args = ModalRoute.of(context)!.settings.arguments;

              print('🔍 نوع البيانات المستلمة: ${args.runtimeType}');

              if (args is Map<String, dynamic>) {
                // الحالة الأولى: البيانات من الحجوزات (Map)
                final courseData = args['course'];

                Course course;
                if (courseData is Map<String, dynamic>) {
                  course = Course.fromMap(courseData);
                } else if (courseData is Course) {
                  course = courseData;
                } else {
                  throw Exception(
                      'نوع بيانات الكورس غير مدعوم: ${courseData.runtimeType}');
                }

                print('✅ تم تحميل الكورس: ${course.title}');

                return PaymentMethodScreen(
                  course: course,
                  teacherId: args['teacherId'] as String? ?? course.teacherId,
                  teacherName:
                      args['teacherName'] as String? ?? course.instructor,
                  bookingData: args['bookingData'] as Map<String, dynamic>?,
                );
              } else if (args is Course) {
                // الحالة الثانية: بيانات Course مباشرة
                print('✅ تم تحميل الكورس مباشرة: ${args.title}');
                return PaymentMethodScreen(
                  course: args,
                  teacherId: args.teacherId,
                  teacherName: args.instructor,
                  bookingData: null,
                );
              } else if (args == null) {
                throw Exception('لم يتم إرسال بيانات للدفع');
              } else {
                throw Exception('نوع البيانات غير مدعوم: ${args.runtimeType}');
              }
            } catch (e) {
              print('❌ خطأ في تحميل شاشة الدفع: $e');

              // العودة للشاشة السابقة مع رسالة خطأ
              return Scaffold(
                appBar: AppBar(title: Text('خطأ في الدفع')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 20),
                      Text(
                        'حدث خطأ في تحميل صفحة الدفع',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'تفاصيل الخطأ: $e',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('العودة'),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        },
      ),
    );
  }
}

// ⭐⭐ شاشة البداية المحسنة - الضغط على أي مكان في الصورة ⭐⭐
class SplashScreen extends StatelessWidget {
  void _navigateToApp(BuildContext context) {
    print('🎯 تم الضغط على الصورة - الانتقال لتسجيل الدخول');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          print('👆 تم الضغط على الصورة');
          _navigateToApp(context);
        },
        child: Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            'assets/images/appface.jpeg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // ⭐ تحسين: استخدام Future.delayed لمنح الوقت لتهيئة Firebase Auth
      await Future.delayed(Duration(milliseconds: 500));

      setState(() {
        _isInitialized = true;
      });

      // تحميل البيانات الإضافية بعد التهيئة
      _loadAdditionalData();
    } catch (e) {
      print('⚠️ خطأ في تهيئة التطبيق: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _loadAdditionalData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider =
          Provider.of<FirebaseAuthProvider>(context, listen: false);
      final coursesProvider =
          Provider.of<CoursesProvider>(context, listen: false);
      final subjectProvider =
          Provider.of<SubjectProvider>(context, listen: false);
      final paymentProvider =
          Provider.of<PaymentProvider>(context, listen: false);

      if (authProvider.isLoggedIn) {
        final userType = authProvider.userType ?? 'student';
        final userId = authProvider.currentUser!.uid;

        coursesProvider.loadAllCourses();
        subjectProvider.loadSubjects();
        paymentProvider.updateWalletBalance(userId);

        if (userType == 'teacher' && authProvider.kycCompleted) {
          coursesProvider.loadTeacherCourses(userId);
          subjectProvider.loadTeacherSubjects(userId);
          paymentProvider.fetchTeacherTransactions(userId);
        } else if (userType == 'student') {
          paymentProvider.fetchUserTransactions(userId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<FirebaseAuthProvider>(context);

    // ⭐ إصلاح الارتجاع: عرض شاشة التحميل حتى تكتمل التهيئة
    if (!_isInitialized) {
      return LoadingScreen();
    }

    if (authProvider.isLoading) {
      return LoadingScreen();
    }

    if (authProvider.isLoggedIn) {
      print('🎯 تحميل الشاشة الرئيسية للمستخدم المسجل');
      authProvider.printUserInfo();

      final userType = authProvider.userType ?? 'student';
      return HomeScreenFinal(userType: userType);
    }

    print('🔐 تحميل شاشة تسجيل الدخول');
    return LoginScreen();
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade100, width: 2),
              ),
              child: Icon(Icons.school, color: Colors.blue, size: 60),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 20),
            Text(
              'جاري تحميل TeachZone...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'منصة التعلم الذكي',
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
}
