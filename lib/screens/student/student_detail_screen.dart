// lib/screens/student/student_detail_screen.dart
import 'package:flutter/material.dart';
// ⭐ إزالة استيراد report_model.dart واستبداله باستيراد الـ Provider
import '../../providers/student_report_provider.dart';

class StudentDetailScreen extends StatelessWidget {
  // ⭐ تغيير النوع لـ StudentReport من الـ Provider
  final StudentReport student;

  const StudentDetailScreen({Key? key, required this.student})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تقرير ${student.studentName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStudentInfo(),
            const SizedBox(height: 20),
            _buildPerformanceChart(),
            const SizedBox(height: 20),
            _buildRecentTests(),
            const SizedBox(height: 20),
            _buildAttendanceInfo(),
            const SizedBox(height: 20),
            _buildAssignmentsInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue[100],
              child: student.photoUrl.isNotEmpty && student.photoUrl != ''
                  ? ClipOval(
                      child: Image.network(
                        student.photoUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.person, size: 40, color: Colors.blue[800]),
            ),
            const SizedBox(height: 16),
            Text(student.studentName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('المعدل: ${student.averageScore.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            _buildPerformanceIndicator(student.performanceLevel),
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

  Widget _buildPerformanceChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('أداء الطالب',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 50, color: Colors.blue),
                    SizedBox(height: 10),
                    Text('مستوى الأداء: ${student.performanceLevel}'),
                    SizedBox(height: 5),
                    Text('المعدل: ${student.averageScore.toStringAsFixed(1)}%'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTests() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الاختبارات الحديثة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.quiz, color: Colors.blue),
              title: const Text('آخر اختبار'),
              subtitle: Text(
                  '${student.lastTestScore.toStringAsFixed(1)}% - ${_formatDate(student.lastTestDate)}'),
              trailing: Chip(
                label: Text(student.performanceLevel),
                backgroundColor:
                    _getLevelColor(student.performanceLevel).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('معدل الحضور',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.green),
              title: const Text('نسبة الحضور'),
              subtitle: LinearProgressIndicator(
                value: student.attendanceRate / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  student.attendanceRate >= 80
                      ? Colors.green
                      : student.attendanceRate >= 60
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
              trailing: Text('${student.attendanceRate.toStringAsFixed(1)}%'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الواجبات المكتملة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.assignment, color: Colors.purple),
              title: const Text('تقدم الواجبات'),
              subtitle: LinearProgressIndicator(
                value: student.totalAssignments > 0
                    ? student.completedAssignments / student.totalAssignments
                    : 0,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
              trailing: Text(
                  '${student.completedAssignments}/${student.totalAssignments}'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'ممتاز':
        return Colors.green;
      case 'جيد':
        return Colors.blue;
      case 'متوسط':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
