import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/repositories/onlineExamRepository.dart';
import 'package:eschool_saas_staff/data/models/onlineExam.dart';
import 'package:eschool_saas_staff/data/models/subject.dart'
    as subject_model; // Add SubjectDetail model
import 'package:eschool_saas_staff/utils/api.dart'; // Add this import
import 'package:dio/dio.dart'; // Add this import

import 'package:eschool_saas_staff/data/models/subjectDetail.dart';

abstract class OnlineExamState {}

class OnlineExamInitial extends OnlineExamState {}

class OnlineExamLoading extends OnlineExamState {}

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

class CreateOnlineExamSuccess extends OnlineExamState {}

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

class OnlineExamCubit extends Cubit<OnlineExamState> {
  final OnlineExamRepository _repository;

  OnlineExamCubit(this._repository) : super(OnlineExamInitial());

  // Method untuk mendapatkan ujian aktif
  Future<void> getOnlineExams({
    String? search,
    bool? getFull = false,
    int? subjectId,
    int? classSectionId,
    int? sessionYearId,
  }) async {
    try {
      emit(OnlineExamLoading());

      final result = await _repository.getOnlineExams(
        search: search,
        subjectId: subjectId,
        classSectionId: classSectionId,
        sessionYearId: sessionYearId,
        status: 'active',
      );

      print("FULL LE");
      print(getFull);
      print(result['exams'].length);

      final List<OnlineExam> exams = [];
      if (result['exams'] is List) {
        for (var examData in result['exams']) {
          try {
            if (examData['status'].toString() == '1' || getFull == true) {
              exams.add(OnlineExam.fromJson(examData));
            }
          } catch (e) {
            print('Error parsing exam: $e');
          }
        }
      }

      emit(OnlineExamSuccess(
        exams: exams,
        archivedExams: [],
        subjectDetails: result['subjectDetails'] ?? [],
      ));
    } catch (e) {
      print("Cubit Error: $e");
      emit(OnlineExamFailure(e.toString()));
    }
  }

  // Add this method to OnlineExamCubit class
  Future<void> createOnlineExam({
    required int classSectionId,
    required int classSubjectId,
    required String title,
    required String examKey,
    required int duration,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      emit(CreateOnlineExamLoading());

      await _repository.createOnlineExam(
        classSectionId: classSectionId,
        classSubjectId: classSubjectId,
        title: title,
        examKey: examKey,
        duration: duration,
        startDate: startDate,
        endDate: endDate,
      );

      emit(CreateOnlineExamSuccess());

      // Refresh data setelah berhasil membuat ujian
      await getOnlineExams();
    } catch (e) {
      print('Create Exam Error: $e');
      emit(CreateOnlineExamFailure(e.toString()));
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
      emit(SubjectsError(e.toString()));
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
    required DateTime endDate,
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
        endDate: endDate,
      );

      // Refresh the exams list after successful update
      await getOnlineExams();

      emit(OnlineExamSuccess(exams: [], subjectDetails: [])); // Temporary emit
    } catch (e) {
      emit(OnlineExamFailure(e.toString()));
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
      await Future.delayed(Duration(milliseconds: 1000));

      // Refresh data berdasarkan mode
      if (mode == 'archive') {
        // Refresh kedua list
        await Future.wait([
          getArchivedExams(),
          getOnlineExams(),
        ]);
      } else {
        await getOnlineExams();
      }
    } catch (e) {
      print('Delete Error in Cubit: $e');
      emit(OnlineExamFailure(e.toString()));
      rethrow;
    }
  }

  // Method khusus untuk mendapatkan ujian yang diarsipkan
  Future<void> getArchivedExams() async {
    try {
      emit(OnlineExamLoading());

      final result = await _repository.getOnlineExams(
        status: 'archived',
      );

      print('Archived Exams Raw Result: $result');

      final List<OnlineExam> archivedExams = [];
      if (result['exams'] is List) {
        for (var examData in result['exams']) {
          try {
            // Update status check to 2
            if (examData['status'].toString() == '2') {
              final exam = OnlineExam.fromJson(examData);
              archivedExams.add(exam);
              print(
                  'Added archived exam: ${exam.title} with status: ${exam.status}');
            }
          } catch (e) {
            print('Error parsing archived exam: $e');
          }
        }
      }

      print('Final archived exams count: ${archivedExams.length}');

      emit(OnlineExamSuccess(
        exams: [],
        archivedExams: archivedExams,
        subjectDetails: result['subjectDetails'] ?? [],
      ));
    } catch (e) {
      print("Archive Error: $e");
      emit(OnlineExamFailure(e.toString()));
    }
  }
}
