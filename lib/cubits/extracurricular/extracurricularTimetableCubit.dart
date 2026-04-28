import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/extracurricular/extracurricularTimetable.dart';
import 'package:eschool_saas_staff/data/repositories/extracurricular/extracurricularTimetableRepository.dart';
import 'package:flutter/foundation.dart';

abstract class ExtracurricularTimetableState {}

class ExtracurricularTimetableInitial extends ExtracurricularTimetableState {}

class ExtracurricularTimetableLoading extends ExtracurricularTimetableState {}

class ExtracurricularTimetableSuccess extends ExtracurricularTimetableState {
  final List<ExtracurricularTimetable> timetables;

  ExtracurricularTimetableSuccess(this.timetables);
}

class ExtracurricularTimetableFailure extends ExtracurricularTimetableState {
  final String errorMessage;

  ExtracurricularTimetableFailure(this.errorMessage);
}

class ExtracurricularTimetableCubit
    extends Cubit<ExtracurricularTimetableState> {
  final ExtracurricularTimetableRepository _repository;

  ExtracurricularTimetableCubit(this._repository)
      : super(ExtracurricularTimetableInitial());

  Future<void> getExtracurricularTimetable() async {
    debugPrint('🚀 [EXTRACURRICULAR TIMETABLE CUBIT] Fetching timetable...');
    emit(ExtracurricularTimetableLoading());
    try {
      final timetables = await _repository.getExtracurricularTimetable();
      debugPrint(
          '✅ [EXTRACURRICULAR TIMETABLE CUBIT] Success: ${timetables.length} items');
      emit(ExtracurricularTimetableSuccess(timetables));
    } catch (e) {
      debugPrint('❌ [EXTRACURRICULAR TIMETABLE CUBIT] Error: $e');
      emit(ExtracurricularTimetableFailure(e.toString()));
    }
  }
}
