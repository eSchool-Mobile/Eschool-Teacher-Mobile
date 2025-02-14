import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/repositories/onlineExamRepository.dart';
import 'package:eschool_saas_staff/data/models/onlineExam.dart';
import 'package:eschool_saas_staff/data/models/subject.dart'; // Add SubjectDetail model
import 'package:eschool_saas_staff/utils/api.dart'; // Add this import
import 'package:dio/dio.dart'; // Add this import

abstract class OnlineExamState {}

class OnlineExamInitial extends OnlineExamState {}

class OnlineExamLoading extends OnlineExamState {}

class OnlineExamSuccess extends OnlineExamState {
  final List<OnlineExam> exams;
  final List<dynamic> subjectDetails;

  OnlineExamSuccess({
    required this.exams,
    required this.subjectDetails,
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

  Future<void> getOnlineExams({
    String? search,
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
      );

      print('Subject Details from API:');
      if (result['subjectDetails'] is List) {
        for (var subject in result['subjectDetails']) {
          var prettyJson = JsonEncoder.withIndent('\t').convert(subject);
          prettyJson.split('\n').forEach((line) => print(line));
        }
      }

      final List<OnlineExam> exams = [];
      if (result['exams'] is List) {
        for (var examData in result['exams']) {
          try {
            exams.add(OnlineExam.fromJson(examData));
          } catch (e) {
            print('Error parsing exam: $e');
          }
        }
      }

      emit(OnlineExamSuccess(
        exams: exams,
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
          .map((subject) => Subject.fromJson(subject))
          .toList();

      emit(SubjectsLoaded(subjects));
    } catch (e) {
      emit(SubjectsError(e.toString()));
    }
  }
}
