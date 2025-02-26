import 'dart:convert';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/data/models/onlineExam.dart';
import 'package:eschool_saas_staff/data/models/questionOnlineExam.dart';
import 'package:eschool_saas_staff/data/models/BankOnlineQuestion.dart'; // Update this importimport 'package:eschool_saas_staff/data/models/bankSoalQuestion.dart';import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:dio/dio.dart';

class OnlineExamRepository {
  Future<Map<String, dynamic>> getOnlineExams({
    String? search,
    int? subjectId,
    dynamic? archive = null,
    int? classSectionId,
    int? sessionYearId,
    String status = 'active',
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
          if (subjectId != null) 'class_subject_id': subjectId.toString(),
          if (classSectionId != null)
            'class_section_id': classSectionId.toString(),
          if (sessionYearId != null)
            'session_year_id': sessionYearId.toString(),
          'type': 'all',
          if (archive != null) 'archive': archive,
        },
      );

      // Return all exams without filtering
      return {
        'exams': response['rows'] ?? [],
        'subjectDetails': response['subjectDetails'] ?? [],
      };
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
      final response = await Api.post(
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

      print('Update Exam Response: $response');
    } catch (e) {
      print('Error updating online exam: $e');
      throw Exception('Failed to update online exam: $e');
    }
  }

  Future<void> deleteOnlineExam(int id, {String mode = 'archive'}) async {
    try {
      final response = await Api.delete(
        url: '${Api.deleteOnlineExam}/$id',
        useAuthToken: true,
        body: {
          'mode': mode,
        },
        queryParameters: {
          'mode': mode,
        },
      );

      print('Delete Response in Repository: $response');

      if (response['status'] != true) {
        throw ApiException(
            response['message'] ?? 'Failed to delete online exam');
      }

      // Tunggu sebentar sebelum melanjutkan
      await Future.delayed(Duration(milliseconds: 1000));
    } catch (e) {
      print('Error deleting online exam: $e');
      if (e is ApiException) {
        throw e;
      }
      throw ApiException('Failed to delete online exam: $e');
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

  Future<List<QuestionOnlineExam>> getOnlineExamQuestions(
    int examId, {
    int? bankId,
  }) async {
    try {
      final response = await Api.get(
        url: "${Api.getOnlineExamQuestions}/$examId",
        useAuthToken: true,
        queryParameters: bankId != null ? {'bank_id': bankId} : null,
      );

      print('Questions Response: $response');

      if (response['status'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final examQuestions = data['exam_questions'] as List;

        return examQuestions.map((question) {
          // Parse options
          final options = (question['options'] as List?)?.first ?? {};

          print("OK BELUM ERROR");

          return QuestionOnlineExam(
            id: question['id'] ?? 0,
            question: question['question_text'] ?? '',
            correctAnswer: options['is_answer'] == 1
                ? 'A'
                : '', // Sesuaikan dengan response API
            marks: question['marks'] ?? 0,
            options: question['options'],
            title: '', // Bisa diambil dari exam['title'] jika diperlukan
            version: '1.0', // Sesuaikan dengan kebutuhan
            type: question["type"] ?? "multiple_choice",
            onlineExamId: examId,
          );
        }).toList();
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
          'questions': questions.map((q) => q.toJson()).toList(),
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

  Future<List<QuestionOnlineExam>> getOnlineExamQuestionListCorrection(
      int examId, String? search) async {
    try {
      final response = await Api.get(
          url:
              "${Api.getOnlineExamQuestionListCorrection}?examId=${examId.toString()}&&search=${search}",
          useAuthToken: true,
          queryParameters: {
            "examId": examId.toString(),
            if (search != null) "search": search,
          });

      print("RIL DATA");

      String jsonString = JsonEncoder.withIndent("  ").convert(response);
      jsonString.split('\n').forEach(print);

      if (response['status'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final examQuestions = data['exam_questions'] as List;

        return examQuestions.map((question) {
          final options = (question['options'] as List?)?.first ?? {};

          return QuestionOnlineExam(
            id: question['id'] ?? 0,
            question: question['question_text'] ?? '',
            correctAnswer: options['is_answer'] == 1
                ? 'A'
                : '', // Sesuaikan dengan response API
            marks: question['marks'] ?? 0,
            options: question['options'],
            title: '', // Bisa diambil dari exam['title'] jika diperlukan
            version: '1.0', // Sesuaikan dengan kebutuhan
            type: question["type"] ?? "multiple_choice",
            onlineExamId: examId,
          );
        }).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch questions');
      }
    } catch (e) {
      print('Error fetching questions: $e');
      throw Exception(e.toString());
    }
  }

  Future<List<BankSoalQuestion>> getBankSoal(int examId) async {
    try {
      final response = await Api.get(
        url: "${Api.getOnlineExamQuestions}/$examId",
        useAuthToken: true,
      );

      print('Bank Soal Response: $response');

      if (response['status'] == true) {
        final List bankList = response['data']['bank_soal'] ?? [];
        return bankList.map((bank) => BankSoalQuestion.fromJson(bank)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch bank soal');
      }
    } catch (e) {
      print('Error fetching bank soal: $e');
      throw Exception(e.toString());
    }
  }
}
