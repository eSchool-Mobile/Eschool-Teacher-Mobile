import 'package:eschool_saas_staff/data/models/staff/studentDetails.dart';
import 'package:eschool_saas_staff/data/repositories/feeRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StudentsFeeStatusState {}

class StudentsFeeStatusInitial extends StudentsFeeStatusState {}

class StudentsFeeStatusFetchInProgress extends StudentsFeeStatusState {}

class StudentsFeeStatusFetchSuccess extends StudentsFeeStatusState {
  final int totalPage;
  final int currentPage;
  final List<StudentDetails> students;

  final bool fetchMoreError;
  final bool fetchMoreInProgress;
  final double compolsoryFeeAmount;
  final double optionalFeeAmount;

  // New metadata fields
  final String feesType;
  final String className;
  final double totalAmount;
  final String dueDate;
  final int totalStudents;
  final int paidStudents;
  final int unpaidStudents;

  StudentsFeeStatusFetchSuccess({
    required this.currentPage,
    required this.students,
    required this.fetchMoreError,
    required this.fetchMoreInProgress,
    required this.totalPage,
    required this.compolsoryFeeAmount,
    required this.optionalFeeAmount,
    this.feesType = "",
    this.className = "",
    this.totalAmount = 0.0,
    this.dueDate = "",
    this.totalStudents = 0,
    this.paidStudents = 0,
    this.unpaidStudents = 0,
  });

  StudentsFeeStatusFetchSuccess copyWith({
    int? currentPage,
    bool? fetchMoreError,
    bool? fetchMoreInProgress,
    int? totalPage,
    List<StudentDetails>? students,
    double? compolsoryFeeAmount,
    double? optionalFeeAmount,
    String? feesType,
    String? className,
    double? totalAmount,
    String? dueDate,
    int? totalStudents,
    int? paidStudents,
    int? unpaidStudents,
  }) {
    return StudentsFeeStatusFetchSuccess(
      compolsoryFeeAmount: compolsoryFeeAmount ?? this.compolsoryFeeAmount,
      optionalFeeAmount: optionalFeeAmount ?? this.optionalFeeAmount,
      currentPage: currentPage ?? this.currentPage,
      students: students ?? this.students,
      fetchMoreError: fetchMoreError ?? this.fetchMoreError,
      fetchMoreInProgress: fetchMoreInProgress ?? this.fetchMoreInProgress,
      totalPage: totalPage ?? this.totalPage,
      feesType: feesType ?? this.feesType,
      className: className ?? this.className,
      totalAmount: totalAmount ?? this.totalAmount,
      dueDate: dueDate ?? this.dueDate,
      totalStudents: totalStudents ?? this.totalStudents,
      paidStudents: paidStudents ?? this.paidStudents,
      unpaidStudents: unpaidStudents ?? this.unpaidStudents,
    );
  }
}

class StudentsFeeStatusFetchFailure extends StudentsFeeStatusState {
  final String errorMessage;

  StudentsFeeStatusFetchFailure(this.errorMessage);
}

class StudentsFeeStatusCubit extends Cubit<StudentsFeeStatusState> {
  final FeeRepository _feeRepository = FeeRepository();

  // Store the search query for pagination
  String _searchQuery = "";

  StudentsFeeStatusCubit() : super(StudentsFeeStatusInitial());

  void getStudentFeePaymentStatus({
    required int sessionYearId,
    required int status,
    required int feeId,
    String? search,
  }) async {
    emit(StudentsFeeStatusFetchInProgress());
    _searchQuery = search ?? "";

    try {
      final result = await _feeRepository.getStudentsFeePaymentStatus(
        sessionYearId: sessionYearId,
        status: status,
        feeId: feeId,
        search: _searchQuery,
      );

      emit(StudentsFeeStatusFetchSuccess(
        currentPage: result.currentPage,
        students: result.students,
        fetchMoreError: false,
        fetchMoreInProgress: false,
        compolsoryFeeAmount: result.compolsoryFeeAmount,
        optionalFeeAmount: result.optionalFeeAmount,
        totalPage: result.totalPage,
        feesType: result.feesType,
        className: result.className,
        totalAmount: result.totalAmount,
        dueDate: result.dueDate,
        totalStudents: result.totalStudents,
        paidStudents: result.paidStudents,
        unpaidStudents: result.unpaidStudents,
      ));
    } catch (e) {
      emit(StudentsFeeStatusFetchFailure(e.toString()));
    }
  }

  bool hasMore() {
    if (state is StudentsFeeStatusFetchSuccess) {
      return (state as StudentsFeeStatusFetchSuccess).currentPage <
          (state as StudentsFeeStatusFetchSuccess).totalPage;
    }
    return false;
  }

  void fetchMore({
    required int sessionYearId,
    required int status,
    required int feeId,
  }) async {
    if (state is StudentsFeeStatusFetchSuccess) {
      if ((state as StudentsFeeStatusFetchSuccess).fetchMoreInProgress) {
        return;
      }
      try {
        emit((state as StudentsFeeStatusFetchSuccess)
            .copyWith(fetchMoreInProgress: true));

        final result = await _feeRepository.getStudentsFeePaymentStatus(
          feeId: feeId,
          sessionYearId: sessionYearId,
          status: status,
          search: _searchQuery,
          page: (state as StudentsFeeStatusFetchSuccess).currentPage + 1,
        );

        final currentState = (state as StudentsFeeStatusFetchSuccess);
        List<StudentDetails> students = currentState.students;

        students.addAll(result.students);

        emit(StudentsFeeStatusFetchSuccess(
          compolsoryFeeAmount: result.compolsoryFeeAmount,
          optionalFeeAmount: result.optionalFeeAmount,
          currentPage: result.currentPage,
          fetchMoreError: false,
          fetchMoreInProgress: false,
          totalPage: result.totalPage,
          students: students,
          feesType: result.feesType,
          className: result.className,
          totalAmount: result.totalAmount,
          dueDate: result.dueDate,
          totalStudents: result.totalStudents,
          paidStudents: result.paidStudents,
          unpaidStudents: result.unpaidStudents,
        ));
      } catch (e) {
        emit((state as StudentsFeeStatusFetchSuccess)
            .copyWith(fetchMoreInProgress: false, fetchMoreError: true));
      }
    }
  }
}
