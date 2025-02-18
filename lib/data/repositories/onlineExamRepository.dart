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

          return QuestionOnlineExam(
            id: question['id'] ?? 0,
            question: question['question_text'] ?? '',
            optionA: options['option'] ?? '', // Menggunakan option dari options
            optionB: '', // Sesuaikan dengan response API
            optionC: '', // Sesuaikan dengan response API
            optionD: '', // Sesuaikan dengan response API
            correctAnswer: options['is_answer'] == 1
                ? 'A'
                : '', // Sesuaikan dengan response API
            marks: question['marks'] ?? 0,
            title: '', // Bisa diambil dari exam['title'] jika diperlukan
            version: '1.0', // Sesuaikan dengan kebutuhan
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

  Future<List<Map<String, dynamic>>> getBankSoal() async {
    try {
      final response = await Api.get(
        url: Api.getBankSoal,
        useAuthToken: true,
        queryParameters: {
          'status': 'active', // Add required parameters
          'type': 'all'
        },
      );

      if (response['status'] == true || response['error'] == false) {
        final data = response['data'];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data.containsKey('bank_soal')) {
          return List<Map<String, dynamic>>.from(data['bank_soal']);
        }
        return [];
      } else {
        throw Exception(
            response['message'] ?? 'Failed to fetch question banks');
      }
    } catch (e) {
      print('Error fetching question banks: $e');
      throw Exception(e.toString());
    }
  }
}
