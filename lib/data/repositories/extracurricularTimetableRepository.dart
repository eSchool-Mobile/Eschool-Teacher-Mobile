import 'package:eschool_saas_staff/data/models/extracurricularTimetable.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class ExtracurricularTimetableRepository {
  Future<List<ExtracurricularTimetable>> getExtracurricularTimetable() async {
    try {
      print(
          '🔍 [EXTRACURRICULAR TIMETABLE REPO] API Call: ${Api.getExtracurricularTimetable}');

      final response = await Api.get(
        url: Api.getExtracurricularTimetable,
        useAuthToken: true,
      );

      print(
          '✅ [EXTRACURRICULAR TIMETABLE REPO] Response: ${response['message'] ?? 'Success'}');

      if (response['error'] == true) {
        print(
            '❌ [EXTRACURRICULAR TIMETABLE REPO] API Error: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to load extracurricular timetable');
      }

      // Get rows from response
      final List<dynamic> rows = response['rows'] ?? [];
      print(
          '📊 [EXTRACURRICULAR TIMETABLE REPO] Loaded ${rows.length} timetable items');

      return rows
          .map((json) => ExtracurricularTimetable.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ [EXTRACURRICULAR TIMETABLE REPO] Exception: $e');
      throw ApiException(e.toString());
    }
  }
}
