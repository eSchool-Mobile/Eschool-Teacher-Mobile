import 'question.dart';

class SubjectQuestion {
  final int id;
  final int subjectId;
  final String subjectName;
  final List<Question> questions;

  SubjectQuestion({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.questions
  });

  factory SubjectQuestion.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'] as Map<String, dynamic>?;

    return SubjectQuestion(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : json['id'] ?? 0,
      subjectId: subject?['id'] is String ? 
        int.tryParse(subject?['id']) ?? 0 : subject?['id'] ?? 0,
      subjectName: subject?['name']?.toString() ?? '',
      questions: (json['versions'] as List? ?? [])
          .map((v) => Question.fromJson(v as Map<String, dynamic>))
          .toList()
    );
  }
}