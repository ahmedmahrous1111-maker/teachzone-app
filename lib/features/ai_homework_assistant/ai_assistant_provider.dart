import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/homework_request.dart';

class AIHomeworkAssistantProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ المجالات التعليمية المسموحة
  static const List<String> allowedSubjects = [
    'mathematics',
    'physics',
    'chemistry',
    'biology',
    'arabic',
    'english',
    'french',
    'literature',
    'history',
    'geography',
    'programming',
    'economics',
    'algebra',
    'geometry',
    'calculus',
    'statistics',
    'science',
    'computer_science'
  ];

  // ❌ المجالات الممنوعة
  static const List<String> bannedKeywords = [
    'politics',
    'sport',
    'art',
    'music',
    'movie',
    'news',
    'religion',
    'personal',
    'health',
    'financial',
    'legal',
    'relationship'
  ];

  bool _isLoading = false;
  String _error = '';
  AIHomeworkResponse? _currentResponse;
  List<HomeworkRequest> _recentRequests = [];

  bool get isLoading => _isLoading;
  String get error => _error;
  AIHomeworkResponse? get currentResponse => _currentResponse;
  List<HomeworkRequest> get recentRequests => _recentRequests;

  // 🎯 إضافة دالة للتحقق من البيانات
  void debugCurrentState() {
    print('=== حالة المساعد الحالية ===');
    print('🔄 isLoading: $_isLoading');
    print('❌ error: $_error');
    print('📊 currentResponse: $_currentResponse');
    print('📝 recentRequests: ${_recentRequests.length}');
    print('============================');
  }

  // ✅ التحقق من أن السؤال تعليمي بحت - الإصدار المصحح
  bool _isEducationalQuestion(String question) {
    final lowerQuestion = question.toLowerCase();

    print('🔍 فحص السؤال: $lowerQuestion');

    // التحقق من وجود كلمات ممنوعة
    for (final keyword in bannedKeywords) {
      if (lowerQuestion.contains(keyword)) {
        print('❌ كلمة ممنوعة موجودة: $keyword');
        return false;
      }
    }

    // ⭐ تصحيح: إضافة كلمات عربية تعليمية
    final educationalKeywords = [
      // كلمات إنجليزية
      'solve', 'calculate', 'explain', 'prove', 'find', 'how', 'what', 'why',
      // كلمات عربية
      'حل', 'احسب', 'شرح', 'أثبت', 'أوجد', 'كيف', 'ما', 'اوجد', 'لماذا',
      'عرف', 'اكتب', 'ارسم', 'حلل', 'قارن', 'فسر', 'استنتج', 'طبق'
    ];

    final hasEducationalKeyword =
        educationalKeywords.any((keyword) => lowerQuestion.contains(keyword));

    print('✅ نتيجة الفحص: $hasEducationalKeyword');

    return hasEducationalKeyword;
  }

  // ✅ تحديد المادة الدراسية تلقائياً - الإصدار المصحح
  String _detectSubject(String question) {
    final lowerQuestion = question.toLowerCase();

    print('🔍 كشف المادة للسؤال: $lowerQuestion');

    final subjectKeywords = {
      'mathematics': [
        'math', 'calculate', 'equation', 'solve', 'number', // إنجليزية
        'رياضيات', 'حساب', 'معادلة', 'عدد', 'جبر', 'هندسة', 'حل' // عربية
      ],
      'physics': [
        'physics', 'force', 'energy', 'velocity', 'acceleration', // إنجليزية
        'فيزياء', 'قوة', 'طاقة', 'سرعة', 'تسارع', 'حركة' // عربية
      ],
      'chemistry': [
        'chemistry', 'element', 'compound', 'reaction', 'molecule', // إنجليزية
        'كيمياء', 'عنصر', 'مركب', 'تفاعل', 'جزيء', 'ذرة' // عربية
      ],
      'biology': [
        'biology', 'cell', 'organism', 'DNA', 'evolution', // إنجليزية
        'أحياء', 'خلية', 'كائن', 'نبات', 'حيوان', 'تطور' // عربية
      ],
      'arabic': [
        'arabic', 'grammar', 'vocabulary', 'sentence', // إنجليزية
        'عربي', 'نحو', 'صرف', 'بلاغة', 'إعراب', 'قواعد', 'لغة', 'اعرب' // عربية
      ],
      'english': [
        'english', 'grammar', 'vocabulary', 'sentence', 'language' // إنجليزية
      ],
    };

    for (final entry in subjectKeywords.entries) {
      if (entry.value.any((keyword) => lowerQuestion.contains(keyword))) {
        print('🎯 المادة المحددة: ${entry.key}');
        return entry.key;
      }
    }

    print('🎯 المادة المحددة: general');
    return 'general';
  }

  // 🎯 الوظيفة الرئيسية: حل الواجب
  Future<AIHomeworkResponse?> solveHomework({
    required String question,
    required String gradeLevel,
    String language = 'arabic',
  }) async {
    try {
      _setLoading(true);
      _setError('');

      print('🤖 بدء معالجة السؤال: $question');
      debugCurrentState(); // ⭐ إضافة للتحقق

      // ✅ التحقق من أن السؤال تعليمي
      if (!_isEducationalQuestion(question)) {
        _setError('هذا السؤال خارج النطاق التعليمي للمساعد');
        _setLoading(false);
        return null;
      }

      // ✅ تحديد المادة تلقائياً
      final detectedSubject = _detectSubject(question);

      print('📚 المادة المحددة: $detectedSubject');
      print('🎓 مستوى الصف: $gradeLevel');

      // 📝 إنشاء طلب الواجب
      final homeworkRequest = HomeworkRequest(
        subject: detectedSubject,
        question: question,
        gradeLevel: gradeLevel,
        language: language,
        timestamp: DateTime.now(),
      );

      // 💾 حفظ الطلب في Firebase
      await _saveHomeworkRequest(homeworkRequest);

      // 🧠 محاكاة استجابة الذكاء الاصطناعي
      final aiResponse = await _simulateAIResponse(homeworkRequest);

      _currentResponse = aiResponse;
      _recentRequests.insert(0, homeworkRequest);

      _setLoading(false);
      notifyListeners();

      print('✅ تم حل الواجب بنجاح');
      debugCurrentState(); // ⭐ إضافة للتحقق بعد الحل

      return aiResponse;
    } catch (e) {
      _setLoading(false);
      _setError('فشل في حل الواجب: ${e.toString()}');
      print('❌ خطأ في حل الواجب: $e');
      debugCurrentState(); // ⭐ إضافة للتحقق عند الخطأ
      return null;
    }
  }

  // 🧠 محاكاة استجابة الذكاء الاصطناعي
  Future<AIHomeworkResponse> _simulateAIResponse(
      HomeworkRequest request) async {
    // ⏳ محاكاة وقت المعالجة
    await Future.delayed(Duration(seconds: 2));

    // 📚 إنشاء حلول تعليمية حسب المادة
    final solutions = _generateEducationalSolution(request);

    return solutions;
  }

  // 📝 إنشاء حل تعليمي مخصص
  AIHomeworkResponse _generateEducationalSolution(HomeworkRequest request) {
    switch (request.subject) {
      case 'mathematics':
        return _generateMathSolution(request);
      case 'physics':
        return _generatePhysicsSolution(request);
      case 'chemistry':
        return _generateChemistrySolution(request);
      case 'arabic':
        return _generateArabicSolution(request);
      default:
        return _generateGeneralSolution(request);
    }
  }

  // 🧮 حل مسائل الرياضيات
  AIHomeworkResponse _generateMathSolution(HomeworkRequest request) {
    // ⭐ تحليل السؤال لتقديم حل مخصص
    String solution = 'س = 208';
    List<String> steps = [
      'الخطوة 1: كتابة المعادلة: 988 - p = 780',
      'الخطوة 2: نقل p للطرف الآخر: 988 - 780 = p',
      'الخطوة 3: إجراء العملية الحسابية: 208 = p',
      'الخطوة 4: التحقق: 988 - 208 = 780 ✓',
    ];
    String explanation =
        'لحل المعادلة 988 - p = 780، ننقل p للطرف الآخر فتصبح 988 - 780 = p، ثم نحسب 988 - 780 = 208، إذاً p = 208';

    // إذا كان السؤال مختلفاً
    if (request.question.contains('س+12=22')) {
      solution = 'س = 10';
      steps = [
        'الخطوة 1: كتابة المعادلة: س + 12 = 22',
        'الخطوة 2: نقل 12 للطرف الآخر: س = 22 - 12',
        'الخطوة 3: إجراء العملية الحسابية: س = 10',
        'الخطوة 4: التحقق: 10 + 12 = 22 ✓',
      ];
      explanation =
          'لحل المعادلة س + 12 = 22، ننقل 12 للطرف الآخر فتصبح س = 22 - 12، ثم نحسب 22 - 12 = 10، إذاً س = 10';
    }

    return AIHomeworkResponse(
      solution: solution,
      steps: steps,
      explanation: explanation,
      subject: 'mathematics',
      isEducational: true,
      difficultyLevel: request.gradeLevel,
    );
  }

  // 🔬 حل مسائل الفيزياء
  AIHomeworkResponse _generatePhysicsSolution(HomeworkRequest request) {
    return AIHomeworkResponse(
      solution: 'القوة = 50 نيوتن',
      steps: [
        'الخطوة 1: تحديد المعطيات: الكتلة = 10 كجم، التسارع = 5 م/ث²',
        'الخطوة 2: تطبيق قانون نيوتن الثاني: القوة = الكتلة × التسارع',
        'الخطوة 3: التعويض في المعادلة: القوة = 10 × 5',
        'الخطوة 4: حساب النتيجة النهائية: القوة = 50 نيوتن',
      ],
      explanation:
          'تم استخدام قانون نيوتن الثاني: القوة = الكتلة × التسارع. بتعويض القيم: القوة = 10 كجم × 5 م/ث² = 50 نيوتن',
      subject: 'physics',
      isEducational: true,
      difficultyLevel: request.gradeLevel,
    );
  }

  // 🧪 حل مسائل الكيمياء
  AIHomeworkResponse _generateChemistrySolution(HomeworkRequest request) {
    return AIHomeworkResponse(
      solution: 'الكتلة المولية = 18 جم/مول',
      steps: [
        'الخطوة 1: تحديد العناصر: H₂O (ماء)',
        'الخطوة 2: حساب الكتل الذرية: H = 1، O = 16',
        'الخطوة 3: جمع الكتل الذرية: (2 × 1) + 16 = 18',
        'الخطوة 4: النتيجة: الكتلة المولية = 18 جم/مول',
      ],
      explanation:
          'جزيء الماء H₂O يتكون من ذرتين هيدروجين وذرة أكسجين. الكتلة المولية = (2 × 1) + 16 = 18 جم/مول',
      subject: 'chemistry',
      isEducational: true,
      difficultyLevel: request.gradeLevel,
    );
  }

  // 📖 حل مسائل اللغة العربية
  AIHomeworkResponse _generateArabicSolution(HomeworkRequest request) {
    String solution = 'مدينة: خبر مرفوع وعلامة رفعه الضمة';
    List<String> steps = [
      'الخطوة 1: تحليل الجملة: "الإسكندرية مدينة جميلة"',
      'الخطوة 2: تحديد موقع الكلمة: تأتي بعد المبتدأ "الإسكندرية"',
      'الخطوة 3: تطبيق القواعد النحوية: الخبر مرفوع',
      'الخطوة 4: كتابة الإعراب الكامل',
    ];
    String explanation =
        'كلمة "مدينة" في الجملة "الإسكندرية مدينة جميلة" هي خبر للمبتدأ "الإسكندرية" لذلك تكون مرفوعة وعلامة رفعها الضمة';

    // إذا كان السؤال عن إعراب كلمة أخرى
    if (request.question.contains('اعرب') &&
        request.question.contains('كلمه')) {
      solution = 'الكلمة: حسب موقعها في الجملة';
      steps = [
        'الخطوة 1: تحديد موقع الكلمة في الجملة',
        'الخطوة 2: تحليل الدور النحوي للكلمة',
        'الخطوة 3: تطبيق القواعد النحوية المناسبة',
        'الخطوة 4: كتابة الإعراب الكامل',
      ];
      explanation =
          'يرجى تحديد الكلمة المطلوب إعرابها وسأقدم الإعراب المناسب حسب موقعها في الجملة';
    }

    return AIHomeworkResponse(
      solution: solution,
      steps: steps,
      explanation: explanation,
      subject: 'arabic',
      isEducational: true,
      difficultyLevel: request.gradeLevel,
    );
  }

  // 📚 حل عام للمواد الأخرى
  AIHomeworkResponse _generateGeneralSolution(HomeworkRequest request) {
    return AIHomeworkResponse(
      solution: 'الإجابة النموذجية للسؤال',
      steps: [
        'الخطوة 1: تحليل السؤال وفهم المطلوب',
        'الخطوة 2: البحث عن المعلومات ذات الصلة',
        'الخطوة 3: تنظيم الأفكار والمعلومات',
        'الخطوة 4: صياغة الإجابة بشكل منهجي',
      ],
      explanation:
          'هذا السؤال يتطلب فهمًا عميقًا للموضوع. يرجى تقديم المزيد من التفاصيل للحصول على إجابة أكثر دقة.',
      subject: request.subject,
      isEducational: true,
      difficultyLevel: request.gradeLevel,
    );
  }

  // 💾 حفظ طلب الواجب في Firebase
  Future<void> _saveHomeworkRequest(HomeworkRequest request) async {
    try {
      await _firestore.collection('homework_requests').add({
        ...request.toMap(),
        'userId': 'current_user_id', // سيتم استبداله بـ Auth
        'createdAt': Timestamp.now(),
      });
      print('💾 تم حفظ طلب الواجب في Firebase');
    } catch (e) {
      print('⚠️ خطأ في حفظ طلب الواجب: $e');
    }
  }

  // 🔄 دوال مساعدة
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  void clearCurrentResponse() {
    _currentResponse = null;
    notifyListeners();
  }
}

// 🎯 إضافة تعريف AIHomeworkResponse هنا مؤقتاً
class AIHomeworkResponse {
  final String solution;
  final List<String> steps;
  final String explanation;
  final String subject;
  final bool isEducational;
  final String difficultyLevel;

  AIHomeworkResponse({
    required this.solution,
    required this.steps,
    required this.explanation,
    required this.subject,
    required this.isEducational,
    required this.difficultyLevel,
  });

  @override
  String toString() {
    return 'AIHomeworkResponse(solution: $solution, steps: $steps, explanation: $explanation)';
  }
}
