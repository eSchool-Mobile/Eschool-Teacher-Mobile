import 'package:eschool_saas_staff/data/repositories/subjectAttendanceRepository.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SubmitAttendanceSubjectState {}

class SubmitAttendanceSubjectInitial extends SubmitAttendanceSubjectState {}

class SubmitAttendanceSubjectInProgress extends SubmitAttendanceSubjectState {}

class SubmitAttendanceSubjectSuccess extends SubmitAttendanceSubjectState {}

class SubmitAttendanceSubjectFailure extends SubmitAttendanceSubjectState {
  final String errorMessage;

  SubmitAttendanceSubjectFailure(this.errorMessage);
}

class SubmitAttendanceSubjectCubit extends Cubit<SubmitAttendanceSubjectState> {
  final SubjectAttendanceRepository _subjectAttendanceRepository =
      SubjectAttendanceRepository();

  SubmitAttendanceSubjectCubit() : super(SubmitAttendanceSubjectInitial());

  Future<void> submitSubjectAttendance({
    required DateTime date,
    required int classSectionId,
    required int timetableId,
    required int jumlahJp,
    required String materi,
    required String lampiran,
    required List<({StudentAttendanceStatus status, int studentId})>
        attendanceReport,
  }) async {
    emit(SubmitAttendanceSubjectInProgress());
    try {
      await _subjectAttendanceRepository.submitSubjectAttendance(
        classSectionId: classSectionId,
        date: "${date.year}-${date.month}-${date.day}",
        timetableId: timetableId,
        jumlahJp: jumlahJp,
        materi: materi,
        lampiran: lampiran,
        attendance: attendanceReport
            .map(
              (attendanceReport) => {
                "student_id": attendanceReport.studentId,
                "type": _mapAttendanceStatusToType(attendanceReport.status),
              },
            )
            .toList(),
      );
      emit(SubmitAttendanceSubjectSuccess());
    } catch (e) {
      print("Error during attendance submission: $e");
      emit(SubmitAttendanceSubjectFailure(e.toString()));
    }
  }

  int _mapAttendanceStatusToType(StudentAttendanceStatus status) {
    switch (status) {
      case StudentAttendanceStatus.present:
        return 1;
      case StudentAttendanceStatus.absent:
        return 0;
      case StudentAttendanceStatus.sick:
        return 2;
      case StudentAttendanceStatus.permission:
        return 3;
      case StudentAttendanceStatus.alpa:
        return 4;
      default:
        return 0; // Default ke absent jika status tidak dikenali
    }
  }
}
