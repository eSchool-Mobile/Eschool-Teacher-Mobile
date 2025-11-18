import 'package:eschool_saas_staff/data/models/extracurricularTimetable.dart';
import 'package:eschool_saas_staff/data/models/extracurricularTimetableEntry.dart';
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

  // Create new timetable entry
  Future<void> createTimetableEntry(ExtracurricularTimetableEntry entry) async {
    try {
      print(
          '🔍 [TIMETABLE REPO] Creating timetable entry for ${entry.extracurricularId}');

      final response = await Api.post(
        url: Api.createExtracurricularTimetable,
        useAuthToken: true,
        body: entry.toCreateRequest(),
      );

      print('🔍 [TIMETABLE REPO] Create response: $response');

      if (response['error'] == true) {
        print('❌ [TIMETABLE REPO] Create failed: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to create timetable entry');
      }

      print('✅ [TIMETABLE REPO] Timetable entry created successfully');
    } catch (e) {
      print('❌ [TIMETABLE REPO] Create exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Update existing timetable entry
  Future<void> updateTimetableEntry(
      int id, ExtracurricularTimetableEntry entry) async {
    try {
      print('🔍 [TIMETABLE REPO] Updating timetable entry ID: $id');

      final response = await Api.put(
        url: '${Api.updateExtracurricularTimetable}/$id',
        useAuthToken: true,
        body: entry.toCreateRequest(),
      );

      print('🔍 [TIMETABLE REPO] Update response: $response');

      if (response['error'] == true) {
        print('❌ [TIMETABLE REPO] Update failed: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to update timetable entry');
      }

      print('✅ [TIMETABLE REPO] Timetable entry updated successfully');
    } catch (e) {
      print('❌ [TIMETABLE REPO] Update exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Reset/Delete timetable entry
  Future<void> resetTimetableEntry(int id, {bool permanent = false}) async {
    try {
      print(
          '🔍 [TIMETABLE REPO] Resetting timetable entry ID: $id (permanent: $permanent)');

      final queryParams =
          permanent ? {'mode': 'permanent'} : <String, String>{};

      final response = await Api.delete(
        url: '${Api.resetExtracurricularTimetable}/$id',
        useAuthToken: true,
        body: {},
        queryParameters: queryParams,
      );

      print('🔍 [TIMETABLE REPO] Reset response: $response');

      if (response['error'] == true) {
        print('❌ [TIMETABLE REPO] Reset failed: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to reset timetable entry');
      }

      print('✅ [TIMETABLE REPO] Timetable entry reset successfully');
    } catch (e) {
      print('❌ [TIMETABLE REPO] Reset exception: $e');
      throw ApiException(e.toString());
    }
  }
}
