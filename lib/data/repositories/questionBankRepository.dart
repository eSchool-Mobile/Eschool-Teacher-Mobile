import 'dart:convert';
import 'package:eschool_saas_staff/data/models/question.dart' hide ApiException;
import 'package:eschool_saas_staff/data/models/questionBank.dart';
import 'package:eschool_saas_staff/data/models/subjectQuestion.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class QuestionBankRepository {
  Future<List<SubjectQuestion>> getTeacherSubjects() async {
    try {
      final response = await Api.get(url: Api.getTeacherSubject);
      print("API Raw Response: $response"); // Debug log

      if (response['data'] == null) {
        throw ApiException("Data is null");
      }

      final subjects = (response['data'] as List)
          .map((json) => SubjectQuestion.fromJson(json))
          .toList();
      print("Parsed Subjects: $subjects"); // Debug log

      return subjects;
    } catch (e) {
      print("Error fetching subjects: $e");
      throw ApiException(e.toString());
    }
  }

  Future<List<Question>> getBankQuestions(int subjectId, int bankId) async {
    try {
      final response = await Api.get(
        url: Api.getBankQuestions,
        queryParameters: {
          'subject_id': subjectId,
          'banksoal_id': bankId,
        },
      );

      print("API Raw Response: $response"); // Debug log

      if (response['data'] == null) {
        throw ApiException("Data is null");
      }

      final questions = (response['data'] as List)
          .map((json) => Question.fromJson(json))
          .toList();

      print("Parsed Questions: $questions"); // Debug log

      return questions;
    } catch (e) {
      print("Error fetching questions: $e");
      throw ApiException(e.toString());
    }
  }

  Future<List<BankSoal>> getBankSoal(int subjectId) async {
    try {
      final response = await Api.get(
        url: Api.getBankSoal,
        queryParameters: {'subject_id': subjectId},
      );

      if (response['data'] == null) {
        throw ApiException("Data is null");
      }

      final bankSoal = (response['data'] as List)
          .map((json) => BankSoal.fromJson(json))
          .toList();

      return bankSoal;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> createQuestionBank({
    required int subjectId,
    required String name,
  }) async {
    try {
      print(
          "Creating bank soal with: subject_id=$subjectId, name=$name"); // Debug log

      final response = await Api.post(
        url: Api.createQuestionBank,
        body: {
          'subject_id': subjectId.toString(), // Convert to string
          'name': name,
        },
      );

      print("Create bank soal response: $response"); // Debug log

      if (response['error'] == true) {
        throw ApiException(response['message']);
      }
    } catch (e) {
      print("Error creating bank soal: $e"); // Debug log
      throw ApiException(e.toString());
    }
  }

  Future<void> createQuestion({
    required int banksoalId,
    required int subjectId,
    required String name,
    required String type,
    required int defaultPoint,
    required String question,
    String note = '', // Make note optional with default empty string
    required List<QuestionOption> options,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'banksoal_id': banksoalId.toString(),
        'subject_id': subjectId.toString(),
        'name': name,
        'type': type,
        'default_point': defaultPoint.toString(),
        'question': question,
        'note': note, // No need to check if empty
        'options': options
            .map((opt) => {
                  'text': opt.text,
                  'percentage': opt.percentage,
                  'feedback': opt.feedback,
                })
            .toList(),
      };

      await Api.post(url: Api.createQuestion, body: requestBody);
    } catch (e) {
      throw ApiException('Failed to create question: ${e.toString()}');
    }
  }

  Future<void> updateQuestionBank({
    required int subjectId,
    required int banksoalId,
    required String name,
  }) async {
    try {
      final response = await Api.post(
        url: Api.updateQuestionBank,
        body: {
          'subject_id': subjectId,
          'banksoal_id': banksoalId,
          'name': name,
        },
      );

      if (response['error'] == true) {
        throw ApiException(response['message']);
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> updateQuestion({
    required int banksoalSoalId,
    required int subjectId,
    required String name,
    required String type,
    required int defaultPoint,
    required String question,
    String note = '',
    required List<QuestionOption> options,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'banksoal_soal_id': banksoalSoalId.toString(),
        'subject_id': subjectId.toString(),
        'name': name,
        'type': type,
        'default_point': defaultPoint.toString(),
        'question': question,
        'note': note,
        'options': options
            .map((opt) => {
                  'text': opt.text,
                  'percentage': opt.percentage.toString(),
                  'feedback': opt.feedback,
                })
            .toList(),
      };

      print("Updating question with data: $requestBody"); // Debug log

      final response =
          await Api.post(url: Api.updateQuestion, body: requestBody);

      print("Update response: $response"); // Debug log

      // Check response code and error flag
      if (response['code'] == 200 && response['error'] == false) {
        print("Question updated successfully");
        return;
      }

      throw ApiException(response['message'] ?? 'Failed to update question');
    } catch (e) {
      print("Error updating question: $e"); // Debug log

      // Check if response indicates success despite error
      if (e.toString().contains('Soal Updated Successfully')) {
        print("Update successful despite error");
        return;
      }

      throw ApiException(e.toString());
    }
  }

  Future<void> deleteBankSoal({
    required int subjectId,
    required int banksoalId,
  }) async {
    try {
      print('🗑️ Attempting to delete bank soal:');
      print('Subject ID: $subjectId');
      print('Bank Soal ID: $banksoalId');

      final response = await Api.delete(
        url: Api.deleteQuestionBank,
        body: {
          'subject_id': subjectId.toString(),
          'banksoal_id': banksoalId.toString(),
        },
      );

      print('Delete Response: $response');

      if (response['error'] == true) {
        print('❌ Delete Error: ${response['message']}');
        throw ApiException(response['message']);
      }

      print('✅ Bank soal deleted successfully');
    } catch (e) {
      print('❌ Delete Exception: $e');
      throw ApiException(e.toString());
    }
  }

  Future<void> deleteQuestion({
    required int subjectId,
    required int banksoalId,
    required int banksoalSoalId,
  }) async {
    try {
      print('🗑️ Attempting to delete question:');
      print('Subject ID: $subjectId');
      print('Bank Soal ID: $banksoalId');
      print('Question ID: $banksoalSoalId');

      final response = await Api.delete(
        url: Api.deleteQuestion,
        body: {
          'subject_id': subjectId.toString(),
          'banksoal_id': banksoalId.toString(),
          'banksoal_soal_id': banksoalSoalId.toString(),
        },
      );

      print('Delete Response: $response');

      if (response['error'] == true) {
        print('❌ Delete Error: ${response['message']}');
        throw ApiException(response['message']);
      }

      print('✅ Question deleted successfully');
    } catch (e) {
      print('❌ Delete Exception: $e');
      throw ApiException(e.toString());
    }
  }
}
