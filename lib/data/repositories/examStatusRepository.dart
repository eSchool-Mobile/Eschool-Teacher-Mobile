import 'package:eschool_saas_staff/data/models/studentExamStatus.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:dio/dio.dart';

class ExamStatusRepository {
  Future<StudentExamStatusResponse> getStudentExamStatus(int examId) async {
    try {
      final result = await Api.get(
        url: Api.getOnlineExamStatus,
        queryParameters: {
          'online_exam_id': examId,
        },
      );

      // Debug: Log the actual response format
      print('API Response Type: ${result.runtimeType}');
      print('API Response: $result');

      // Handle wrapped object response format (normal case)
      print('Processing as Object response');
      return StudentExamStatusResponse.fromJson(result);
    } on ApiException catch (apiError) {
      // Handle API specific errors
      print('API Exception: ${apiError.errorMessage}');

      // If the API throws "Invalid response format", it might be because
      // the server returned an array instead of expected object format
      if (apiError.errorMessage.contains('Invalid response format')) {
        // Try to make a raw HTTP request to get the actual response
        try {
          final dio = Dio();
          final response = await dio.get(
            Api.getOnlineExamStatus,
            queryParameters: {
              'online_exam_id': examId,
            },
            options: Options(
              headers: Api.headers(useAuthToken: true),
              responseType: ResponseType.json,
            ),
          );

          print('Raw Response Status: ${response.statusCode}');
          print('Raw Response Data Type: ${response.data.runtimeType}');
          print('Raw Response Data: ${response.data}');

          if (response.statusCode == 200 && response.data is List) {
            // Process the array response directly
            final List<StudentExamStatus> studentStatuses = [];

            for (var item in response.data as List) {
              if (item is Map<String, dynamic>) {
                try {
                  studentStatuses.add(StudentExamStatus.fromJson(item));
                } catch (parseError) {
                  print('Error parsing individual item: $parseError');
                  print('Item data: $item');
                }
              }
            }

            return StudentExamStatusResponse(
              success: true,
              message: 'Data berhasil dimuat',
              data: studentStatuses,
            );
          }
        } catch (rawError) {
          print('Raw request also failed: $rawError');
        }
      }

      throw Exception('API Error: ${apiError.errorMessage}');
    } catch (e, stackTrace) {
      print('Repository Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to get exam status: $e');
    }
  }

  // Add new method to delete student exam status
  Future<Map<String, dynamic>> deleteStudentExamStatus(
      int examId, int studentId) async {
    try {
      final result = await Api.delete(
        url: Api.resetOnlineExamStatus,
        body: {
          'online_exam_id': examId,
          'student_id': studentId,
        },
        useAuthToken: true,
      );

      return result;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
