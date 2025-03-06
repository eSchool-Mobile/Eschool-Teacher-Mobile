import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:eschool_saas_staff/data/models/question.dart' hide ApiException;
import 'package:eschool_saas_staff/data/models/questionBank.dart';
import 'package:eschool_saas_staff/data/models/subjectQuestion.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class QuestionBankRepository {
  Future<List<SubjectQuestion>> getTeacherSubjects(
      {bool isStaffView = false}) async {
    try {
      final response = await Api.get(
        url: Api.getTeacherSubject,
        queryParameters:
            isStaffView ? {'view_type': 'staff', 'all': true} : null,
      );

      print(
          "Raw API Response for ${isStaffView ? 'Staff' : 'Teacher'}: $response");

      if (response['data'] == null) {
        throw ApiException("Data is null");
      }

      // Handle the response structure
      List<Map<String, dynamic>> subjectsData = [];

      if (response['data'] is List) {
        // If data is already a list, use it directly
        subjectsData = (response['data'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else if (response['data'] is Map) {
        // If data is a map, convert its values to a list
        subjectsData = (response['data'] as Map)
            .values
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }

      print("Processed subjects data: $subjectsData");

      final subjects = subjectsData.map((json) {
        try {
          return SubjectQuestion.fromJson(json);
        } catch (e) {
          print("Error parsing subject: $e");
          print("Subject JSON: $json");
          rethrow;
        }
      }).toList();

      print("Successfully parsed ${subjects.length} subjects");
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
    String note = '',
    required List<QuestionOption> options,
    File? image,
  }) async {
    try {
      print('\n=== CREATE QUESTION WITH IMAGE ===');
      print('Starting question creation process...');

      // Create FormData manually to ensure correct format
      final formData = FormData.fromMap({
        'banksoal_id': banksoalId.toString(),
        'subject_id': subjectId.toString(),
        'name': name,
        'type': type,
        'default_point': defaultPoint.toString(),
        'question': question,
        'note': note,
      });

      // Add options as individual form fields
      for (var i = 0; i < options.length; i++) {
        formData.fields.addAll([
          MapEntry('options[$i][text]', options[i].text),
          MapEntry('options[$i][percentage]', options[i].percentage.toString()),
          MapEntry('options[$i][feedback]', options[i].feedback),
        ]);
      }

      // Add image if exists
      if (image != null) {
        print('\n=== IMAGE DETAILS ===');
        print('Image Path: ${image.path}');
        print(
            'Image Size: ${(image.lengthSync() / 1024).toStringAsFixed(2)} KB');
        print('Image Name: ${image.path.split('/').last}');

        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              image.path,
              filename: image.path.split('/').last,
              contentType: MediaType('image', 'jpeg'),
            ),
          ),
        );
        print('Image successfully added to form data');
      }

      print('\n=== SENDING REQUEST ===');
      print('Request URL: ${Api.createQuestion}');
      print('Form Data Fields: ${formData.fields}');

      // Use Dio with custom headers
      final dio = Dio();
      dio.options.headers = {
        ...Api.headers(),
        'Content-Type': 'multipart/form-data',
      };

      final response = await dio.post(
        Api.createQuestion,
        data: formData,
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      print('\n=== RESPONSE DETAILS ===');
      print('Response Status: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.data['error'] == true) {
        throw ApiException(
            response.data['message'] ?? 'Failed to create question');
      }

      print('\n=== QUESTION CREATED SUCCESSFULLY ===');
    } catch (e) {
      print('\n=== ERROR CREATING QUESTION ===');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: $e');
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
    File? image, // Tambahkan parameter image
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

      // Add image if provided
      if (image != null) {
        requestBody['image'] = await MultipartFile.fromFile(
          image.path,
          filename: 'question_image.jpg',
        );
      }

      final response =
          await Api.post(url: Api.updateQuestion, body: requestBody);

      if (response['code'] == 200 && response['error'] == false) {
        print("Question updated successfully");
        return;
      }

      throw ApiException(response['message'] ?? 'Failed to update question');
    } catch (e) {
      print("Error updating question: $e");

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

      // Verify question exists first
      final questions = await getBankQuestions(subjectId, banksoalId);
      final questionExists = questions.any((q) => q.id == banksoalSoalId);

      if (!questionExists) {
        throw ApiException('Soal tidak ditemukan atau sudah dihapus');
      }

      final response = await Api.delete(
        url: Api.deleteQuestion,
        body: {
          'subject_id': subjectId.toString(),
          'banksoal_id': banksoalId.toString(),
          'banksoal_soal_id': banksoalSoalId.toString(),
        },
      );

      print('Delete Response: $response');

      // Handle specific validation error
      if (response['error'] == true) {
        if (response['message'] is Map &&
            response['message']['banksoal_soal_id']
                    ?.contains('validation.exists') ==
                true) {
          throw ApiException('Soal tidak ditemukan atau sudah dihapus');
        }
        throw ApiException(response['message'].toString());
      }

      print('✅ Question deleted successfully');
    } catch (e) {
      print('❌ Delete Exception: $e');
    }
  }
}
