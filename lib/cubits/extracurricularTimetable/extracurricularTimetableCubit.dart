import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/repositories/extracurricularTimetableRepository.dart';
import 'package:eschool_saas_staff/data/models/extracurricularTimetableEntry.dart';
import 'package:eschool_saas_staff/data/models/extracurricularTimetable.dart';

part 'extracurricularTimetableState.dart';

class ExtracurricularTimetableCubit
    extends Cubit<ExtracurricularTimetableState> {
  final ExtracurricularTimetableRepository _repository;

  ExtracurricularTimetableCubit(this._repository)
      : super(ExtracurricularTimetableInitial());

  // Get all timetable data
  Future<void> getExtracurricularTimetable() async {
    try {
      emit(ExtracurricularTimetableLoading());

      final timetables = await _repository.getExtracurricularTimetable();

      emit(ExtracurricularTimetableSuccess('Data berhasil dimuat',
          timetables: timetables));
    } catch (e) {
      emit(ExtracurricularTimetableFailure(e.toString()));
    }
  }

  // Create new timetable entry
  Future<void> createTimetableEntry(ExtracurricularTimetableEntry entry) async {
    try {
      emit(ExtracurricularTimetableLoading());

      await _repository.createTimetableEntry(entry);

      // Refresh data after create and emit success with updated data
      final timetables = await _repository.getExtracurricularTimetable();
      emit(ExtracurricularTimetableSuccess('Jadwal berhasil ditambahkan',
          timetables: timetables));
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

      // Refresh data after update to show new data and remove old data
      final timetables = await _repository.getExtracurricularTimetable();
      emit(ExtracurricularTimetableSuccess('Jadwal berhasil diperbarui',
          timetables: timetables));
    } catch (e) {
      emit(ExtracurricularTimetableFailure(e.toString()));
    }
  }

  // Reset/Delete timetable entry
  Future<void> resetTimetableEntry(int id, {bool permanent = false}) async {
    try {
      emit(ExtracurricularTimetableLoading());

      await _repository.resetTimetableEntry(id, permanent: permanent);

      // Refresh data after reset/delete to remove the item from list
      final timetables = await _repository.getExtracurricularTimetable();

      final message = permanent
          ? 'Jadwal berhasil dihapus permanen'
          : 'Jadwal berhasil direset';
      emit(ExtracurricularTimetableSuccess(message, timetables: timetables));
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
