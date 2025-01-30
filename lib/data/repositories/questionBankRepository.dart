import 'package:eschool_saas_staff/data/models/question.dart' hide ApiException;
import 'package:eschool_saas_staff/data/models/subjectQuestion.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

class QuestionBankRepository {
  Future<List<SubjectQuestion>> getQuestionsBySubject(int subjectId) async {
    try { 
      final result = await Api.get(
        url: Api.getQuestionBank,
        queryParameters: {'subject_id': subjectId},
        useAuthToken: true,
      );
      
      print("RAW API RESPONSE: ${jsonEncode(result)}"); // Debug print
      
      final List dataList = result['data'] as List;
      return dataList.map((item) {
        print("Processing item: ${jsonEncode(item)}"); // Debug print
        return SubjectQuestion.fromJson(item as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Repository Error: $e"); 
      throw e;
    }
  }

  Future<Question> getQuestionDetail(int subjectId, int questionId) async {
    try {
      final result = await Api.get(
        url: Api.getQuestionDetail,
        queryParameters: {
          'subject_id': subjectId,
          'banksoal_id': questionId
        },
        useAuthToken: true,  
      );
      
      return Question.fromJson(result['data']);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> createQuestion(Question question) async {
    try {
      // Validate options
      if (question.options.isEmpty) {
        throw ApiException('At least one option is required');
      }

      // Validate each option
      for (var option in question.options) {
        if (option.text.trim().isEmpty) {
          throw ApiException('Option text is required');
        }
        if (option.feedback.trim().isEmpty) {
          throw ApiException('Option feedback is required');
        }
        if (option.percentage.isEmpty) {
          throw ApiException('Option percentage is required');
        }
      }

      final formData = {
        'subject_id': int.parse(question.subjectId),
        'name': question.name.trim(),
        'type': question.type.toLowerCase(),
        'default_point': int.parse(question.defaultPoint),
        'question': question.question.trim(),
        'note': question.note.trim(),
        'options': question.options.map((option) => {
          'text': option.text.trim(),
          'percentage': int.parse(option.percentage),
          'feedback': option.feedback.trim()
        }).toList(),
      };

      print("Creating question with formData: $formData");

      final result = await Api.post(
        url: Api.createQuestion,
        body: formData,
        useAuthToken: true,  
      );

      if (result['error'] == true) {
        throw ApiException(result['message'] ?? 'Failed to create question');
      }
    } catch (e) {
      print("Error creating question: $e");
      throw ApiException(e.toString());
    }
  }

  Future<void> updateQuestion(Question question) async {
    try {
      final requestBody = {
        'banksoal_id': question.id,
        'subject_id': int.parse(question.subjectId), // Convert string to int
        'name': question.name,
        'type': question.type,
        'default_point': question.defaultPoint,
        'question': question.question,
        'note': question.note,
        'options': question.options.map((option) => {
          'text': option.text,
          'percentage': option.percentage,
          'feedback': option.feedback
        }).toList(),
      };

      print('Update Request: $requestBody');

      final result = await Api.post(
        url: Api.updateQuestion,
        body: requestBody,
        useAuthToken: true,
      );

      if (result['error'] == true) {
        throw ApiException(result['message']);
      }
    } catch (e) {
      print('Error updating question: $e');
      rethrow;
    }
  }

  Future<void> deleteQuestion(int subjectId, int questionId) async {
    try {
      await Api.get(
        url: Api.deleteQuestion,
        queryParameters: {
          'subject_id': subjectId,
          'banksoal_id': questionId  
        },
        useAuthToken: true,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
