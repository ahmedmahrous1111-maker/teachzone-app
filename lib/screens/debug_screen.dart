import 'package:flutter/material.dart';
import '../services/test_service.dart';

class DebugScreen extends StatelessWidget {
  final TestService _testService = TestService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('شاشة التطوير والاختبار'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.developer_mode, size: 64, color: Colors.orange),
                    SizedBox(height: 16),
                    Text(
                      'أدوات التطوير',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'هذه الشاشة لإضافة بيانات تجريبية للاختبار',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            ElevatedButton.icon(
              onPressed: () async {
                await _testService.addAllTestData();
                _showSnackBar(context, 'تم إضافة البيانات التجريبية بنجاح!');
              },
              icon: Icon(Icons.add_circle),
              label: Text('إضافة بيانات تجريبية'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: () async {
                await _testService.clearTestData();
                _showSnackBar(context, 'تم حذف البيانات التجريبية');
              },
              icon: Icon(Icons.delete),
              label: Text('حذف جميع البيانات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: () async {
                final hasData = await _testService.hasTestData();
                _showSnackBar(context, 
                  hasData ? 'يوجد بيانات تجريبية' : 'لا يوجد بيانات تجريبية'
                );
              },
              icon: Icon(Icons.check_circle),
              label: Text('التحقق من البيانات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            SizedBox(height: 20),
            
            Divider(),
            
            Text(
              'بيانات الاختبار المتوفرة:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('• 8 مواد دراسية مختلفة'),
            Text('• معلم تجريبي (أستاذ أحمد)'),
            Text('• طالب تجريبي (محمد عبدالله)'),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }
}