import 'package:eschool_saas_staff/data/models/attendanceStudent.dart';
import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:eschool_saas_staff/data/repositories/subjectAttendanceRepository.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SubjectAttendanceState {}

class SubjectAttendanceInitial extends SubjectAttendanceState {}

class SubjectAttendanceFetchInProgress extends SubjectAttendanceState {}

class SubjectAttendanceFetchSuccess extends SubjectAttendanceState {
  final List<AttendanceStudent> attendance;
  final bool isHoliday;
  final Holiday holidayDetails;
  final String? materi;
  final String? lampiran;

  SubjectAttendanceFetchSuccess({
    required this.attendance,
    required this.isHoliday,
    required this.holidayDetails,
    this.lampiran,
    this.materi,
  });

  @override
  String toString() {
    return 'SubjectAttendanceFetchSuccess(attendance: $attendance, isHoliday: $isHoliday, holidayDetails: $holidayDetails, materi: $materi, lampiran: $lampiran)';
  }
}

class SubjectAttendanceFetchFailure extends SubjectAttendanceState {
  final String errorMessage;

  SubjectAttendanceFetchFailure(this.errorMessage);
}

class SubjectAttendanceCubit extends Cubit<SubjectAttendanceState> {
  final SubjectAttendanceRepository _subjectAttendanceRepository =
      SubjectAttendanceRepository();

  SubjectAttendanceCubit() : super(SubjectAttendanceInitial());

  Future<void> fetchSubjectAttendance({
    required int classSectionId,
    required DateTime date,
    required int timetableId,
  }) async {
    emit(SubjectAttendanceFetchInProgress());
    try {
      final result = await _subjectAttendanceRepository.getAttendance(
        classSectionId: classSectionId,
        date: "${date.year}-${date.month}-${date.day}",
        timetableId: timetableId,
      );

      print("Attendance Details: ${result.attendance.map((a) => {
            'id': a.id,
            'student_id': a.studentId,
            'type': a.type,
            'note': a.note
          }).toList()}");

      print("API Response2: ${result}");
      emit(SubjectAttendanceFetchSuccess(
        attendance: result.attendance,
        isHoliday: result.isHoliday,
        holidayDetails: result.holidayDetails,
        materi: result.materi,
        lampiran: result.lampiran,
      ));
    } catch (e, stackTrace) {
      print("Error fetching attendance: $e");
      print("Stack trace: $stackTrace");
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(SubjectAttendanceFetchFailure(userFriendlyMessage));
      print(
          'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }
}
