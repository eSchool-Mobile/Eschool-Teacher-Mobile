class Extracurricular {
  final int id;
  final String name;
  final String description;
  final int coachId;
  final String coachName;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  Extracurricular({
    required this.id,
    required this.name,
    required this.description,
    required this.coachId,
    required this.coachName,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Extracurricular.fromJson(Map<String, dynamic> json) {
    return Extracurricular(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      coachId: json['coach_id'] ?? 0,
      coachName: json['coach_name'] ?? '',
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coach_id': coachId,
      'coach_name': coachName,
      'deleted_at': deletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isArchived => deletedAt != null;
}
