import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/teacher_report_provider.dart';
import '../../models/analytics_model.dart';
import '../../models/teacher_report_model.dart';

class TeacherReportsScreen extends StatefulWidget {
  @override
  _TeacherReportsScreenState createState() => _TeacherReportsScreenState();
}

class _TeacherReportsScreenState extends State<TeacherReportsScreen> {
  @override
  void initState() {
    super.initState();
    // ⭐ الحل: تأجيل التحميل حتى انتهاء بناء الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final provider = Provider.of<TeacherReportProvider>(context, listen: false);

    // ⭐ التأكد من عدم التحميل المزدوج
    if (provider.teacherAnalytics.totalSessions == 0 && !provider.isLoading) {
      provider.loadTeacherAnalytics('teacher-123');
      provider.loadTeacherReports('teacher-123');
    }
  }

  // 🧪 دالة اختبار TeacherReportProvider - أضف هذا
  void _testTeacherReportProvider() async {
    final provider = Provider.of<TeacherReportProvider>(context, listen: false);

    print('\n🎯 ====================================');
    print('🧪 بدء اختبار TeacherReportProvider مع Firebase');
    print('🎯 ====================================\n');

    try {
      // 1. اختبار تحميل الإحصائيات
      print('1. 🔄 جاري تحميل إحصائيات المعلم...');
      await provider.loadTeacherAnalytics('test_teacher_123');
      print('   ✅ تم تحميل الإحصائيات بنجاح');
      print('   📊 إجمالي الجلسات: ${provider.teacherAnalytics.totalSessions}');
      print('   💰 الأرباح: ${provider.teacherAnalytics.totalEarnings}');
      print('   ⭐ التقييم: ${provider.teacherAnalytics.averageRating}');

      // 2. اختبار إنشاء تقرير
      print('\n2. 📝 جاري إنشاء تقرير جديد...');
      final report = await provider.generateTeacherReport(
        teacherId: 'test_teacher_123',
        teacherName: 'أحمد محمد',
        studentName: 'محمد علي',
        courseName: 'رياضيات متقدمة',
        subject: 'رياضيات',
        reportContent: 'الطالب أظهر تقدمًا ممتازًا في مفاهيم الجبر.',
        rating: 4.8,
      );
      print('   ✅ تم إنشاء التقرير بنجاح');
      print('   📄 ID التقرير: ${report.id}');
      print('   👨‍🏫 المعلم: ${report.teacherName}');
      print('   👨‍🎓 الطالب: ${report.studentName}');

      // 3. اختبار تحميل جميع التقارير
      print('\n3. 📂 جاري تحميل جميع تقارير المعلم...');
      await provider.loadTeacherReports('test_teacher_123');
      print('   ✅ تم تحميل ${provider.teacherReports.length} تقرير');

      // عرض التفاصيل
      for (int i = 0; i < provider.teacherReports.length; i++) {
        final r = provider.teacherReports[i];
        print('   📋 التقرير ${i + 1}: ${r.courseName} - ${r.rating} ⭐');
      }

      // 4. اختبار الـ Stream
      print('\n4. 🔥 جاري اختبار الـ Stream (Real-time updates)...');
      final stream = provider.getTeacherReportsStream('test_teacher_123');
      final subscription = stream.listen((reports) {
        print('   📡 Stream حدث - عدد التقارير: ${reports.length}');
      });

      // انتظار قليل لرؤية الـ Stream يعمل
      await Future.delayed(Duration(seconds: 3));
      subscription.cancel();

      print('\n🎉 ====================================');
      print('✅ كل اختبارات TeacherReportProvider تمت بنجاح!');
      print('🔥 Firebase connection: ACTIVE');
      print('📊 Analytics: WORKING');
      print('📝 Reports: WORKING');
      print('🔗 Stream: WORKING');
      print('🎉 ====================================\n');

      // تحديث الواجهة
      setState(() {});

      // عرض رسالة للمستخدم
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('✅ تم اختبار TeacherReportProvider بنجاح - انظر الكونسول'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      print('\n❌ ====================================');
      print('🚨 فشل في اختبار TeacherReportProvider: $error');
      print('❌ ====================================\n');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ فشل في الاختبار: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🧪 زر الاختبار - أضف هذا
  Widget _buildTestButton() {
    return Card(
      margin: EdgeInsets.all(16),
      color: Colors.orange[50],
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '🔧 اختبار TeacherReportProvider',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.orange[700]),
            ),
            SizedBox(height: 10),
            Text(
              'سيتم اختبار الاتصال بـ Firebase وإنشاء تقارير اختبارية',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _testTeacherReportProvider,
              child: Text('بدء الاختبار'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تقارير الأداء'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          // 🧪 إضافة زر الاختبار في AppBar - اختياري
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: _testTeacherReportProvider,
            tooltip: 'اختبار النظام',
          ),
        ],
      ),
      body: Consumer<TeacherReportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading &&
              provider.teacherAnalytics.totalSessions == 0) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🧪 إضافة زر الاختبار في بداية المحتوى
                _buildTestButton(),
                SizedBox(height: 16),

                // 📊 بطاقة الإحصائيات الرئيسية
                _buildStatsCard(provider.teacherAnalytics),
                SizedBox(height: 20),

                // 📈 الرسوم البيانية
                _buildChartsSection(provider.teacherAnalytics),
                SizedBox(height: 20),

                // 📋 التقارير المُنشأة
                _buildReportsList(provider.teacherReports),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 🧪 زر اختبار إضافي بجانب FAB
          FloatingActionButton(
            onPressed: _testTeacherReportProvider,
            child: Icon(Icons.bug_report),
            backgroundColor: Colors.orange,
            mini: true,
            heroTag: "testButton",
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => _generateNewReport(context),
            child: Icon(Icons.analytics),
            backgroundColor: Colors.blue[700],
            heroTag: "mainButton",
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(AnalyticsModel analytics) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'نظرة عامة على الأداء',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('الجلسات', '${analytics.totalSessions}'),
                _buildStatItem('مكتملة', '${analytics.completedSessions}'),
                _buildStatItem(
                    'الإيرادات', '${analytics.totalEarnings.toInt()} ريال'),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('الطلاب', '${analytics.totalStudents}'),
                _buildStatItem('نشطون', '${analytics.activeStudents}'),
                _buildStatItem('التقييم', '${analytics.averageRating}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700]),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildChartsSection(AnalyticsModel analytics) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الرسوم البيانية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // الجلسات حسب اليوم
            _buildChartItem(
              'الجلسات حسب اليوم',
              analytics.sessionsByDay,
            ),
            SizedBox(height: 16),

            // الجلسات حسب المادة
            _buildChartItem(
              'الجلسات حسب المادة',
              analytics.sessionsBySubject,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartItem(String title, Map<String, int> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...data.entries.map((entry) => _buildChartBar(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildChartBar(String label, int value) {
    final maxValue = 10; // لأغراض العرض
    final percentage = value / maxValue;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label),
          ),
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Container(
                  height: 20,
                  width: MediaQuery.of(context).size.width * 0.4 * percentage,
                  decoration: BoxDecoration(
                    color: Colors.blue[500],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Text('$value'),
        ],
      ),
    );
  }

  Widget _buildReportsList(List<TeacherReport> reports) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التقارير المُنشأة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...reports.map((report) => _buildReportItem(report)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(TeacherReport report) {
    return ListTile(
      leading: Icon(Icons.assessment, color: Colors.blue[700]),
      title: Text(report.courseName),
      subtitle: Text('${report.studentName} - ${report.subject}'),
      trailing: Text(_formatDate(report.createdAt)),
      onTap: () => _viewReportDetails(report),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewReportDetails(TeacherReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تقرير ${report.courseName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('المعلم: ${report.teacherName}'),
              Text('الطالب: ${report.studentName}'),
              Text('المادة: ${report.subject}'),
              SizedBox(height: 16),
              Text('التقييم: ${report.rating} ⭐'),
              SizedBox(height: 16),
              Text(
                'محتوى التقرير:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(report.reportContent),
              SizedBox(height: 16),
              Text('التاريخ: ${_formatDate(report.createdAt)}'),
            ],
          ),
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

  String _getPeriodText(String period) {
    switch (period) {
      case 'daily':
        return 'يومي';
      case 'weekly':
        return 'أسبوعي';
      case 'monthly':
        return 'شهري';
      default:
        return 'مخصص';
    }
  }

  void _generateNewReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إنشاء تقرير جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('تقرير يومي'),
              onTap: () => _generateReport('daily', context),
            ),
            ListTile(
              title: Text('تقرير أسبوعي'),
              onTap: () => _generateReport('weekly', context),
            ),
            ListTile(
              title: Text('تقرير شهري'),
              onTap: () => _generateReport('monthly', context),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ التصحيح: استخدام الـ parameters الصحيحة
  void _generateReport(String period, BuildContext context) async {
    final provider = Provider.of<TeacherReportProvider>(context, listen: false);

    try {
      final report = await provider.generateTeacherReport(
        teacherId: 'teacher-123',
        teacherName: 'أحمد محمد',
        studentName: 'محمد علي',
        courseName: '${_getPeriodText(period)} - رياضيات',
        subject: 'رياضيات',
        reportContent:
            'تقرير ${_getPeriodText(period)} يوضح تقدم الطالب في فهم المفاهيم الرياضية.',
        rating: 4.5,
      );

      Navigator.pop(context); // إغلاق الدايلوج
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم إنشاء التقرير: ${report.courseName}'),
          backgroundColor: Colors.green,
        ),
      );

      // تحديث الشاشة لعرض التقرير الجديد
      setState(() {});
    } catch (error) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ فشل في إنشاء التقرير: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
