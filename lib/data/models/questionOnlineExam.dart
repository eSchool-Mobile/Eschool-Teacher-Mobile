class QuestionOnlineExam {
  final int id;
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
    print("BELUM ERROR PT 2");
    final options = (json['options'] as List?)?.first ?? {};
    return QuestionOnlineExam(
      id: json['id'] ?? 0,
      question: json['question_text'] ?? '',
      correctAnswer: options['is_answer'] == 1 ? 'A' : '',
      marks: json['marks'] ?? 0,
      title: '',
      options:
          (json['type'] == 'multiple_choice' || json['type'] == 'true_false')
              ? options
              : null,
      version: '1.0',
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
