class BankSoalQuestion {
  final int id;
  final String name;
  final List<SoalQuestion> soal;
  // Defaultkan ke 0 untuk menghindari null
  final int classSectionId;
  final int classSubjectId;
  final String? subjectName;

  BankSoalQuestion({
    required this.id,
    required this.name,
    required this.soal,
    this.classSectionId = 0, // Default value
    this.classSubjectId = 0, // Default value
    this.subjectName,
  });

  factory BankSoalQuestion.fromJson(Map<String, dynamic> json) {
    print('Raw JSON for BankSoalQuestion: $json');

    try {
      // Parse soal list safely
      List<SoalQuestion> parsedSoal = [];
      if (json['soal'] != null && json['soal'] is List) {
        parsedSoal = (json['soal'] as List)
            .map((s) => SoalQuestion.fromJson(s))
            .toList();
      }

      // Get class_section_id and class_subject_id from nested objects if available
      int sectionId =
          (json['class_section']?['id'] ?? json['class_section_id'] ?? 0);

      int subjectId =
          (json['class_subject']?['id'] ?? json['class_subject_id'] ?? 0);

      return BankSoalQuestion(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        soal: parsedSoal,
        classSectionId: sectionId,
        classSubjectId: subjectId,
        subjectName: json['subject_name'],
      );
    } catch (e) {
      print('Error parsing BankSoalQuestion: $e');
      // Return a default object in case of error
      return BankSoalQuestion(
        id: 0,
        name: 'Error',
        soal: [],
        classSectionId: 0,
        classSubjectId: 0,
      );
    }
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
    try {
      List<SoalOption> parsedOptions = [];
      if (json['options'] != null && json['options'] is List) {
        parsedOptions = (json['options'] as List)
            .map((opt) => SoalOption.fromJson(opt))
            .toList();
      }

      return SoalQuestion(
        id: json['id'] ?? 0,
        question: json['question'] ?? '',
        type: json['type'] ?? 'multiple_choice',
        options: parsedOptions,
        marks: json['marks'] ?? 0,
        version: json['version']?.toString() ?? '1',
      );
    } catch (e) {
      print('Error parsing SoalQuestion: $e');
      return SoalQuestion(
        id: 0,
        question: 'Error',
        type: 'multiple_choice',
        options: [],
        marks: 0,
        version: '1',
      );
    }
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
