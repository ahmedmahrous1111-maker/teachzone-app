import 'package:flutter/material.dart';
import 'home_screen.dart';

class CurriculumSelectionScreen extends StatefulWidget {
  final String userType;

  const CurriculumSelectionScreen({Key? key, required this.userType}) : super(key: key);

  @override
  _CurriculumSelectionScreenState createState() => _CurriculumSelectionScreenState();
}

class _CurriculumSelectionScreenState extends State<CurriculumSelectionScreen> {
  String? _selectedCurriculum;
  String? _selectedGrade;

  final List<Curriculum> _curriculums = [
    Curriculum(
      id: 'egyptian',
      name: 'المنهج المصري',
      description: 'المنهج التعليمي المصري المعتمد من وزارة التربية والتعليم',
      flag: '🇪🇬',
      color: Colors.red,
      grades: ['الإعدادي', 'الثانوي'],
    ),
    Curriculum(
      id: 'saudi',
      name: 'المنهج السعودي',
      description: 'المنهج التعليمي السعودي المعتمد من وزارة التعليم',
      flag: '🇸🇦',
      color: Colors.green,
      grades: ['المتوسط', 'الثانوي'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // الجزء العلوي الثابت
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // زر الرجوع والعنوان
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.blue),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'اختر المنهج التعليمي',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'اختر المنهج والمرحلة التعليمية',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // ملاحظة
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Text(
                '💡 التطبيق يعمل حالياً على المنهجين المصري والسعودي فقط',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // المحتوى القابل للتمرير
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اختيار المنهج
                    Text(
                      'اختر الدولة والمنهج',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 16),

                    // قائمة المناهج
                    ..._curriculums.map((curriculum) => 
                      _buildCurriculumCard(curriculum)
                    ).toList(),

                    SizedBox(height: 24),

                    // اختيار المرحلة التعليمية
                    if (_selectedCurriculum != null) ...[
                      Text(
                        'اختر المرحلة التعليمية',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 16),

                      // مراحل المنهج المصري
                      if (_selectedCurriculum == 'egyptian') 
                        Column(
                          children: [
                            _buildGradeCard('الإعدادي', 'المرحلة الإعدادية', Icons.school, Colors.blue),
                            SizedBox(height: 12),
                            _buildGradeCard('الثانوي', 'المرحلة الثانوية', Icons.school, Colors.green),
                          ],
                        )

                      // مراحل المنهج السعودي
                      else if (_selectedCurriculum == 'saudi') 
                        Column(
                          children: [
                            _buildGradeCard('المتوسط', 'المرحلة المتوسطة', Icons.school, Colors.blue),
                            SizedBox(height: 12),
                            _buildGradeCard('الثانوي', 'المرحلة الثانوية', Icons.school, Colors.green),
                          ],
                        ),

                      SizedBox(height: 30),
                    ],

                    // مساحة إضافية في الأسفل
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // زر المتابعة (ثابت في الأسفل) - التصحيح هنا
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!)), // تم التصحيح
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedCurriculum != null && _selectedGrade != null ? () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(
                          userType: widget.userType,
                          selectedCurriculum: _selectedCurriculum!,
                          selectedGrade: _selectedGrade!,
                        ),
                      ),
                      (route) => false,
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedCurriculum != null && _selectedGrade != null ? 
                      _getCurriculumColor(_selectedCurriculum!) : Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'متابعة إلى المنصة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurriculumCard(Curriculum curriculum) {
    bool isSelected = _selectedCurriculum == curriculum.id;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? curriculum.color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? curriculum.color : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedCurriculum = curriculum.id;
              _selectedGrade = null;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                // العلم
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: curriculum.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: curriculum.color),
                  ),
                  child: Center(
                    child: Text(
                      curriculum.flag,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                
                SizedBox(width: 12),
                
                // المعلومات
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        curriculum.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: curriculum.color,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        curriculum.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'المراحل: ${curriculum.grades.join('، ')}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // علامة الاختيار
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected ? curriculum.color : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? curriculum.color : Colors.grey,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradeCard(String grade, String label, IconData icon, Color color) {
    bool isSelected = _selectedGrade == grade;
    
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedGrade = grade;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? color : Colors.grey, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.grey[700],
                    ),
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: isSelected ? color : Colors.grey,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
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
}

class Curriculum {
  final String id;
  final String name;
  final String description;
  final String flag;
  final Color color;
  final List<String> grades;

  Curriculum({
    required this.id,
    required this.name,
    required this.description,
    required this.flag,
    required this.color,
    required this.grades,
  });
}