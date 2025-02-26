import 'dart:convert';

class OnlineExam {
  final int id;
  final int classSectionId;
  final int classSubjectId;
  final int status; // 1 = active, 2 = archived
  final String title;
  final String examKey;
  final int duration;
  final DateTime startDate;
  final DateTime endDate;
  final String subjectName;

  OnlineExam({
    required this.id,
    required this.classSectionId,
    required this.classSubjectId,
    required this.title,
    required this.examKey,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.subjectName,
  });

  factory OnlineExam.fromJson(Map<String, dynamic> json) {
    print('Parsing exam with status: ${json['status']}');
    return OnlineExam(
      id: json['id'] ?? 0,
      classSectionId: json['class_section']['id'] ?? 0,
      classSubjectId: json['class_subject']['id'] ?? 0,
      title: json['title'] ?? '',
      examKey: json['exam_key'].toString(),
      duration: json['duration'] ?? 0,
      startDate: DateTime.parse(json['start_date'] ?? ''),
      endDate: DateTime.parse(json['end_date'] ?? ''),
      status: json['status'] ?? 1,
      subjectName: json['subject_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_section_id': classSectionId,
      'class_subject_id': classSubjectId,
      'title': title,
      'exam_key': examKey.toString(),
      'duration': duration,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}

class Question {
  final int id;
  final int onlineExamId;
  final int questionId;
  final int marks;

  Question({
    required this.id,
    required this.onlineExamId,
    required this.questionId,
    required this.marks,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      onlineExamId: json['online_exam_id'] ?? 0,
      questionId: json['question_id'] ?? 0,
      marks: json['marks'] ?? 0,
    );
  }
}

class ClassSection {
  final int id;
  final String name;
  final String fullName;

  ClassSection({
    required this.id,
    required this.name,
    required this.fullName,
  });

  factory ClassSection.fromJson(Map<String, dynamic> json) {
    return ClassSection(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      fullName: json['full_name'] ?? '',
    );
  }
}
