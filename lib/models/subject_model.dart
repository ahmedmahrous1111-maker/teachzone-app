// 📁 lib/models/subject_model.dart - محدث مع Firebase
import 'package:cloud_firestore/cloud_firestore.dart';

class Subject {
  final String id;
  final String name;
  final String description;
  final String teacherId;
  final String teacherName;
  final double price;
  final double rating;
  final String imageUrl;
  final List<String> categories;
  final int totalStudents;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final bool isPublished;

  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.teacherId,
    required this.teacherName,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.categories,
    required this.totalStudents,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.isPublished = true,
  });

  // ⭐ دوال Firebase الجديدة
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'price': price,
      'rating': rating,
      'imageUrl': imageUrl,
      'categories': categories,
      'totalStudents': totalStudents,
      'isActive': isActive,
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : Timestamp.now(),
    };
  }

  // ⭐ تحويل من Firestore Document
  factory Subject.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Subject(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      teacherId: data['teacherId'] ?? '',
      teacherName: data['teacherName'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      totalStudents: data['totalStudents'] ?? 0,
      isActive: data['isActive'] ?? true,
      isPublished: data['isPublished'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // ⭐ دالة لإنشاء مادة جديدة (للاستخدام مع Firebase)
  factory Subject.createNew({
    required String name,
    required String description,
    required String teacherId,
    required String teacherName,
    required double price,
    required List<String> categories,
    String imageUrl = '',
  }) {
    return Subject(
      id: '', // ⭐ سيتم تعبئته من Firebase
      name: name,
      description: description,
      teacherId: teacherId,
      teacherName: teacherName,
      price: price,
      rating: 0.0,
      imageUrl: imageUrl,
      categories: categories,
      totalStudents: 0,
      createdAt: DateTime.now(),
      updatedAt: null,
      isActive: true,
      isPublished: true,
    );
  }

  Subject copyWith({
    String? id,
    String? name,
    String? description,
    String? teacherId,
    String? teacherName,
    double? price,
    double? rating,
    String? imageUrl,
    List<String>? categories,
    int? totalStudents,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isPublished,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      totalStudents: totalStudents ?? this.totalStudents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  // ✅ الحفاظ على دوال التوافق مع الكود القديم
  Map<String, dynamic> toMap() {
    return toFirestore()
      ..['createdAt'] = createdAt.millisecondsSinceEpoch
      ..['updatedAt'] = updatedAt?.millisecondsSinceEpoch;
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      totalStudents: map['totalStudents'] ?? 0,
      isActive: map['isActive'] ?? true,
      isPublished: map['isPublished'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }

  @override
  String toString() {
    return 'Subject(id: $id, name: $name, teacher: $teacherName, price: $price)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Subject && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
