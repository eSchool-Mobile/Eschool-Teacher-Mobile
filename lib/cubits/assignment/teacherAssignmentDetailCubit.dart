import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/staffTeacher/teacherAssignmentDetail.dart';
import 'package:eschool_saas_staff/data/repositories/academics/assignmentMonitoringRepository.dart';
import 'package:equatable/equatable.dart';

// States
abstract class TeacherAssignmentDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TeacherAssignmentDetailInitial extends TeacherAssignmentDetailState {}

class TeacherAssignmentDetailLoading extends TeacherAssignmentDetailState {}

class TeacherAssignmentDetailSuccess extends TeacherAssignmentDetailState {
  final List<TeacherAssignmentDetail> assignments;
  final int teacherId;
  final String? submissionStatus;
  final String? startDate;
  final String? endDate;

  TeacherAssignmentDetailSuccess({
    required this.assignments,
    required this.teacherId,
    this.submissionStatus,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props =>
      [assignments, teacherId, submissionStatus, startDate, endDate];
}

class TeacherAssignmentDetailFailure extends TeacherAssignmentDetailState {
  final String errorMessage;

  TeacherAssignmentDetailFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// Cubit
class TeacherAssignmentDetailCubit extends Cubit<TeacherAssignmentDetailState> {
  final AssignmentMonitoringRepository _assignmentMonitoringRepository;

  TeacherAssignmentDetailCubit(this._assignmentMonitoringRepository)
      : super(TeacherAssignmentDetailInitial());

  Future<void> getTeacherAssignmentDetails({
    required int teacherId,
    String? submissionStatus,
    String? startDate,
    String? endDate,
  }) async {
    try {
      emit(TeacherAssignmentDetailLoading());

      final result =
          await _assignmentMonitoringRepository.getTeacherAssignmentDetails(
        teacherId: teacherId,
        submissionStatus: submissionStatus,
        startDate: startDate,
        endDate: endDate,
      );

      final teacherAssignmentDetail =
          result['data'] as TeacherAssignmentDetailResponse;

      emit(TeacherAssignmentDetailSuccess(
        assignments: teacherAssignmentDetail.data,
        teacherId: teacherId,
        submissionStatus: submissionStatus,
        startDate: startDate,
        endDate: endDate,
      ));
    } catch (e) {
      emit(TeacherAssignmentDetailFailure(e.toString()));
    }
  }
}
