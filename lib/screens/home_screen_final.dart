import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_auth_provider.dart';
import '../providers/courses_provider.dart';
import '../widgets/course_card.dart';
import 'student/student_booking_screen.dart';
import 'student/student_bookings_list.dart';
import 'student/student_reports_screen.dart';
import 'teacher/bookings/bookings_screen.dart';
import 'teacher/teacher_courses_screen.dart';
import 'teacher/teacher_reports_screen.dart';
import 'teacher/kyc_onboarding_screen.dart';
import 'video_room.dart';
import 'notifications_screen.dart';
import '../services/local_notification_service.dart';
import '../models/course_model.dart'; // ⭐ جديد: لإنشاء كورس تجريبي
// ⭐ جديد: استيراد شاشة مساعد الواجبات
import '../features/ai_homework_assistant/screens/homework_assistant_screen.dart';

class HomeScreenFinal extends StatefulWidget {
  final String userType;

  const HomeScreenFinal({Key? key, required this.userType}) : super(key: key);

  @override
  _HomeScreenFinalState createState() => _HomeScreenFinalState();
}

class _HomeScreenFinalState extends State<HomeScreenFinal> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    LocalNotificationService.initializeWithMockData();
    _initializeData();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final coursesProvider =
          Provider.of<CoursesProvider>(context, listen: false);

      // ⭐ تحميل الكورسات عند بدء التطبيق
      if (widget.userType == 'student') {
        coursesProvider.loadAllCourses();
      } else {
        final authProvider =
            Provider.of<FirebaseAuthProvider>(context, listen: false);
        if (authProvider.currentUser != null && authProvider.kycCompleted) {
          coursesProvider.loadTeacherCourses(authProvider.currentUser!.uid);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userType == 'student'
            ? 'TeachZone - الطالب'
            : 'TeachZone - المعلم'),
        backgroundColor:
            widget.userType == 'student' ? Colors.blue : Colors.green,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsScreen(),
                    ),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: FutureBuilder<int>(
                  future: Future(
                      () => LocalNotificationService.getUnreadCount('user1')),
                  builder: (context, snapshot) {
                    final unreadCount = snapshot.data ?? 0;
                    if (unreadCount > 0) {
                      return Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'الكورسات'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }

  Widget _getCurrentScreen() {
    // ✅ التحقق من حالة KYC للمعلمين
    if (widget.userType == 'teacher') {
      final authProvider = context.read<FirebaseAuthProvider>();
      final kycCompleted = authProvider.kycCompleted;

      // إذا لم يكمل المعلم عملية KYC
      if (!kycCompleted) {
        return _buildKYCRequiredView(authProvider);
      }
    }

    if (widget.userType == 'student') {
      switch (_currentIndex) {
        case 0:
          return StudentHomeFinal();
        case 1:
          return StudentCoursesFinal();
        case 2:
          return StudentProfileFinal();
        default:
          return StudentHomeFinal();
      }
    } else {
      switch (_currentIndex) {
        case 0:
          return TeacherHomeFinal();
        case 1:
          return TeacherCoursesFinal();
        case 2:
          return TeacherProfileFinal();
        default:
          return TeacherHomeFinal();
      }
    }
  }

  // ✅ واجهة KYC المطلوبة
  Widget _buildKYCRequiredView(FirebaseAuthProvider authProvider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 80,
              color: Colors.orange,
            ),
            SizedBox(height: 20),
            Text(
              'التحقق مطلوب',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'لبدء تقديم الحصص، يرجى إكمال عملية التحقق من الهوية والمؤهلات',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KYCOnboardingScreen(),
                  ),
                );
              },
              child: Text('بدء عملية التحقق'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تسجيل الخروج'),
        content: Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<FirebaseAuthProvider>(context, listen: false)
                  .signOut();
            },
            child: Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// 🎯 واجهة الطالب الرئيسية - محدثة
class StudentHomeFinal extends StatefulWidget {
  @override
  State<StudentHomeFinal> createState() => _StudentHomeFinalState();
}

class _StudentHomeFinalState extends State<StudentHomeFinal> {
  // ⭐ جديد: حالة مؤقتة للاختيار الحالي (قبل الحفظ)
  String? _tempSelectedCurriculum;
  String? _tempSelectedLevel;

