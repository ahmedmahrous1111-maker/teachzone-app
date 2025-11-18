import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/mock_auth_provider.dart';
import '../providers/courses_provider.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/course_card.dart';
import 'course_details_screen.dart';
import 'teacher/teacher_courses_screen.dart';
import 'teacher/bookings/bookings_screen.dart';
import 'student/student_booking_screen.dart';
import 'teacher/bookings/bookings_screen.dart';
import 'student/student_bookings_list.dart'; // ⭐ الإضافة الجديدة

class HomeScreen extends StatefulWidget {
  final String userType;
  final String selectedCurriculum;
  final String selectedGrade;

  const HomeScreen({
    Key? key,
    required this.userType,
    this.selectedCurriculum = 'saudi',
    this.selectedGrade = 'أول ثانوي',
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  List<Widget> get _screens {
    if (widget.userType == 'student') {
      return [
        StudentHomeTab(
          selectedCurriculum: widget.selectedCurriculum,
          selectedGrade: widget.selectedGrade,
        ),
        StudentCoursesTab(),
        StudentProgressTab(),
        StudentProfileTab(),
      ];
    } else {
      return [
        TeacherHomeTab(),
        TeacherCoursesTab(subjectService: null),
        TeacherStudentsTab(),
        TeacherProfileTab(),
      ];
    }
  }

  List<BottomNavigationBarItem> get _bottomNavItems {
    if (widget.userType == 'student') {
      return [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'الكورسات'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'التقدم'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
      ];
    } else {
      return [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        BottomNavigationBarItem(
            icon: Icon(Icons.library_books), label: 'كورساتي'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'الطلاب'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MockAuthProvider>(context);
    final userData = authProvider.userData;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            widget.userType == 'student' ? Colors.blue : Colors.green,
        title: Text(
          widget.userType == 'student'
              ? 'TeachZone - الطالب'
              : 'TeachZone - المعلم',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                print('🔔 زر الإشعارات');
              }),
          IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                print('🔍 زر البحث');
              }),
          IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () => _showLogoutDialog(context, authProvider)),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          print('🎯 تغيير التبويب إلى: $index');
          setState(() => _currentIndex = index);
        },
        selectedItemColor:
            widget.userType == 'student' ? Colors.blue : Colors.green,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: _bottomNavItems,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, MockAuthProvider authProvider) {
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
              authProvider.signOut();
            },
            child: Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ✅ تبويب الرئيسية للطالب - النسخة النهائية المصححة
class StudentHomeTab extends StatelessWidget {
  final String selectedCurriculum;
  final String selectedGrade;

