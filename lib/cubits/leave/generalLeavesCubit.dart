import 'package:eschool_saas_staff/data/models/leaveDetails.dart';
import 'package:eschool_saas_staff/data/repositories/leaveRepository.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

abstract class GeneralLeavesState {}

class GeneralLeavesInitial extends GeneralLeavesState {}

class GeneralLeavesFetchInProgress extends GeneralLeavesState {}

class GeneralLeavesFetchSuccess extends GeneralLeavesState {
  final List<LeaveDetails> leaves;

  GeneralLeavesFetchSuccess({required this.leaves});
}

class GeneralLeavesFetchFailure extends GeneralLeavesState {
  final String errorMessage;

  GeneralLeavesFetchFailure(this.errorMessage);
}

class GeneralLeavesCubit extends Cubit<GeneralLeavesState> {
  final LeaveRepository _leaveRepository = LeaveRepository();

  GeneralLeavesCubit() : super(GeneralLeavesInitial());

  void getGeneralLeaves({required LeaveDayType leaveDayType}) async {
    try {
      debugPrint('=== DEBUG: Fetching General Leaves ===');
      debugPrint('LeaveDayType: $leaveDayType');

      emit(GeneralLeavesFetchInProgress());
      debugPrint('State: GeneralLeavesFetchInProgress');

      final leaves =
          await _leaveRepository.getLeaves(leaveDayType: leaveDayType);
      debugPrint('Leaves fetched successfully');
      debugPrint('Number of leaves: ${leaves.length}');
      if (leaves.isEmpty) {
        debugPrint('WARNING: No leaves found in response');
      } else {
        debugPrint('First leave details: ${leaves.first.toString()}');
      }

      emit(GeneralLeavesFetchSuccess(leaves: leaves));
      debugPrint('State: GeneralLeavesFetchSuccess with ${leaves.length} leaves');
      debugPrint('=== DEBUG: End Fetching General Leaves ===\n');
    } catch (e) {
      debugPrint('=== DEBUG: Error Fetching General Leaves ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace:\n${StackTrace.current}');
      debugPrint('=== DEBUG: End Error ===\n');
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(GeneralLeavesFetchFailure(userFriendlyMessage));
      debugPrint(
          'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }
}
