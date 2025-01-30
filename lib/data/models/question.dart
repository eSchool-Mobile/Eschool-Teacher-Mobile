import 'dart:convert';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

class Question {
  final String id; // Changed to String
  final String subjectId; // Changed to String
  final String name;
  final String type;
  final String defaultPoint; // Changed to String
  final String question;
  final String note;
  final List<QuestionOption> options;
  final String version; // Changed to String

  Question({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.type,
    required this.defaultPoint,
    required this.question,
    required this.note,
    required this.options,
    required this.version,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var optionsData = json['options'];
    List<QuestionOption> parseOptions() {
      if (optionsData == null) return [];
      
      if (optionsData is String) {
        try {
          optionsData = jsonDecode(optionsData);
        } catch (e) {
          return [];
        }
      }
      
      if (optionsData is List) {
        if (optionsData.isEmpty) return [];
        if (optionsData[0] is List) {
          optionsData = optionsData[0];
        }
      }
      
      return (optionsData as List)
        .map((o) => QuestionOption.fromJson(o))
        .toList();
    }

    return Question(
      id: json['id']?.toString() ?? '',
      subjectId: json['banksoal_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      defaultPoint: json['default_point']?.toString() ?? '0',
      question: json['question']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      version: json['version']?.toString() ?? '1',
      options: parseOptions(),
    );
  }

  Map<String, dynamic> toJson() => {
    'banksoal_id': id,
    'subject_id': subjectId, // Ensure this is included
    'name': name,
    'type': type,
    'default_point': defaultPoint,
    'question': question,
    'note': note,
    'options': options.map((o) => o.toJson()).toList(),
  };
}

class QuestionOption {
  final String text;
  final String percentage; // Changed to String
  final String feedback;

  QuestionOption({
    required this.text,
    required this.percentage,
    required this.feedback,
  });

  factory QuestionOption.fromJson(dynamic json) {
    if (json is String) {
      try {
        json = jsonDecode(json);
      } catch (e) {
        print("Error parsing option: $e");
        return QuestionOption(text: '', percentage: '0', feedback: '');
      }
    }
    return QuestionOption(
      text: json['text']?.toString() ?? '',
      percentage: json['percentage']?.toString() ?? '0',
      feedback: json['feedback']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'percentage': int.parse(percentage),
      'feedback': feedback
    };
  }
}