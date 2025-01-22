import 'package:eschool_saas_staff/data/models/assignment.dart';
import 'package:eschool_saas_staff/data/repositories/assignmentRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';

abstract class AssignmentState {}

class AssignmentInitial extends AssignmentState {}

class AssignmentFetchInProgress extends AssignmentState {}

class AssignmentsFetchSuccess extends AssignmentState {
  final List<Assignment> assignment;
  final int totalPage;
  final int currentPage;
  final bool moreAssignmentsFetchError;
  final bool fetchMoreAssignmentsInProgress;
  AssignmentsFetchSuccess({
    required this.assignment,
    required this.totalPage,
    required this.currentPage,
    required this.moreAssignmentsFetchError,
    required this.fetchMoreAssignmentsInProgress,
  });
  AssignmentsFetchSuccess copyWith({
    final List<Assignment>? newAssignment,
    final int? newTotalPage,
    final int? newCurrentPage,
    final bool? newMoreAssignmentsFetchError,
    final bool? newFetchMoreAssignmentsInProgress,
  }) {
    print("assignment:${newAssignment ?? assignment}");
    print("OK1");
    print("totalPage:${newTotalPage ?? totalPage}");
    print("OK2");
    print("currentPage:${newCurrentPage ?? currentPage}");
    print("OK3");
    print(
        "moreAssignmentsFetchError:${newMoreAssignmentsFetchError ?? moreAssignmentsFetchError}");
    print("OK4");
    print(
        "fetchMoreAssignmentsInProgress:${newFetchMoreAssignmentsInProgress ?? fetchMoreAssignmentsInProgress}");
    print("OK5");

    return AssignmentsFetchSuccess(
      assignment: newAssignment ?? assignment,
      totalPage: newTotalPage ?? totalPage,
      currentPage: newCurrentPage ?? currentPage,
      moreAssignmentsFetchError:
          newMoreAssignmentsFetchError ?? moreAssignmentsFetchError,
      fetchMoreAssignmentsInProgress:
          newFetchMoreAssignmentsInProgress ?? fetchMoreAssignmentsInProgress,
    );
  }
}

class AssignmentFetchFailure extends AssignmentState {
  final String errorMessage;
  AssignmentFetchFailure(this.errorMessage);
}

class AssignmentCubit extends Cubit<AssignmentState> {
  final AssignmentRepository _assignmentRepository = AssignmentRepository();

  AssignmentCubit() : super(AssignmentInitial());

  Future<void> fetchAssignment({
    required int classSectionId,
    required int subjectId,
    int? page,
  }) async {
    try {
      emit(AssignmentFetchInProgress());
      final result = await _assignmentRepository.fetchAssignment(
        classSectionId: classSectionId,
        classSubjectId: subjectId,
        page: page,
      );

      final resultJsonString =
          const JsonEncoder.withIndent('  ').convert(result);
      resultJsonString.split('\n').forEach((line) => print(line));

      emit(AssignmentsFetchSuccess(
        assignment: result.assignments,
        currentPage: result.currentPage,
        totalPage: result.totalPage,
        moreAssignmentsFetchError: false,
        fetchMoreAssignmentsInProgress: false,
      ));
    } catch (e) {
      return emit(
        AssignmentFetchFailure(e.toString()),
      );
    }
  }

  void updateState(AssignmentState updatedState) {
    emit(updatedState);
  }

  bool hasMore() {
    if (state is AssignmentsFetchSuccess) {
      return (state as AssignmentsFetchSuccess).currentPage <
          (state as AssignmentsFetchSuccess).totalPage;
    }
    return false;
  }

  Future<void> fetchMoreAssignment({
    required int classSectionId,
    required int classSubjectId,
  }) async {
    try {
      emit(
        (state as AssignmentsFetchSuccess)
            .copyWith(newFetchMoreAssignmentsInProgress: true),
      );

      print("OKOEYYYYYYYYYYYYYYYYYYYYYYYYY");

      final fetchMoreAssignment = await _assignmentRepository.fetchAssignment(
        classSectionId: classSectionId,
        classSubjectId: classSubjectId,
        page: (state as AssignmentsFetchSuccess).currentPage + 1,
      );

      final currentState = state as AssignmentsFetchSuccess;

      List<Assignment> assignments = currentState.assignment;

      assignments.addAll(fetchMoreAssignment.assignments);

      emit(
        AssignmentsFetchSuccess(
          assignment: assignments,
          totalPage: fetchMoreAssignment.totalPage,
          currentPage: fetchMoreAssignment.currentPage,
          moreAssignmentsFetchError: false,
          fetchMoreAssignmentsInProgress: false,
        ),
      );
    } catch (e) {
      emit(
        (state as AssignmentsFetchSuccess).copyWith(
          newMoreAssignmentsFetchError: true,
          newFetchMoreAssignmentsInProgress: false,
        ),
      );
    }
  }

  Future<void> deleteAssignment(
    int assignmentId,
  ) async {
    if (state is AssignmentsFetchSuccess) {
      List<Assignment> listOfAssignments =
          (state as AssignmentsFetchSuccess).assignment;

      listOfAssignments.removeWhere((element) => element.id == assignmentId);

      emit(
        AssignmentsFetchSuccess(
          assignment: listOfAssignments,
          currentPage: (state as AssignmentsFetchSuccess).currentPage,
          fetchMoreAssignmentsInProgress:
              (state as AssignmentsFetchSuccess).fetchMoreAssignmentsInProgress,
          moreAssignmentsFetchError:
              (state as AssignmentsFetchSuccess).moreAssignmentsFetchError,
          totalPage: (state as AssignmentsFetchSuccess).totalPage,
        ),
      );
    }
  }
}
