import 'package:eschool_saas_staff/data/models/attendanceStudent.dart';
import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:eschool_saas_staff/data/repositories/subjectAttendanceRepository.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';
import 'package:eschool_saas_staff/utils/logger.dart';
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
    int? timetableId,
    required int gradeLevelId,
  }) async {
    const scope = 'SubjectAttendanceCubit.fetchSubjectAttendance';
    emit(SubjectAttendanceFetchInProgress());
    try {
      AppLogger.info(scope, 'Fetch start', data: {
        'class_section_id': classSectionId,
        'date': date.toIso8601String(),
        'timetable_id': timetableId,
        'grade_level_id': gradeLevelId,
      });

      if (timetableId == null) {
        // No timetable available, emit success with empty data
        AppLogger.debug(
            scope, 'No timetable available, emitting empty success');
        emit(SubjectAttendanceFetchSuccess(
          attendance: [],
          isHoliday: false,
          holidayDetails: Holiday(),
          materi: null,
          lampiran: null,
        ));
        return;
      }

      final result = await _subjectAttendanceRepository.getAttendance(
        classSectionId: classSectionId,
        date: "${date.year}-${date.month}-${date.day}",
        timetableId: timetableId,
        gradeLevelId: gradeLevelId,
      );

      AppLogger.debug(scope, 'Attendance list built', data: {
        'items': result.attendance
            .map((a) => {
                  'id': a.id,
                  'student_id': a.studentId,
                  'type': a.type,
                  'note': a.note,
                })
            .toList(),
      });

      AppLogger.debug(scope, 'Fetch success', data: {
        'attendance_count': result.attendance.length,
        'is_holiday': result.isHoliday,
        'has_lampiran': result.lampiran != null,
        'has_materi': result.materi != null,
      });

      emit(SubjectAttendanceFetchSuccess(
        attendance: result.attendance,
        isHoliday: result.isHoliday,
        holidayDetails: result.holidayDetails,
        materi: result.materi,
        lampiran: result.lampiran,
      ));
    } catch (e, stackTrace) {
      AppLogger.error(scope, 'Fetch failed',
          data: {
            'class_section_id': classSectionId,
            'date': date.toIso8601String(),
            'timetable_id': timetableId,
            'grade_level_id': gradeLevelId,
          },
          error: e,
          stack: stackTrace);
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(SubjectAttendanceFetchFailure(userFriendlyMessage));
      AppLogger.debug(scope, 'User friendly error emitted', data: {
        'user_message': userFriendlyMessage,
        'technical': ErrorMessageUtils.getTechnicalErrorMessage(e),
      });
    }
  }
}
