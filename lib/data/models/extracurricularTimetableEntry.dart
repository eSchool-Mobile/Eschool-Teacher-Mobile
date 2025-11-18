class ExtracurricularTimetableEntry {
  final int? id;
  final String? extracurricularId;
  final String? extracurricularName;
  final String day;
  final String startTime;
  final String endTime;
  final String? createdAt;
  final String? updatedAt;

  ExtracurricularTimetableEntry({
    this.id,
    this.extracurricularId,
    this.extracurricularName,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.createdAt,
    this.updatedAt,
  });

  factory ExtracurricularTimetableEntry.fromJson(Map<String, dynamic> json) {
    return ExtracurricularTimetableEntry(
      id: json['id'] as int?,
      extracurricularId: json['extracurricular_id']?.toString(),
      extracurricularName: json['extracurricular_name'] as String?,
      day: json['day'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'extracurricular_id': extracurricularId,
        'extracurricular_name': extracurricularName,
        'day': day,
        'start_time': startTime,
        'end_time': endTime,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  // Create request body for API
  Map<String, dynamic> toCreateRequest() => {
        'extracurricular_id': extracurricularId,
        'day': day,
        'start_time': startTime,
        'end_time': endTime,
      };

  // Copy with method for updates
  ExtracurricularTimetableEntry copyWith({
    int? id,
    String? extracurricularId,
    String? extracurricularName,
    String? day,
    String? startTime,
    String? endTime,
    String? createdAt,
    String? updatedAt,
  }) {
    return ExtracurricularTimetableEntry(
      id: id ?? this.id,
      extracurricularId: extracurricularId ?? this.extracurricularId,
      extracurricularName: extracurricularName ?? this.extracurricularName,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get formatted time range
  String get timeRange => '$startTime - $endTime';

  // Get day name in Indonesian
  String get dayInIndonesian {
    switch (day.toLowerCase()) {
      case 'monday':
        return 'Senin';
      case 'tuesday':
        return 'Selasa';
      case 'wednesday':
        return 'Rabu';
      case 'thursday':
        return 'Kamis';
      case 'friday':
        return 'Jumat';
      case 'saturday':
        return 'Sabtu';
      case 'sunday':
        return 'Minggu';
      default:
        return day;
    }
  }

  // Validate time format (HH:MM)
  static bool isValidTimeFormat(String time) {
    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return timeRegex.hasMatch(time);
  }

  // Check if end time is after start time
  bool get isValidTimeRange {
    if (!isValidTimeFormat(startTime) || !isValidTimeFormat(endTime)) {
      return false;
    }

    final startParts = startTime.split(':');
    final endParts = endTime.split(':');

    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    return endMinutes > startMinutes;
  }

  @override
  String toString() {
    return 'ExtracurricularTimetableEntry{id: $id, day: $day, timeRange: $timeRange}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtracurricularTimetableEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
