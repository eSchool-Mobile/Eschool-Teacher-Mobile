import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/repositories/onlineExamRepository.dart';
import 'package:eschool_saas_staff/data/models/onlineExam.dart';
import 'package:eschool_saas_staff/data/models/subject.dart'
    as subject_model; // Add SubjectDetail model
import 'package:eschool_saas_staff/utils/api.dart'; // Add this import
// Add this import
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';

import 'package:eschool_saas_staff/data/models/subjectDetail.dart';


abstract class OnlineExamState {}

class OnlineExamInitial extends OnlineExamState {}

class OnlineExamLoading extends OnlineExamState {}

class OnlineExamAnswer extends OnlineExamState {
  final int id;
  final String studentName;
  final int studentId;
  final String answer;
  final int marks;
  final int totalMarks;
  late bool isCorrect;

  OnlineExamAnswer({
    required this.id,
    required this.studentName,
    required this.studentId,
    required this.isCorrect,
    required this.totalMarks,
    required this.marks,
    required this.answer,
  });
}

class OnlineExamAnswersSuccess extends OnlineExamState {
  final List<OnlineExamAnswer> answers;

  OnlineExamAnswersSuccess({
    required this.answers,
  });
}

class OnlineExamSuccess extends OnlineExamState {
  final List<OnlineExam> exams;
  final List<OnlineExam> archivedExams;
  final List<dynamic> subjectDetails;

  OnlineExamSuccess({
    required this.exams,
    this.archivedExams = const [],
    required this.subjectDetails,
  });
}

// Add this new state
class OnlineExamLoaded extends OnlineExamState {
  final OnlineExam exam;
  final List<SubjectDetail> subjects;

  OnlineExamLoaded({
    required this.exam,
    required this.subjects,
  });
}

class OnlineExamFailure extends OnlineExamState {
  final String message;

  OnlineExamFailure(this.message);
}

// Add these states
class CreateOnlineExamLoading extends OnlineExamState {}

// Add new state
class CreateOnlineExamSuccess extends OnlineExamState {
  final OnlineExam exam;
  CreateOnlineExamSuccess(this.exam);
}

class CreateOnlineExamFailure extends OnlineExamState {
  final String message;
  CreateOnlineExamFailure(this.message);
}

// Tambahkan state baru
class SubjectsLoading extends OnlineExamState {}

class SubjectsLoaded extends OnlineExamState {
  final List<dynamic> subjects;
  SubjectsLoaded(this.subjects);
}

class SubjectsError extends OnlineExamState {
  final String message;
  SubjectsError(this.message);
}

// Add new states
class StoringQuestions extends OnlineExamState {}

class QuestionsStored extends OnlineExamState {}

class OnlineExamCubit extends Cubit<OnlineExamState> {
  final OnlineExamRepository _repository;

  OnlineExamCubit(this._repository) : super(OnlineExamInitial());

