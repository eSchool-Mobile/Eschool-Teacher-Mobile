class StudentExamStatus {
  final int id;
  final String name;
  final String className;
  final int status; // 1: in progress, 2: completed
  final String? startTime;
  final String? endTime;

  StudentExamStatus({
    required this.id,
    required this.name,
    required this.className,
    required this.status,
    this.startTime,
    this.endTime,
  });

  factory StudentExamStatus.fromJson(Map<String, dynamic> json) {
    return StudentExamStatus(
      id: json['student_id'], // Changed from 'id' to 'student_id'
      name: json['student_name'], // Changed from 'name' to 'student_name'
      className: json['class_name'],
      status: json['status'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}

class StudentExamStatusResponse {
  final bool success;
  final String message;
  final List<StudentExamStatus> data;

  StudentExamStatusResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StudentExamStatusResponse.fromJson(Map<String, dynamic> json) {
    return StudentExamStatusResponse(
      success: json['error'] ==
          false, // Changed from json['success'] to !json['error']
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => StudentExamStatus.fromJson(item))
          .toList(),
    );
  }
}
