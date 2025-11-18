import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/firebase_auth_provider.dart';

class KYCOnboardingScreen extends StatefulWidget {
  @override
  _KYCOnboardingScreenState createState() => _KYCOnboardingScreenState();
}

class _KYCOnboardingScreenState extends State<KYCOnboardingScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _documents = [];
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _specialtiesController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  final List<String> _availableSpecialties = [
    'رياضيات',
    'فيزياء',
    'كيمياء',
    'أحياء',
    'لغة عربية',
    'لغة إنجليزية',
    'تاريخ',
    'جغرافيا',
    'تربية إسلامية',
    'حاسب آلي'
  ];
  final List<String> _selectedSpecialties = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إكمال بياناتك للتحقق'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: _isSubmitting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('جاري تقديم طلب التحقق...'),
                ],
              ),
            )
          : Stepper(
              currentStep: _currentStep,
              onStepContinue: _continueToNextStep,
              onStepCancel: _goToPreviousStep,
              onStepTapped: (step) => setState(() => _currentStep = step),
              controlsBuilder: (context, details) {
                return Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        ElevatedButton(
                          onPressed: details.onStepCancel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: Text('السابق'),
                        ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: details.onStepContinue,
                        child:
                            Text(_currentStep == 4 ? 'تقديم الطلب' : 'التالي'),
                      ),
                    ],
                  ),
                );
              },
              steps: [
                _buildWelcomeStep(),
                _buildPersonalInfoStep(),
                _buildQualificationsStep(),
                _buildDocumentsStep(),
                _buildReviewStep(),
              ],
            ),
    );
  }

  Step _buildWelcomeStep() {
    return Step(
      title: Text('مرحباً!'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'لبدء تقديم الحصص، نحتاج للتحقق من هويتك ومؤهلاتك',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            'المستندات المطلوبة:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('• صورة الهوية الوطنية'),
          Text('• الشهادة الجامعية أو المؤهل العلمي'),
          Text('• السيرة الذاتية'),
          Text('• صورة شخصية واضحة'),
        ],
      ),
    );
  }

  Step _buildPersonalInfoStep() {
    return Step(
      title: Text('المعلومات الشخصية'),
      content: Column(
        children: [
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: 'الاسم الكامل (كما في الهوية)',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال الاسم الكامل';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _idNumberController,
            decoration: InputDecoration(
              labelText: 'رقم الهوية الوطنية',
              prefixIcon: Icon(Icons.credit_card),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال رقم الهوية';
              }
              if (value.length != 10) {
                return 'رقم الهوية يجب أن يكون 10 أرقام';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Step _buildQualificationsStep() {
    return Step(
      title: Text('المؤهلات والتخصص'),
      content: Column(
        children: [
          TextFormField(
            controller: _experienceController,
            decoration: InputDecoration(
              labelText: 'سنوات الخبرة في التدريس',
              prefixIcon: Icon(Icons.work),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال سنوات الخبرة';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          Text('التخصصات:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSpecialties.map((specialty) {
              final isSelected = _selectedSpecialties.contains(specialty);
              return FilterChip(
                label: Text(specialty),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSpecialties.add(specialty);
                    } else {
                      _selectedSpecialties.remove(specialty);
                    }
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue,
              );
            }).toList(),
          ),
          if (_selectedSpecialties.isEmpty)
            Text(
              'يرجى اختيار تخصص واحد على الأقل',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Step _buildDocumentsStep() {
    return Step(
      title: Text('رفع المستندات'),
      content: Column(
        children: [
          _buildDocumentItem('صورة الهوية الوطنية', Icons.credit_card, 'id'),
          _buildDocumentItem('الشهادة الجامعية', Icons.school, 'degree'),
          _buildDocumentItem('السيرة الذاتية', Icons.description, 'cv'),
          _buildDocumentItem('صورة شخصية', Icons.camera_alt, 'personal'),
          SizedBox(height: 16),
          Text(
            'ملاحظة: يمكنك رفع المستندات لاحقاً من خلال الملف الشخصي',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Step _buildReviewStep() {
    return Step(
      title: Text('مراجعة المعلومات'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الاسم: ${_fullNameController.text}'),
          Text('رقم الهوية: ${_idNumberController.text}'),
          Text('سنوات الخبرة: ${_experienceController.text}'),
          Text('التخصصات: ${_selectedSpecialties.join(", ")}'),
          SizedBox(height: 20),
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(height: 8),
                  Text(
                    'سيتم مراجعة طلبك خلال 24-48 ساعة',
                    style: TextStyle(color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String title, IconData icon, String type) {
    final hasDocument = _documents.any((doc) => doc['type'] == type);

    return Card(
      child: ListTile(
        leading: Icon(icon, color: hasDocument ? Colors.green : Colors.grey),
        title: Text(title),
        subtitle: hasDocument ? Text('تم الرفع') : Text('لم يتم الرفع بعد'),
        trailing: hasDocument
            ? Icon(Icons.check_circle, color: Colors.green)
            : Icon(Icons.upload),
        onTap: () => _uploadDocument(type, title),
      ),
    );
  }

  void _uploadDocument(String type, String title) async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('التقاط صورة'),
            onTap: () async {
              Navigator.pop(context);
              final XFile? image =
                  await picker.pickImage(source: ImageSource.camera);
              if (image != null) {
                _handleDocumentUpload(type, title, image);
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('اختيار من المعرض'),
            onTap: () async {
              Navigator.pop(context);
              final XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                _handleDocumentUpload(type, title, image);
              }
            },
          ),
        ],
      ),
    );
  }

  void _handleDocumentUpload(String type, String title, XFile file) {
    setState(() {
      _documents.removeWhere((doc) => doc['type'] == type);
      _documents.add({
        'type': type,
        'title': title,
        'file': file,
        'uploadedAt': DateTime.now(),
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم رفع $title بنجاح')),
    );
  }

  void _continueToNextStep() {
    if (_currentStep == 0) {
      setState(() => _currentStep++);
    } else if (_currentStep == 1) {
      if (_fullNameController.text.isEmpty ||
          _idNumberController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('يرجى إدخال جميع المعلومات الشخصية')),
        );
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 2) {
      if (_experienceController.text.isEmpty || _selectedSpecialties.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('يرجى إدخال سنوات الخبرة واختيار تخصص واحد على الأقل')),
        );
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 3) {
      setState(() => _currentStep++);
    } else if (_currentStep == 4) {
      _submitKYC();
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submitKYC() async {
    if (!mounted) return;

    setState(() => _isSubmitting = true);

    try {
      final authProvider =
          Provider.of<FirebaseAuthProvider>(context, listen: false);

      // إنشاء ملفات وهمية للاختبار (مؤقت)
      final XFile mockFile = XFile(''); // ملف وهمي

      bool success = await authProvider.submitKYCRequest(
        fullName: _fullNameController.text,
        idNumber: _idNumberController.text,
        idImage: mockFile,
        degreeImage: mockFile,
        cvFile: mockFile,
        personalPhoto: mockFile,
        specialties: _selectedSpecialties,
        yearsOfExperience: int.parse(_experienceController.text),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تقديم طلب التحقق بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );

        Future.microtask(() {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'فشل في تقديم الطلب'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _idNumberController.dispose();
    _specialtiesController.dispose();
    _experienceController.dispose();
    super.dispose();
  }
}
