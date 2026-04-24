import 'package:flutter/foundation.dart';
class StudentExamStatus {
  final int id;
  final String name;
  final String className;
  final String? sectionName;
  final String? mediumName;
  final int status; // 1: in progress, 2: completed
  final String? startTime;
  final String? endTime;

  StudentExamStatus({
    required this.id,
    required this.name,
    required this.className,
    this.sectionName,
    this.mediumName,
    required this.status,
    this.startTime,
    this.endTime,
  });
  factory StudentExamStatus.fromJson(Map<String, dynamic> json) {
    try {
      return StudentExamStatus(
        id: json['student_id'] ?? 0,
        name: json['student_name'] ?? 'Unknown Student',
        className: json['class_name'] ?? 'Unknown Class',
        sectionName: json['section_name'],
        mediumName: json['medium_name'],
        status: json['status'] ?? 0,
        startTime: json['start_time'],
        endTime: json['end_time'],
      );
    } catch (e) {
      debugPrint('Error parsing StudentExamStatus: $e');
      debugPrint('JSON data: $json');
      rethrow;
    }
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
