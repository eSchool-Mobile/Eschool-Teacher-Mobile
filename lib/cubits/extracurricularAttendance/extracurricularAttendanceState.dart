import 'package:eschool_saas_staff/data/models/extracurricular/extracurricularAttendance.dart';

abstract class ExtracurricularAttendanceState {}

class ExtracurricularAttendanceInitial extends ExtracurricularAttendanceState {}

class ExtracurricularAttendanceLoading extends ExtracurricularAttendanceState {}

class ExtracurricularAttendanceSuccess extends ExtracurricularAttendanceState {
  final String message;
  final ExtracurricularAttendanceResponse? attendanceData;
  final List<Map<String, dynamic>>? extracurricularList;

  ExtracurricularAttendanceSuccess({
    required this.message,
    this.attendanceData,
    this.extracurricularList,
  });
}

class ExtracurricularAttendanceFailure extends ExtracurricularAttendanceState {
  final String errorMessage;

  ExtracurricularAttendanceFailure(this.errorMessage);
}

// State untuk save attendance
class ExtracurricularAttendanceSaveLoading
    extends ExtracurricularAttendanceState {}

class ExtracurricularAttendanceSaveSuccess
    extends ExtracurricularAttendanceState {
  final String message;
  final int? savedCount;

  ExtracurricularAttendanceSaveSuccess({
    required this.message,
    this.savedCount,
  });
}

class ExtracurricularAttendanceSaveFailure
    extends ExtracurricularAttendanceState {
  final String errorMessage;

  ExtracurricularAttendanceSaveFailure(this.errorMessage);
}
