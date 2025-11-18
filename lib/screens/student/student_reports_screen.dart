// lib/screens/student/student_reports_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_report_provider.dart';
// ⭐ تم إزالة استيراد report_model.dart علشان في تعارض
import 'student_detail_screen.dart';
import 'create_report_screen.dart';

class StudentReportsScreen extends StatefulWidget {
  const StudentReportsScreen({Key? key}) : super(key: key);

  @override
  _StudentReportsScreenState createState() => _StudentReportsScreenState();
}

class _StudentReportsScreenState extends State<StudentReportsScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل بيانات التقارير عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentReportProvider>().loadStudentReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 تقارير الطلاب'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReports,
          ),
        ],
      ),
      body: Consumer<StudentReportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // شريط الإحصائيات
              _buildStatsBar(provider),

              // أدوات البحث والتصفية
              _buildSearchAndFilters(provider),

              // قائمة الطلاب
              Expanded(
                child: _buildStudentsList(provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewReport,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsBar(StudentReportProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('إجمالي الطلاب', provider.totalStudents.toString()),
          _buildStatItem(
              'متوسط الدرجات', '${provider.averageScore.toStringAsFixed(1)}%'),
          _buildStatItem(
              'نسبة النجاح', '${provider.successRate.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12)),
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSearchAndFilters(StudentReportProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث عن طالب...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => provider.searchStudents(value),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (value) => provider.filterByLevel(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('الكل')),
              const PopupMenuItem(value: 'excellent', child: Text('ممتاز')),
              const PopupMenuItem(value: 'good', child: Text('جيد')),
              const PopupMenuItem(value: 'average', child: Text('متوسط')),
            ],
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.filter_alt),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList(StudentReportProvider provider) {
    if (provider.filteredStudents.isEmpty) {
      return const Center(
        child: Text('لا توجد بيانات للعرض'),
      );
    }

    return ListView.builder(
      itemCount: provider.filteredStudents.length,
      itemBuilder: (context, index) {
        final student = provider.filteredStudents[index];
        return _buildStudentCard(student, provider);
      },
    );
  }

  Widget _buildStudentCard(
      StudentReport student, StudentReportProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: student.photoUrl.isNotEmpty && student.photoUrl != ''
              ? ClipOval(
                  child: Image.network(
                    student.photoUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(Icons.person, color: Colors.blue[800]),
        ),
        title: Text(student.studentName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المعدل: ${student.averageScore.toStringAsFixed(1)}%'),
            const SizedBox(height: 4),
            _buildPerformanceIndicator(student.performanceLevel),
            Text('الحضور: ${student.attendanceRate.toStringAsFixed(1)}%'),
            Text(
                'الواجبات: ${student.completedAssignments}/${student.totalAssignments}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () => _viewStudentDetails(student),
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.green),
              onPressed: () => _shareReport(student),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceIndicator(String level) {
    Color color;
    switch (level) {
      case 'ممتاز':
        color = Colors.green;
        break;
      case 'جيد':
        color = Colors.blue;
        break;
      case 'متوسط':
        color = Colors.orange;
        break;
      default:
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        level,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية النتائج'),
        content: const Text('خيارات التصفية المتقدمة...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تم'),
          ),
        ],
      ),
    );
  }

  void _exportReports() {
    // TODO: تنفيذ تصدير التقارير
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري تصدير التقارير...')),
    );
  }

  void _createNewReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateReportScreen(),
      ),
    );
  }

  void _viewStudentDetails(StudentReport student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDetailScreen(student: student),
      ),
    );
  }

  void _shareReport(StudentReport student) {
    // TODO: تنفيذ مشاركة التقرير
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('جاري مشاركة تقرير ${student.studentName}')),
    );
  }
}