  // Method untuk mendapatkan ujian aktif
  Future<void> getOnlineExams(
      {String? search,
      dynamic getFull,
      int? subjectId,
      int? classSectionId,
      int? sessionYearId,
      DateTime? startDate,
      DateTime? endDate}) async {
    try {
      emit(OnlineExamLoading());

      final result = await _repository.getOnlineExams(
          search: search,
          subjectId: subjectId,
          classSectionId: classSectionId,
          sessionYearId: sessionYearId,
          startDate: startDate,
          endDate: endDate,
          status: 'active',
          archive: getFull);

      final List<OnlineExam> activeExams = [];
      final List<OnlineExam> archivedExams = [];

      if (result['exams'] is List) {
        for (var examData in result['exams']) {
          try {
            final exam = OnlineExam.fromJson(examData);
            // Status 1 = active, Status 2 = archived
            // if (getFull == true) {
            activeExams.add(exam);
            // }
          } catch (e) {
            debugPrint('Error parsing active exam: $e');
          }
        }
      }
      emit(OnlineExamSuccess(
        exams: activeExams,
        archivedExams: archivedExams,
        subjectDetails: result['subjectDetails'] ?? [],
      ));
    } catch (e) {
      debugPrint("Cubit Error: $e");
      // Gunakan ErrorMessageUtils untuk mengkonversi error teknis menjadi pesan yang ramah
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(OnlineExamFailure(userFriendlyMessage));

      // Log technical error untuk debugging (hanya untuk development)
      debugPrint(
          'Technical error in getOnlineExams: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }

  Future<void> getOnlineExamResultAnswer({
    required int examId,
    required int questionId,
    String? search,
  }) async {
    try {
      emit(OnlineExamLoading());

      final result = await _repository.getOnlineExamResultAnswer(
        onlineExamId: examId,
        questionId: questionId,
        search: search,
      );

      emit(OnlineExamAnswersSuccess(
        answers: (result['answers'] as List<dynamic>)
            .map((answer) => OnlineExamAnswer(
                  id: answer['answer_id'] ?? 0,
                  marks: answer['marks'] ?? 0,
                  totalMarks: result['marks'] ?? 0,
                  studentId: answer['student_id'] ?? 0,
                  studentName: answer['student_name'] ?? '',
                  answer: answer['answer'] ?? '',
                  isCorrect: answer['is_answer'] ?? false,
                ))
            .toList(),
      ));
    } catch (e) {
      // Gunakan ErrorMessageUtils untuk mengkonversi error teknis menjadi pesan yang ramah
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(OnlineExamFailure(userFriendlyMessage));

      // Log technical error untuk debugging (hanya untuk development)
      debugPrint(
          'Technical error in getOnlineExamResultAnswer: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }

  // Update the createOnlineExam method in OnlineExamCubit
  Future<void> createOnlineExam({
    required int classSectionId,
    required int classSubjectId,
    required String title,
    required String examKey,
    required int duration, // Add duration parameter
    required DateTime startDate,
  }) async {
    try {
      emit(CreateOnlineExamLoading());

      await _repository.createOnlineExam(
        classSectionId: classSectionId,
        classSubjectId: classSubjectId,
        title: title,
        examKey: examKey,
        duration: duration, // Pass duration to repository
        startDate: startDate,
      );

      // After successful creation, immediately fetch updated exam list
      final result = await _repository.getOnlineExams();

      final List<OnlineExam> exams = [];
      if (result['exams'] is List) {
        for (var examData in result['exams']) {
          try {
            final exam = OnlineExam.fromJson(examData);
            exams.add(exam);
          } catch (e) {
            debugPrint('Error parsing exam: $e');
          }
        }
      } // Emit success state with updated exam list
      emit(OnlineExamSuccess(
        exams: exams,
        subjectDetails: result['subjectDetails'] ?? [],
      ));
    } catch (e) {
      // Gunakan ErrorMessageUtils untuk mengkonversi error teknis menjadi pesan yang ramah
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(CreateOnlineExamFailure(userFriendlyMessage));

      // Log technical error untuk debugging (hanya untuk development)
      debugPrint(
          'Technical error in createOnlineExam: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }

  // Add this method to the existing OnlineExamCubit class

  // Tambahkan method baru di dalam class OnlineExamCubit
  Future<void> getSubjectsForClass(int classSectionId) async {
    try {
      emit(SubjectsLoading());
      final result = await _repository.getOnlineExams(
        classSectionId: classSectionId,
      );

      final subjects = (result['subjectDetails'] as List)
          .map((subject) => subject_model.Subject.fromJson(subject))
          .toList();
      emit(SubjectsLoaded(subjects));
    } catch (e) {
      // Gunakan ErrorMessageUtils untuk mengkonversi error teknis menjadi pesan yang ramah
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(SubjectsError(userFriendlyMessage));

      // Log technical error untuk debugging (hanya untuk development)
      debugPrint(
          'Technical error in getSubjectsForClass: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }

  Future<bool> updateOnlineExamAnswerCorrection({
    required int examId,
    required List<Map<String, int>> data,
  }) async {
    debugPrint(data.toString());
    String formattedJson = const JsonEncoder.withIndent("  ").convert(data);

    // Cetak per baris
    for (var line in formattedJson.split("\n")) {
      debugPrint(line.toString());
    }
    debugPrint("OK DARI SISNI");
    try {
      await _repository.updateOnlineExamAnswerCorrection(
        onlineExamId: examId,
        data: data,
      );
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // Add this method to the OnlineExamCubit class
  Future<void> updateOnlineExam({
    required int id,
    required int classSectionId,
    required int classSubjectId,
    required String title,
    required String examKey,
    required int duration,
    required DateTime startDate,
  }) async {
    try {
      emit(OnlineExamLoading());

      await _repository.updateOnlineExam(
        id: id,
        classSectionId: classSectionId,
        classSubjectId: classSubjectId,
        title: title,
        examKey: examKey,
        duration: duration,
        startDate: startDate,
      );

      // Fetch updated exam list immediately

      final result = await _repository.getOnlineExams();

      final List<OnlineExam> exams = [];
      if (result['exams'] is List) {
        for (var examData in result['exams']) {
          try {
            final exam = OnlineExam.fromJson(examData);
            exams.add(exam);
          } catch (e) {
            debugPrint('Error parsing exam: $e');
          }
        }
      }

      // Emit success state with updated exam list
      emit(OnlineExamSuccess(
        exams: exams,
        subjectDetails: result['subjectDetails'] ?? [],
      ));
    } catch (e) {
      // Gunakan ErrorMessageUtils untuk mengkonversi error teknis menjadi pesan yang ramah
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(OnlineExamFailure(userFriendlyMessage));

      // Log technical error untuk debugging (hanya untuk development)
      debugPrint(
          'Technical error in updateOnlineExam: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
      rethrow;
    }
  }

  Future<void> deleteOnlineExam({
    required int examId,
    required String mode,
  }) async {
    try {
      emit(OnlineExamLoading());

      await _repository.deleteOnlineExam(examId, mode: mode);

      // Tunggu sebentar sebelum refresh data
      await Future.delayed(const Duration(milliseconds: 1000));

      // Refresh data berdasarkan mode
      if (mode == 'permanent') {
        await getArchivedExams(); // Refresh archived list untuk mode permanent
      } else {
        await getOnlineExams(); // Refresh active list untuk mode archive
      }
    } catch (e) {
      debugPrint('Delete Error in Cubit: $e');
      String errorMessage = 'Gagal menghapus ujian';

      if (e is ApiException) {
        errorMessage = e.errorMessage;
      }

      emit(OnlineExamFailure(errorMessage));
      rethrow;
    }
  }

  // Perbaikan pada metode getArchivedExams()

  Future<void> getArchivedExams() async {
    try {
      emit(OnlineExamLoading());

      final result = await _repository.getOnlineExams(
        archive: true,
      );

      final List<OnlineExam> archivedExams = [];
      if (result['exams'] is List) {
        for (var examData in result['exams']) {
          try {
            final exam = OnlineExam.fromJson(examData);
            // Jangan filter berdasarkan status, tambahkan semua hasil dari parameter archive:true
            archivedExams.add(exam);
          } catch (e) {
            debugPrint('Error parsing archived exam: $e');
          }
        }
      }

      emit(OnlineExamSuccess(
        exams: [], // Keep active exams empty for archive view
        archivedExams: archivedExams,
        subjectDetails: result['subjectDetails'] ?? [],
      ));
    } catch (e) {
      debugPrint("Archive Error: $e");
      // Gunakan ErrorMessageUtils untuk mengkonversi error teknis menjadi pesan yang ramah
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(OnlineExamFailure(userFriendlyMessage));

      // Log technical error untuk debugging (hanya untuk development)
      debugPrint(
          'Technical error in getArchivedExams: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
    }
  }

  Future<void> restoreOnlineExam(int examId) async {
    try {
      emit(OnlineExamLoading());

      await _repository.restoreOnlineExam(examId);

      // Refresh both active and archived exam lists
      final result = await _repository.getOnlineExams();
      final archivedResult = await _repository.getOnlineExams(archive: true);

      final List<OnlineExam> activeExams = [];
      final List<OnlineExam> archivedExams = [];

      // Process active exams
      if (result['exams'] is List) {
        for (var examData in result['exams']) {
          try {
            final exam = OnlineExam.fromJson(examData);
            activeExams.add(exam);
          } catch (e) {
            debugPrint('Error parsing active exam: $e');
          }
        }
      }

      // Process archived exams
      if (archivedResult['exams'] is List) {
        for (var examData in archivedResult['exams']) {
          try {
            final exam = OnlineExam.fromJson(examData);
            if (exam.status == 2) {
              archivedExams.add(exam);
            }
          } catch (e) {
            debugPrint('Error parsing archived exam: $e');
          }
        }
      }

      emit(OnlineExamSuccess(
        exams: activeExams,
        archivedExams: archivedExams,
        subjectDetails: result['subjectDetails'] ?? [],
      ));
    } catch (e) {
      debugPrint('Restore Error: $e');
      // Gunakan ErrorMessageUtils untuk mengkonversi error teknis menjadi pesan yang ramah
      final userFriendlyMessage = ErrorMessageUtils.getReadableErrorMessage(e);
      emit(OnlineExamFailure(userFriendlyMessage));

      // Log technical error untuk debugging (hanya untuk development)
      debugPrint(
          'Technical error in restoreOnlineExam: ${ErrorMessageUtils.getTechnicalErrorMessage(e)}');
      rethrow;
    }
  }
}
