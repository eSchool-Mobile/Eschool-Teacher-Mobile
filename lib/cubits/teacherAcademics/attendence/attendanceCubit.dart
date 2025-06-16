import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:eschool_saas_staff/data/models/studentAttendance.dart';
import 'package:eschool_saas_staff/data/repositories/attendanceRepository.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceFetchInProgress extends AttendanceState {}

class AttendanceFetchSuccess extends AttendanceState {
  final List<StudentAttendance> attendance;
  final bool isHoliday;
  final Holiday holidayDetails;

  AttendanceFetchSuccess({
    required this.attendance,
    required this.isHoliday,
    required this.holidayDetails,
  });

  @override
  String toString() {
    return 'AttendanceFetchSuccess(attendance: $attendance, isHoliday: $isHoliday, holidayDetails: $holidayDetails)';
  }
}

class AttendanceFetchFailure extends AttendanceState {
  final String errorMessage;

  AttendanceFetchFailure(this.errorMessage);
}

class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRepository _attendanceRepository = AttendanceRepository();

  AttendanceCubit() : super(AttendanceInitial());

  Future<void> fetchAttendance({
    required int classSectionId,
    required DateTime date,
    required int? type,
  }) async {
    emit(AttendanceFetchInProgress());
    try {
      final result = await _attendanceRepository.getAttendance(
        classSectionId: classSectionId,
        date: "${date.year}-${date.month}-${date.day}",
        type: type,
      );

      print("API Response1: ${result.attendance}");

      emit(
        AttendanceFetchSuccess(
          attendance: result.attendance,
          isHoliday: result.isHoliday,
          holidayDetails: result.holidayDetails,
        ),
      );
    } catch (e, stackTrace) {
      print("Error fetching attendance: $e");
      print("Stack trace: $stackTrace");
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(AttendanceFetchFailure(userFriendlyMessage));
      print(
          'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }
}
