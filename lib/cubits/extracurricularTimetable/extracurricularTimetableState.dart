part of 'extracurricularTimetableCubit.dart';

abstract class ExtracurricularTimetableState {}

class ExtracurricularTimetableInitial extends ExtracurricularTimetableState {}

class ExtracurricularTimetableLoading extends ExtracurricularTimetableState {}

class ExtracurricularTimetableSuccess extends ExtracurricularTimetableState {
  final String message;
  final List<ExtracurricularTimetable>? timetables;

  ExtracurricularTimetableSuccess(this.message, {this.timetables});
}

class ExtracurricularTimetableFailure extends ExtracurricularTimetableState {
  final String error;

  ExtracurricularTimetableFailure(this.error);
}
