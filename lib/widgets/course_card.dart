import 'package:flutter/material.dart';
import '../models/course_model.dart';
import 'package:provider/provider.dart';
import '../providers/courses_provider.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final bool showTeacherOptions;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const CourseCard({
    Key? key,
    required this.course,
    this.showTeacherOptions = false,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTeacher = showTeacherOptions;

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _onCourseTap(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس البطاقة
              _buildCardHeader(context),
              SizedBox(height: 12),

              // معلومات الكورس
              _buildCourseInfo(),
              SizedBox(height: 12),

              // التقدم والتقييم
              _buildProgressAndRating(),
              SizedBox(height: 12),

              // ⭐ جديد: زر الدفع للطلاب
              if (!isTeacher && course.price > 0) _buildPaymentButton(context),

              // خيارات المعلم (إذا كان معلم)
              if (isTeacher) _buildTeacherOptions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    return Row(
      children: [
        // صورة الكورس
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _getCourseColor(course.subject),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              _getCourseIcon(course.subject),
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        SizedBox(width: 12),

        // معلومات أساسية
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                course.instructor,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // سعر الكورس أو حالة التسجيل
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getCourseColor(course.subject).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            course.price > 0
                ? '${course.price} ${course.getCurrencySymbol()}'
                : 'مجاني',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _getCourseColor(course.subject),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          course.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8),

        // التخصص والمستوى
        Row(
          children: [
            _buildInfoChip(course.subject, _getCourseColor(course.subject)),
            SizedBox(width: 8),
            _buildInfoChip(course.level, Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressAndRating() {
    return Row(
      children: [
        // التقدم
        if (course.progress > 0) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التقدم',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: course.progress / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                SizedBox(height: 2),
                Text(
                  '${course.progress.toInt()}% مكتمل',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
        ],

        // التقييم
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'التقييم',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  SizedBox(width: 4),
                  Text(
                    course.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '(${course.reviewCount})',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ⭐ جديد: زر الدفع للطلاب
  Widget _buildPaymentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _navigateToPayment(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 20),
            SizedBox(width: 8),
            Text(
              'اشترك الآن - ${course.price} ${course.getCurrencySymbol()}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ خيارات المعلم المحدثة
  Widget _buildTeacherOptions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (onEdit != null)
            _buildTeacherAction(
              Icons.edit,
              'تعديل',
              Colors.blue,
              onEdit!,
            ),
          _buildTeacherAction(
            Icons.people,
            'الطلاب',
            Colors.green,
            () => _manageStudents(context),
          ),
          _buildTeacherAction(
            Icons.analytics,
            'التقارير',
            Colors.orange,
            () => _viewAnalytics(context),
          ),
          if (onDelete != null)
            _buildTeacherAction(
              Icons.delete,
              'حذف',
              Colors.red,
              onDelete!,
            ),
        ],
      ),
    );
  }

  Widget _buildTeacherAction(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
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

  void _onCourseTap(BuildContext context) {
    // ⭐ تحديث: عند النقر على الكورس، الانتقال للدفع إذا كان مدفوع
    if (!showTeacherOptions && course.price > 0) {
      _navigateToPayment(context);
    } else {
      // TODO: الانتقال لشاشة تفاصيل الكورس للمعلم أو الكورسات المجانية
      print('تم النقر على الكورس: ${course.title}');
    }
  }

  // ⭐ جديد: الانتقال لشاشة الدفع
  void _navigateToPayment(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/payment-method',
      arguments: {
        'course': course,
        'teacherId': course.teacherId,
        'teacherName': course.instructor,
      },
    );
  }

  // ✅ دوال معالجة خيارات المعلم
  void _editCourse(BuildContext context) {
    if (onEdit != null) {
      onEdit!();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('تعديل الكورس'),
          content: Text('هل تريد تعديل كورس "${course.title}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSuccessMessage(context, 'تم فتح صفحة تعديل الكورس');
              },
              child: Text('تعديل'),
            ),
          ],
        ),
      );
    }
  }

  void _manageStudents(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إدارة الطلاب'),
        content: Text('إدارة الطلاب المسجلين في كورس "${course.title}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage(context, 'تم فتح صفحة إدارة الطلاب');
            },
            child: Text('عرض الطلاب'),
          ),
        ],
      ),
    );
  }

  void _viewAnalytics(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تقارير الكورس'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnalyticsItem(
                'الطلاب المسجلين', '${course.enrolledStudents} طالب'),
            _buildAnalyticsItem('معدل الإكمال', '${course.progress}%'),
            _buildAnalyticsItem(
                'التقييم العام', course.rating.toStringAsFixed(1)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsItem(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }

  void _deleteCourse(BuildContext context) {
    if (onDelete != null) {
      onDelete!();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('حذف الكورس'),
          content: Text(
              'هل أنت متأكد من حذف كورس "${course.title}"؟ لا يمكن التراجع عن هذا الإجراء.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmDeleteCourse(context);
              },
              child: Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }

  void _confirmDeleteCourse(BuildContext context) {
    final coursesProvider =
        Provider.of<CoursesProvider>(context, listen: false);

    // TODO: تنفيذ عملية الحذف الفعلية
    coursesProvider.deleteCourse(course.id);

    _showSuccessMessage(context, 'تم حذف الكورس بنجاح');
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
