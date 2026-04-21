import 'package:eschool_saas_staff/data/models/timeTableSlot.dart';
import 'package:eschool_saas_staff/data/repositories/teacherAcademicRepository.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

abstract class TeacherMyTimetableState {}

class TeacherMyTimetableInitial extends TeacherMyTimetableState {}

class TeacherMyTimetableFetchInProgress extends TeacherMyTimetableState {}

class TeacherMyTimetableFetchSuccess extends TeacherMyTimetableState {
  final List<TimeTableSlot> timeTableSlots;

  TeacherMyTimetableFetchSuccess({required this.timeTableSlots});
}

class TeacherMyTimetableFetchFailure extends TeacherMyTimetableState {
  final String errorMessage;

  TeacherMyTimetableFetchFailure(this.errorMessage);
}

class TeacherMyTimetableCubit extends Cubit<TeacherMyTimetableState> {
  final TeacherAcademicsRepository _teacherAcademicsRepository =
      TeacherAcademicsRepository();

  TeacherMyTimetableCubit() : super(TeacherMyTimetableInitial());

  // Add new method for wali kelas
  void fetchTimetableSlots({
    required int classSectionId,
    required DateTime date,
  }) async {
    try {
      emit(TeacherMyTimetableFetchInProgress());

      final slots =
          await _teacherAcademicsRepository.getTeacherTimetableByClassSection(
        classSectionId: classSectionId,
        date: date,
      );

      debugPrint(
          "Fetched timetable slots for class section $classSectionId: ${slots.length}");
      for (var slot in slots) {
        debugPrint("Slot ID: ${slot.id}, Subject: ${slot.subject?.name}");
      }

      emit(TeacherMyTimetableFetchSuccess(timeTableSlots: slots));
    } catch (e) {
      debugPrint("Error fetching timetable slots: $e");
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(TeacherMyTimetableFetchFailure(userFriendlyMessage));
      debugPrint(
          'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }

  void getTeacherMyTimetable({bool isRefresh = false, String? dayKey}) async {
    if (state is TeacherMyTimetableFetchSuccess && !isRefresh) {
      return;
    }
    try {
      emit(TeacherMyTimetableFetchInProgress());

      debugPrint("Requesting timetable data for day: ${dayKey ?? 'all days'}");

      // Pass the dayKey to the repository method
      final slots = await _teacherAcademicsRepository.getTeacherMyTimetable(
          dayKey: dayKey);

      debugPrint(
          "Fetched ${slots.length} timetable slots for day: ${dayKey ?? 'all days'}");
      // Log each slot for debugging
      for (var slot in slots) {
        debugPrint(
            "Slot - Day: ${slot.day}, Subject: ${slot.subject?.name}, Time: ${slot.startTime}-${slot.endTime}");
      }

      emit(TeacherMyTimetableFetchSuccess(timeTableSlots: slots));
    } catch (e) {
      debugPrint("Error fetching timetable: $e");
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(TeacherMyTimetableFetchFailure(userFriendlyMessage));
      debugPrint(
          'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }
}
