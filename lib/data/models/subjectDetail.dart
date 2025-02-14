class SubjectDetail {
  final int id;
  final Subject subject;
  final int class_subject_id;
  final ClassSectionDetail classSection;

  SubjectDetail({
    required this.id,
    required this.class_subject_id,
    required this.subject,
    required this.classSection,
  });

  factory SubjectDetail.fromJson(Map<String, dynamic> json) {
    return SubjectDetail(
      id: json['id'] ?? 0,
      class_subject_id: json['class_subject']['id'] ?? 0,
      subject: Subject.fromJson(json['class_subject']['subject'] ?? {}),
      classSection: ClassSectionDetail.fromJson(json['class_section'] ?? {}),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectDetail &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          subject.id == other.subject.id &&
          classSection.id == other.classSection.id;

  @override
  int get hashCode =>
      id.hashCode ^ subject.id.hashCode ^ classSection.id.hashCode;
}

class Subject {
  final int id;
  final String name;
  final String type;
  final String code;
  final String bgColor;

  Subject({
    required this.id,
    required this.name,
    required this.type,
    required this.code,
    required this.bgColor,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      code: json['code'] ?? '',
      bgColor: json['bg_color'] ?? '#000000',
    );
  }
}

class ClassSectionDetail {
  final int id;
  final String name;
  final ClassDetail classDetail;
  final SectionDetail section;

  ClassSectionDetail({
    required this.id,
    required this.name,
    required this.classDetail,
    required this.section,
  });

  factory ClassSectionDetail.fromJson(Map<String, dynamic> json) {
    return ClassSectionDetail(
      id: json['id'] ?? 0,
      name: json['class']['name'] + ' ' + json['section']['name'] ?? '',
      classDetail: ClassDetail.fromJson(json['class'] ?? {}),
      section: SectionDetail.fromJson(json['section'] ?? {}),
    );
  }
}

class ClassDetail {
  final int id;
  final String name;

  ClassDetail({required this.id, required this.name});

  factory ClassDetail.fromJson(Map<String, dynamic> json) {
    return ClassDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class SectionDetail {
  final int id;
  final String name;

  SectionDetail({required this.id, required this.name});

  factory SectionDetail.fromJson(Map<String, dynamic> json) {
    return SectionDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
