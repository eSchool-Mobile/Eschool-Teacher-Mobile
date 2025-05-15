class AssignmentMonitoringResponse {
  final bool error;
  final String message;
  final AssignmentMonitoringData data;

  AssignmentMonitoringResponse({
    required this.error,
    required this.message,
    required this.data,
  });

  factory AssignmentMonitoringResponse.fromJson(Map<String, dynamic> json) {
    return AssignmentMonitoringResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: AssignmentMonitoringData.fromJson(json['data'] ?? {}),
    );
  }
}

class AssignmentMonitoringData {
  final int total;
  final List<AssignmentMonitoring> rows;

  AssignmentMonitoringData({
    required this.total,
    required this.rows,
  });

  factory AssignmentMonitoringData.fromJson(Map<String, dynamic> json) {
    List<AssignmentMonitoring> rows = [];
    if (json['rows'] != null && json['rows'] is List) {
      rows = (json['rows'] as List)
          .map((item) => AssignmentMonitoring.fromJson(item))
          .toList();
    }

    return AssignmentMonitoringData(
      total: json['total'] ?? 0,
      rows: rows,
    );
  }
}

class AssignmentMonitoring {
  final int id;
  final int no;
  final String teacherName;
  final int totalAssignments;

  AssignmentMonitoring({
    required this.id,
    required this.no,
    required this.teacherName,
    required this.totalAssignments,
  });

  factory AssignmentMonitoring.fromJson(Map<String, dynamic> json) {
    return AssignmentMonitoring(
      id: json['id'] ?? 0,
      no: json['no'] ?? 0,
      teacherName: json['teacher_name'] ?? '',
      totalAssignments: json['total_assignments'] ?? 0,
    );
  }
}
