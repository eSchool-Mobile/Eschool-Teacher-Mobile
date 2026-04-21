import 'package:eschool_saas_staff/data/models/BankOnlineQuestion.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/questionOnlineExam.dart';
import 'package:eschool_saas_staff/data/repositories/onlineExamRepository.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';
import 'package:flutter/foundation.dart';
// import 'package:eschool_saas_staff/data/models/BankSoal.dart';

abstract class QuestionOnlineExamState {}

class QuestionOnlineExamInitial extends QuestionOnlineExamState {}

class QuestionOnlineExamLoading extends QuestionOnlineExamState {}

class QuestionOnlineExamSuccess extends QuestionOnlineExamState {
  final List<QuestionOnlineExam> questions;
  QuestionOnlineExamSuccess(this.questions);
}

class QuestionOnlineExamFailure extends QuestionOnlineExamState {
  final String message;
  QuestionOnlineExamFailure(this.message);
}

class QuestionBanksLoading extends QuestionOnlineExamState {}

class QuestionBanksLoaded extends QuestionOnlineExamState {
  final List<BankSoalQuestion> banks;
  QuestionBanksLoaded(this.banks);
}

class QuestionOnlineExamCubit extends Cubit<QuestionOnlineExamState> {
  final OnlineExamRepository _repository;

  QuestionOnlineExamCubit(this._repository)
      : super(QuestionOnlineExamInitial());

  Future<void> getQuestions(int examId) async {
    try {
      emit(QuestionOnlineExamLoading());
      final questions = await _repository.getOnlineExamQuestions(examId);

      // Debug info lebih detail
      for (var q in questions) {
        debugPrint(
            'Question ID: ${q.id}, Version: ${q.version}, Type: ${q.version.runtimeType}');
      }
      emit(QuestionOnlineExamSuccess(questions));
    } catch (e) {
      // Gunakan ErrorMessageUtils untuk mengkonversi error teknis menjadi pesan yang ramah
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(QuestionOnlineExamFailure(userFriendlyMessage));

      // Log technical error untuk debugging (hanya untuk development)
      debugPrint(
          'Technical error in getQuestions: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }

  Future<void> loadQuestionsFromBank(int examId, int bankId) async {
    try {
      emit(QuestionOnlineExamLoading());
      final questions = await _repository.getOnlineExamQuestions(
        examId,
        bankId: bankId,
      );
      emit(QuestionOnlineExamSuccess(questions));
    } catch (e) {
   
      // Gunakan ErrorMessageUtils untuk mengkonversi error teknis menjadi pesan yang ramah
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(QuestionOnlineExamFailure(userFriendlyMessage));

      // Log technical error untuk debugging (hanya untuk development)
      debugPrint(
          'Technical error in loadQuestionsFromBank: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }

  Future<void> getOnlineExamResultQuestions({
    required int examId,
    String? search,
  }) async {
    try {
      emit(QuestionOnlineExamLoading());
      final questions =
          await _repository.getOnlineExamQuestionListCorrection(examId, search);
      debugPrint("AMAN NIEH");
      emit(QuestionOnlineExamSuccess(questions));
    } catch (e) {
    
      // Gunakan ErrorMessageUtils untuk mengkonversi error teknis menjadi pesan yang ramah
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(QuestionOnlineExamFailure(userFriendlyMessage));

      // Log technical error untuk debugging (hanya untuk development)
      debugPrint(
          'Technical error in getOnlineExamResultQuestions: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }

  Future<void> getBankSoal(int examId) async {
    try {
      emit(QuestionBanksLoading());
      final banks = await _repository.getBankSoal(examId);
      emit(QuestionBanksLoaded(banks));
    } catch (e) {
     
      // Gunakan ErrorMessageUtils untuk mengkonversi error teknis menjadi pesan yang ramah
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(QuestionOnlineExamFailure(userFriendlyMessage));

      // Log technical error untuk debugging (hanya untuk development)
      debugPrint(
          'Technical error in getBankSoal: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }

  Future<void> deleteQuestions(int examId, Set<int> questionIndexes,
      List<QuestionOnlineExam> questions) async {
    try {
      debugPrint('=== CUBIT DELETE QUESTIONS ===');
      debugPrint('Exam ID: $examId');
      debugPrint('Selected Indexes: $questionIndexes');

      emit(QuestionOnlineExamLoading());

      // Convert indexes to question IDs
      List<int> questionIds =
          questionIndexes.map((index) => questions[index].id).toList();
      debugPrint('Question IDs to delete: $questionIds');

      // Delete questions
      await _repository.deleteOnlineExamQuestions(examId, questionIds);
      debugPrint('Delete request completed successfully');

      // Refresh questions list
      debugPrint('Refreshing questions list...');
      await getQuestions(examId);
      debugPrint('Questions list refreshed');
    } catch (e) {
      debugPrint('=== CUBIT DELETE ERROR ===');
      debugPrint('Error Type: ${e.runtimeType}');
      debugPrint('Error Message: $e');
      // Gunakan ErrorMessageUtils untuk mengkonversi error teknis menjadi pesan yang ramah
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(QuestionOnlineExamFailure(userFriendlyMessage));

      // Log technical error untuk debugging (hanya untuk development)
      debugPrint(
          'Technical error in deleteQuestions: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
      rethrow;
    }
  }
}
