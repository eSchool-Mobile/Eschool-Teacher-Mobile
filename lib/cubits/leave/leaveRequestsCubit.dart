import 'package:eschool_saas_staff/data/models/leave/leaveRequest.dart';
import 'package:eschool_saas_staff/data/repositories/leave/leaveRepository.dart';
import 'package:eschool_saas_staff/utils/system/errorMessageUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

abstract class LeaveRequestsState {}

class LeaveRequestsInitial extends LeaveRequestsState {}

class LeaveRequestsFetchInProgress extends LeaveRequestsState {}

class LeaveRequestsFetchSuccess extends LeaveRequestsState {
  final List<LeaveRequest> leaveRequests;

  LeaveRequestsFetchSuccess({required this.leaveRequests});
}

class LeaveRequestsFetchFailure extends LeaveRequestsState {
  final String errorMessage;

  LeaveRequestsFetchFailure(this.errorMessage);
}

class LeaveRequestsCubit extends Cubit<LeaveRequestsState> {
  final LeaveRepository _leaveRepository = LeaveRepository();

  LeaveRequestsCubit() : super(LeaveRequestsInitial());

  void getLeaveRequests() async {
    try {
      emit(LeaveRequestsFetchInProgress());

      final leaveRequests = await _leaveRepository.getLeaveRequests();

      emit(LeaveRequestsFetchSuccess(leaveRequests: leaveRequests));
    } catch (e) {
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(LeaveRequestsFetchFailure(userFriendlyMessage));
      debugPrint(
          'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }
}
