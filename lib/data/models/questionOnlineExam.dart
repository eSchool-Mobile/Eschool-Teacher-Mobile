class QuestionOnlineExam {
  final int id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final int marks;
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
    this.onlineExamId,
  });

  factory QuestionOnlineExam.fromJson(Map<String, dynamic> json) {
    return QuestionOnlineExam(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      optionA: json['option_a'] ?? '',
      optionB: json['option_b'] ?? '',
      optionC: json['option_c'] ?? '',
      optionD: json['option_d'] ?? '',
      correctAnswer: json['correct_answer'] ?? '',
      marks: json['marks'] ?? 0,
      onlineExamId: json['online_exam_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_answer': correctAnswer,
      'marks': marks,
      'online_exam_id': onlineExamId,
    };
  }
}