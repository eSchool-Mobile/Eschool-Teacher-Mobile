import 'dart:convert';

class Question {
  final int id;
  final int bankSoalId;
  final int subjectId;
  final int defaultPoint;
  final String createdAt;
  final String updatedAt;
  final BankSoalInfo bankSoal;
  final List<QuestionVersion> versions;

  Question(
      {required this.id,
      required this.bankSoalId,
      required this.subjectId,
      required this.createdAt,
      required this.updatedAt,
      required this.bankSoal,
      required this.versions,
      required this.defaultPoint,
      });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      bankSoalId: json['bank_soal_id'] ?? 0,
      subjectId: json['subject_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      defaultPoint: json['default_point'] ?? 0,
      bankSoal: BankSoalInfo.fromJson(json['bank_soal'] ?? {}),
      // orderType: json['choice_style'] ?? 'numeric',
      versions: (json['versions'] as List?)
              ?.map((v) => QuestionVersion.fromJson(v))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bank_soal_id': bankSoalId,
        'subject_id': subjectId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'bank_soal': bankSoal.toJson(),
        'versions': versions.map((v) => v.toJson()).toList(),
      };
}

class BankSoalInfo {
  final int id;
  final String name;

  BankSoalInfo({
    required this.id,
    required this.name,
  });

  factory BankSoalInfo.fromJson(Map<String, dynamic> json) {
    return BankSoalInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class QuestionVersion {
  final int id;
  final String version;
  final String question;
  final String name;
  final String note;
  final int defaultPoint;
  final String type;
  final String orderType;
  final List<QuestionOption> options;
  final String? image; // Add this field

  QuestionVersion({
    required this.id,
    required this.version,
    required this.question,
    required this.name,
    required this.note,
    required this.defaultPoint,
    required this.type,
    required this.options,
    required this.orderType,
    this.image,
  });

  factory QuestionVersion.fromJson(Map<String, dynamic> json) {
    List<QuestionOption> parseOptions(String optionsString) {
      final List<dynamic> optionsList = jsonDecode(optionsString);
      return optionsList.map((o) => QuestionOption.fromJson(o)).toList();
    }

    print("JESONNYA");
    print(json);

    return QuestionVersion(
      id: json['id'] ?? 0,
      version: json['version'] ?? '',
      question: json['question'] ?? '',
      name: json['name'] ?? '',
      note: json['note'] ?? '',
      defaultPoint: json['default_point'] ?? 0,
      type: json['type'] ?? '',
      options: parseOptions(json['options'] ?? '[]'),
      image: json['image'], // Add this field
      orderType: json['choice_style'] ?? 'numeric',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'version': version,
        'question': question,
        'name': name,
        'note': note,
        'default_point': defaultPoint,
        'type': type,
        'options': options.map((o) => o.toJson()).toList(),
        'image': image, // Add this field
      };
}

class QuestionOption {
  final String text;
  final int percentage;
  final String feedback;
  final String type;
  final String? image;

  QuestionOption({
    required this.text,
    required this.percentage,
    required this.feedback,
    this.type = '',
    this.image,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      text: json['text'] ?? '',
      percentage: int.tryParse(json['percentage'].toString()) ?? 0,
      feedback: json['feedback'] ?? '',
      type: json['type'] ?? '',
      image: json['image'], // Parse image
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'percentage': percentage.toString(), // Make sure percentage is string
        'feedback': feedback,
        'type': type,
        'image': image,
      };
}
