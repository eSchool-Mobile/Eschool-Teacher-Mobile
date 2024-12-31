import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:eschool_saas_staff/data/models/studentAttendance.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class AttendanceRepository {
  Future<
      ({
        List<StudentAttendance> attendance,
        bool isHoliday,
        Holiday holidayDetails
      })> getAttendance({
    required int classSectionId,
    required int? type,
    required String date,
  }) async {
    try {
      // Debug API request
      print('\n=== Attendance API Request ===');
      print('URL: ${Api.getAttendance}');
      print('Parameters: {');
      print('  class_section_id: $classSectionId,');
      print('  date: $date,');
      print('  type: $type');
      print('}');

      final result = await Api.get(
        url: Api.getAttendance,
        useAuthToken: true,
        queryParameters: {
          "class_section_id": classSectionId,
          "date": date,
          if (type != null) "type": type
        },
      );

      // Debug API response
      print('\n=== Attendance API Response ===');
      print('Raw Response: $result');
      print('data: ${result['data']}');
      print('is_holiday: ${result['is_holiday']}');
      print('holiday: ${result['holiday']}');

      if (result['data'] == null || result['is_holiday'] == null) {
        print('\n=== API Error ===');
        print('Invalid response structure');
        print('Missing fields: ${[
          if (result['data'] == null) 'data',
          if (result['is_holiday'] == null) 'is_holiday',
        ].join(', ')}');
        throw ApiException("Invalid response from API");
      }

      return (
        attendance: (result['data'] as List)
            .map(
              (attendanceReport) =>
                  StudentAttendance.fromJson(attendanceReport),
            )
            .toList(),
        isHoliday: result['is_holiday'] as bool,
        holidayDetails: Holiday.fromJson(
          Map.from(result['holiday'] == null
              ? {}
              : (result['holiday'] as List).firstOrNull ?? {}),
        )
      );
    } catch (e) {
      print("Error in getAttendance: $e");
      throw ApiException("Failed to Fetch Attendance: $e");
    }
  }

  Future<void> submitAttendance({
    required int classSectionId,
    required String date,
    required List<Map<String, dynamic>> attendance,
    required bool isHoliday,
    required bool sendAbsentNotification,
  }) async {
    try {
      await Api.post(
        url: Api.submitAttendance,
        useAuthToken: true,
        body: {
          "class_section_id": classSectionId,
          "date": date,
          "attendance": attendance,
          // "absent_notification": sendAbsentNotification ? 1 : 0,
          // "holiday": isHoliday ? 1 : 0,
        },
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
