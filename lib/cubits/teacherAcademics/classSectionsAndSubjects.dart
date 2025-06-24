import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/teacherSubject.dart';
import 'package:eschool_saas_staff/data/repositories/academicRepository.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ClassSectionsAndSubjectsState {}

class ClassSectionsAndSubjectsInitial extends ClassSectionsAndSubjectsState {}

class ClassSectionsAndSubjectsFetchInProgress
    extends ClassSectionsAndSubjectsState {}

class ClassSectionsAndSubjectsFetchSuccess
    extends ClassSectionsAndSubjectsState {
  final List<ClassSection> classSections;
  final List<TeacherSubject> subjects;

  ClassSectionsAndSubjectsFetchSuccess(
      {required this.classSections, required this.subjects});
}

class ClassSectionsAndSubjectsFetchFailure
    extends ClassSectionsAndSubjectsState {
  final String errorMessage;

  ClassSectionsAndSubjectsFetchFailure(this.errorMessage);
}

class ClassSectionsAndSubjectsCubit
    extends Cubit<ClassSectionsAndSubjectsState> {
  final AcademicRepository _academicRepository = AcademicRepository();

  ClassSectionsAndSubjectsCubit() : super(ClassSectionsAndSubjectsInitial());

  void getClassSectionsAndSubjects({int? classSectionId}) async {
    try {
      print(
          "ClassSectionsAndSubjectsCubit: Starting to fetch class sections and subjects");
      emit(ClassSectionsAndSubjectsFetchInProgress());

      final classesResult = await _academicRepository.getClasses();
      print(
          "ClassSectionsAndSubjectsCubit: Received classes - Primary: ${classesResult.primaryClasses.length}, Other: ${classesResult.classes.length}");

      //
      List<ClassSection> classSections =
          List<ClassSection>.from(classesResult.classes);
      classSections
          .addAll(List<ClassSection>.from(classesResult.primaryClasses));

      print(
          "ClassSectionsAndSubjectsCubit: Combined total classes: ${classSections.length}");

      emit(ClassSectionsAndSubjectsFetchSuccess(
          classSections: classSections,
          subjects: await _academicRepository.getClassSectionSubjects(
              classSectionId: classSectionId ?? classSections.first.id ?? 0)));
    } catch (e) {
      print("ClassSectionsAndSubjectsCubit: Error occurred - $e");
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(ClassSectionsAndSubjectsFetchFailure(userFriendlyMessage));
      print(
          'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }

  Future<void> getNewSubjectsFromSelectedClassSectionIndex(
      {required int newClassSectionId}) async {
    if (state is ClassSectionsAndSubjectsFetchSuccess) {
      final successState = (state as ClassSectionsAndSubjectsFetchSuccess);
      emit(ClassSectionsAndSubjectsFetchSuccess(
          classSections: successState.classSections,
          subjects: await _academicRepository.getClassSectionSubjects(
              classSectionId: newClassSectionId)));
    }
  }
}
