import 'package:eschool_saas_staff/data/repositories/leaveRepository.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

abstract class ApplyLeaveState {}

class ApplyLeaveInitial extends ApplyLeaveState {}

class ApplyLeaveInProgress extends ApplyLeaveState {}

class ApplyLeaveSuccess extends ApplyLeaveState {}

class ApplyLeaveFailure extends ApplyLeaveState {
  final String errorMessage;

  ApplyLeaveFailure(this.errorMessage);
}

class ApplyLeaveCubit extends Cubit<ApplyLeaveState> {
  final LeaveRepository _leaveRepository = LeaveRepository();

  ApplyLeaveCubit() : super(ApplyLeaveInitial());

  void applyLeave(
      {required String reason,
      required Map<DateTime, String> leaveDays,
      List<String>? attachmentPaths}) async {
    try {
      List<Map<String, String>> leaveDetails = [];

      for (var leaveDay in leaveDays.keys) {
        leaveDetails.add({
          "type": getLeaveTypeValueFromKey(leaveTypeKey: leaveDays[leaveDay]!),
          "date": "${leaveDay.year}-${leaveDay.month}-${leaveDay.day}"
        });
      }
      emit(ApplyLeaveInProgress());
      await _leaveRepository.applyLeave(
        leaves: leaveDetails,
        reason: reason,
        attachmentPaths: attachmentPaths,
      );
      emit(ApplyLeaveSuccess());
    } catch (e) {
      // Gunakan ErrorMessageUtils untuk mengkonversi error teknis menjadi pesan yang ramah
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(ApplyLeaveFailure(userFriendlyMessage));

      // Log technical error untuk debugging (hanya untuk development)
      debugPrint(
          'Technical error in applyLeave: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }
}
