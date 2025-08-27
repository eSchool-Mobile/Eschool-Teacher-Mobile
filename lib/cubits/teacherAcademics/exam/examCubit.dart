// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:eschool_saas_staff/data/models/exam.dart';
import 'package:eschool_saas_staff/data/repositories/studentRepository.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';

abstract class ExamsState {}

class ExamsInitial extends ExamsState {}

class ExamsFetchSuccess extends ExamsState {
  final List<Exam> examList;

  ExamsFetchSuccess({required this.examList});
}

class ExamsFetchFailure extends ExamsState {
  final String errorMessage;

  ExamsFetchFailure(this.errorMessage);
}

class ExamsFetchInProgress extends ExamsState {}

class ExamsCubit extends Cubit<ExamsState> {
  final StudentRepository _studentRepository = StudentRepository();

  ExamsCubit() : super(ExamsInitial());

  ///[0- Upcoming, 1-On Going, 2-Completed, 3-All Details]
  void fetchExamsList({
    required int examStatus,
    int? classSectionId,
    int? studentId,
    int? publishStatus,
  }) {
    emit(ExamsFetchInProgress());
    _studentRepository
        .fetchExamsList(
          examStatus: examStatus,
          studentID: studentId,
          publishStatus: publishStatus,
          classSectionId: classSectionId,
        )
        .then((value) => emit(ExamsFetchSuccess(examList: value)))
        .catchError((e) {
      // Gunakan ErrorMessageUtils untuk mengkonversi error teknis menjadi pesan yang ramah
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(ExamsFetchFailure(userFriendlyMessage));

      // Log technical error untuk debugging (hanya untuk development)
      print(
          'Technical error in fetchExamsList: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    });
  }

  List<Exam> getAllExams() {
    if (state is ExamsFetchSuccess) {
      return (state as ExamsFetchSuccess).examList;
    }
    return [];
  }

  List<String> getExamName() {
    return getAllExams().map((exams) => exams.getExamName()).toList();
  }

  Exam getExams({required int index}) {
    return getAllExams()[index];
  }
}