  // ⭐ جديد: قائمة المناهج والمراحل
  final Map<String, List<String>> _curriculumLevels = {
    '🇪🇬 المنهج المصري': ['المرحلة الإعدادية', 'المرحلة الثانوية'],
    '🇸🇦 المنهج السعودي': ['المرحلة المتوسطة', 'المرحلة الثانوية'],
  };

  @override
  void initState() {
    super.initState();
    // ⭐ جديد: تحميل الاختيارات السابقة من Provider
    _loadSavedSelections();
  }

  void _loadSavedSelections() {
    // ⭐ جديد: استخدام البيانات من Provider مباشرة
    final authProvider =
        Provider.of<FirebaseAuthProvider>(context, listen: false);
    setState(() {
      _tempSelectedCurriculum =
          authProvider.selectedCurriculum ?? '🇪🇬 المنهج المصري';
      _tempSelectedLevel = authProvider.selectedLevel ?? 'المرحلة الإعدادية';
    });
  }

  void _showCurriculumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختيار المنهج والمرحلة'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // اختيار المنهج
              Text('اختر المنهج:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ..._curriculumLevels.keys.map((curriculum) {
                return RadioListTile<String>(
                  title: Text(curriculum),
                  value: curriculum,
                  groupValue: _tempSelectedCurriculum,
                  onChanged: (value) {
                    setState(() {
                      _tempSelectedCurriculum = value;
                      _tempSelectedLevel = null; // إعادة تعيين المرحلة
                    });
                    Navigator.pop(context);
                    _showCurriculumDialog(); // إعادة فتح الديالوج لاختيار المرحلة
                  },
                );
              }).toList(),

              SizedBox(height: 20),

              // اختيار المرحلة (يظهر فقط بعد اختيار المنهج)
              if (_tempSelectedCurriculum != null) ...[
                Text('اختر المرحلة:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ..._curriculumLevels[_tempSelectedCurriculum]!.map((level) {
                  return RadioListTile<String>(
                    title: Text(level),
                    value: level,
                    groupValue: _tempSelectedLevel,
                    onChanged: (value) {
                      setState(() {
                        _tempSelectedLevel = value;
                      });
                      _saveSelections();
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  // ⭐ جديد: حفظ الاختيارات في Firebase عبر Provider
  Future<void> _saveSelections() async {
    if (_tempSelectedCurriculum == null || _tempSelectedLevel == null) {
      return;
    }

    try {
      final authProvider =
          Provider.of<FirebaseAuthProvider>(context, listen: false);
      await authProvider.saveCurriculumSelection(
        curriculum: _tempSelectedCurriculum!,
        level: _tempSelectedLevel!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث المنهج والمرحلة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      print(
          '✅ تم حفظ الاختيار في Firebase: $_tempSelectedCurriculum - $_tempSelectedLevel');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حفظ البيانات: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('❌ خطأ في حفظ الاختيار: $e');
    }
  }

  // ⭐ جديد: دالة لإنشاء كورس تجريبي
  Course _createTestCourse() {
    return Course(
      id: 'test-course-payment',
      title: 'كورس رياضيات متقدم',
      description: 'كورس تجريبي لاختبار نظام الدفع الجديد',
      instructor: 'د. أحمد محمد',
      teacherId: 'test-teacher-123',
      subject: 'رياضيات',
      level: 'متقدم',
      price: 150.0,
      currency: 'SAR',
      rating: 4.8,
      reviewCount: 47,
      enrolledStudents: 125,
      progress: 0.0,
      imageUrl: '',
      isPublished: true,
      isActive: true,
      createdAt: DateTime.now(),
      chapters: [
        'المقدمة',
        'الجبر المتقدم',
        'الهندسة التحليلية',
        'التفاضل والتكامل'
      ],
      totalLessons: 15,
      completedLessons: 0,
      duration: '6 أسابيع',
      category: 'تعليمي',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<FirebaseAuthProvider>(context);
    final coursesProvider = Provider.of<CoursesProvider>(context);
    final userData = authProvider.userData;

    // ⭐ جديد: استخدام البيانات من Provider بدلاً من الحالة المحلية
    final currentCurriculum =
        authProvider.selectedCurriculum ?? _tempSelectedCurriculum;
    final currentLevel = authProvider.selectedLevel ?? _tempSelectedLevel;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // ⭐ جديد: قسم اختيار المنهج والمرحلة (دائم) - متكامل مع Provider
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المنهج والمرحلة التعليمية',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: _showCurriculumDialog,
                        iconSize: 20,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.school, color: Colors.blue, size: 18),
                      SizedBox(width: 8),
                      Text(
                        currentCurriculum ?? 'لم يتم اختيار منهج',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.grade, color: Colors.green, size: 18),
                      SizedBox(width: 8),
                      Text(
                        currentLevel ?? 'لم يتم اختيار مرحلة',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  // ⭐ جديد: مؤشر إذا كان محفوظاً في السحابة
                  if (authProvider.hasSelectedCurriculum)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(Icons.cloud_done, color: Colors.green, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'محفوظ في السحابة',
                            style: TextStyle(fontSize: 12, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // بطاقة الترحيب
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue, Colors.lightBlue]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.school, size: 40, color: Colors.white),
                SizedBox(height: 10),
                Text('أهلاً بك ${userData['name'] ?? 'أيها الطالب'}!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text('استمر في رحلة التعلم الخاصة بك',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          SizedBox(height: 20),

          // ⭐ جديد: زر تجريبي لنظام الدفع
          Container(
            width: double.infinity,
            child: Material(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  // الانتقال لشاشة الدفع التجريبية
                  Navigator.pushNamed(
                    context,
                    '/payment-method',
                    arguments: {
                      'course': _createTestCourse(),
                      'teacherId': 'test-teacher-123',
                      'teacherName': 'د. أحمد محمد',
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'تجربة نظام الدفع الجديد',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),

          // ⭐ جديد: زر مساعد الواجبات الذكي
          Container(
            width: double.infinity,
            child: Material(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/homework-assistant');
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'مساعد الواجبات الذكي',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),

          // إحصائيات سريعة
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard('الكورسات', '${coursesProvider.courses.length}',
                  Icons.library_books, Colors.blue),
              _buildStatCard('الحجوزات', '3', Icons.bookmark, Colors.green),
              _buildStatCard('المهام', '12', Icons.assignment, Colors.orange),
              _buildStatCard('التقييم', '4.5', Icons.star, Colors.purple),
            ],
          ),
          SizedBox(height: 20),

          // أزرار الإجراءات السريعة
          Container(
            width: double.infinity,
            child: Material(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => StudentBookingScreen()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_call, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'احجز جلسة تعليمية',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: Material(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StudentBookingsListScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'عرض حجوزاتي',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),

          // قسم الكورسات النشطة
          _buildCoursesSection(coursesProvider),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildCoursesSection(CoursesProvider provider) {
    if (provider.isLoading) {
      return Container(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('جاري تحميل الكورسات...'),
            ],
          ),
        ),
      );
    }

    if (provider.hasError) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              provider.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadAllCourses(),
              child: Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (provider.courses.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد كورسات نشطة حالياً'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadAllCourses(),
              child: Text('تحديث القائمة'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('الكورسات النشطة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(
              '${provider.courses.length} كورس',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        SizedBox(height: 16),
        Column(
          children: provider.courses
              .take(3) // عرض أول 3 كورسات فقط
              .map((course) => Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: CourseCard(course: course),
                  ))
              .toList(),
        ),
        if (provider.courses.length > 3)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: () {
                // الانتقال لشاشة الكورسات الكاملة
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => StudentCoursesFinal()),
                );
              },
              child: Text('عرض جميع الكورسات (${provider.courses.length})'),
            ),
          ),
      ],
    );
  }
}

// 🎯 كورسات الطالب - محدثة
class StudentCoursesFinal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final coursesProvider = Provider.of<CoursesProvider>(context);

    return Scaffold(
      body: coursesProvider.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل الكورسات...'),
                ],
              ),
            )
          : coursesProvider.hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        coursesProvider.errorMessage,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => coursesProvider.loadAllCourses(),
                        child: Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : coursesProvider.courses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school_outlined,
                              size: 80, color: Colors.grey),
                          SizedBox(height: 20),
                          Text('لا توجد كورسات حالياً',
                              style: TextStyle(fontSize: 18)),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => coursesProvider.loadAllCourses(),
                            child: Text('تحديث القائمة'),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      children: [
                        // Header
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Colors.blue, Colors.lightBlueAccent]),
                          ),
                          child: Column(
                            children: [
                              Text('الكورسات المتاحة',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              SizedBox(height: 8),
                              Text(
                                  '${coursesProvider.courses.length} كورس متاح',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white70)),
                            ],
                          ),
                        ),
                        // Courses List
                        ...coursesProvider.courses.map((course) => Padding(
                              padding: EdgeInsets.all(16),
                              child: CourseCard(course: course),
                            )),
                      ],
                    ),
    );
  }
}

