import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/mock_auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  String _userType = 'student';
  String? _selectedCurriculum;
  String? _selectedGrade;
  XFile? _profileImage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<Map<String, String>> _curriculums = [
    {'id': 'saudi', 'name': 'المنهج السعودي 🇸🇦', 'flag': '🇸🇦'},
    {'id': 'egyptian', 'name': 'المنهج المصري 🇪🇬', 'flag': '🇪🇬'},
  ];

  final Map<String, List<String>> _grades = {
    'saudi': ['أول ثانوي', 'ثاني ثانوي', 'ثالث ثانوي'],
    'egyptian': ['أول إعدادي', 'ثاني إعدادي', 'ثالث إعدادي', 'أول ثانوي', 'ثاني ثانوي', 'ثالث ثانوي'],
  };

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختر مصدر الصورة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.blue),
              title: Text('التقاط صورة جديدة'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.green),
              title: Text('اختيار من المعرض'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      PermissionStatus status = await Permission.camera.request();
      
      if (status.isGranted) {
        final XFile? image = await ImagePicker().pickImage(
          source: ImageSource.camera,
          maxWidth: 500,
          maxHeight: 500,
          imageQuality: 80,
        );
        if (image != null) {
          setState(() {
            _profileImage = image;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم التقاط الصورة بنجاح')),
          );
        }
      } else if (status.isDenied) {
        _showPermissionDialog('الكاميرا', 'لالتقاط صورة شخصية');
      } else if (status.isPermanentlyDenied) {
        _showOpenSettingsDialog('الكاميرا', 'لالتقاط صورة شخصية');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في التقاط الصورة: $e')),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      PermissionStatus status = await Permission.photos.request();
      
      if (status.isGranted) {
        final XFile? image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          maxWidth: 500,
          maxHeight: 500,
          imageQuality: 80,
        );
        if (image != null) {
          setState(() {
            _profileImage = image;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم اختيار الصورة بنجاح')),
          );
        }
      } else if (status.isDenied) {
        _showPermissionDialog('معرض الصور', 'لاختيار صورة شخصية');
      } else if (status.isPermanentlyDenied) {
        _showOpenSettingsDialog('معرض الصور', 'لاختيار صورة شخصية');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في اختيار الصورة: $e')),
      );
    }
  }

  void _showPermissionDialog(String feature, String purpose) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('الإذن مطلوب'),
        content: Text('يحتاج التطبيق إلى الوصول إلى $feature $purpose.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }

  void _showOpenSettingsDialog(String feature, String purpose) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('الإذن مرفوض'),
        content: Text('تم رفض الوصول إلى $feature. يرجى تفعيل الإذن من إعدادات التطبيق $purpose.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('لاحقاً'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('كلمات المرور غير متطابقة')),
        );
        return;
      }

      if (_userType == 'student' && (_selectedCurriculum == null || _selectedGrade == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('يرجى اختيار المنهج والمرحلة التعليمية')),
        );
        return;
      }

      final authProvider = Provider.of<MockAuthProvider>(context, listen: false);
      
      print('🎯 بدء إنشاء الحساب...');
      print('📧 البريد: ${_emailController.text}');
      print('👤 النوع: $_userType');

      try {
        bool success = await authProvider.signUp(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          userType: _userType,
          phone: _phoneController.text,
          curriculum: _selectedCurriculum,
          grade: _selectedGrade,
          profileImage: _profileImage,
        );

        print('✅ نتيجة التسجيل: $success');

        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم إنشاء الحساب بنجاح!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل في إنشاء الحساب: ${authProvider.error}')),
          );
        }
      } catch (e) {
        print('❌ خطأ في التسجيل: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MockAuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'إنشاء حساب جديد',
          style: TextStyle(
            color: Colors.blue[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // صورة الملف الشخصي
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.grey[300]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: _profileImage != null
                                ? ClipOval(
                                    child: Image.file(
                                      File(_profileImage!.path),
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey[500],
                                  ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.5),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'الصورة الشخصية',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      if (_profileImage != null)
                        Text(
                          '✓ تم اختيار الصورة',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        Text(
                          'انقر على الأيقونة لإضافة صورة',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // نوع المستخدم
                Text(
                  'نوع الحساب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildUserTypeCard('طالب', 'student', Icons.school, Colors.blue),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildUserTypeCard('معلم', 'teacher', Icons.person, Colors.green),
                    ),
                  ],
                ),

                SizedBox(height: 32),

                // البيانات الشخصية
                Text(
                  'البيانات الشخصية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 20),

                // الاسم الكامل
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم الكامل',
                    hintText: 'أدخل اسمك الكامل',
                    prefixIcon: Icon(Icons.person, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الاسم الكامل';
                    }
                    if (value.length < 3) {
                      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                // البريد الإلكتروني
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    hintText: 'example@email.com',
                    prefixIcon: Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال البريد الإلكتروني';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'يرجى إدخال بريد إلكتروني صحيح';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                // رقم الهاتف
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    hintText: '05XXXXXXXX',
                    prefixIcon: Icon(Icons.phone, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال رقم الهاتف';
                    }
                    if (value.length < 10) {
                      return 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                // كلمة المرور
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    hintText: 'أدخل كلمة المرور',
                    prefixIcon: Icon(Icons.lock, color: Colors.blue),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    if (value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                // تأكيد كلمة المرور
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'تأكيد كلمة المرور',
                    hintText: 'أعد إدخال كلمة المرور',
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.blue),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى تأكيد كلمة المرور';
                    }
                    return null;
                  },
                ),

                // اختيار المنهج والمرحلة (للطلاب فقط)
                if (_userType == 'student') ...[
                  SizedBox(height: 32),
                  Text(
                    'البيانات التعليمية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 20),

                  // اختيار المنهج
                  DropdownButtonFormField<String>(
                    value: _selectedCurriculum,
                    decoration: InputDecoration(
                      labelText: 'اختر المنهج',
                      prefixIcon: Icon(Icons.school, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    items: _curriculums.map((curriculum) {
                      return DropdownMenuItem(
                        value: curriculum['id'],
                        child: Text(
                          curriculum['name']!,
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCurriculum = value;
                        _selectedGrade = null;
                      });
                    },
                    validator: (value) {
                      if (_userType == 'student' && (value == null || value.isEmpty)) {
                        return 'يرجى اختيار المنهج';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20),

                  // اختيار المرحلة
                  if (_selectedCurriculum != null)
                    DropdownButtonFormField<String>(
                      value: _selectedGrade,
                      decoration: InputDecoration(
                        labelText: 'اختر المرحلة',
                        prefixIcon: Icon(Icons.grade, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                      items: _grades[_selectedCurriculum]!.map((grade) {
                        return DropdownMenuItem(
                          value: grade,
                          child: Text(
                            grade,
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGrade = value;
                        });
                      },
                      validator: (value) {
                        if (_userType == 'student' && (value == null || value.isEmpty)) {
                          return 'يرجى اختيار المرحلة';
                        }
                        return null;
                      },
                    ),
                ],

                SizedBox(height: 40),

                // زر إنشاء الحساب - الإصدار المصحح
                Container(
                  height: 56,
                  child: authProvider.isLoading
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'جاري إنشاء الحساب...',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            minimumSize: Size(double.infinity, 56),
                          ),
                          child: Text(
                            'إنشاء حساب',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),

                SizedBox(height: 16),

                // رابط تسجيل الدخول
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'لديك حساب بالفعل؟ تسجيل الدخول',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(String title, String type, IconData icon, Color color) {
    bool isSelected = _userType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _userType = type;
          if (_userType == 'teacher') {
            _selectedCurriculum = null;
            _selectedGrade = null;
          }
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: isSelected ? color : Colors.grey, 
              size: 40
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}