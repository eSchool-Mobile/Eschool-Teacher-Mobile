import 'package:eschool_saas_staff/data/repositories/permissionRepository.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

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
      // Check if cubit is closed before emitting
      if (isClosed) return;

      // Validation: if rejecting, reject_reason must be provided
      if (!approveLeave &&
          (rejectReason == null || rejectReason.trim().isEmpty)) {
        if (!isClosed) {
          emit(ApproveOrRejectStudentPermissionFailure(
              "Alasan penolakan wajib diisi saat menolak izin siswa"));
        }
        return;
      }

      if (!isClosed) {
        emit(ApproveOrRejectStudentPermissionInProgress());
      }

      await _permissionRepository.approveOrRejectStudentPermission(
          leaveId: leaveId,
          status: approveLeave ? 1 : 2,
          rejectionReason: rejectReason);
      //// 0 -> Pending, 1 -> Approved, 2 -> Rejected

      if (!isClosed) {
        emit(ApproveOrRejectStudentPermissionSuccess());
      }
    } catch (e) {
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      if (!isClosed) {
        emit(ApproveOrRejectStudentPermissionFailure(userFriendlyMessage));
      }
      debugPrint(
          'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }
}