// 🎯 ملف الطالب الشخصي
class StudentProfileFinal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<FirebaseAuthProvider>(context);
    final userData = authProvider.userData;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          SizedBox(height: 16),
          Text(userData['name'] ?? 'أحمد محمد',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('طالب', style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 30),
          _buildProfileOption(Icons.person, 'البيانات الشخصية'),
          _buildProfileOption(Icons.security, 'الأمان'),
          _buildProfileOption(Icons.notifications, 'الإشعارات'),
          _buildProfileOption(Icons.help, 'المساعدة'),
          _buildProfileOption(Icons.info, 'عن التطبيق'),
          _buildProfileOption(Icons.logout, 'تسجيل الخروج', isLogout: true),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title,
      {bool isLogout = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2))
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : Colors.blue),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isLogout ? Colors.red : Colors.black)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => print('📱 $title'),
      ),
    );
  }
}

// 🎯 واجهة المعلم الرئيسية - محدثة
class TeacherHomeFinal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<FirebaseAuthProvider>(context);
    final coursesProvider = Provider.of<CoursesProvider>(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // بطاقة الترحيب
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient:
                  LinearGradient(colors: [Colors.green, Colors.greenAccent]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.person, size: 40, color: Colors.white),
                SizedBox(height: 10),
                Text('أهلاً بك ${authProvider.userName ?? 'أيها المعلم'}!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text('لوحة تحكم المعلم',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          SizedBox(height: 20),

          // إحصائيات سريعة
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildTeacherStatCard('الطلاب', '47', Icons.people, Colors.blue),
              _buildTeacherStatCard(
                  'الكورسات',
                  '${coursesProvider.teacherCourses.length}',
                  Icons.library_books,
                  Colors.green),
              _buildTeacherStatCard(
                  'الجلسات', '23', Icons.video_call, Colors.orange),
              _buildTeacherStatCard(
                  'الإيرادات', '2,450', Icons.attach_money, Colors.purple),
            ],
          ),
          SizedBox(height: 20),

          // أزرار الإجراءات السريعة
          Container(
            width: double.infinity,
            child: Material(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BookingsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'إدارة الحجوزات',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: Material(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TeacherCoursesScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.library_books, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'إدارة الكورسات',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

// 🎯 كورسات المعلم - محدثة
class TeacherCoursesFinal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TeacherCoursesScreen(); // ⭐ استخدام الشاشة المحدثة
  }
}

// 🎯 ملف المعلم الشخصي
class TeacherProfileFinal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<FirebaseAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('ملفي الشخصي'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(authProvider.userName ?? 'أستاذ محمد أحمد',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('معلم', style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 30),
            _buildProfileOption(Icons.person, 'البيانات الشخصية'),
            _buildProfileOption(Icons.security, 'الأمان'),
            _buildProfileOption(Icons.notifications, 'الإشعارات'),
            _buildProfileOption(Icons.analytics, 'تقارير الطلاب', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentReportsScreen(),
                ),
              );
            }),
            // 🔧 الزر الجديد: تقارير الأداء (اختبار)
            _buildProfileOption(Icons.assessment, 'تقارير الأداء (اختبار)',
                onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeacherReportsScreen(),
                ),
              );
            }),
            _buildProfileOption(Icons.bar_chart, 'التقارير والإحصائيات',
                onTap: () {
              Navigator.pushNamed(context, '/teacher-reports');
            }),
            _buildProfileOption(Icons.business_center, 'الحساب البنكي'),
            _buildProfileOption(Icons.help, 'المساعدة'),
            _buildProfileOption(Icons.info, 'عن التطبيق'),
            _buildProfileOption(Icons.logout, 'تسجيل الخروج', isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title,
      {bool isLogout = false, VoidCallback? onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2))
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : Colors.green),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isLogout ? Colors.red : Colors.black)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap ?? () => print('📱 $title'),
      ),
    );
  }
}
