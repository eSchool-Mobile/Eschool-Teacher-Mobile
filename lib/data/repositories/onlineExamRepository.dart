import 'dart:convert';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/data/models/onlineExam.dart';
import 'package:eschool_saas_staff/data/models/questionOnlineExam.dart';
import 'package:eschool_saas_staff/data/models/BankOnlineQuestion.dart'; // Update this importimport 'package:eschool_saas_staff/data/models/bankSoalQuestion.dart';import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class OnlineExamRepository {
  Future<Map<String, dynamic>> getOnlineExams({
    String? search,
    int? subjectId,
    dynamic? archive = null,
    int? classSectionId,
    int? sessionYearId,
    String status = 'active',
    DateTime? startDate,
    DateTime? endDate,
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
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
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

      return {
        'exams': response['rows'] ?? [],
        'subjectDetails': response['subjectDetails'] ?? [],
      };
    } catch (e) {
      print("Repository Error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getOnlineExamResultAnswer({
    required int onlineExamId,
    required int questionId,
    String? search,
  }) async {
    try {
      // Convert null search to empty string to avoid 'null' in URL
      final searchQuery = search ?? '';

      final response = await Api.get(
        url: Api.getOnlineExamAnswerCorrection,
        useAuthToken: true,
        queryParameters: {
          'online_exam_id': onlineExamId,
          'question_id': questionId,
          'search': searchQuery,
        },
      );

      print("===");
        var encoder = JsonEncoder.withIndent("  "); // Indentasi 2 spasi
  String prettyJson = encoder.convert(response);

  // Split per baris dan print satu per satu
  prettyJson.split('\n').forEach(print);


      // Check for error response
      if (response['error'] == true) {
        throw Exception(response['message'] ?? 'Unknown error occurred');
      }

      // Check for valid data structure
      if (response['status'] == true && response['data'] != null) {
        return { "marks": response['data']['marks'], "answers": response['data']['answers'] as List<dynamic> };
      }

      return { "marks": response['data']['marks'] ?? 0, "answers": [] };
    } catch (e) {
      print('Error getting online exam result answer: $e');
      throw Exception('Failed to fetch exam answers: ${e.toString()}');
    }
  }

  Future<void> updateOnlineExamAnswerCorrection({
    required int onlineExamId,
    required List<Map<String, int>> data,
  }) async {
    try {
      final response = await Api.post(
        url: Api.updateOnlineExamAnswerCorrection,
        useAuthToken: true,
        body: {
          'online_exam_id': onlineExamId,
          'data': data,
        },
      );

      print("ERROR UPDATE ANSWER: $response");

      if (response['status'] != true) {
        throw ApiException(
            response['message'] ?? 'Failed to update online exam question');
      }
    } catch (e) {
      throw ApiException(e.toString());
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
  }) async {
    try {
      final response = await Api.post(
        url: '${Api.updateOnlineExam}/$id',
        useAuthToken: true, // Enable authentication
        body: {
          'class_section_id': classSectionId.toString(),
          'class_subject_id': classSubjectId.toString(),
          'title': title,
          'exam_key': examKey,
          'duration': duration.toString(),
          'start_date': DateFormat('yyyy-MM-dd HH:mm').format(startDate),
        },
      );

      print('Update Exam Response: $response');

      if (response.containsKey('status') && response['status'] != true) {
        throw ApiException(
            response['message'] ?? 'Failed to update online exam');
      }
    } catch (e) {
      print('Error updating online exam: $e');
      throw ApiException(e.toString());
    }
  }

  Future<void> deleteOnlineExam(int id, {String mode = 'archive'}) async {
    try {
      // Cek apakah ujian masih ada sebelum dihapus
      final checkExam = await Api.get(
        url: '${Api.getOnlineExamList}',
        useAuthToken: true,
        queryParameters: {
          'exam_id': id.toString(),
        },
      );

      if (checkExam['rows']?.isEmpty ?? true) {
        throw ApiException(
            'Ujian tidak ditemukan atau sudah dihapus sebelumnya');
      }

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

      if (response['status'] != true) {
        throw ApiException(response['message'] ?? 'Gagal menghapus ujian');
      }

      // Tunggu sebentar sebelum melanjutkan
      await Future.delayed(Duration(milliseconds: 500));
    } catch (e) {
      print('Error deleting online exam: $e');
      if (e is DioException) {
        final response = e.response?.data;
        if (e.response?.statusCode == 404) {
          throw ApiException(
              'Ujian tidak ditemukan atau sudah dihapus sebelumnya');
        }
        throw ApiException(response?['message'] ?? 'Gagal menghapus ujian');
      }
      throw ApiException(e.toString());
    }
  }

  Future<void> restoreOnlineExam(int id) async {
    try {
      final response = await Api.delete(
        // Ubah dari post ke delete
        url: '${Api.deleteOnlineExam}/$id',
        useAuthToken: true,
        body: {
          'mode': 'restore',
        },
        queryParameters: {
          'mode': 'restore', // Tambahkan query parameter
        },
      );

      print('Restore Exam Response: $response');

      if (response['status'] != true) {
        throw ApiException(
            response['message'] ?? 'Failed to restore online exam');
      }

      // Tunggu sebentar sebelum melanjutkan
      await Future.delayed(Duration(milliseconds: 500));
    } catch (e) {
      print('Error restoring online exam: $e');
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> createOnlineExam({
    required int classSectionId,
    required int classSubjectId,
    required String title,
    required String examKey,
    required int duration,
    required DateTime startDate,
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
          'start_date': DateFormat('yyyy-MM-dd HH:mm').format(startDate),
        },
      );

      print('Create Exam Response: $response');

      if (response['status'] == true) {
        return response['data'] ?? {};
      } else {
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
            question_id: question['question_id'] ?? 0,
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

  Future<List<QuestionOnlineExam>> getOnlineExamQuestionListCorrection(
      int examId, String? search) async {
    try {
      final response = await Api.get(
          url:
              "${Api.getOnlineExamQuestionListCorrection}?exam_id=${examId.toString()}&&search=${search}",
          useAuthToken: true);
      
      print("AMAN SINI 1");

      if (response['status'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        print("AMAN SINI 2");
        final examQuestions = data['exam_questions'] as List;

        print("AMAN SINI 3");

        return examQuestions.map((question) {
final options = (question['options'] as List?)?.isNotEmpty == true
    ? question['options']!.first
    : {};

          return QuestionOnlineExam(
            id: question['id'] ?? 0,
            question_id: question['question_id'] ?? 0,
            question: question['question_text'] ?? '',
            correctAnswer: options['is_answer'] == 1
                ? 'A'
                : '', // Sesuaikan dengan response API
            marks: question['marks'] ?? 0,
            options: question['options'],
            title: '',
            version: '1.0', // Sesuaikan dengan kebutuhan
            type: question["question_type"] ?? "multiple_choice",
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

      if (response['status'] == true && response['data'] != null) {
        // Extract exam data untuk mendapatkan class_section_id dan class_subject_id
        final examData = response['data']['exam'] as Map<String, dynamic>?;
        final classSectionId = examData?['class_section']?['id'] ?? 0;
        final classSubjectId = examData?['subject']?['id'] ?? 0;

        // Parse bank soal list
        final List bankList = response['data']['bank_soal'] ?? [];
        return bankList.map((bank) {
          // Tambahkan class_section_id dan class_subject_id ke setiap bank soal
          final bankData = Map<String, dynamic>.from(bank);
          bankData['class_section_id'] = classSectionId;
          bankData['class_subject_id'] = classSubjectId;
          return BankSoalQuestion.fromJson(bankData);
        }).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch bank soal');
      }
    } catch (e) {
      print('Error fetching bank soal: $e');
      throw Exception(e.toString());
    }
  }

  Future<void> storeOnlineExamQuestions({
    required int examId,
    required int classSectionId,
    required int classSubjectId,
    required Map<String, Map<String, dynamic>> assignQuestions,
  }) async {
    try {
      // Add additional validation
      if (examId <= 0 || classSectionId <= 0 || classSubjectId <= 0) {
        throw ApiException('Invalid input parameters');
      }

      final response = await Api.post(
        url: Api.storeOnlineExamQuestions,
        useAuthToken: true,
        body: {
          'exam_id': examId,
          'class_section_id': classSectionId,
          'class_subject_id': classSubjectId,
          'assign_questions': assignQuestions,
          'merge_existing': true, // Add flag to merge with existing questions
        },
      );

      print('Store questions response: $response');

      if (response['status'] != true) {
        throw ApiException(response['message'] ?? 'Failed to store questions');
      }
    } catch (e) {
      print('Error storing questions: $e');
      throw ApiException(e.toString());
    }
  }

  Future<void> deleteOnlineExamQuestions(
      int examId, List<int> questionIds) async {
    try {
      print('=== DELETE QUESTIONS REQUEST ===');
      print('URL: ${Api.deleteQuestionOnlineExam}');
      print('Exam ID: $examId');
      print('Question IDs: $questionIds');

      final response = await Api.delete(
        url: Api.deleteQuestionOnlineExam,
        useAuthToken: true,
        body: {
          'exam_id': examId,
          'question_id': questionIds,
        },
      );

      print('=== DELETE QUESTIONS RESPONSE ===');
      print('Status: ${response['status']}');
      print('Message: ${response['message']}');
      print('Full Response: $response');

      if (response['status'] != true) {
        throw ApiException(response['message'] ?? 'Failed to delete questions');
      }
    } catch (e) {
      print('=== DELETE QUESTIONS ERROR ===');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: $e');
      throw ApiException(e.toString());
    }
  }
}
