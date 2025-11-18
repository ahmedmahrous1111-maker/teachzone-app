import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_auth_provider.dart';
import 'curriculum_selection_screen.dart';
import 'home_screen_final.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // ⭐ جديد لحقل الاسم
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String _userType = 'student';
  bool _isLoading = false;
  bool _isSignUp = false; // ⭐ جديد للتبديل بين التسجيل والدخول

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<FirebaseAuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان الرئيسي
                  Center(
                    child: Text(
                      _isSignUp ? 'إنشاء حساب جديد' : 'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),

                  SizedBox(height: 8),

                  Center(
                    child: Text(
                      _isSignUp
                          ? 'أنشئ حسابك للبدء في رحلة التعلم'
                          : 'أدخل بياناتك للمتابعة',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  // اختيار نوع المستخدم
                  Text(
                    'نوع الحساب',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),

                  SizedBox(height: 16),

                  // أزرار اختيار الطالب/المعلم
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _userType == 'student'
                                  ? Colors.blue
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                            color: _userType == 'student'
                                ? Colors.blue
                                : Colors.white,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _userType = 'student';
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 12),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.school,
                                      color: _userType == 'student'
                                          ? Colors.white
                                          : Colors.blue,
                                      size: 40,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'طالب',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _userType == 'student'
                                            ? Colors.white
                                            : Colors.blue,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'متعلم',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _userType == 'student'
                                            ? Colors.white70
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _userType == 'teacher'
                                  ? Colors.green
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                            color: _userType == 'teacher'
                                ? Colors.green
                                : Colors.white,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _userType = 'teacher';
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 12),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: _userType == 'teacher'
                                          ? Colors.white
                                          : Colors.green,
                                      size: 40,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'معلم',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _userType == 'teacher'
                                            ? Colors.white
                                            : Colors.green,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'مدرس',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _userType == 'teacher'
                                            ? Colors.white70
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 40),

                  // ⭐ جديد: حقل الاسم (للتسجيل فقط)
                  if (_isSignUp) ...[
                    Text(
                      'الاسم الكامل',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'أحمد محمد',
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      validator: (value) {
                        if (_isSignUp && (value == null || value.isEmpty)) {
                          return 'يرجى إدخال الاسم الكامل';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                  ],

                  // حقل البريد الإلكتروني
                  Text(
                    'البريد الإلكتروني',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'ali@teachzone.com',
                      prefixIcon: Icon(Icons.email, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      }
                      if (!value.contains('@')) {
                        return 'يرجى إدخال بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 24),

                  // حقل كلمة المرور
                  Text(
                    'كلمة المرور',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'أدخل كلمة المرور',
                      prefixIcon: Icon(Icons.lock, color: Colors.blue),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
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
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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

                  SizedBox(height: 24),

                  // ⭐ تحديث: تذكرني ونسيت كلمة المرور (للتسجيل الدخول فقط)
                  if (!_isSignUp) ...[
                    Row(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value!;
                                });
                              },
                              activeColor: Colors.blue,
                            ),
                            Text(
                              'تذكرني',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () {
                            _showForgotPasswordDialog();
                          },
                          child: Text(
                            'نسيت كلمة المرور؟',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                  ],

                  // زر التسجيل/الدخول - محدث
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () {
                              if (_isSignUp) {
                                _signUp(context, authProvider); // ⭐ جديد
                              } else {
                                _login(context, authProvider);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _userType == 'student' ? Colors.blue : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: authProvider.isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isSignUp
                                  ? 'إنشاء حساب ${_userType == 'student' ? 'طالب' : 'معلم'}'
                                  : 'تسجيل الدخول ك${_userType == 'student' ? 'طالب' : 'معلم'}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // ⭐ جديد: زر التبديل بين التسجيل والدخول
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          // مسح الأخطاء عند التبديل
                          authProvider.clearError();
                        });
                      },
                      child: Text(
                        _isSignUp
                            ? 'لديك حساب؟ سجل الدخول'
                            : 'لا تملك حساب؟ أنشئ حساب جديد',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // خط فاصل
                  if (!_isSignUp) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey[400],
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'أو',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey[400],
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30),

                    // تسجيل الدخول بحسابات أخرى
                    Center(
                      child: Text(
                        'تسجيل الدخول بحسابات أخرى',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // أزرار وسائل التواصل
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(Icons.facebook, Colors.blue[800]!),
                        SizedBox(width: 20),
                        _buildSocialButton(Icons.g_translate, Colors.red),
                        SizedBox(width: 20),
                        _buildSocialButton(Icons.apple, Colors.black),
                      ],
                    ),

                    SizedBox(height: 20),
                  ],

                  // 🔐 بيانات تجريبية للاختبار
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'بيانات تجريبية للاختبار:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          SizedBox(height: 8),
                          Text('أدخل أي بريد إلكتروني وكلمة مرور (6+ أحرف)'),
                          Text('مثال: test@test.com / 123456'),
                        ],
                      ),
                    ),
                  ),

                  // ⭐ عرض رسائل الخطأ من FirebaseAuthProvider
                  if (authProvider.error.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authProvider.error,
                              style: TextStyle(color: Colors.red.shade800),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, size: 16),
                            onPressed: () {
                              authProvider.clearError();
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: IconButton(
        icon: Icon(icon, size: 30),
        color: color,
        onPressed: () {},
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('نسيت كلمة المرور؟'),
        content: Text(
            'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إرسال الرابط'),
          ),
        ],
      ),
    );
  }

  // ✅ دالة Login المحدثة
  void _login(BuildContext context, FirebaseAuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;

      try {
        // ✅ تسجيل الدخول مع Firebase
        bool success = await authProvider.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (!mounted) return;

        if (success) {
          print('✅ تسجيل الدخول ناجح - الانتقال للشاشة الرئيسية');
        } else {
          print('❌ فشل تسجيل الدخول: ${authProvider.error}');
        }
      } catch (e) {
        print('❌ استثناء في تسجيل الدخول: $e');
      }
    }
  }

  // ⭐ جديد: دالة إنشاء حساب جديد
  void _signUp(BuildContext context, FirebaseAuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;

      try {
        // ✅ إنشاء حساب جديد مع Firebase
        bool success = await authProvider.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          userType: _userType,
        );

        if (!mounted) return;

        if (success) {
          print('✅ إنشاء الحساب ناجح - الانتقال للشاشة الرئيسية');
        } else {
          print('❌ فشل إنشاء الحساب: ${authProvider.error}');
        }
      } catch (e) {
        print('❌ استثناء في إنشاء الحساب: $e');
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose(); // ⭐ جديد
    super.dispose();
  }
}
