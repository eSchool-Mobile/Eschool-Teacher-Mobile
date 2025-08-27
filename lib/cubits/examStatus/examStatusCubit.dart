import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eschool_saas_staff/data/models/studentExamStatus.dart';
import 'package:eschool_saas_staff/data/repositories/examStatusRepository.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';

class ExamStatusCubit extends Cubit<ExamStatusState> {
  final ExamStatusRepository _examStatusRepository;

  ExamStatusCubit({required ExamStatusRepository examStatusRepository})
      : _examStatusRepository = examStatusRepository,
        super(ExamStatusInitial());
  Future<void> getStudentExamStatus(int examId) async {
    try {
      emit(ExamStatusLoading());

      final studentExamStatusResponse =
          await _examStatusRepository.getStudentExamStatus(examId);
      emit(ExamStatusSuccess(
        studentExamStatuses: studentExamStatusResponse.data,
        message: studentExamStatusResponse.message,
      ));
    } catch (e) {
      // Log technical error untuk debugging (hanya untuk development)
      print('Technical error in getStudentExamStatus: $e');

      // Gunakan ErrorMessageUtils untuk mengkonversi error teknis menjadi pesan yang ramah
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(ExamStatusFailure(
        errorMessage: userFriendlyMessage,
      ));
    }
  }

  // Add method to delete student exam status
  Future<bool> deleteStudentExamStatus(int examId, int studentId) async {
    try {
      final result = await _examStatusRepository.deleteStudentExamStatus(
        examId,
        studentId,
      );

      if (result['error'] == false) {
        // Refresh student exam status list
        await getStudentExamStatus(examId);
        return true;
      }
      return false;
    } catch (e) {
      // Gunakan ErrorMessageUtils untuk mengkonversi error teknis menjadi pesan yang ramah
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(ExamStatusFailure(
        errorMessage: userFriendlyMessage,
      ));

      // Log technical error untuk debugging (hanya untuk development)
      print(
          'Technical error in deleteStudentExamStatus: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
      return false;
    }
  }
}

abstract class ExamStatusState extends Equatable {
  const ExamStatusState();

  @override
  List<Object> get props => [];
}

class ExamStatusInitial extends ExamStatusState {}

class ExamStatusLoading extends ExamStatusState {}

class ExamStatusSuccess extends ExamStatusState {
  final List<StudentExamStatus> studentExamStatuses;
  final String message;

  const ExamStatusSuccess({
    required this.studentExamStatuses,
    required this.message,
  });

  @override
  List<Object> get props => [studentExamStatuses, message];
}

class ExamStatusFailure extends ExamStatusState {
  final String errorMessage;

  const ExamStatusFailure({
    required this.errorMessage,
  });

  @override
  List<Object> get props => [errorMessage];
}
