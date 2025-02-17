import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/questionOnlineExam.dart';
import 'package:eschool_saas_staff/data/repositories/onlineExamRepository.dart';

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

class QuestionOnlineExamCubit extends Cubit<QuestionOnlineExamState> {
  final OnlineExamRepository _repository;

  QuestionOnlineExamCubit(this._repository) : super(QuestionOnlineExamInitial());

  Future<void> getQuestions(int examId) async {
    try {
      emit(QuestionOnlineExamLoading());
      final questions = await _repository.getOnlineExamQuestions(examId);
      emit(QuestionOnlineExamSuccess(questions));
    } catch (e) {
      emit(QuestionOnlineExamFailure(e.toString()));
    }
  }

  Future<void> storeQuestions({
    required int examId,
    required List<QuestionOnlineExam> questions,
  }) async {
    try {
      emit(QuestionOnlineExamLoading());
      await _repository.storeOnlineExamQuestions(
        examId: examId,
        questions: questions,
      );
      await getQuestions(examId);
    } catch (e) {
      emit(QuestionOnlineExamFailure(e.toString()));
    }
  }
}