import 'package:eschool_saas_staff/data/models/leaveDetails.dart';
import 'package:eschool_saas_staff/data/repositories/leaveRepository.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      print('=== DEBUG: Fetching General Leaves ===');
      print('LeaveDayType: $leaveDayType');

      emit(GeneralLeavesFetchInProgress());
      print('State: GeneralLeavesFetchInProgress');

      final leaves =
          await _leaveRepository.getLeaves(leaveDayType: leaveDayType);
      print('Leaves fetched successfully');
      print('Number of leaves: ${leaves.length}');
      if (leaves.isEmpty) {
        print('WARNING: No leaves found in response');
      } else {
        print('First leave details: ${leaves.first.toString()}');
      }

      emit(GeneralLeavesFetchSuccess(leaves: leaves));
      print('State: GeneralLeavesFetchSuccess with ${leaves.length} leaves');
      print('=== DEBUG: End Fetching General Leaves ===\n');
    } catch (e) {
      print('=== DEBUG: Error Fetching General Leaves ===');
      print('Error: $e');
      print('Stack trace:\n${StackTrace.current}');
      print('=== DEBUG: End Error ===\n');
      emit(GeneralLeavesFetchFailure(e.toString()));
    }
  }
}
