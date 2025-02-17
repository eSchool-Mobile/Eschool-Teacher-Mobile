import 'dart:convert';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/data/models/onlineExam.dart';
import 'package:eschool_saas_staff/data/models/questionOnlineExam.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:dio/dio.dart';

class OnlineExamRepository {
  Future<Map<String, dynamic>> getOnlineExams({
    String? search,
    int? subjectId, // Ini adalah class_subject_id
    int? classSectionId,
    int? sessionYearId,
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      final response = await Api.get(
        url: Api.getOnlineExamList,
        useAuthToken: true,
        queryParameters: {
          'offset': offset.toString(),
          'limit': limit.toString(),
          'sort': 'id',
          'order': 'DESC',
          if (search != null && search.isNotEmpty) 'search': search,
          if (subjectId != null)
            'class_subject_id':
                subjectId.toString(), // Ubah ke class_subject_id
          if (classSectionId != null)
            'class_section_id': classSectionId.toString(),
          if (sessionYearId != null)
            'session_year_id': sessionYearId.toString(),
          'status': 'active',
          'type': 'all',
        },
      );

      print('API Response: $response');

      if (response is Map<String, dynamic>) {
        return {
          'exams': response['rows'] ?? [],
          'subjectDetails': response['subjectDetails'] ?? [],
        };
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print("Repository Error: $e");
      rethrow;
    }
  }

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
      await Api.post(
        url: '${Api.updateOnlineExam}/$id',
        useAuthToken: true, // Enable authentication
        body: {
          'class_section_id': classSectionId,
          'class_subject_id': classSubjectId,
          'title': title,
          'exam_key': examKey,
          'duration': duration,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
    } catch (e) {
      print('Error updating online exam: $e');
      throw Exception('Failed to update online exam: $e');
    }
  }

  Future<void> deleteOnlineExam(int id, {String mode = 'archive'}) async {
    try {
      await Api.delete(
        url: '${Api.deleteOnlineExam}/$id',
        useAuthToken: true, // Enable authentication
        body: {},
        queryParameters: {'mode': mode},
      );
    } catch (e) {
      print('Error deleting online exam: $e');
      throw Exception('Failed to delete online exam: $e');
    }
  }

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
      final response = await Api.post(
        url: Api.createOnlineExam,
        useAuthToken: true,
        body: {
          'class_section_id': classSectionId.toString(),
          'class_subject_id': classSubjectId.toString(),
          'title': title,
          'exam_key': examKey,
          'duration': duration.toString(),
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      print('Create Exam Response: $response');

      // Perbaiki pengecekan response
      if (response['status'] == true) {
        // Berhasil
        return;
      } else {
        // Gagal
        throw Exception(response['message'] ?? 'Failed to create online exam');
      }
    } catch (e) {
      print('Error creating exam: $e');
      throw Exception(e.toString());
    }
  }

  Future<List<QuestionOnlineExam>> getOnlineExamQuestions(int examId) async {
    try {
      final response = await Api.get(
        url: "${Api.getOnlineExamQuestions}/$examId",
        useAuthToken: true,
      );

      print('Questions Response: $response');

      if (response['status'] == true) {
        // Mengambil exam_questions dari nested response
        final data = response['data'] as Map<String, dynamic>;
        final examQuestions = data['exam_questions'] as List;

        // Mengambil bank_soal jika diperlukan
        final bankSoal = data['bank_soal'] as List;

        // Convert exam_questions ke QuestionOnlineExam
        final List<QuestionOnlineExam> questions =
            examQuestions.map((question) {
          return QuestionOnlineExam(
            id: question['id'] ?? 0,
            question: question['question'] ?? '',
            optionA: question['option_a'] ?? '',
            optionB: question['option_b'] ?? '',
            optionC: question['option_c'] ?? '',
            optionD: question['option_d'] ?? '',
            correctAnswer: question['correct_answer'] ?? '',
            marks: question['marks'] ?? 0,
            onlineExamId: examId,
          );
        }).toList();

        return questions;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch questions');
      }
    } catch (e) {
      print('Error fetching questions: $e');
      throw Exception(e.toString());
    }
  }

  Future<void> storeOnlineExamQuestions({
    required int examId,
    required List<QuestionOnlineExam> questions,
  }) async {
    try {
      final response = await Api.post(
        url: Api.storeOnlineExamQuestions,
        useAuthToken: true,
        body: {
          'exam_id': examId,
          'questions': questions.map((q) => q?.toJson()).toList(),
        },
      );

      if (response['status'] != true) {
        throw Exception(response['message'] ?? 'Failed to store questions');
      }
    } catch (e) {
      print('Error storing questions: $e');
      throw Exception(e.toString());
    }
  }
}
