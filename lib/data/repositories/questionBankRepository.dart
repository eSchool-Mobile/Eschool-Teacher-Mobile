import 'package:eschool_saas_staff/data/models/question.dart';
import 'package:eschool_saas_staff/data/models/subjectQuestion.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'dart:convert';

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
      await Api.post(
        url: Api.createQuestion,
        body: question.toJson(),
        useAuthToken: true,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> updateQuestion(int questionId, Question question) async {
    try {
      final body = {
        'banksoal_id': questionId,
        ...question.toJson()
      };
      
      await Api.post(
        url: Api.updateQuestion,
        body: body,
        useAuthToken: true,
      );
    } catch (e) {
      throw ApiException(e.toString());
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