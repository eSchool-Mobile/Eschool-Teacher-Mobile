import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/repositories/academicRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ClassesState {}

class ClassesInitial extends ClassesState {}

class ClassesFetchInProgress extends ClassesState {}

class ClassesFetchSuccess extends ClassesState {
  final List<ClassSection> classes;
  final List<ClassSection> primaryClasses;

  ClassesFetchSuccess({required this.classes, required this.primaryClasses});
}

class ClassesFetchFailure extends ClassesState {
  final String errorMessage;

  ClassesFetchFailure(this.errorMessage);
}

class ClassesCubit extends Cubit<ClassesState> {
  final AcademicRepository _academicRepository = AcademicRepository();

  ClassesCubit() : super(ClassesInitial());

  void getClasses() async {
    try {
      emit(ClassesFetchInProgress());
      final result = await _academicRepository.getClasses();
      print(
          "Primary classes: ${result.primaryClasses.map((e) => "${e.name} (${e.id})").toList()}");
      print(
          "Other classes: ${result.classes.map((e) => "${e.name} (${e.id})").toList()}");
      emit(ClassesFetchSuccess(
          classes: result.classes, primaryClasses: result.primaryClasses));
    } catch (e) {
      print("Error fetching classes: $e"); // Debug log
      emit(ClassesFetchFailure(e.toString()));
    }
  }

  List<ClassSection> getAllClasses() {
    if (state is ClassesFetchSuccess) {
      final currentState = state as ClassesFetchSuccess;

      // Gabungkan primaryClasses dan classes
      final allClasses = [
        ...currentState.primaryClasses,
        ...currentState.classes
      ];

      // Debug logs
      print(
          "getAllClasses - Primary Classes: ${currentState.primaryClasses.map((e) => "${e.name} (${e.id})").toList()}");
      print(
          "getAllClasses - Other Classes: ${currentState.classes.map((e) => "${e.name} (${e.id})").toList()}");
      print(
          "getAllClasses - Combined Classes: ${allClasses.map((e) => "${e.name} (${e.id})").toList()}");

      return allClasses;
    }
    return [];
  }
}
