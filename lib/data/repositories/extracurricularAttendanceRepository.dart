import 'package:eschool_saas_staff/data/models/extracurricularAttendance.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/utils/hiveBoxKeys.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ExtracurricularAttendanceRepository {
  // Get attendance data for extracurricular
  Future<ExtracurricularAttendanceResponse> getExtracurricularAttendance({
    required int attendanceId,
    int? extracurricularId,
    String? date,
  }) async {
    try {
      print('🔍 [ATTENDANCE REPO] Getting attendance for ID: $attendanceId');

      // Build query parameters
      Map<String, dynamic> queryParams = {};
      if (extracurricularId != null) {
        queryParams['ekstrakurikuler_id'] = extracurricularId.toString();
      }
      if (date != null) {
        queryParams['date'] = date;
      }

      print('🔍 [ATTENDANCE REPO] Query params: $queryParams');

      final response = await Api.get(
        url: Api.getExtracurricularAttendance
            .replaceAll('{id}', attendanceId.toString()),
        useAuthToken: true,
        queryParameters: queryParams,
      );

      print('🔍 [ATTENDANCE REPO] Response: $response');

      if (response['error'] == false) {
        final attendanceResponse =
            ExtracurricularAttendanceResponse.fromJson(response);
        print(
            '✅ [ATTENDANCE REPO] Successfully parsed ${attendanceResponse.members.length} members');
        return attendanceResponse;
      } else {
        throw Exception(response['message'] ?? 'Failed to get attendance data');
      }
    } catch (e) {
      print('❌ [ATTENDANCE REPO] Error getting attendance: $e');
      throw Exception('Failed to get attendance data: $e');
    }
  }

  // Save attendance data for extracurricular
  Future<ExtracurricularAttendanceSaveResponse> saveExtracurricularAttendance({
    required int sessionId,
    required ExtracurricularAttendanceRequest request,
  }) async {
    try {
      print('💾 [ATTENDANCE REPO] Saving attendance for session: $sessionId');
      print('💾 [ATTENDANCE REPO] Request data: ${request.toJson()}');

      final response = await Api.post(
        url: Api.saveExtracurricularAttendance
            .replaceAll('{id}', sessionId.toString()),
        useAuthToken: true,
        body: request.toJson(),
      );

      print('💾 [ATTENDANCE REPO] Response: $response');

      if (response['success'] == true) {
        final saveResponse =
            ExtracurricularAttendanceSaveResponse.fromJson(response);
        print(
            '✅ [ATTENDANCE REPO] Successfully saved ${saveResponse.savedCount} attendance records');
        return saveResponse;
      } else {
        throw Exception(
            response['message'] ?? 'Failed to save attendance data');
      }
    } catch (e) {
      print('❌ [ATTENDANCE REPO] Error saving attendance: $e');
      throw Exception('Failed to save attendance data: $e');
    }
  }

  // Get extracurricular list for dropdown/filter
  Future<List<Map<String, dynamic>>> getExtracurricularList() async {
    try {
      print('🔍 [ATTENDANCE REPO] Getting extracurricular list');

      final response = await Api.get(
        url: Api.getExtracurriculars,
        useAuthToken: true,
      );

      print('🔍 [ATTENDANCE REPO] Extracurricular list response: $response');

      if (response['error'] == false) {
        final List<dynamic> data = response['data'] ?? [];
        final List<Map<String, dynamic>> extracurriculars = data
            .map((item) => {
                  'id': item['id'],
                  'name': item['name'] ?? item['title'] ?? 'Unknown',
                  'description': item['description'] ?? '',
                })
            .toList();

        print(
            '✅ [ATTENDANCE REPO] Successfully fetched ${extracurriculars.length} extracurriculars');
        return extracurriculars;
      } else {
        throw Exception(
            response['message'] ?? 'Failed to get extracurricular list');
      }
    } catch (e) {
      print('❌ [ATTENDANCE REPO] Error getting extracurricular list: $e');
      throw Exception('Failed to get extracurricular list: $e');
    }
  }

  // Get staff info for session ID (if needed)
  Future<Map<String, dynamic>> getStaffInfo() async {
    try {
      final authBox = Hive.box(authBoxKey);
      final staffData = authBox.get(userDetailsKey);

      if (staffData != null) {
        return {
          'id': staffData['id'],
          'name': staffData['full_name'] ?? staffData['name'],
          'email': staffData['email'],
        };
      } else {
        throw Exception('Staff data not found');
      }
    } catch (e) {
      print('❌ [ATTENDANCE REPO] Error getting staff info: $e');
      throw Exception('Failed to get staff info: $e');
    }
  }

  // Helper method to format date for API (d-m-Y format)
  String formatDateForApi(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  // Helper method to parse date from API (d-m-Y format)
  DateTime? parseDateFromApi(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print('❌ [ATTENDANCE REPO] Error parsing date: $dateString, error: $e');
    }

    return null;
  }

  // Get attendance history for a specific extracurricular and date range
  Future<List<ExtracurricularAttendance>> getAttendanceHistory({
    required int extracurricularId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print(
          '🔍 [ATTENDANCE REPO] Getting attendance history for extracurricular: $extracurricularId');

      Map<String, dynamic> queryParams = {
        'ekstrakurikuler_id': extracurricularId.toString(),
      };

      if (startDate != null) {
        queryParams['start_date'] = formatDateForApi(startDate);
      }
      if (endDate != null) {
        queryParams['end_date'] = formatDateForApi(endDate);
      }

      // Note: This endpoint might need to be adjusted based on actual backend implementation
      final response = await Api.get(
        url: Api.getExtracurricularAttendanceHistory,
        useAuthToken: true,
        queryParameters: queryParams,
      );

      print('🔍 [ATTENDANCE REPO] History response: $response');

      if (response['error'] == false) {
        final List<dynamic> data = response['data'] ?? [];
        final List<ExtracurricularAttendance> attendanceList = data
            .map((item) => ExtracurricularAttendance.fromJson(item))
            .toList();

        print(
            '✅ [ATTENDANCE REPO] Successfully fetched ${attendanceList.length} attendance records');
        return attendanceList;
      } else {
        throw Exception(
            response['message'] ?? 'Failed to get attendance history');
      }
    } catch (e) {
      print('❌ [ATTENDANCE REPO] Error getting attendance history: $e');
      throw Exception('Failed to get attendance history: $e');
    }
  }
}
