class TeacherAssignmentDetailResponse {
  final bool error;
  final String message;
  final List<TeacherAssignmentDetail> data;

  TeacherAssignmentDetailResponse({
    required this.error,
    required this.message,
    required this.data,
  });

  factory TeacherAssignmentDetailResponse.fromJson(Map<String, dynamic> json) {
    List<TeacherAssignmentDetail> data = [];
    if (json['data'] != null && json['data'] is List) {
      data = (json['data'] as List)
          .map((item) => TeacherAssignmentDetail.fromJson(item))
          .toList();
    }

    return TeacherAssignmentDetailResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: data,
    );
  }
}

class TeacherAssignmentDetail {
  final String name;
  final String subject;
  final String classSection;
  final DateTime startDate;
  final DateTime dueDate;
  final DateTime endDate;
  final int points;
  final int minPoints;
  final int submissionsCount;
  final String instructions;
  final DateTime createdAt;

  TeacherAssignmentDetail({
    required this.name,
    required this.subject,
    required this.classSection,
    required this.startDate,
    required this.dueDate,
    required this.endDate,
    required this.points,
    required this.minPoints,
    required this.submissionsCount,
    required this.instructions,
    required this.createdAt,
  });

  factory TeacherAssignmentDetail.fromJson(Map<String, dynamic> json) {
    return TeacherAssignmentDetail(
      name: json['name'] ?? '',
      subject: json['subject'] ?? '',
      classSection: json['class_section'] ?? '',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : DateTime.now(),
      points: json['points'] ?? 0,
      minPoints: json['min_points'] ?? 0,
      submissionsCount: json['submissions_count'] ?? 0,
      instructions: json['instructions'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
