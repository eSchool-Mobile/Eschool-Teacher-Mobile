import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/question.dart';
import 'package:eschool_saas_staff/data/models/questionBank.dart';
import 'package:eschool_saas_staff/data/models/subjectQuestion.dart';
import 'package:eschool_saas_staff/data/repositories/questionBankRepository.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';
// Tambahkan import File
import 'dart:io';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

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
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(QuestionBankError(userFriendlyMessage));
      print(
          'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }

  Future<void> fetchBankQuestions({
    required int subjectId,
    required int bankId,
    int? examId,
  }) async {
    try {
      emit(QuestionBankLoading());

      final questions = await _repository.getBankQuestions(
        subjectId: subjectId,
        bankId: bankId,
        onlineExamId: examId,
      );

      emit(BankQuestionsFetchSuccess(questions));
    } catch (e) {
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(QuestionBankError(userFriendlyMessage));
      print(
          'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }

  Future<void> fetchBankSoal(int subjectId) async {
    try {
      emit(QuestionBankLoading());
      final bankSoal = await _repository.getBankSoal(subjectId);
      emit(BankSoalFetchSuccess(bankSoal));
    } catch (e) {
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(QuestionBankError(userFriendlyMessage));
      print(
          'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
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
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(QuestionBankError(userFriendlyMessage));
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
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(QuestionBankError(userFriendlyMessage));
      throw e;
    }
  }

  // Add createQuestion method
  Future<void> createQuestion({
    required int banksoalId,
    required int subjectId,
    required String name,
    required String type,
    required String orderType,
    required int defaultPoint,
    required String question,
    required String note,
    required List<QuestionOption> options,
    File? image,
  }) async {
    try {
      emit(QuestionBankLoading());

      print('\n=== QUESTION BANK CUBIT: CREATE QUESTION ===');
      print('Starting question creation in cubit...');

      // Validate image if exists
      if (image != null) {
        print('\n=== IMAGE VALIDATION ===');
        final imageSize = await image.length();
        final imageSizeInMB = imageSize / (1024 * 1024);
        print('Image Size: ${imageSizeInMB.toStringAsFixed(2)} MB');

        if (imageSizeInMB > 2) {
          throw ApiException('Ukuran gambar harus kurang dari 2MB');
        }

        final extension = image.path.split('.').last.toLowerCase();
        print('Image Extension: $extension');

        if (!['jpg', 'jpeg', 'png'].contains(extension)) {
          throw ApiException(
              'Hanya file JPG, JPEG, dan PNG yang diperbolehkan');
        }
      }

      await _repository.createQuestion(
        banksoalId: banksoalId,
        subjectId: subjectId,
        name: name,
        type: type,
        orderType: orderType,
        defaultPoint: defaultPoint,
        question: question,
        note: note,
        options: options,
        image: image,
      );

      final questions = await _repository.getBankQuestions(
          subjectId: subjectId, bankId: banksoalId);
      emit(BankQuestionsFetchSuccess(questions));
    } catch (e) {
      print('\n=== ERROR IN CUBIT ===');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: $e');
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(QuestionBankError(userFriendlyMessage));
      print(
          'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
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
    dynamic? image, // Tambahkan parameter image
    String? orderType,
  }) async {
    print("OKKK 10");
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
        bankSoalId: bankSoalId,
        note: note,
        options: options,
        image: image,
        orderType: type == "multiple_choice" ? orderType : null,
      );

      print("OK 12");

      // Fetch updated questions after successful update
      final questions = await _repository.getBankQuestions(
          subjectId: subjectId, bankId: bankSoalId);
      print("OK 13");
      emit(BankQuestionsFetchSuccess(questions));
      print("OK 14");
    } catch (e) {
      // Check if error message indicates success
      if (e.toString().contains('Soal Updated Successfully')) {
        // Fetch updated questions even though we got an error
        final questions = await _repository.getBankQuestions(
            subjectId: subjectId, bankId: banksoalSoalId);
        emit(BankQuestionsFetchSuccess(questions));
        return;
      }

      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(QuestionBankError(userFriendlyMessage));
      print(
          'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
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
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(QuestionBankError(userFriendlyMessage));
      print(
          'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
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

      // Get updated questions list
      final updatedQuestions = await _repository.getBankQuestions(
        subjectId: subjectId,
        bankId: banksoalId,
      );

      emit(BankQuestionsFetchSuccess(updatedQuestions));
      print('✅ Delete question process completed successfully');
    } catch (e) {
      print('❌ Delete Error in Cubit: $e');
      if (e.toString().contains('validation.exists')) {
        emit(QuestionBankError('Soal tidak ditemukan atau sudah dihapus'));
      } else {
        final userFriendlyMessage =
            ErrorMessageUtils.getReadableErrorMessage(e);
        emit(QuestionBankError(userFriendlyMessage));
        print(
            'Technical error: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
      }
      throw e;
    }
  }
}
