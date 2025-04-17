class Holiday {
  final int? id;
  final String? start_date;
  final String? end_date;
  final String? title;
  final String? description;
  final int? schoolId;
  final String? createdAt;
  final String? updatedAt;
  final String? defaultDateFormat;

  Holiday({
    this.id,
    this.start_date,
    this.end_date,
    this.title,
    this.description,
    this.schoolId,
    this.createdAt,
    this.updatedAt,
    this.defaultDateFormat,
  });

  Holiday copyWith({
    int? id,
    String? start_date,
    String? end_date,
    String? title,
    String? description,
    int? schoolId,
    String? createdAt,
    String? updatedAt,
    String? defaultDateFormat,
  }) {
    return Holiday(
      id: id ?? this.id,
      start_date: start_date ?? this.start_date,
      end_date: end_date ?? this.end_date,
      title: title ?? this.title,
      description: description ?? this.description,
      schoolId: schoolId ?? this.schoolId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      defaultDateFormat: defaultDateFormat ?? this.defaultDateFormat,
    );
  }

  Holiday.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        start_date = json['start_date'] as String?,
        end_date = json['end_date'] as String?,
        title = json['title'] as String?,
        description = json['description'] as String?,
        schoolId = json['school_id'] as int?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?,
       defaultDateFormat = json['default_date_format']?['start_date'] as String?;


  Map<String, dynamic> toJson() => {
        'id': id,
        'start_date': start_date,
        'end_date': end_date,
        'title': title,
        'description': description,
        'school_id': schoolId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'default_date_format': defaultDateFormat
      };
}