  const StudentHomeTab(
      {Key? key, required this.selectedCurriculum, required this.selectedGrade})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MockAuthProvider>(context);
    final coursesProvider = Provider.of<CoursesProvider>(context);
    final userData = authProvider.userData;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      coursesProvider.fetchCourses();
    });

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient:
                  LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: userData?['profileImage'] != null
                      ? FutureBuilder<File>(
                          future: Future.value(File(userData!['profileImage'])),
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data!.existsSync()) {
                              return ClipOval(
                                child: Image.file(
                                  snapshot.data!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.person,
                                        color: Colors.white, size: 30);
                                  },
                                ),
                              );
                            }
                            return Icon(Icons.person,
                                color: Colors.white, size: 30);
                          },
                        )
                      : Icon(Icons.person, color: Colors.white, size: 30),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('أهلاً بك ${userData?['name'] ?? 'أيها الطالب'}!',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      SizedBox(height: 4),
                      Text('استمر في رحلة التعلم الخاصة بك',
                          style:
                              TextStyle(fontSize: 14, color: Colors.white70)),
                      if (userData?['grade'] != null) ...[
                        SizedBox(height: 4),
                        Text('الصف: ${userData!['grade']}',
                            style:
                                TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCurriculumColor(selectedCurriculum).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: _getCurriculumColor(selectedCurriculum)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getCurriculumColor(selectedCurriculum),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                      child: Text(_getCurriculumFlag(selectedCurriculum),
                          style: TextStyle(fontSize: 16))),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('المنهج والمرحلة',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600])),
                      Text(
                          '${_getCurriculumName(selectedCurriculum)} - ${_getGradeName(selectedGrade)}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getCurriculumColor(selectedCurriculum))),
                    ],
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.edit,
                        color: _getCurriculumColor(selectedCurriculum)),
                    onPressed: () {
                      print('✏️ زر تعديل المنهج');
                    }),
              ],
            ),
          ),
          SizedBox(height: 24),
          Text('إحصائيات سريعة',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800])),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                    'الكورسات المسجلة', '5', Icons.library_books, Colors.blue),
                _buildStatCard('الحجوزات النشطة', '3', Icons.bookmark,
                    Colors.green), // ⭐ معدل
                _buildStatCard('المهام المكتملة', '12',
                    Icons.assignment_turned_in, Colors.orange),
                _buildStatCard(
                    'التقييم العام', '4.5', Icons.star, Colors.purple),
              ],
            ),
          ),

          SizedBox(height: 24),

          // 🟢 زر حجز جلسة تعليمية - الإصدار المؤكد
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                print('🎯 الضغط على زر الحجز...');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentBookingScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_call, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'احجز جلسة تعليمية',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // 🟦 زر عرض الحجوزات - الإضافة الجديدة
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                print('📋 الضغط على زر حجوزاتي...');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentBookingsListScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'عرض حجوزاتي',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('الكورسات النشطة',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800])),
            TextButton(
                onPressed: () {
                  print('📚 عرض جميع الكورسات');
                },
                child: Text('عرض الكل', style: TextStyle(color: Colors.blue))),
          ]),
          SizedBox(height: 16),
          _buildCoursesList(coursesProvider),
        ],
      ),
    );
  }

  Widget _buildCoursesList(CoursesProvider provider) {
    if (provider.isLoading) return LoadingShimmer();
    if (provider.hasError) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('حدث خطأ في تحميل البيانات',
                style: TextStyle(fontSize: 16, color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
                onPressed: () => provider.fetchCourses(),
                child: Text('إعادة المحاولة')),
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
            Text('لا توجد كورسات نشطة حالياً',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }
    return Column(
      children: provider.courses
          .take(3)
          .map((course) => CourseCard(course: course))
          .toList(),
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
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 2))
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
          Text(title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Color _getCurriculumColor(String curriculum) {
    switch (curriculum) {
      case 'egyptian':
        return Colors.red;
      case 'saudi':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _getCurriculumName(String curriculum) {
    switch (curriculum) {
      case 'egyptian':
        return 'المنهج المصري';
      case 'saudi':
        return 'المنهج السعودي';
      default:
        return 'المنهج السعودي';
    }
  }

  String _getCurriculumFlag(String curriculum) {
    switch (curriculum) {
      case 'egyptian':
        return '🇪🇬';
      case 'saudi':
        return '🇸🇦';
      default:
        return '🇸🇦';
    }
  }

  String _getGradeName(String grade) {
    switch (grade) {
      case 'الإعدادي':
      case 'المتوسط':
        return 'المرحلة الإعدادية';
      case 'الثانوي':
        return 'المرحلة الثانوية';
      default:
        return grade;
    }
  }
}

// ✅ تبويب الكورسات للطالب - الإصدار المؤكد 100%
class StudentCoursesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final coursesProvider = Provider.of<CoursesProvider>(context);

    // جلب البيانات مرة واحدة عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      coursesProvider.fetchCourses();
    });

    return Scaffold(
      body: coursesProvider.isLoading
          ? Center(child: LoadingShimmer())
          : coursesProvider.courses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'لا توجد كورسات حالياً',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'سجل في كورس لتبدأ رحلة التعلم',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          print('🔍 استكشاف الكورسات');
                        },
                        child: Text('استكشاف الكورسات'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    // هيدر بسيط
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.lightBlueAccent],
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'كورساتي',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${coursesProvider.courses.length} كورس مسجل',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // قائمة الكورسات
                    ...coursesProvider.courses.map((course) => Padding(
                          padding: EdgeInsets.all(16),
                          child: CourseCard(course: course),
                        )),
                  ],
                ),
    );
  }
}

// ✅ تبويب التقدم للطالب
class StudentProgressTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.blue, Colors.lightBlueAccent]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('تقدمك الدراسي',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 8),
                  Text('تابع إنجازاتك في رحلة التعلم',
                      style: TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              ),
            ),
            SizedBox(height: 24),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('الإنجاز العام',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                                value: 0.7,
                                strokeWidth: 12,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue))),
                        Column(children: [
                          Text('70%',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue)),
                          Text('مكتمل',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text('إحصائيات التعلم',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildProgressCard(
                    'ساعات التعلم', '24', Icons.access_time, Colors.blue),
                _buildProgressCard(
                    'الدروس المكتملة', '15', Icons.check_circle, Colors.green),
                _buildProgressCard('المهام المسلمة', '8',
                    Icons.assignment_turned_in, Colors.orange),
                _buildProgressCard(
                    'النقاط', '350', Icons.emoji_events, Colors.purple),
              ],
            ),
            SizedBox(height: 24),
            Text('تقدم الكورسات',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildCourseProgress('الرياضيات', 0.8, Colors.blue),
            _buildCourseProgress('الفيزياء', 0.6, Colors.green),
            _buildCourseProgress('الكيمياء', 0.4, Colors.orange),
            _buildCourseProgress('اللغة العربية', 0.9, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseProgress(String courseName, double progress, Color color) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(courseName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${(progress * 100).toInt()}%',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            ]),
            SizedBox(height: 8),
            LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4)),
          ],
        ),
      ),
    );
  }
}

