class BankSoal {
  final int id;
  final int teacherId;
  final int subjectId;
  final String name;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int soalCount;

  BankSoal({
    required this.id,
    required this.teacherId,
    required this.subjectId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.soalCount,
  });

  factory BankSoal.fromJson(Map<String, dynamic> json) {
    return BankSoal(
      id: json['id'] ?? 0,
      teacherId: json['teacher_id'] ?? 0,
      subjectId: json['subject_id'] ?? 0,
      name: json['name'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'],
      soalCount: json['soal_count'] ?? 0,
    );
  }
}