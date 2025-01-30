import 'dart:ffi';

import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/data/models/subject.dart';

class Assignment {
  Assignment({
    required this.id,
    required this.classSectionId,
    required this.subjectId,
    required this.name,
    required this.description,
    required this.dueDate,
    required this.startDate,
    required this.endDate,
    required this.points,
    required this.minPoints,
    required this.maxFile,
    required this.resubmission,
    required this.extraDaysForResubmission,
    required this.sessionYearId,
    required this.createdAt,
    required this.classSection,
    required this.studyMaterial,
    required this.subject,
    required this.text,
    required this.acceptedFile,
  });

  final int id;
  final int classSectionId;
  final int subjectId;
  final String name;
  final String description;
  final DateTime dueDate;
  final DateTime startDate;
  final DateTime endDate;
  final int points;
  final int minPoints;
  final int maxFile;
  final int resubmission;
  final int extraDaysForResubmission;
  final int sessionYearId;
  final String createdAt;
  final ClassSection classSection;
  final List<StudyMaterial> studyMaterial;
  final Subject subject;
  final String text; // Changed from bool to String to match API
  final List<String> acceptedFile;

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] ?? 0,
      classSectionId: json['class_section_id'] ?? 0,
      subjectId: json['subject_id'] ?? 0,
      name: json['name'] ?? "",
      description: json["instructions"] ?? "",
      dueDate: DateTime.parse(json['due_date'] ?? DateTime.now().toString()),
      startDate:
          DateTime.parse(json['start_date'] ?? DateTime.now().toString()),
      endDate: DateTime.parse(json['end_date'] ?? DateTime.now().toString()),
      points: json["points"] ?? 0,
      minPoints: json["min_points"] ?? 0,
      maxFile: json["max_file"] ?? 0,
      resubmission: json['resubmission'] ?? 0,
      extraDaysForResubmission: json["extra_days_for_resubmission"] ?? 0,
      sessionYearId: json['session_year_id'] ?? 0,
      createdAt: json['created_at'] ?? "",
      classSection: ClassSection.fromJson(json['class_section'] ?? {}),
      studyMaterial: ((json['file'] ?? []) as List)
          .map((e) => StudyMaterial.fromJson(Map.from(e)))
          .toList(),
      subject: Subject.fromJson(json['subject'] ?? {}),
      text: json['text']?.toString() ?? "0", // Convert to String
      acceptedFile: List<String>.from(json['filetypes'] ?? []),
    );
  }
}
