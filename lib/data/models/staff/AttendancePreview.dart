class AttendancePreview {
  final String studentName;
  final int present;
  final int absent;
  final int late;
  final double percentage;

  AttendancePreview({
    required this.studentName,
    required this.present,
    required this.absent,
    required this.late,
    required this.percentage,
  });
}
