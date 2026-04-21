import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/models/assignmentMonitoring.dart';
import 'package:eschool_saas_staff/data/models/teacherAssignmentDetail.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:flutter/foundation.dart';

class AssignmentMonitoringRepository {
  Future<Map<String, dynamic>> getAssignmentMonitoring({
    String? submissionStatus,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': limit,
      };

      if (submissionStatus != null && submissionStatus.isNotEmpty) {
        queryParameters['submission_status'] = submissionStatus;

        // Make sure to include_zero_assignments when filtering for not_submitted
        if (submissionStatus == 'not_submitted') {
          queryParameters['include_zero_assignments'] = 'true';
          debugPrint('DEBUG: Including zero assignments for not_submitted filter');
        }
      }

      // Only include date filters if both are provided
      if (startDate != null &&
          startDate.isNotEmpty &&
          endDate != null &&
          endDate.isNotEmpty) {
        queryParameters['start_date'] = startDate;
        queryParameters['end_date'] = endDate;
      }

      // Print final query parameters
      debugPrint('DEBUG: API Request parameters: $queryParameters');

      final result = await Api.get(
        url: Api.getAssignmentMonitoring,
        queryParameters: queryParameters,
        useAuthToken: true,
      );

      // Print response status untuk debugging
      debugPrint(
          'DEBUG: API Response - error: ${result['error']}, message: ${result['message']}');
      debugPrint('DEBUG: Total records: ${result['data']['total']}');

      // Tambahan log khusus untuk filter not_submitted
      if (submissionStatus == 'not_submitted') {
        final rows = result['data']['rows'] as List;
        if (rows.isNotEmpty) {
          debugPrint(
              'DEBUG: Found ${rows.length} teachers with not_submitted status');
          for (int i = 0; i < (rows.length > 3 ? 3 : rows.length); i++) {
            debugPrint(
                'DEBUG: Teacher: ${rows[i]['teacher_name']}, Total Assignments: ${rows[i]['total_assignments']}');
          }
        } else {
          debugPrint('DEBUG: No teachers found with not_submitted status');
        }
      }

      return {
        "data": AssignmentMonitoringResponse.fromJson(result),
      };
    } on DioException catch (e) {
      throw ApiException(e.response?.data?["message"] ??
          "Gagal mendapatkan data pemantauan tugas");
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(
          "Terjadi kesalahan tidak terduga saat memproses data pemantauan tugas");
    }
  }

  Future<Map<String, dynamic>> getTeacherAssignmentDetails({
    required int teacherId,
    String? submissionStatus,
    String? startDate,
    String? endDate,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {};

      if (submissionStatus != null && submissionStatus.isNotEmpty) {
        queryParameters['submission_status'] = submissionStatus;
      }

      // Only include date filters if both are provided
      if (startDate != null &&
          startDate.isNotEmpty &&
          endDate != null &&
          endDate.isNotEmpty) {
        queryParameters['start_date'] = startDate;
        queryParameters['end_date'] = endDate;
      }

      final result = await Api.get(
        url: "${Api.getTeacherAssignmentMonitoring}/$teacherId/assignments",
        queryParameters: queryParameters,
        useAuthToken: true,
      );

      return {
        "data": TeacherAssignmentDetailResponse.fromJson(result),
      };
    } on DioException catch (e) {
      throw ApiException(e.response?.data?["message"] ??
          "Gagal mendapatkan detail tugas guru");
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(
          "Terjadi kesalahan tidak terduga saat memproses detail tugas guru");
    }
  }
}
