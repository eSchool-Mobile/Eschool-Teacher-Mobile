import 'package:eschool_saas_staff/data/models/extracurricular/extracurricular.dart';
import 'package:eschool_saas_staff/data/models/auth/user.dart';
import 'package:eschool_saas_staff/utils/system/api.dart';
import 'package:flutter/foundation.dart';

class ExtracurricularRepository {
  // Get list of active extracurriculars
  Future<List<Extracurricular>> getExtracurriculars() async {
    try {
      debugPrint('🔍 [EXTRACURRICULAR REPO] API Call: ${Api.getExtracurriculars}');

      final response = await Api.get(
        url: Api.getExtracurriculars,
        useAuthToken: true,
        queryParameters: {
          'role': 'teacher',
          'view_type': 'teacher',
          'all': 'true',
        },
      );

      debugPrint(
          '✅ [EXTRACURRICULAR REPO] Response: ${response['message'] ?? 'Success'}');

      if (response['error'] == true) {
        debugPrint('❌ [EXTRACURRICULAR REPO] API Error: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to load extracurriculars');
      }

      // Response now uses 'rows' instead of 'data'
      final List<dynamic> rows = response['rows'] ?? [];

      debugPrint('📊 [EXTRACURRICULAR REPO] Loaded ${rows.length} extracurriculars');

      final extracurriculars =
          rows.map((json) => Extracurricular.fromJson(json)).toList();

      debugPrint(
          '📊 [EXTRACURRICULAR REPO] Successfully loaded ${extracurriculars.length} active items');

      return extracurriculars;
    } catch (e) {
      debugPrint('❌ [EXTRACURRICULAR REPO] Exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Get list of archived extracurriculars
  Future<List<Extracurricular>> getArchivedExtracurriculars() async {
    try {
      debugPrint(
          '🔍 [EXTRACURRICULAR REPO] API Call: ${Api.getTrashedExtracurriculars}');

      final response = await Api.get(
        url: Api.getTrashedExtracurriculars,
        useAuthToken: true,
        queryParameters: {
          'role': 'teacher',
          'view_type': 'teacher',
        },
      );

      debugPrint(
          '✅ [EXTRACURRICULAR REPO] Archived Response: ${response['message'] ?? 'Success'}');

      // Check for success field instead of error field
      if (response['success'] != true) {
        debugPrint('❌ [EXTRACURRICULAR REPO] API Error: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to load archived extracurriculars');
      }

      // Response uses 'data' field for trashed endpoint
      final List<dynamic> data = response['data'] ?? [];

      debugPrint(
          '📊 [EXTRACURRICULAR REPO] Loaded ${data.length} archived extracurriculars');

      final archivedExtracurriculars =
          data.map((json) => Extracurricular.fromJson(json)).toList();

      // Debug: Print all items and their deletedAt status
      for (var item in archivedExtracurriculars) {
        debugPrint(
            '🔍 [DEBUG ARCHIVED] Item ID: ${item.id}, Name: ${item.name}, deletedAt: ${item.deletedAt}');
      }

      debugPrint(
          '📊 [EXTRACURRICULAR REPO] Successfully loaded ${archivedExtracurriculars.length} archived items');

      return archivedExtracurriculars;
    } catch (e) {
      debugPrint('❌ [EXTRACURRICULAR REPO] Exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Create new extracurricular
  Future<void> createExtracurricular({
    required String name,
    required String description,
    required int coachId,
  }) async {
    try {
      debugPrint('➕ [EXTRACURRICULAR REPO] Creating: $name');

      final response = await Api.post(
        url: Api.createExtracurricular,
        useAuthToken: true,
        body: {
          'name': name,
          'description': description,
          'coach_id': coachId.toString(),
        },
      );

      if (response['error'] == true) {
        debugPrint('❌ [EXTRACURRICULAR REPO] Create failed: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to create extracurricular');
      }

      debugPrint('✅ [EXTRACURRICULAR REPO] Created successfully');
    } catch (e) {
      debugPrint('❌ [EXTRACURRICULAR REPO] Create exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Update extracurricular
  Future<void> updateExtracurricular({
    required int id,
    required String name,
    required String description,
    required int coachId,
  }) async {
    try {
      debugPrint('✏️ [EXTRACURRICULAR REPO] Updating ID $id: $name');

      final response = await Api.put(
        url: '${Api.updateExtracurricular}/$id',
        useAuthToken: true,
        body: {
          'name': name,
          'description': description,
          'coach_id': coachId.toString(),
        },
      );

      if (response['error'] == true) {
        debugPrint('❌ [EXTRACURRICULAR REPO] Update failed: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to update extracurricular');
      }

      debugPrint('✅ [EXTRACURRICULAR REPO] Updated successfully');
    } catch (e) {
      debugPrint('❌ [EXTRACURRICULAR REPO] Update exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Soft delete (Archive) extracurricular
  Future<void> deleteExtracurricular(int id) async {
    try {
      debugPrint('🗂️ [EXTRACURRICULAR REPO] Archiving ID: $id');

      final response = await Api.delete(
        url: '${Api.deleteExtracurricular}/$id',
        useAuthToken: true,
        body: {},
        queryParameters: {'mode': 'archive'},
      );

      if (response['error'] == true) {
        debugPrint(
            '❌ [EXTRACURRICULAR REPO] Archive failed: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to archive extracurricular');
      }

      debugPrint('✅ [EXTRACURRICULAR REPO] Archived successfully');
    } catch (e) {
      debugPrint('❌ [EXTRACURRICULAR REPO] Archive exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Restore archived extracurricular
  Future<void> restoreExtracurricular(int id) async {
    try {
      debugPrint('🔄 [EXTRACURRICULAR REPO] Restoring ID: $id');

      // Use dedicated restore endpoint
      final response = await Api.post(
        url: '${Api.restoreExtracurricular}/$id',
        useAuthToken: true,
        body: {},
      );

      debugPrint('🔍 [EXTRACURRICULAR REPO] Restore response: $response');

      // Check for success field (similar to trashed endpoint)
      if (response['success'] != true && response['error'] == true) {
        debugPrint(
            '❌ [EXTRACURRICULAR REPO] Restore failed: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to restore extracurricular');
      }

      debugPrint('✅ [EXTRACURRICULAR REPO] Restored successfully');
    } catch (e) {
      debugPrint('❌ [EXTRACURRICULAR REPO] Restore exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Force delete (Permanent delete) extracurricular
  Future<void> forceDeleteExtracurricular(int id) async {
    try {
      debugPrint('🗑️ [EXTRACURRICULAR REPO] Permanent delete ID: $id');

      final response = await Api.delete(
        url: '${Api.forceDeleteExtracurricular}/$id',
        useAuthToken: true,
        body: {},
        queryParameters: {'mode': 'permanent'}, // Optional parameter
      );

      debugPrint('🔍 [EXTRACURRICULAR REPO] Permanent delete response: $response');

      if (response['error'] == true) {
        debugPrint(
            '❌ [EXTRACURRICULAR REPO] Permanent delete failed: ${response['message']}');
        throw ApiException(response['message'] ??
            'Failed to permanently delete extracurricular');
      }

      debugPrint('✅ [EXTRACURRICULAR REPO] Permanently deleted successfully');
    } catch (e) {
      debugPrint('❌ [EXTRACURRICULAR REPO] Permanent delete exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Get list of teachers and staff
  Future<List<User>> getTeachersStaffList() async {
    try {
      debugPrint('🔍 [EXTRACURRICULAR REPO] API Call: ${Api.getTeachersStaffList}');

      final response = await Api.get(
        url: Api.getTeachersStaffList,
        useAuthToken: true,
        queryParameters: {
          'role': 'teacher,staff',
        },
      );

      debugPrint(
          '✅ [EXTRACURRICULAR REPO] Teachers/Staff Response: ${response['message'] ?? 'Success'}');

      if (response['error'] == true) {
        debugPrint('❌ [EXTRACURRICULAR REPO] API Error: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to load teachers/staff');
      }

      // Handle paginated response structure
      final responseData = response['data'];
      final List<dynamic> data = responseData is Map
          ? (responseData['data'] ?? [])
          : (responseData ?? []);

      debugPrint('📊 [EXTRACURRICULAR REPO] Loaded ${data.length} users');

      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ [EXTRACURRICULAR REPO] Exception: $e');
      throw ApiException(e.toString());
    }
  }
}
