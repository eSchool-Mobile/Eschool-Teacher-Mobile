import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/models/assignmentMonitoring.dart';
import 'package:eschool_saas_staff/data/models/teacherAssignmentDetail.dart';
import 'package:eschool_saas_staff/utils/api.dart';

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
        url: Api.getAssignmentMonitoring,
        queryParameters: queryParameters,
        useAuthToken: true,
      );

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
