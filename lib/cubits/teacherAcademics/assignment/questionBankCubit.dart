import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/question.dart';
import 'package:eschool_saas_staff/data/models/questionBank.dart';
import 'package:eschool_saas_staff/data/models/subjectQuestion.dart';
import 'package:eschool_saas_staff/data/repositories/questionBankRepository.dart';

abstract class QuestionBankState {}

class QuestionBankInitial extends QuestionBankState {}

class QuestionBankLoading extends QuestionBankState {}

class QuestionBankError extends QuestionBankState {
  final String message;
  QuestionBankError(this.message);
}

class SubjectsFetchSuccess extends QuestionBankState {
  final List<SubjectQuestion> subjects;
  SubjectsFetchSuccess(this.subjects);
}

class BankQuestionsFetchSuccess extends QuestionBankState {
  final List<Question> questions;
  BankQuestionsFetchSuccess(this.questions);
}

// Add new state
class BankSoalFetchSuccess extends QuestionBankState {
  final List<BankSoal> bankSoal;
  BankSoalFetchSuccess(this.bankSoal);
}

class QuestionBankCubit extends Cubit<QuestionBankState> {
  final QuestionBankRepository _repository;

  QuestionBankCubit({required QuestionBankRepository repository})
      : _repository = repository,
        super(QuestionBankInitial());

  Future<void> fetchTeacherSubjects({bool isStaffView = false}) async {
    try {
      emit(QuestionBankLoading());
      print("Fetching subjects for ${isStaffView ? 'staff' : 'teacher'}...");

      final subjects =
          await _repository.getTeacherSubjects(isStaffView: isStaffView);

      if (subjects.isEmpty) {
        emit(QuestionBankError("Tidak ada mata pelajaran yang tersedia"));
        return;
      }

      print("Successfully fetched ${subjects.length} subjects");
      emit(SubjectsFetchSuccess(subjects));
    } catch (e) {
      print("Error in QuestionBankCubit: $e");
      emit(QuestionBankError(e.toString()));
    }
  }

  Future<void> fetchBankQuestions(int subjectId, int bankId) async {
    try {
      emit(QuestionBankLoading());
      final questions = await _repository.getBankQuestions(subjectId, bankId);
      emit(BankQuestionsFetchSuccess(questions));
    } catch (e) {
      emit(QuestionBankError(e.toString()));
    }
  }

  // Add new method in QuestionBankCubit class
  Future<void> fetchBankSoal(int subjectId) async {
    try {
      emit(QuestionBankLoading());
      final bankSoal = await _repository.getBankSoal(subjectId);
      emit(BankSoalFetchSuccess(bankSoal));
    } catch (e) {
      emit(QuestionBankError(e.toString()));
    }
  }

  // Add createQuestionBank method
  Future<void> createQuestionBank({
    required int subjectId,
    required String name,
  }) async {
    try {
      emit(QuestionBankLoading());

      await _repository.createQuestionBank(
        subjectId: subjectId,
        name: name,
      );
      // Fetch updated bank soal list after creation
      final bankSoal = await _repository.getBankSoal(subjectId);
      emit(BankSoalFetchSuccess(bankSoal));
    } catch (e) {
      emit(QuestionBankError(e.toString()));
      throw e; // Re-throw to handle in UI
    }
  }

  // Add updateQuestionBank method
  Future<void> updateQuestionBank({
    required int subjectId,
    required int banksoalId,
    required String name,
  }) async {
    try {
      emit(QuestionBankLoading());
      await _repository.updateQuestionBank(
        subjectId: subjectId,
        banksoalId: banksoalId,
        name: name,
      );
      // Fetch updated bank soal list after update
      final bankSoal = await _repository.getBankSoal(subjectId);
      emit(BankSoalFetchSuccess(bankSoal));
    } catch (e) {
      emit(QuestionBankError(e.toString()));
      throw e;
    }
  }

  // Add createQuestion method
  Future<void> createQuestion({
    required int banksoalId,
    required int subjectId,
    required String name,
    required String type,
    required int defaultPoint,
    required String question,
    required String note,
    required List<QuestionOption> options,
  }) async {
    try {
      emit(QuestionBankLoading());
      await _repository.createQuestion(
        banksoalId: banksoalId,
        subjectId: subjectId,
        name: name,
        type: type,
        defaultPoint: defaultPoint,
        question: question,
        note: note,
        options: options,
      );
      // Fetch updated questions after creation
      final questions =
          await _repository.getBankQuestions(subjectId, banksoalId);
      emit(BankQuestionsFetchSuccess(questions));
    } catch (e) {
      emit(QuestionBankError(e.toString()));
      throw e;
    }
  }

  // Add updateQuestion method
  Future<void> updateQuestion({
    required int banksoalSoalId,
    required int subjectId,
    required int bankSoalId,
    required String name,
    required String type,
    required int defaultPoint,
    required String question,
    required String note,
    required List<QuestionOption> options,
  }) async {
    try {
      emit(QuestionBankLoading());

      print("OK 11");

      print(banksoalSoalId);
      print(subjectId);

      await _repository.updateQuestion(
        banksoalSoalId: banksoalSoalId,
        subjectId: subjectId,
        name: name,
        type: type,
        defaultPoint: defaultPoint,
        question: question,
        note: note,
        options: options,
      );

      print("OK 12");

      // Fetch updated questions after successful update
      final questions =
          await _repository.getBankQuestions(subjectId, bankSoalId);
      print("OK 13");
      emit(BankQuestionsFetchSuccess(questions));
      print("OK 14");
    } catch (e) {
      // Check if error message indicates success
      if (e.toString().contains('Soal Updated Successfully')) {
        // Fetch updated questions even though we got an error
        final questions =
            await _repository.getBankQuestions(subjectId, banksoalSoalId);
        emit(BankQuestionsFetchSuccess(questions));
        return;
      }

      emit(QuestionBankError(e.toString()));
      throw e;
    }
  }

  Future<void> deleteBankSoal({
    required int subjectId,
    required int banksoalId,
  }) async {
    try {
      print('📝 QuestionBankCubit: Starting delete process');
      emit(QuestionBankLoading());

      print('📊 Delete Parameters:');
      print('Subject ID: $subjectId');
      print('Bank Soal ID: $banksoalId');

      await _repository.deleteBankSoal(
        subjectId: subjectId,
        banksoalId: banksoalId,
      );

      print('🔄 Refreshing bank soal list');
      final bankSoal = await _repository.getBankSoal(subjectId);
      emit(BankSoalFetchSuccess(bankSoal));
      print('✅ Delete process completed successfully');
    } catch (e) {
      print('❌ Delete Error in Cubit: $e');
      emit(QuestionBankError(e.toString()));
      throw e;
    }
  }

  // Add this method to QuestionBankCubit class
  Future<void> deleteQuestion({
    required int subjectId,
    required int banksoalId,
    required int banksoalSoalId,
  }) async {
    try {
      print('📝 QuestionBankCubit: Starting delete question process');
      emit(QuestionBankLoading());

      await _repository.deleteQuestion(
        subjectId: subjectId,
        banksoalId: banksoalId,
        banksoalSoalId: banksoalSoalId,
      );

      print('🔄 Refreshing questions list');
      final questions =
          await _repository.getBankQuestions(subjectId, banksoalId);
      emit(BankQuestionsFetchSuccess(questions));
      print('✅ Delete question process completed successfully');
    } catch (e) {
      print('❌ Delete Error in Cubit: $e');
      emit(QuestionBankError(e.toString()));
      throw e;
    }
  }
}
