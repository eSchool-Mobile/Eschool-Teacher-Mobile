import 'package:eschool_saas_staff/data/repositories/leaveRepository.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ApproveOrRejectStudentLeaveRequestState {}

class ApproveOrRejectStudentLeaveRequestInitial
    extends ApproveOrRejectStudentLeaveRequestState {}

class ApproveOrRejectStudentLeaveRequestInProgress
    extends ApproveOrRejectStudentLeaveRequestState {}

class ApproveOrRejectStudentLeaveRequestSuccess
    extends ApproveOrRejectStudentLeaveRequestState {}

class ApproveOrRejectStudentLeaveRequestFailure
    extends ApproveOrRejectStudentLeaveRequestState {
  final String errorMessage;

  ApproveOrRejectStudentLeaveRequestFailure(this.errorMessage);
}

class ApproveOrRejectStudentLeaveRequestCubit
    extends Cubit<ApproveOrRejectStudentLeaveRequestState> {
  final LeaveRepository _leaveRepository = LeaveRepository();

  ApproveOrRejectStudentLeaveRequestCubit()
      : super(ApproveOrRejectStudentLeaveRequestInitial());

  void approveOrRejectStudentLeaveRequest(
      {required int leaveRequestId,
      required bool approveLeave,
      String? rejectReason}) async {
    try {
      // Validasi tambahan: jika menolak, reject_reason harus ada
      if (!approveLeave &&
          (rejectReason == null || rejectReason.trim().isEmpty)) {
        emit(ApproveOrRejectStudentLeaveRequestFailure(
            "Alasan penolakan wajib diisi saat menolak permohonan izin siswa"));
        return;
      }

      emit(ApproveOrRejectStudentLeaveRequestInProgress());
      await _leaveRepository.approveOrRejectStudentLeaveRequest(
          leaveRequestId: leaveRequestId,
          status: approveLeave ? 1 : 2,
          rejectReason: rejectReason);
      //// 0 -> Pending, 1 -> Approved, 2 -> Rejected
      emit(ApproveOrRejectStudentLeaveRequestSuccess());
    } catch (e) {
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(ApproveOrRejectStudentLeaveRequestFailure(userFriendlyMessage));
      print(
          'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }
}