// ✅ تبويب الملف الشخصي للطالب
class StudentProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MockAuthProvider>(context);
    final userData = authProvider.userData;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue,
              child: userData?['profileImage'] != null
                  ? FutureBuilder<File>(
                      future: Future.value(File(userData!['profileImage'])),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.existsSync()) {
                          return ClipOval(
                            child: Image.file(
                              snapshot.data!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.person,
                                    size: 60, color: Colors.white);
                              },
                            ),
                          );
                        }
                        return Icon(Icons.person,
                            size: 60, color: Colors.white);
                      },
                    )
                  : Icon(Icons.person, size: 60, color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(userData?['name'] ?? 'أحمد محمد',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('طالب', style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 30),
            _buildProfileOption(Icons.person, 'البيانات الشخصية', onTap: () {
              print('👤 البيانات الشخصية');
            }),
            _buildProfileOption(Icons.security, 'الأمان', onTap: () {
              print('🔒 الأمان');
            }),
            _buildProfileOption(Icons.notifications, 'الإشعارات', onTap: () {
              print('🔔 الإشعارات');
            }),
            _buildProfileOption(Icons.help, 'المساعدة', onTap: () {
              print('❓ المساعدة');
            }),
            _buildProfileOption(Icons.info, 'عن التطبيق', onTap: () {
              print('ℹ️ عن التطبيق');
            }),
            _buildProfileOption(
              Icons.logout,
              'تسجيل الخروج',
              isLogout: true,
              onTap: () {
                print('🚪 تسجيل الخروج');
                _showLogoutDialog(context, authProvider);
              },
            ),
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
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2))
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : Colors.blue),
        title: Text(title,
            style: TextStyle(
                color: isLogout ? Colors.red : Colors.black,
                fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, MockAuthProvider authProvider) {
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
              authProvider.signOut();
            },
            child: Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ✅ تبويب الرئيسية للمعلم
class TeacherHomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MockAuthProvider>(context);
    final userData = authProvider.userData;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.greenAccent],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أهلاً بك ${userData?['name'] ?? 'أستاذنا الفاضل'}!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'لوحة تحكم المعلم',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _buildTeacherStatItem(
                            'الطلاب', '47', Icons.people, Colors.blue)),
                    SizedBox(width: 12),
                    Expanded(
                        child: _buildTeacherStatItem('الكورسات', '8',
                            Icons.library_books, Colors.green)),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildTeacherStatItem(
                            'الجلسات', '23', Icons.video_call, Colors.orange)),
                    SizedBox(width: 12),
                    Expanded(
                        child: _buildTeacherStatItem('الإيرادات', '2,450',
                            Icons.attach_money, Colors.purple)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الإجراءات السريعة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _buildTeacherActionItem(
                                'إنشاء كورس', Icons.add_circle, Colors.green,
                                () {
                          print('➕ إنشاء كورس');
                        })),
                        SizedBox(width: 12),
                        Expanded(
                            child: _buildTeacherActionItem(
                                'إدارة الطلاب', Icons.people_alt, Colors.blue,
                                () {
                          print('👥 إدارة الطلاب');
                        })),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTeacherActionItem('إدارة الحجوزات',
                                Icons.calendar_today, Colors.orange, () {
                          print('📅 إدارة الحجوزات');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BookingsScreen()),
                          );
                        })),
                        SizedBox(width: 12),
                        Expanded(
                            child: _buildTeacherActionItem(
                                'التقارير', Icons.analytics, Colors.purple, () {
                          print('📊 التقارير');
                        })),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  print('📅 زر إدارة الحجوزات');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookingsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'إدارة الحجوزات',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الجلسات القادمة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildScheduleItem('رياضيات - أحمد', '10:00 ص', 'جلسة فردية'),
                  _buildScheduleItem('فيزياء - محمد', '02:00 م', 'مراجعة'),
                  _buildScheduleItem('كيمياء - سارة', '04:00 م', 'شرح الدرس'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherStatItem(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherActionItem(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String student, String time, String type) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: Colors.green, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(type, style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text(time,
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ✅ تبويب كورسات المعلم
class TeacherCoursesTab extends StatelessWidget {
  final dynamic subjectService;
  const TeacherCoursesTab({Key? key, required this.subjectService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TeacherCoursesScreen();
  }
}

// ✅ تبويبات المعلم الأخرى
class TeacherStudentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.purple),
            SizedBox(height: 16),
            Text('إدارة الطلاب',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('عرض وإدارة طلابك',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class TeacherProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text('ملف المعلم الشخصي',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('إدارة بياناتك الشخصية',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
