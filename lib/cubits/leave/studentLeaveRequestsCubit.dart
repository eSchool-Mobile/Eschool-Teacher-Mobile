import 'package:eschool_saas_staff/data/models/leave/leaveRequest.dart';
import 'package:eschool_saas_staff/data/repositories/leaveRepository.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

abstract class StudentLeaveRequestsState {}

class StudentLeaveRequestsInitial extends StudentLeaveRequestsState {}

class StudentLeaveRequestsFetchInProgress extends StudentLeaveRequestsState {}

class StudentLeaveRequestsFetchSuccess extends StudentLeaveRequestsState {
  final List<LeaveRequest> leaveRequests;

  StudentLeaveRequestsFetchSuccess({required this.leaveRequests});
}

class StudentLeaveRequestsFetchFailure extends StudentLeaveRequestsState {
  final String errorMessage;

  StudentLeaveRequestsFetchFailure(this.errorMessage);
}

class StudentLeaveRequestsCubit extends Cubit<StudentLeaveRequestsState> {
  final LeaveRepository _leaveRepository = LeaveRepository();

  StudentLeaveRequestsCubit() : super(StudentLeaveRequestsInitial());

  void getStudentLeaveRequests() async {
    try {
      emit(StudentLeaveRequestsFetchInProgress());

      final leaveRequests = await _leaveRepository.getStudentLeaveRequests();

      // Create a new list with updated student information
      final updatedLeaveRequests = <LeaveRequest>[];

      for (var leaveRequest in leaveRequests) {
        var updatedRequest = leaveRequest;

        // Fetch student information if user data is missing
        if (leaveRequest.userId != null &&
            (leaveRequest.user?.fullName == null ||
                leaveRequest.user?.fullName?.isEmpty == true)) {
          try {
            final studentInfo = await _leaveRepository.getStudentInfo(
                studentId: leaveRequest.userId!);
            if (studentInfo != null) {
              // Update the leave request with student information using copyWith
              updatedRequest = leaveRequest.copyWith(
                user: User(
                  id: studentInfo.id,
                  firstName: studentInfo.firstName,
                  lastName: studentInfo.lastName,
                  fullName: studentInfo.fullName ??
                      "${studentInfo.firstName ?? ''} ${studentInfo.lastName ?? ''}"
                          .trim(),
                  image: studentInfo.image,
                ),
              );
            }
          } catch (e) {
            // If fetching student info fails, continue with existing data
            debugPrint(
                'Failed to fetch student info for ID ${leaveRequest.userId}: $e');
          }
        }

        updatedLeaveRequests.add(updatedRequest);
      }

      emit(StudentLeaveRequestsFetchSuccess(
          leaveRequests: updatedLeaveRequests));
    } catch (e) {
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(StudentLeaveRequestsFetchFailure(userFriendlyMessage));
      debugPrint(
          'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }
}
