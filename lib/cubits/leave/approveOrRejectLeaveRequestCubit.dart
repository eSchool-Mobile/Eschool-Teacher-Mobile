import 'package:eschool_saas_staff/data/repositories/leave/leaveRepository.dart';
import 'package:eschool_saas_staff/utils/system/errorMessageUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

abstract class ApproveOrRejectLeaveRequestState {}

class ApproveOrRejectLeaveRequestInitial
    extends ApproveOrRejectLeaveRequestState {}

class ApproveOrRejectLeaveRequestInProgress
    extends ApproveOrRejectLeaveRequestState {}

class ApproveOrRejectLeaveRequestSuccess
    extends ApproveOrRejectLeaveRequestState {}

class ApproveOrRejectLeaveRequestFailure
    extends ApproveOrRejectLeaveRequestState {
  final String errorMessage;

  ApproveOrRejectLeaveRequestFailure(this.errorMessage);
}

class ApproveOrRejectLeaveRequestCubit
    extends Cubit<ApproveOrRejectLeaveRequestState> {
  final LeaveRepository _leaveRepository = LeaveRepository();

  ApproveOrRejectLeaveRequestCubit()
      : super(ApproveOrRejectLeaveRequestInitial());

  void approveOrRejectLeaveRequest(
      {required int leaveRequestId,
      required bool approveLeave,
      String? rejectReason}) async {
    try {
      // Validasi tambahan: jika menolak, reject_reason harus ada
      if (!approveLeave &&
          (rejectReason == null || rejectReason.trim().isEmpty)) {
        emit(ApproveOrRejectLeaveRequestFailure(
            "Alasan penolakan wajib diisi saat menolak permohonan cuti"));
        return;
      }

      emit(ApproveOrRejectLeaveRequestInProgress());
      await _leaveRepository.approveOrRejectLeaveRequest(
          leaveRequestId: leaveRequestId,
          status: approveLeave ? 1 : 2,
          rejectReason: rejectReason);
      //// 0 -> Pending, 1 -> Approved, 2 -> Rejected
      emit(ApproveOrRejectLeaveRequestSuccess());
    } catch (e) {
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(ApproveOrRejectLeaveRequestFailure(userFriendlyMessage));
      debugPrint(
          'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }
}
