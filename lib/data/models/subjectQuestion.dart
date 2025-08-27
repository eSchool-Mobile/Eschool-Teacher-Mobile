import 'question.dart';

class SubjectQuestion {
  final int? id;
  final int teacherId;
  final int subjectId;
  final String name;
  final int soalCount;
  final List<QuestionBank> banks;
  final int bankSoalCount;
  final String subjectWithName;
  final Subject subject;

  SubjectQuestion({
    this.id,
    required this.teacherId,
    required this.subjectId,
    required this.name,
    required this.soalCount,
    this.banks = const [],
    required this.bankSoalCount,
    required this.subjectWithName,
    required this.subject,
  });

  factory SubjectQuestion.fromJson(Map<String, dynamic> json) {
    try {
      final subject = json['subject'] ?? {};

      return SubjectQuestion(
        id: json['id'] ?? subject['id'],
        teacherId: json['teacher_id'] ?? 0,
        subjectId: subject['id'] ?? 0,
        name: subject['name'] ?? '',
        soalCount: json['bank_soal_count'] ?? 0,
        banks: [],
        bankSoalCount: json['bank_soal_count'] ?? 0,
        subjectWithName: json['subject_with_name'] ??
            "${subject['name']} (${subject['type'] ?? 'Theory'})",
        subject: Subject.fromJson(subject),
      );
    } catch (e) {
      print("Error parsing SubjectQuestion: ${json.toString()}");
      print("Error details: $e");
      rethrow;
    }
  }
}

class QuestionBank {
  final int? id;
  final String name;
  final int? subjectId;
  final List<Question> questions;

  QuestionBank({
    this.id,
    required this.name,
    this.subjectId,
    this.questions = const [],
  });

  factory QuestionBank.fromJson(Map<String, dynamic> json) {
    return QuestionBank(
      id: json['id'] as int?,
      name: json['name'] ?? '',
      subjectId: json['subject_id'] as int?,
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((q) => Question.fromJson(q))
              .toList()
          : [],
    );
  }
}

class Subject {
  final int id;
  final String name;
  final String type;
  final String nameWithType;

  Subject({
    required this.id,
    required this.name,
    required this.type,
    required this.nameWithType,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    try {
      return Subject(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        type: json['type'] ?? 'Theory',
        nameWithType: json['name_with_type'] ??
            "${json['name'] ?? ''} - ${json['type'] ?? 'Theory'}",
      );
    } catch (e) {
      print("Error parsing Subject: $json");
      print("Error details: $e");
      rethrow;
    }
  }
}
