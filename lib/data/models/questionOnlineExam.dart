import 'package:flutter/foundation.dart';

class QuestionOnlineExam {
  final int id;
  final int questionId;
  final String question;
  final String correctAnswer;
  final int marks;
  final String? title;
  final String? version;
  final int? onlineExamId;
  final String type;
  final List<dynamic> options;

  QuestionOnlineExam({
    required this.id,
    required this.questionId,
    required this.question,
    required this.correctAnswer,
    required this.marks,
    required this.options,
    this.title,
    this.version,
    this.onlineExamId,
    required this.type,
  });

  factory QuestionOnlineExam.fromJson(Map<String, dynamic> json) {
    // Ambil semua options, bukan hanya yang pertama
    final options = json['options'] ?? [];

    // Ambil versi dengan penanganan yang lebih baik
    var version = json['version'];

    // Pastikan kita mendapatkan nilai versi yang benar
    // Log lebih detail untuk membantu debug
    debugPrint(
        'Question ID: ${json['id']}, Raw version: $version, Type: ${version.runtimeType}');

    // Penanganan khusus untuk nilai versi
    String versionStr;
    if (version == null) {
      versionStr = '1';
    } else if (version is int) {
      versionStr = version.toString();
    } else if (version is double) {
      versionStr = version.toString();
    } else if (version is String) {
      versionStr = version;
    } else {
      versionStr = version.toString();
    }

    return QuestionOnlineExam(
      id: json['id'] ?? 0,
      questionId: json['question_id'] ?? 0,
      question: json['question_text'] ?? '',
      correctAnswer: json['options'] != null &&
              json['options'].isNotEmpty &&
              json['options'][0]['is_answer'] == 1
          ? 'A'
          : '',
      marks: json['marks'] ?? 0,
      title: json['title'] ?? 'Soal',
      options: options,
      version: versionStr,
      onlineExamId: json['exam_id'],
      type: json['type'] ?? 'multiple_choice',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': question,
      'marks': marks,
      'options': [],
      'exam_id': onlineExamId,
    };
  }
}
