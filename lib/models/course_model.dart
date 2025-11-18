import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String teacherId;
  final String subject;
  final String level;
  final double price;
  final double rating;
  final int reviewCount;
  final int enrolledStudents;
  final double progress;
  final String imageUrl;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> chapters;
  final int totalLessons;
  final int completedLessons;
  final String duration;
  final String category;
  final bool isActive;
  final String currency;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.teacherId,
    required this.subject,
    required this.level,
    this.price = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.enrolledStudents = 0,
    this.progress = 0,
    this.imageUrl = '',
    this.isPublished = true,
    required this.createdAt,
    this.updatedAt,
    this.chapters = const [],
    this.totalLessons = 0,
    this.completedLessons = 0,
    this.duration = '',
    this.category = '',
    this.isActive = true,
    this.currency = 'SAR',
  });

  // ⭐⭐ جديد: دالة fromMap المطلوبة ⭐⭐
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      instructor: map['instructor'] as String? ?? '',
      teacherId: map['teacherId'] as String? ?? map['instructor'] ?? '',
      subject: map['subject'] as String? ?? '',
      level: map['level'] as String? ?? '',
      price: (map['price'] ?? 0).toDouble(),
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      enrolledStudents: map['enrolledStudents'] ?? 0,
      progress: (map['progress'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      isPublished: map['isPublished'] ?? true,
      isActive: map['isActive'] ?? true,
      currency: map['currency'] ?? 'SAR',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.parse(map['createdAt'].toString()))
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(map['updatedAt'].toString()))
          : null,
      chapters: List<String>.from(map['chapters'] ?? []),
      totalLessons: map['totalLessons'] ?? 0,
      completedLessons: map['completedLessons'] ?? 0,
      duration: map['duration'] ?? '',
      category: map['category'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'instructor': instructor,
      'teacherId': teacherId,
      'subject': subject,
      'level': level,
      'price': price,
      'rating': rating,
      'reviewCount': reviewCount,
      'enrolledStudents': enrolledStudents,
      'progress': progress,
      'imageUrl': imageUrl,
      'isPublished': isPublished,
      'isActive': isActive,
      'currency': currency,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : Timestamp.fromDate(createdAt),
      'chapters': chapters,
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'duration': duration,
      'category': category,
    };
  }

  factory Course.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Course(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      instructor: data['instructor'] ?? '',
      teacherId: data['teacherId'] ?? '',
      subject: data['subject'] ?? '',
      level: data['level'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      enrolledStudents: data['enrolledStudents'] ?? 0,
      progress: (data['progress'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      isPublished: data['isPublished'] ?? true,
      isActive: data['isActive'] ?? true,
      currency: data['currency'] ?? 'SAR',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      chapters: List<String>.from(data['chapters'] ?? []),
      totalLessons: data['totalLessons'] ?? 0,
      completedLessons: data['completedLessons'] ?? 0,
      duration: data['duration'] ?? '',
      category: data['category'] ?? '',
    );
  }

  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? instructor,
    String? teacherId,
    String? subject,
    String? level,
    double? price,
    double? rating,
    int? reviewCount,
    int? enrolledStudents,
    double? progress,
    String? imageUrl,
    bool? isPublished,
    bool? isActive,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? chapters,
    int? totalLessons,
    int? completedLessons,
    String? duration,
    String? category,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      instructor: instructor ?? this.instructor,
      teacherId: teacherId ?? this.teacherId,
      subject: subject ?? this.subject,
      level: level ?? this.level,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      progress: progress ?? this.progress,
      imageUrl: imageUrl ?? this.imageUrl,
      isPublished: isPublished ?? this.isPublished,
      isActive: isActive ?? this.isActive,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      chapters: chapters ?? this.chapters,
      totalLessons: totalLessons ?? this.totalLessons,
      completedLessons: completedLessons ?? this.completedLessons,
      duration: duration ?? this.duration,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return toFirestore()..['id'] = id;
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructor: json['instructor'] ?? '',
      teacherId: json['teacherId'] ?? json['instructor'] ?? '',
      subject: json['subject'] ?? '',
      level: json['level'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      enrolledStudents: json['enrolledStudents'] ?? 0,
      progress: (json['progress'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      isPublished: json['isPublished'] ?? true,
      isActive: json['isActive'] ?? true,
      currency: json['currency'] ?? 'SAR',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      chapters: List<String>.from(json['chapters'] ?? []),
      totalLessons: json['totalLessons'] ?? 0,
      completedLessons: json['completedLessons'] ?? 0,
      duration: json['duration'] ?? '',
      category: json['category'] ?? '',
    );
  }

  String get color {
    switch (subject.toLowerCase()) {
      case 'رياضيات':
        return 'blue';
      case 'فيزياء':
        return 'green';
      case 'كيمياء':
        return 'orange';
      case 'لغة عربية':
        return 'purple';
      case 'لغة إنجليزية':
        return 'red';
      default:
        return 'grey';
    }
  }

  String get icon {
    switch (subject.toLowerCase()) {
      case 'رياضيات':
        return 'calculate';
      case 'فيزياء':
        return 'science';
      case 'كيمياء':
        return 'emoji_objects';
      case 'لغة عربية':
        return 'menu_book';
      case 'لغة إنجليزية':
        return 'language';
      default:
        return 'school';
    }
  }

  bool get isFree => price == 0;

  String get formattedDuration {
    if (duration.isEmpty) return 'غير محدد';
    return duration;
  }

  String get formattedPrice {
    if (isFree) return 'مجاني';
    return '${getCurrencySymbol()} $price';
  }

  String getCurrencySymbol() {
    switch (currency) {
      case 'SAR':
        return 'ر.س';
      case 'EGP':
        return 'ج.م';
      case 'USD':
        return '\$';
      default:
        return currency;
    }
  }

  String get ratingStars {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    String stars = '⭐' * fullStars;
    if (hasHalfStar) stars += '½';

    return stars;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Course && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Course(id: $id, title: $title, instructor: $instructor, price: $price $currency, rating: $rating)';
  }
}

class Chapter {
  final String id;
  final String title;
  final String description;
  final int order;
  final List<Lesson> lessons;
  final bool isCompleted;

  Chapter({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    this.lessons = const [],
    this.isCompleted = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'order': order,
      'lessons': lessons.map((lesson) => lesson.toFirestore()).toList(),
      'isCompleted': isCompleted,
    };
  }

  factory Chapter.fromFirestore(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      order: json['order'] ?? 0,
      lessons: List<Lesson>.from(
          (json['lessons'] ?? []).map((x) => Lesson.fromFirestore(x))),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => toFirestore();
  factory Chapter.fromJson(Map<String, dynamic> json) =>
      Chapter.fromFirestore(json);
}

class Lesson {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String duration;
  final bool isCompleted;
  final bool isLocked;
  final int order;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    this.videoUrl = '',
    this.duration = '',
    this.isCompleted = false,
    this.isLocked = false,
    required this.order,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'duration': duration,
      'isCompleted': isCompleted,
      'isLocked': isLocked,
      'order': order,
    };
  }

  factory Lesson.fromFirestore(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      duration: json['duration'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      isLocked: json['isLocked'] ?? false,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => toFirestore();
  factory Lesson.fromJson(Map<String, dynamic> json) =>
      Lesson.fromFirestore(json);
}
