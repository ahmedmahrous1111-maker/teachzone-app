import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/courses_provider.dart';
import '../models/course_model.dart';
import '../widgets/loading_shimmer.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailsScreen({Key? key, required this.courseId})
      : super(key: key);

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  Course? _course;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    try {
      final coursesProvider =
          Provider.of<CoursesProvider>(context, listen: false);
      final course = await coursesProvider.getCourseById(widget.courseId);

      if (mounted) {
        setState(() {
          _course = course;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'فشل في تحميل بيانات الكورس';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorScreen();
    }

    if (_course == null) {
      return _buildNotFoundScreen();
    }

    return _buildCourseDetails(_course!);
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('تحميل...'),
      ),
      body: LoadingShimmer(),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('خطأ'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadCourse,
              child: Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('الكورس غير موجود'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'الكورس غير موجود أو تم حذفه',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('العودة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseDetails(Course course) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getCourseColor(course.subject),
                      _getCourseColor(course.subject).withOpacity(0.7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // صورة الخلفية أو الأيقونة
                    if (course.imageUrl.isNotEmpty)
                      Image.network(
                        course.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    else
                      Center(
                        child: Icon(
                          _getCourseIcon(course.subject),
                          size: 100,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),

                    // تدرج لوني لتحسين قراءة النص
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // معلومات الكورس
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              course.instructor,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  course.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '(${course.reviewCount} تقييم)',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareCourse(course),
              ),
              IconButton(
                icon: Icon(Icons.bookmark_border, color: Colors.white),
                onPressed: () => _bookmarkCourse(course),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // معلومات السعر والإحصائيات
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'السعر',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                course.formattedPrice,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _getCourseColor(course.subject),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => _enrollInCourse(course),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getCourseColor(course.subject),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                            ),
                            child: Text(
                              course.price > 0 ? 'اشترك الآن' : 'ابدأ التعلم',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // وصف الكورس
                  Text(
                    'عن الكورس',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    course.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 20),

                  // الإحصائيات
                  Text(
                    'إحصائيات',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildStatItem('الدروس', '${course.totalLessons}'),
                      _buildStatItem('المدة', course.duration),
                      _buildStatItem('الطلاب', '${course.enrolledStudents}'),
                      _buildStatItem('المستوى', course.level),
                      _buildStatItem('المادة', course.subject),
                      _buildStatItem('التصنيف', course.category),
                    ],
                  ),
                  SizedBox(height: 20),

                  // التقييمات
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'التقييمات',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.amber, size: 20),
                                  SizedBox(width: 4),
                                  Text(
                                    course.rating.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ' (${course.reviewCount} تقييم)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          // هنا يمكن إضافة قائمة التقييمات
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                course.reviewCount == 0
                                    ? 'لا توجد تقييمات بعد'
                                    : 'عرض ${course.reviewCount} تقييم',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // المحتوى (يمكن استبداله ببيانات حقيقية من الكورس)
                  Text(
                    'محتويات الكورس',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildChapterItem('المقدمة', '3 دروس', true),
                  _buildChapterItem('الأساسيات', '6 دروس', false),
                  _buildChapterItem('المستوى المتوسط', '8 دروس', true),
                  _buildChapterItem('المستوى المتقدم', '7 دروس', false),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Container(
      padding: EdgeInsets.all(12),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChapterItem(String title, String lessons, bool isUnlocked) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUnlocked ? Colors.green : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isUnlocked ? Icons.lock_open : Icons.lock,
            color: isUnlocked ? Colors.green : Colors.grey,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  lessons,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  // 🔄 دوال التفاعل الجديدة
  void _shareCourse(Course course) {
    // TODO: تنفيذ مشاركة الكورس
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم نسخ رابط الكورس')),
    );
  }

  void _bookmarkCourse(Course course) {
    // TODO: تنفيذ إضافة/إزالة من المفضلة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إضافة الكورس إلى المفضلة')),
    );
  }

  void _enrollInCourse(Course course) {
    final coursesProvider =
        Provider.of<CoursesProvider>(context, listen: false);

    if (course.price > 0) {
      // TODO: تنفيذ عملية الدفع
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('سيتم تحويلك لصفحة الدفع')),
      );
    } else {
      // تسجيل مجاني
      coursesProvider.enrollStudentInCourse('current_user_id', course.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تسجيلك في الكورس بنجاح')),
      );
    }
  }

  Color _getCourseColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'رياضيات':
        return Colors.blue;
      case 'فيزياء':
        return Colors.green;
      case 'كيمياء':
        return Colors.orange;
      case 'لغة عربية':
        return Colors.purple;
      case 'لغة إنجليزية':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCourseIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'رياضيات':
        return Icons.calculate;
      case 'فيزياء':
        return Icons.science;
      case 'كيمياء':
        return Icons.emoji_objects;
      case 'لغة عربية':
        return Icons.menu_book;
      case 'لغة إنجليزية':
        return Icons.language;
      default:
        return Icons.school;
    }
  }
}
