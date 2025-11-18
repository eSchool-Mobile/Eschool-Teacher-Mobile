part of 'extracurricularTimetableCubit.dart';

abstract class ExtracurricularTimetableState {}

class ExtracurricularTimetableInitial extends ExtracurricularTimetableState {}

class ExtracurricularTimetableLoading extends ExtracurricularTimetableState {}

class ExtracurricularTimetableSuccess extends ExtracurricularTimetableState {
  final String message;

  ExtracurricularTimetableSuccess(this.message);
}

class ExtracurricularTimetableFailure extends ExtracurricularTimetableState {
  final String error;

  ExtracurricularTimetableFailure(this.error);
}
