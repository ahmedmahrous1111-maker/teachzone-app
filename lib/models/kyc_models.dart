// 📁 lib/models/kyc_models.dart
class TeacherKYC {
  final String teacherId;
  final String fullName;
  final String idNumber;
  final String? idImageUrl;
  final String? degreeImageUrl;
  final String? cvUrl;
  final String? personalPhotoUrl;
  final String? videoIntroductionUrl;
  final List<String> specialties;
  final int yearsOfExperience;
  final DateTime submissionDate;
  final TeacherVerificationStatus status;
  final String? adminNotes;
  final String? rejectionReason;

  TeacherKYC({
    required this.teacherId,
    required this.fullName,
    required this.idNumber,
    required this.idImageUrl,
    required this.degreeImageUrl,
    required this.cvUrl,
    required this.personalPhotoUrl,
    required this.videoIntroductionUrl,
    required this.specialties,
    required this.yearsOfExperience,
    required this.submissionDate,
    required this.status,
    this.adminNotes,
    this.rejectionReason,
  });
}

enum TeacherVerificationStatus {
  notStarted, // ❌ لم يبدأ
  pending, // ⏳ قيد المراجعة
  underReview, // 📋 تحت المراجعة
  approved, // ✅ مفعل
  rejected, // ❌ مرفوض
  needsRevision // ✏️ يحتاج تعديل
}
