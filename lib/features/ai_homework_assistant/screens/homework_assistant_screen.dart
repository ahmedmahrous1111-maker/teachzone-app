import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ai_assistant_provider.dart';
import '../widgets/homework_input_widget.dart';

class HomeworkAssistantScreen extends StatelessWidget {
  const HomeworkAssistantScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مساعد الواجبات الذكي',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
        elevation: 0,
      ),
      body: ChangeNotifierProvider(
        create: (context) => AIHomeworkAssistantProvider(),
        child: _HomeworkAssistantContent(),
      ),
    );
  }
}

class _HomeworkAssistantContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AIHomeworkAssistantProvider>(context);

    // ⭐ جديد: طباعة حالة الـ Provider للتdebug
    print('🎯 بناء الواجهة - حالة Provider:');
    print('   🔄 isLoading: ${provider.isLoading}');
    print('   ❌ error: ${provider.error}');
    print('   📊 currentResponse: ${provider.currentResponse}');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[50]!, Colors.white],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 📝 مدخلات الواجب
            HomeworkInputWidget(),

            SizedBox(height: 20),

            // ⏳ مؤشر التحميل
            if (provider.isLoading) ...[
              _buildLoadingWidget(),
              SizedBox(height: 16),
            ],

            // ❌ عرض الخطأ
            if (provider.error.isNotEmpty) _buildErrorWidget(provider),

            // ✅ عرض الحل - تم التعديل هنا
            if (provider.currentResponse != null)
              Expanded(
                  child: _buildSolutionWidget(
                      provider.currentResponse!, provider)),

            // 📖 تعليمات الاستخدام
            if (!provider.isLoading &&
                provider.currentResponse == null &&
                provider.error.isEmpty)
              Expanded(child: _buildInstructionsWidget()),
          ],
        ),
      ),
    );
  }

  // ⭐ جديد: دالة منفصلة لعرض الحل - الإصدار المصحح
  Widget _buildSolutionWidget(
      AIHomeworkResponse response, AIHomeworkAssistantProvider provider) {
    print('🎉 بناء واجهة الحل - البيانات: ${response.solution}');

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'تم حل الواجب بنجاح!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '📚 المادة: ${_getSubjectName(response.subject)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    '✅ الحل: ${response.solution}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '💡 الشرح: ${response.explanation}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // عرض الخطوات
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📝 خطوات الحل:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 12),
                ...response.steps.asMap().entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(fontSize: 14, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          SizedBox(height: 20),

          // زر لحل سؤال جديد - الإصدار المصحح
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                provider.clearCurrentResponse();
              },
              icon: Icon(Icons.add),
              label: Text('حل سؤال جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSubjectName(String subject) {
    final subjectNames = {
      'mathematics': 'الرياضيات',
      'physics': 'الفيزياء',
      'chemistry': 'الكيمياء',
      'biology': 'الأحياء',
      'arabic': 'اللغة العربية',
      'english': 'اللغة الإنجليزية',
      'general': 'عام',
    };
    return subjectNames[subject] ?? subject;
  }

  Widget _buildLoadingWidget() {
    return Column(
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          strokeWidth: 3,
        ),
        SizedBox(height: 16),
        Text(
          'جاري حل الواجب...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'المساعد الذكي يحلل سؤالك ويجهز الحل خطوة بخطوة',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorWidget(AIHomeworkAssistantProvider provider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'حدث خطأ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            provider.error,
            style: TextStyle(color: Colors.red[700]),
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: provider.clearError,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('حاول مرة أخرى'),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsWidget() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 80,
            color: Colors.blue[300],
          ),
          SizedBox(height: 20),
          Text(
            'كيفية استخدام المساعد',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 16),
          _buildInstructionItem(
            icon: Icons.edit,
            title: 'اكتب سؤالك',
            description: 'اكتب سؤال الواجب بشكل واضح ومفصل',
          ),
          _buildInstructionItem(
            icon: Icons.grade,
            title: 'اختر مستوى الصف',
            description: 'حدد المستوى الدراسي المناسب',
          ),
          _buildInstructionItem(
            icon: Icons.psychology,
            title: 'احصل على الحل',
            description: 'المساعد سيقدم الحل مع الخطوات والشرح',
          ),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '💡 نصائح للحصول على أفضل النتائج:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• اكتب السؤال بلغة واضحة\n• استخدم المصطلحات العلمية الصحيحة\n• حدد المادة الدراسية بدقة\n• اذكر جميع المعطيات المطلوبة',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 30),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
