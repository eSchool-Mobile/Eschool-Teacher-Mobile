class QuestionOnlineExam {
  final int id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final int marks;
  final String? title;
  final String? version;
  final int? onlineExamId;

  QuestionOnlineExam({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    required this.marks,
    this.title,
    this.version,
    this.onlineExamId,
  });

  factory QuestionOnlineExam.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List?)?.first ?? {};

    return QuestionOnlineExam(
      id: json['id'] ?? 0,
      question: json['question_text'] ?? '',
      optionA: options['option'] ?? '',
      optionB: '', // Sesuaikan dengan format API
      optionC: '', // Sesuaikan dengan format API
      optionD: '', // Sesuaikan dengan format API
      correctAnswer: options['is_answer'] == 1 ? 'A' : '',
      marks: json['marks'] ?? 0,
      title: '', // Sesuaikan jika diperlukan
      version: '1.0', // Sesuaikan jika diperlukan
      onlineExamId: json['exam_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': question,
      'marks': marks,
      'options': [
        {
          'option': optionA,
          'is_answer': correctAnswer == 'A' ? 1 : 0,
        }
      ],
      'exam_id': onlineExamId,
    };
  }
}
