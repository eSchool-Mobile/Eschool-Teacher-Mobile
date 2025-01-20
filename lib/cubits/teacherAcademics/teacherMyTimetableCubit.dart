import 'package:eschool_saas_staff/data/models/timeTableSlot.dart';
import 'package:eschool_saas_staff/data/repositories/teacherAcademicRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';

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

      print("OKK3");

      final slots = // bukan ini
          await _teacherAcademicsRepository.getTeacherTimetableByClassSection(
        classSectionId: classSectionId,
        date: date,
      );

      print(
          "Fetched timetable slots for class section $classSectionId: ${slots.length}");
      slots.forEach((slot) {
        print("Slot ID: ${slot.id}, Subject: ${slot.subject?.name}");
      });

      emit(TeacherMyTimetableFetchSuccess(timeTableSlots: slots));
    } catch (e) {
      print("Error fetching timetable slots: $e");
      emit(TeacherMyTimetableFetchFailure(e.toString()));
    }
  }

  void getTeacherMyTimetable({bool isRefresh = false}) async {
    if (state is TeacherMyTimetableFetchSuccess && !isRefresh) {
      return;
    }
    try {
      emit(TeacherMyTimetableFetchInProgress());
      final slots = await _teacherAcademicsRepository.getTeacherMyTimetable();

      // Debug logs

      print("DOKSLI ASELI");
      String jsonString = JsonEncoder.withIndent('  ').convert(slots);

      List<String> lines = jsonString.split('\n');
      for (var line in lines) {
        print(line);
      }

      emit(TeacherMyTimetableFetchSuccess(timeTableSlots: slots));
    } catch (e) {
      print("Error fetching timetable: $e");
      emit(TeacherMyTimetableFetchFailure(e.toString()));
    }
  }
}
