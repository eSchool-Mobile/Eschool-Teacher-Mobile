import 'package:eschool_saas_staff/data/models/extracurricular/extracurricularTimetable.dart';
import 'package:eschool_saas_staff/data/models/extracurricular/extracurricularTimetableEntry.dart';
import 'package:eschool_saas_staff/utils/system/api.dart';
import 'package:flutter/foundation.dart';

class ExtracurricularTimetableRepository {
  Future<List<ExtracurricularTimetable>> getExtracurricularTimetable() async {
    try {
      debugPrint(
          '🔍 [EXTRACURRICULAR TIMETABLE REPO] API Call: ${Api.getExtracurricularTimetable}');

      final response = await Api.get(
        url: Api.getExtracurricularTimetable,
        useAuthToken: true,
      );

      debugPrint(
          '✅ [EXTRACURRICULAR TIMETABLE REPO] Response: ${response['message'] ?? 'Success'}');

      if (response['error'] == true) {
        debugPrint(
            '❌ [EXTRACURRICULAR TIMETABLE REPO] API Error: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to load extracurricular timetable');
      }

      // Get rows from response
      final List<dynamic> rows = response['rows'] ?? [];
      debugPrint(
          '📊 [EXTRACURRICULAR TIMETABLE REPO] Loaded ${rows.length} timetable items');

      return rows
          .map((json) => ExtracurricularTimetable.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ [EXTRACURRICULAR TIMETABLE REPO] Exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Create new timetable entry
  Future<void> createTimetableEntry(ExtracurricularTimetableEntry entry) async {
    try {
      debugPrint(
          '🔍 [TIMETABLE REPO] Creating timetable entry for ${entry.extracurricularId}');

      final response = await Api.post(
        url: Api.createExtracurricularTimetable,
        useAuthToken: true,
        body: entry.toCreateRequest(),
      );

      debugPrint('🔍 [TIMETABLE REPO] Create response: $response');

      if (response['error'] == true) {
        debugPrint('❌ [TIMETABLE REPO] Create failed: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to create timetable entry');
      }

      debugPrint('✅ [TIMETABLE REPO] Timetable entry created successfully');
    } catch (e) {
      debugPrint('❌ [TIMETABLE REPO] Create exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Update existing timetable entry
  Future<void> updateTimetableEntry(
      int id, ExtracurricularTimetableEntry entry) async {
    try {
      debugPrint('🔍 [TIMETABLE REPO] Updating timetable entry ID: $id');

      final response = await Api.put(
        url: '${Api.updateExtracurricularTimetable}/$id',
        useAuthToken: true,
        body: entry.toCreateRequest(),
      );

      debugPrint('🔍 [TIMETABLE REPO] Update response: $response');

      if (response['error'] == true) {
        debugPrint('❌ [TIMETABLE REPO] Update failed: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to update timetable entry');
      }

      debugPrint('✅ [TIMETABLE REPO] Timetable entry updated successfully');
    } catch (e) {
      debugPrint('❌ [TIMETABLE REPO] Update exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Reset/Delete timetable entry
  Future<void> resetTimetableEntry(int id, {bool permanent = false}) async {
    try {
      debugPrint(
          '🔍 [TIMETABLE REPO] Resetting timetable entry ID: $id (permanent: $permanent)');

      final queryParams =
          permanent ? {'mode': 'permanent'} : <String, String>{};

      final response = await Api.delete(
        url: '${Api.resetExtracurricularTimetable}/$id',
        useAuthToken: true,
        body: {},
        queryParameters: queryParams,
      );

      debugPrint('🔍 [TIMETABLE REPO] Reset response: $response');

      if (response['error'] == true) {
        debugPrint('❌ [TIMETABLE REPO] Reset failed: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to reset timetable entry');
      }

      debugPrint('✅ [TIMETABLE REPO] Timetable entry reset successfully');
    } catch (e) {
      debugPrint('❌ [TIMETABLE REPO] Reset exception: $e');
      throw ApiException(e.toString());
    }
  }
}
