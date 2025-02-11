import 'package:eschool_saas_staff/data/models/question.dart';
import 'dart:convert';

class QuestionVersion {
  final int id;
  final String version;
  final String question;
  final String name;
  final String note;
  final int defaultPoint;
  final String type;
  final List<QuestionOption> options;
  final String createdAt;
  final String updatedAt;
  final UpdatedBy updatedBy;

  QuestionVersion({
    required this.id,
    required this.version,
    required this.question,
    required this.name,
    required this.note,
    required this.defaultPoint,
    required this.type,
    required this.options,
    required this.createdAt,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory QuestionVersion.fromJson(Map<String, dynamic> json) {
    List<QuestionOption> parseOptions(String optionsString) {
      final List<dynamic> optionsList = jsonDecode(optionsString);
      return optionsList.map((o) => QuestionOption.fromJson(o)).toList();
    }

    return QuestionVersion(
      id: json['id'] ?? 0,
      version: json['version'] ?? '',
      question: json['question'] ?? '',
      name: json['name'] ?? '',
      note: json['note'] ?? '',
      defaultPoint: json['default_point'] ?? 0,
      type: json['type'] ?? '',
      options: parseOptions(json['options'] ?? '[]'),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      updatedBy: UpdatedBy.fromJson(json['updated_by'] ?? {}),
    );
  }
}

class UpdatedBy {
  final String firstName;
  final int id;
  final String fullName;
  final String schoolNames;
  final String role;

  UpdatedBy({
    required this.firstName,
    required this.id,
    required this.fullName,
    required this.schoolNames,
    required this.role,
  });

  factory UpdatedBy.fromJson(Map<String, dynamic> json) {
    return UpdatedBy(
      firstName: json['first_name'] ?? '',
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      schoolNames: json['school_names'] ?? '',
      role: json['role'] ?? '',
    );
  }
}