import 'package:eschool_saas_staff/data/models/BankOnlineQuestion.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/questionOnlineExam.dart';
import 'package:eschool_saas_staff/data/repositories/onlineExamRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/onlineExam/onlineExamCubit.dart';
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
      print("TEST");
      emit(QuestionOnlineExamSuccess(questions));
    } catch (e) {
      print("TEST ERROR");
      emit(QuestionOnlineExamFailure(e.toString()));
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
      emit(QuestionOnlineExamFailure(e.toString()));
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
      emit(QuestionOnlineExamSuccess(questions));
    } catch (e) {
      emit(QuestionOnlineExamFailure(e.toString()));
    }
  }

  Future<void> getBankSoal(int examId) async {
    try {
      emit(QuestionBanksLoading());
      final banks = await _repository.getBankSoal(examId);
      emit(QuestionBanksLoaded(banks));
    } catch (e) {
      emit(QuestionOnlineExamFailure(e.toString()));
    }
  }

  Future<void> deleteQuestions(int examId, Set<int> questionIndexes,
      List<QuestionOnlineExam> questions) async {
    try {
      // Convert indexes to question IDs
      List<int> questionIds =
          questionIndexes.map((index) => questions[index].id).toList();

      // Delete questions
      await _repository.deleteOnlineExamQuestions(examId, questionIds);

      // Refresh questions list
      await getQuestions(examId);
    } catch (e) {
      emit(QuestionOnlineExamFailure(e.toString()));
    }
  }
}
