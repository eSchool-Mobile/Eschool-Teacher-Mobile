import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/timeTableSlot.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class TeacherAcademicsRepository {
  Future<List<TimeTableSlot>> getTeacherMyTimetable() async {
    try {
      final response = await Api.get(
        url: Api.getTeacherMyTimetable,
        useAuthToken: true,
      );



      print("API Response type: ${response['data'].runtimeType}");
      print("Raw API Response: ${response['data']}");

      // Handle both Map and List responses
      if (response['data'] is Map<String, dynamic>) {
        final Map<String, dynamic> data = response['data'];
        List<TimeTableSlot> timeTableSlots = [];

        data.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            timeTableSlots.add(TimeTableSlot.fromJson(value));
          }
        });

        return timeTableSlots;
      } else if (response['data'] is List) {
        final List<dynamic> data = response['data'];
        return data
            .map((slot) => TimeTableSlot.fromJson(slot as Map<String, dynamic>))
            .toList();
      }

      throw Exception("Invalid response format");
    } catch (e) {
      print("Error in getTeacherMyTimetable: $e");
      throw Exception(e.toString());
    }
  }

  Future<List<TimeTableSlot>> getTeacherTimetableByClassSection({
    required int classSectionId,
    required DateTime date,
  }) async {
    try {
      final response = await Api.get(
        url:
            "${Api.getTeacherMyTimetable}?class_section_id=$classSectionId&date=${DateFormat('yyyy-MM-dd').format(date)}",
        useAuthToken: true,
      );

      print("INI RESPONNYAA ${response}");

      if (response['data'] is List) {
        final List<dynamic> data = response['data'];
        return data
            .map((slot) => TimeTableSlot.fromJson(slot as Map<String, dynamic>))
            .toList();
      }

      throw Exception("Invalid response format");
    } catch (e) {
      print("Error in getTeacherTimetableByClassSection: $e");
      throw Exception(e.toString());
    }
  }

  Future<List<ClassSection>> getClassSectionDetails({int? classId}) async {
    try {
      final result = await Api.post(
        url: Api.getClassDetails,
        body: {if (classId != null) "class_id": classId},
      );
      return ((result['data'] ?? []) as List)
          .map((classDetails) =>
              ClassSection.fromJson(Map.from(classDetails ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
