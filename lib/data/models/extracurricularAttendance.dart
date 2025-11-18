class ExtracurricularAttendance {
  final int? id;
  final int? studentId;
  final String? studentName;
  final String? studentNisn;
  final String? className;
  final int? attendanceType; // 0=absent, 1=present, 2=sick, 3=permit
  final String? date;
  final int? extracurricularId;
  final String? extracurricularName;

  const ExtracurricularAttendance({
    this.id,
    this.studentId,
    this.studentName,
    this.studentNisn,
    this.className,
    this.attendanceType,
    this.date,
    this.extracurricularId,
    this.extracurricularName,
  });

  // Factory constructor from JSON
  factory ExtracurricularAttendance.fromJson(Map<String, dynamic> json) {
    return ExtracurricularAttendance(
      id: json['id'],
      studentId: json['student_id'] ?? json['studentId'],
      studentName: json['name'] ?? json['student_name'] ?? json['studentName'],
      studentNisn: json['student_nisn'] ?? json['nisn'],
      className: json['class_name'] ?? json['kelas'] ?? json['className'],
      attendanceType: json['attendance_type'] ?? json['type'],
      date: json['date'],
      extracurricularId:
          json['extracurricular_id'] ?? json['ekstrakurikuler_id'],
      extracurricularName:
          json['extracurricular_name'] ?? json['ekstrakurikuler_name'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'name': studentName,
      'student_nisn': studentNisn,
      'class_name': className,
      'attendance_type': attendanceType,
      'date': date,
      'extracurricular_id': extracurricularId,
      'extracurricular_name': extracurricularName,
    };
  }

  // Helper methods for attendance status
  bool get isPresent => attendanceType == 1;
  bool get isAbsent => attendanceType == 0;
  bool get isSick => attendanceType == 2;
  bool get isPermit => attendanceType == 3;

  String get attendanceStatusText {
    switch (attendanceType) {
      case 0:
        return 'Tidak Hadir';
      case 1:
        return 'Hadir';
      case 2:
        return 'Sakit';
      case 3:
        return 'Izin';
      default:
        return 'Tidak Diketahui';
    }
  }

  // Copy with method
  ExtracurricularAttendance copyWith({
    int? id,
    int? studentId,
    String? studentName,
    String? studentNisn,
    String? className,
    int? attendanceType,
    String? date,
    int? extracurricularId,
    String? extracurricularName,
  }) {
    return ExtracurricularAttendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentNisn: studentNisn ?? this.studentNisn,
      className: className ?? this.className,
      attendanceType: attendanceType ?? this.attendanceType,
      date: date ?? this.date,
      extracurricularId: extracurricularId ?? this.extracurricularId,
      extracurricularName: extracurricularName ?? this.extracurricularName,
    );
  }

  @override
  String toString() {
    return 'ExtracurricularAttendance(id: $id, studentId: $studentId, studentName: $studentName, attendanceType: $attendanceType, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExtracurricularAttendance &&
        other.id == id &&
        other.studentId == studentId &&
        other.attendanceType == attendanceType &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        studentId.hashCode ^
        attendanceType.hashCode ^
        date.hashCode;
  }
}

// Model untuk response API show attendance
class ExtracurricularAttendanceResponse {
  final int? attendanceId;
  final int? extracurricularId;
  final String? date;
  final List<ExtracurricularAttendance> members;

  const ExtracurricularAttendanceResponse({
    this.attendanceId,
    this.extracurricularId,
    this.date,
    required this.members,
  });

  factory ExtracurricularAttendanceResponse.fromJson(
      Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final membersList = data['members'] as List<dynamic>? ?? [];

    return ExtracurricularAttendanceResponse(
      attendanceId: data['attendance_id'],
      extracurricularId: data['ekstrakurikuler_id'],
      date: data['date'],
      members: membersList
          .map((memberJson) => ExtracurricularAttendance.fromJson(memberJson))
          .toList(),
    );
  }
}

// Model untuk request save attendance
class ExtracurricularAttendanceRequest {
  final int extracurricularId;
  final String date;
  final List<AttendanceData> attendanceData;

  const ExtracurricularAttendanceRequest({
    required this.extracurricularId,
    required this.date,
    required this.attendanceData,
  });

  Map<String, dynamic> toJson() {
    return {
      'ekstrakurikuler_id': extracurricularId,
      'date': date,
      'attendance_data': attendanceData.map((data) => data.toJson()).toList(),
    };
  }
}

class AttendanceData {
  final int id; // student id
  final int type; // 0=absent, 1=present, 2=sick, 3=permit

  const AttendanceData({
    required this.id,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
    };
  }
}

// Model untuk response save attendance
class ExtracurricularAttendanceSaveResponse {
  final bool success;
  final String message;
  final int? attendanceId;
  final int? savedCount;

  const ExtracurricularAttendanceSaveResponse({
    required this.success,
    required this.message,
    this.attendanceId,
    this.savedCount,
  });

  factory ExtracurricularAttendanceSaveResponse.fromJson(
      Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return ExtracurricularAttendanceSaveResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      attendanceId: data['attendance_id'],
      savedCount: data['saved_count'],
    );
  }
}
