import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/extracurricularTimetableEntry.dart';
import 'package:eschool_saas_staff/data/repositories/extracurricularTimetableRepository.dart';

part 'extracurricularTimetableState.dart';

class ExtracurricularTimetableCubit
    extends Cubit<ExtracurricularTimetableState> {
  final ExtracurricularTimetableRepository _repository;

  ExtracurricularTimetableCubit(this._repository)
      : super(ExtracurricularTimetableInitial());

  // Create new timetable entry
  Future<void> createTimetableEntry(ExtracurricularTimetableEntry entry) async {
    try {
      emit(ExtracurricularTimetableLoading());

      await _repository.createTimetableEntry(entry);

      emit(ExtracurricularTimetableSuccess('Jadwal berhasil ditambahkan'));
    } catch (e) {
      emit(ExtracurricularTimetableFailure(e.toString()));
    }
  }

  // Update existing timetable entry
  Future<void> updateTimetableEntry(
      int id, ExtracurricularTimetableEntry entry) async {
    try {
      emit(ExtracurricularTimetableLoading());

      await _repository.updateTimetableEntry(id, entry);

      emit(ExtracurricularTimetableSuccess('Jadwal berhasil diperbarui'));
    } catch (e) {
      emit(ExtracurricularTimetableFailure(e.toString()));
    }
  }

  // Reset/Delete timetable entry
  Future<void> resetTimetableEntry(int id, {bool permanent = false}) async {
    try {
      emit(ExtracurricularTimetableLoading());

      await _repository.resetTimetableEntry(id, permanent: permanent);

      final message = permanent
          ? 'Jadwal berhasil dihapus permanen'
          : 'Jadwal berhasil direset';
      emit(ExtracurricularTimetableSuccess(message));
    } catch (e) {
      emit(ExtracurricularTimetableFailure(e.toString()));
    }
  }

  // Reset state to initial
  void resetState() {
    emit(ExtracurricularTimetableInitial());
  }

  // Clear any error or success state
  void clearState() {
    emit(ExtracurricularTimetableInitial());
  }
}
