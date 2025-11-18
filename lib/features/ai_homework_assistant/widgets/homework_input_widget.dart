import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ai_assistant_provider.dart';

class HomeworkInputWidget extends StatefulWidget {
  const HomeworkInputWidget({Key? key}) : super(key: key);

  @override
  _HomeworkInputWidgetState createState() => _HomeworkInputWidgetState();
}

class _HomeworkInputWidgetState extends State<HomeworkInputWidget> {
  final _questionController = TextEditingController();
  String _selectedGrade = 'grade_10';

  final Map<String, String> gradeLevels = {
    'grade_1': 'الصف الأول',
    'grade_2': 'الصف الثاني',
    'grade_3': 'الصف الثالث',
    'grade_4': 'الصف الرابع',
    'grade_5': 'الصف الخامس',
    'grade_6': 'الصف السادس',
    'grade_7': 'الصف السابع',
    'grade_8': 'الصف الثامن',
    'grade_9': 'الصف التاسع',
    'grade_10': 'الصف العاشر',
    'grade_11': 'الصف الحادي عشر',
    'grade_12': 'الصف الثاني عشر',
    'university': 'الجامعة',
  };

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AIHomeworkAssistantProvider>(context);

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مساعد الواجبات الذكي',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 16),

            // 📝 حقل إدخال السؤال
            TextField(
              controller: _questionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'اكتب سؤال الواجب هنا',
                hintText: 'مثال: أحل المعادلة س + ٥ = ١٠',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            SizedBox(height: 16),

            // 🎓 اختيار مستوى الصف
            DropdownButtonFormField<String>(
              value: _selectedGrade,
              decoration: InputDecoration(
                labelText: 'مستوى الصف',
                border: OutlineInputBorder(),
              ),
              items: gradeLevels.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGrade = value!;
                });
              },
            ),
            SizedBox(height: 20),

            // 🚀 زر حل الواجب
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () {
                        if (_questionController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('يرجى كتابة سؤال الواجب'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        provider.solveHomework(
                          question: _questionController.text.trim(),
                          gradeLevel: _selectedGrade,
                        );
                      },
                icon: Icon(Icons.auto_awesome),
                label: Text(
                  provider.isLoading ? 'جاري الحل...' : 'حل الواجب',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}
