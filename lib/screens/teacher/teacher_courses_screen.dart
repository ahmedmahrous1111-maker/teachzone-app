import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/courses_provider.dart';
import '../../providers/firebase_auth_provider.dart';
import '../../models/course_model.dart';
import '../../widgets/course_card.dart';
import '../../widgets/loading_shimmer.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({Key? key}) : super(key: key);

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  @override
  void initState() {
    super.initState();
    _loadTeacherCourses();
  }

  void _loadTeacherCourses() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ التحقق من mounted قبل أي عملية
      if (!mounted) return;

      final authProvider =
          Provider.of<FirebaseAuthProvider>(context, listen: false);
      final coursesProvider =
          Provider.of<CoursesProvider>(context, listen: false);

      if (authProvider.currentUser != null) {
        coursesProvider.loadTeacherCourses(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<FirebaseAuthProvider>(context);
    final coursesProvider = Provider.of<CoursesProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('كورساتي'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.greenAccent],
                  ),
                ),
              ),
            ),
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: () => _showCreateCourseDialog(
                    context, authProvider.currentUserData!),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // إحصائيات الكورسات (محدث)
                  _buildCoursesStats(coursesProvider.teacherCourses),
                  SizedBox(height: 20),

                  // قائمة الكورسات
                  Consumer<CoursesProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) return LoadingShimmer();
                      if (provider.hasError) {
                        return _buildErrorWidget(provider);
                      }
                      if (provider.teacherCourses.isEmpty) {
                        return _buildEmptyCourses(context);
                      }
                      return _buildCoursesList(provider);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showCreateCourseDialog(context, authProvider.currentUserData!),
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ✅ تحديث الإحصائيات لتعتمد على البيانات الحقيقية
  Widget _buildCoursesStats(List<Course> courses) {
    final totalStudents =
        courses.fold(0, (sum, course) => sum + course.enrolledStudents);
    final averageRating = courses.isEmpty
        ? 0
        : courses.map((c) => c.rating).reduce((a, b) => a + b) / courses.length;

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('${courses.length}', 'كورسات نشطة',
              Icons.library_books, Colors.green),
          _buildStatItem(
              '$totalStudents', 'طالب مسجل', Icons.people, Colors.blue),
          _buildStatItem(averageRating.toStringAsFixed(1), 'تقييم', Icons.star,
              Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
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
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(CoursesProvider provider) {
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
            onPressed: _loadTeacherCourses,
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCourses(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'لا توجد كورسات حالياً',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'ابدأ بإنشاء أول كورس لك',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // ✅ التحقق من mounted
              if (!mounted) return;

              final authProvider =
                  Provider.of<FirebaseAuthProvider>(context, listen: false);
              _showCreateCourseDialog(context, authProvider.currentUserData!);
            },
            child: Text('إنشاء أول كورس'),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList(CoursesProvider provider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'كورساتي',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '${provider.teacherCourses.length} كورس',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        SizedBox(height: 16),
        Column(
          children: provider.teacherCourses
              .map((course) => Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: CourseCard(
                      course: course,
                      showTeacherOptions: true,
                      onDelete: () => _deleteCourse(context, course.id),
                      onEdit: () => _editCourse(context, course),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ✅ تحديث دالة إنشاء الكورس لتعمل مع Firebase
  void _showCreateCourseDialog(
      BuildContext context, Map<String, dynamic> user) {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _priceController = TextEditingController();
    final _subjectController = TextEditingController();
    final _levelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إنشاء كورس جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'اسم الكورس',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'وصف الكورس',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 12),
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'المادة',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: 'متوسط',
                decoration: InputDecoration(
                  labelText: 'المستوى',
                  border: OutlineInputBorder(),
                ),
                items: ['مبتدئ', 'متوسط', 'متقدم']
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) => _levelController.text = value!,
              ),
              SizedBox(height: 12),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'السعر',
                  border: OutlineInputBorder(),
                  prefixText: '₺ ',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.isEmpty ||
                  _descriptionController.text.isEmpty) {
                // ✅ التحقق من mounted قبل showSnackBar
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
                );
                return;
              }

              Navigator.pop(context);
              await _createNewCourse(
                context,
                user,
                _titleController.text,
                _descriptionController.text,
                _subjectController.text,
                _levelController.text.isEmpty ? 'متوسط' : _levelController.text,
                double.tryParse(_priceController.text) ?? 0,
              );
            },
            child: Text('إنشاء الكورس'),
          ),
        ],
      ),
    );
  }

  // ✅ دالة إنشاء كورس جديدة في Firebase
  Future<void> _createNewCourse(
    BuildContext context,
    Map<String, dynamic> user,
    String title,
    String description,
    String subject,
    String level,
    double price,
  ) async {
    try {
      final coursesProvider =
          Provider.of<CoursesProvider>(context, listen: false);

      final newCourse = Course(
        id: '', // ⭐ سيتم تعبئته تلقائياً من Firebase
        title: title,
        description: description,
        instructor: user['displayName'] ?? user['name'] ?? 'معلم',
        teacherId: user['uid'] ?? '',
        subject: subject.isNotEmpty ? subject : 'عام',
        level: level,
        price: price,
        rating: 0,
        reviewCount: 0,
        enrolledStudents: 0,
        progress: 0,
        imageUrl: '',
        isPublished: true,
        createdAt: DateTime.now(),
        totalLessons: 0,
        completedLessons: 0,
        duration: '0 ساعة',
        category: 'تعليمي',
      );

      final courseId = await coursesProvider.createCourse(newCourse);

      // ✅ التحقق من mounted قبل showSnackBar
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إنشاء الكورس "$title" بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );

      print('✅ الكورس الجديد تم إنشاؤه بالمعرف: $courseId');
    } catch (error) {
      // ✅ التحقق من mounted قبل showSnackBar
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في إنشاء الكورس: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ دوال جديدة لإدارة الكورسات
  void _deleteCourse(BuildContext context, String courseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف الكورس'),
        content: Text(
            'هل أنت متأكد من حذف هذا الكورس؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final coursesProvider =
                    Provider.of<CoursesProvider>(context, listen: false);
                await coursesProvider.deleteCourse(courseId);

                // ✅ التحقق من mounted قبل showSnackBar
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف الكورس بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (error) {
                // ✅ التحقق من mounted قبل showSnackBar
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('فشل في حذف الكورس: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _editCourse(BuildContext context, Course course) {
    // TODO: تنفيذ شاشة تعديل الكورس

    // ✅ التحقق من mounted قبل showSnackBar
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('سيتم فتح صفحة تعديل الكورس: ${course.title}')),
    );
  }
}
