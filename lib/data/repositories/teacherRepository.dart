import 'package:eschool_saas_staff/data/models/timeTableSlot.dart';
import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/data/models/gradeLevel.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class TeacherRepository {
  Future<List<UserDetails>> getTeachers({String? search}) async {
    try {
      final result = await Api.get(
          url: Api.getTeachers, queryParameters: {"search": search});
      return ((result['data'] ?? []) as List)
          .map((teacher) => UserDetails.fromJson(Map.from(teacher ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<TimeTableSlot>> getTimeTableOfTeacher(
      {required int teacherId}) async {
    try {
      final result = await Api.get(
          url: Api.getTimeTableOfTeacher,
          queryParameters: {"teacher_id": teacherId});
      print("DARI API NIH WOK");
      print(((result['data'] ?? []) as List)
          .map((timeTableSlot) =>
              TimeTableSlot.fromJson(Map.from(timeTableSlot ?? {})))
          .toList());
      return ((result['data'] ?? []) as List)
          .map((timeTableSlot) =>
              TimeTableSlot.fromJson(Map.from(timeTableSlot ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<SessionYear>> getSessionYears() async {
    try {
      final result = await Api.get(url: Api.getSessionYears);
      return ((result['data'] ?? []) as List)
          .map((sessionYear) =>
              SessionYear.fromJson(Map.from(sessionYear ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<GradeLevel>> getGradeLevels({int? sessionYearId}) async {
    try {
      Map<String, dynamic> queryParameters = {};
      if (sessionYearId != null) {
        queryParameters['session_year_id'] = sessionYearId;
      }

      final result = await Api.get(
          url: Api.gradeLevel,
          queryParameters: queryParameters.isNotEmpty ? queryParameters : null);
      return ((result['data'] ?? []) as List)
          .map((gradeLevel) => GradeLevel.fromJson(Map.from(gradeLevel ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
