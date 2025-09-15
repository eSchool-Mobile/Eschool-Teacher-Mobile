import 'package:eschool_saas_staff/data/repositories/permissionRepository.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ApproveOrRejectStudentPermissionState {}

class ApproveOrRejectStudentPermissionInitial
    extends ApproveOrRejectStudentPermissionState {}

class ApproveOrRejectStudentPermissionInProgress
    extends ApproveOrRejectStudentPermissionState {}

class ApproveOrRejectStudentPermissionSuccess
    extends ApproveOrRejectStudentPermissionState {}

class ApproveOrRejectStudentPermissionFailure
    extends ApproveOrRejectStudentPermissionState {
  final String errorMessage;

  ApproveOrRejectStudentPermissionFailure(this.errorMessage);
}

class ApproveOrRejectStudentPermissionCubit
    extends Cubit<ApproveOrRejectStudentPermissionState> {
  final PermissionRepository _permissionRepository = PermissionRepository();

  ApproveOrRejectStudentPermissionCubit()
      : super(ApproveOrRejectStudentPermissionInitial());

  void approveOrRejectStudentPermission(
      {required int leaveId,
      required bool approveLeave,
      String? rejectReason}) async {
    try {
      // Validation: if rejecting, reject_reason must be provided
      if (!approveLeave &&
          (rejectReason == null || rejectReason.trim().isEmpty)) {
        emit(ApproveOrRejectStudentPermissionFailure(
            "Alasan penolakan wajib diisi saat menolak izin siswa"));
        return;
      }

      emit(ApproveOrRejectStudentPermissionInProgress());
      await _permissionRepository.approveOrRejectStudentPermission(
          leaveId: leaveId,
          status: approveLeave ? 1 : 2,
          rejectionReason: rejectReason);
      //// 0 -> Pending, 1 -> Approved, 2 -> Rejected
      emit(ApproveOrRejectStudentPermissionSuccess());
    } catch (e) {
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(ApproveOrRejectStudentPermissionFailure(userFriendlyMessage));
      print(
          'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }
}
