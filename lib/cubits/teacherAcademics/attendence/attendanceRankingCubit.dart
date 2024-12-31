import 'package:eschool_saas_staff/data/models/attendanceRanking.dart';
import 'package:eschool_saas_staff/data/repositories/attendanceRankingRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AttendanceRankingState {}

class AttendanceRankingInitial extends AttendanceRankingState {}

class AttendanceRankingInProgress extends AttendanceRankingState {}

class AttendanceRankingFetchSuccess extends AttendanceRankingState {
  final AttendanceRanking attendanceRanking;

  AttendanceRankingFetchSuccess({required this.attendanceRanking});
}

class AttendanceRankingFetchFailure extends AttendanceRankingState {
  final String errorMessage;

  AttendanceRankingFetchFailure(this.errorMessage);
}

class AttendanceRankingCubit extends Cubit<AttendanceRankingState> {
  final AttendanceRankingRepository _attendanceRankingRepository =
      AttendanceRankingRepository();

  AttendanceRankingCubit() : super(AttendanceRankingInitial());

  void getAttendanceRanking() async {
    try {
      emit(AttendanceRankingInProgress());
      final result = await _attendanceRankingRepository.getAttendanceRankings();
      emit(AttendanceRankingFetchSuccess(attendanceRanking: result));
    } catch (e) {
      emit(AttendanceRankingFetchFailure(e.toString()));
    }
  }
}
