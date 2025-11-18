class HomeworkRequest {
  final String subject;
  final String question;
  final String gradeLevel;
  final String language;
  final DateTime timestamp;

  HomeworkRequest({
    required this.subject,
    required this.question,
    required this.gradeLevel,
    required this.language,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'question': question,
      'gradeLevel': gradeLevel,
      'language': language,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

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

  factory AIHomeworkResponse.fromMap(Map<String, dynamic> map) {
    return AIHomeworkResponse(
      solution: map['solution'] ?? '',
      steps: List<String>.from(map['steps'] ?? []),
      explanation: map['explanation'] ?? '',
      subject: map['subject'] ?? '',
      isEducational: map['isEducational'] ?? true,
      difficultyLevel: map['difficultyLevel'] ?? 'medium',
    );
  }
}
