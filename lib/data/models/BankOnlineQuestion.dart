class BankSoalQuestion {
  final int id;
  final String name;
  final List<SoalQuestion> soal;

  BankSoalQuestion({
    required this.id,
    required this.name,
    required this.soal,
  });

  factory BankSoalQuestion.fromJson(Map<String, dynamic> json) {
    var soalList = json['soal'] as List? ?? [];
    return BankSoalQuestion(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      soal: soalList.map((s) => SoalQuestion.fromJson(s)).toList(),
    );
  }
}

class SoalQuestion {
  final int id;
  final String question;
  final String type;
  final List<SoalOption> options;
  final int marks;
  final String version;

  SoalQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.marks,
    required this.version,
  });

  factory SoalQuestion.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] as List? ?? [];
    return SoalQuestion(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      type: json['type'] ?? '',
      options: optionsList.map((opt) => SoalOption.fromJson(opt)).toList(),
      marks: json['marks'] ?? 0,
      version: json['version']?.toString() ?? '1',
    );
  }
}

class SoalOption {
  final String text;
  final String percentage;
  final String feedback;

  SoalOption({
    required this.text,
    required this.percentage,
    required this.feedback,
  });

  factory SoalOption.fromJson(Map<String, dynamic> json) {
    return SoalOption(
      text: json['text'] ?? '',
      percentage: json['percentage']?.toString() ?? '0',
      feedback: json['feedback'] ?? '',
    );
  }
}