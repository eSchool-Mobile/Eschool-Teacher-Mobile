// Enum untuk status kehadiran
enum AttendanceStatus {
  absent(0, 'Tidak Hadir', 'Alpa'),
  present(1, 'Hadir', 'Present'),
  sick(2, 'Sakit', 'Sick'),
  permission(3, 'Izin', 'Permission');

  const AttendanceStatus(this.value, this.label, this.englishLabel);

  final int value;
  final String label;
  final String englishLabel;

  static AttendanceStatus fromInt(int value) {
    switch (value) {
      case 0:
        return AttendanceStatus.absent;
      case 1:
        return AttendanceStatus.present;
      case 2:
        return AttendanceStatus.sick;
      case 3:
        return AttendanceStatus.permission;
      default:
        print(
            '⚠️ [ENUM] Unknown attendance status: $value, defaulting to present');
        return AttendanceStatus.present;
    }
  }

  static AttendanceStatus? fromIntNullable(int? value) {
    if (value == null) return null;
    return fromInt(value);
  }
}

// Model untuk data absensi ekstrakurikuler
class ExtracurricularAttendance {
  final int attendanceId; // ID record absensi
  final int studentId; // ID siswa (REQUIRED)
  final String studentName; // Nama siswa (REQUIRED)
  final String? studentNisn; // NISN siswa
  final String? className; // Nama kelas
  final AttendanceStatus status; // Status kehadiran (ENUM)
  final DateTime date; // Tanggal absensi (REQUIRED)
  final int? extracurricularId; // ID ekstrakurikuler
  final String? extracurricularName; // Nama ekstrakurikuler

  const ExtracurricularAttendance({
    required this.attendanceId,
    required this.studentId,
    required this.studentName,
    this.studentNisn,
    this.className,
    required this.status,
    required this.date,
    this.extracurricularId,
    this.extracurricularName,
  });

  // Factory constructor from JSON with proper error handling
  factory ExtracurricularAttendance.fromJson(Map<String, dynamic> json) {
    // Parse date with fallback to current date if null
    DateTime parsedDate;
    try {
      if (json['date'] != null && json['date'] != '') {
        parsedDate = DateTime.parse(json['date']);
      } else {
        print(
            '⚠️ [MODEL] Date is null/empty for attendance ID: ${json['attendance_id'] ?? json['id']}, using current date');
        parsedDate = DateTime.now();
      }
    } catch (e) {
      print(
          '⚠️ [MODEL] Failed to parse date: ${json['date']}, using current date');
      parsedDate = DateTime.now();
    }

    // Parse status with fallback to Present if null/invalid
    AttendanceStatus parsedStatus;
    try {
      final statusValue =
          json['status'] ?? json['attendance_type'] ?? json['type'] ?? 1;
      parsedStatus = AttendanceStatus.fromInt(statusValue);
    } catch (e) {
      print(
          '⚠️ [MODEL] Failed to parse status: ${json['status']}, using Present as default');
      parsedStatus = AttendanceStatus.present;
    }

    return ExtracurricularAttendance(
      attendanceId: json['attendance_id'] ?? json['id'] ?? 0,
      studentId: json['student_id'] ?? json['studentId'] ?? 0,
      studentName: json['student_name'] ??
          json['name'] ??
          json['studentName'] ??
          'Unknown Student',
      studentNisn: json['student_nisn'] ?? json['nisn'],
      className: json['class_name'] ?? json['kelas'] ?? json['className'],
      status: parsedStatus,
      date: parsedDate,
      extracurricularId:
          json['extracurricular_id'] ?? json['ekstrakurikuler_id'],
      extracurricularName: json['eskul_name'] ??
          json['extracurricular_name'] ??
          json['ekstrakurikuler_name'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'attendance_id': attendanceId,
      'student_id': studentId,
      'student_name': studentName,
      'student_nisn': studentNisn,
      'class_name': className,
      'status': status.value,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'extracurricular_id': extracurricularId,
      'extracurricular_name': extracurricularName,
    };
  }

  // Helper methods for attendance status
  bool get isPresent => status == AttendanceStatus.present;
  bool get isAbsent => status == AttendanceStatus.absent;
  bool get isSick => status == AttendanceStatus.sick;
  bool get isPermission => status == AttendanceStatus.permission;

  String get statusText => status.label;
  String get statusEnglishText => status.englishLabel;
  int get statusValue => status.value;

  // Copy with method
  ExtracurricularAttendance copyWith({
    int? attendanceId,
    int? studentId,
    String? studentName,
    String? studentNisn,
    String? className,
    AttendanceStatus? status,
    DateTime? date,
    int? extracurricularId,
    String? extracurricularName,
  }) {
    return ExtracurricularAttendance(
      attendanceId: attendanceId ?? this.attendanceId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentNisn: studentNisn ?? this.studentNisn,
      className: className ?? this.className,
      status: status ?? this.status,
      date: date ?? this.date,
      extracurricularId: extracurricularId ?? this.extracurricularId,
      extracurricularName: extracurricularName ?? this.extracurricularName,
    );
  }

  @override
  String toString() {
    return 'ExtracurricularAttendance(attendanceId: $attendanceId, studentId: $studentId, studentName: $studentName, status: ${status.label}, date: ${date.toIso8601String().split('T')[0]})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExtracurricularAttendance &&
        other.attendanceId == attendanceId &&
        other.studentId == studentId &&
        other.status == status &&
        other.date == date;
  }

  @override
  int get hashCode {
    return attendanceId.hashCode ^
        studentId.hashCode ^
        status.hashCode ^
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
    // Handle both possible response structures
    List<dynamic> membersList = [];

    // Try 'rows' first (actual API response), then 'data.members' (fallback)
    if (json['rows'] != null) {
      membersList = json['rows'] as List<dynamic>;
    } else {
      final data = json['data'] ?? {};
      membersList = data['members'] as List<dynamic>? ?? [];
    }

    return ExtracurricularAttendanceResponse(
      attendanceId: json['attendance_id'] ?? json['data']?['attendance_id'],
      extracurricularId:
          json['ekstrakurikuler_id'] ?? json['data']?['ekstrakurikuler_id'],
      date: json['date'] ?? json['data']?['date'],
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
  final int studentId; // student id (FIXED: was 'id')
  final int type; // 0=absent, 1=present, 2=sick, 3=permit

  const AttendanceData({
    required this.studentId,
    required this.type,
  });

  // Factory from ExtracurricularAttendance
  factory AttendanceData.fromAttendance(ExtracurricularAttendance attendance) {
    return AttendanceData(
      studentId: attendance.studentId,
      type: attendance.status.value,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId, // FIXED: use 'student_id' not 'id'
      'type': type,
    };
  }

  @override
  String toString() {
    return 'AttendanceData(studentId: $studentId, type: $type)';
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
