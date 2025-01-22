import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/question.dart';
import 'package:eschool_saas_staff/data/models/subjectQuestion.dart';
import 'package:eschool_saas_staff/data/repositories/questionBankRepository.dart';

class QuestionBankState {
  final List<SubjectQuestion> questions;
  final bool isLoading;
  final String? error;

  QuestionBankState({
    this.questions = const [],
    this.isLoading = false,
    this.error,
  });

  QuestionBankState copyWith({
    List<SubjectQuestion>? questions,
    bool? isLoading,
    String? error,
  }) {
    return QuestionBankState(
      questions: questions ?? this.questions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class QuestionBankCubit extends Cubit<QuestionBankState> {
  final QuestionBankRepository _repository;

  QuestionBankCubit(this._repository) : super(QuestionBankState());

  Future<void> getQuestions(int subjectId) async {
    try {
      print("Cubit: Fetching questions"); // Debug print
      emit(QuestionBankState(isLoading: true));
      
      final questions = await _repository.getQuestionsBySubject(subjectId);
      print("Cubit: Got ${questions.length} subjects"); // Debug print
      
      emit(QuestionBankState(questions: questions));
    } catch (e) {
      print("Cubit error: $e"); // Debug print
      emit(QuestionBankState(error: e.toString()));
    }
  }

  Future<void> createQuestion(Question question) async {
    try {
      await _repository.createQuestion(question);
      if (question.subjectId != null) {
        await getQuestions(int.parse(question.subjectId));
      }
    } catch (e) {
      emit(QuestionBankState(error: e.toString()));
    }
  }

  Future<void> updateQuestion(int questionId, Question question) async {
    try {
      await _repository.updateQuestion(questionId, question);
      if (question.subjectId != null) {
        await getQuestions(int.parse(question.subjectId));
      }
    } catch (e) {
      emit(QuestionBankState(error: e.toString()));
    }
  }

  Future<void> deleteQuestion(int subjectId, int questionId) async {
    try {
      await _repository.deleteQuestion(subjectId, questionId);
      await getQuestions(subjectId);
    } catch (e) {
      emit(QuestionBankState(error: e.toString()));
    }
  }
}