class AttendanceRanking {
  final List<GroupedByClassLevel>? groupedByClassLevel;
  final List<AllStudents>? allStudents;

  AttendanceRanking({
    this.groupedByClassLevel,
    this.allStudents,
  });

  factory AttendanceRanking.fromJson(Map<String, dynamic> json) {
    return AttendanceRanking(
      groupedByClassLevel: (json['grouped_by_class_level'] as List<dynamic>?)
          ?.map((e) => GroupedByClassLevel.fromJson(e as Map<String, dynamic>))
          .toList(),
      allStudents: (json['all_students'] as List<dynamic>?)
          ?.map((e) => AllStudents.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GroupedByClassLevel {
  final String? classLevel;
  final List<TopStudents>? topStudents;

  GroupedByClassLevel({this.classLevel, this.topStudents});

  factory GroupedByClassLevel.fromJson(Map<String, dynamic> json) {
    return GroupedByClassLevel(
      classLevel: json['class_level'] as String?,
      topStudents: (json['top_students'] as List<dynamic>?)
          ?.map((e) => TopStudents.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TopStudents {
  final int? rank;
  final String? className;
  final String? studentName;
  final int? studentId;
  final String? jumlahJpSum;
  final String? point;

  TopStudents({
    this.rank,
    this.className,
    this.studentName,
    this.studentId,
    this.jumlahJpSum,
    this.point,
  });

  factory TopStudents.fromJson(Map<String, dynamic> json) {
    return TopStudents(
      rank: json['rank'] as int?,
      className: json['class'] as String?,
      studentName: json['student_name'] as String?,
      studentId: json['student_id'] as int?,
      jumlahJpSum: json['jumlah_jp_sum'] as String?,
      point: json['point'] as String?,
    );
  }
}

class AllStudents {
  final int? studentId;
  final String? studentName;
  final String? classLevel;
  final String? className;
  final String? jumlahJpSum;
  final String? point;

  AllStudents({
    this.studentId,
    this.studentName,
    this.classLevel,
    this.className,
    this.jumlahJpSum,
    this.point,
  });

  factory AllStudents.fromJson(Map<String, dynamic> json) {
    return AllStudents(
      studentId: json['student_id'] as int?,
      studentName: json['student_name'] as String?,
      classLevel: json['class_level'] as String?,
      className: json['class'] as String?,
      jumlahJpSum: json['jumlah_jp_sum'] as String?,
      point: json['point'] as String?,
    );
  }
}
