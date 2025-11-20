import 'package:eschool_saas_staff/data/models/extracurricular.dart';
import 'package:eschool_saas_staff/data/models/user.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/utils/constants.dart';

class ExtracurricularRepository {
  // Get list of active extracurriculars
  Future<List<Extracurricular>> getExtracurriculars() async {
    try {
      print('🔍 [EXTRACURRICULAR REPO] API Call: ${Api.getExtracurriculars}');

      final response = await Api.get(
        url: Api.getExtracurriculars,
        useAuthToken: true,
        queryParameters: {
          'role': 'teacher',
          'view_type': 'teacher',
          'all': 'true',
        },
      );

      print(
          '✅ [EXTRACURRICULAR REPO] Response: ${response['message'] ?? 'Success'}');

      if (response['error'] == true) {
        print('❌ [EXTRACURRICULAR REPO] API Error: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to load extracurriculars');
      }

      // Response now uses 'rows' instead of 'data'
      final List<dynamic> rows = response['rows'] ?? [];

      print('📊 [EXTRACURRICULAR REPO] Loaded ${rows.length} extracurriculars');

      final extracurriculars =
          rows.map((json) => Extracurricular.fromJson(json)).toList();

      print(
          '📊 [EXTRACURRICULAR REPO] Successfully loaded ${extracurriculars.length} active items');

      return extracurriculars;
    } catch (e) {
      print('❌ [EXTRACURRICULAR REPO] Exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Get list of archived extracurriculars
  Future<List<Extracurricular>> getArchivedExtracurriculars() async {
    try {
      print(
          '🔍 [EXTRACURRICULAR REPO] API Call: ${Api.getTrashedExtracurriculars}');

      final response = await Api.get(
        url: Api.getTrashedExtracurriculars,
        useAuthToken: true,
        queryParameters: {
          'role': 'teacher',
          'view_type': 'teacher',
        },
      );

      print(
          '✅ [EXTRACURRICULAR REPO] Archived Response: ${response['message'] ?? 'Success'}');

      // Check for success field instead of error field
      if (response['success'] != true) {
        print('❌ [EXTRACURRICULAR REPO] API Error: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to load archived extracurriculars');
      }

      // Response uses 'data' field for trashed endpoint
      final List<dynamic> data = response['data'] ?? [];

      print(
          '📊 [EXTRACURRICULAR REPO] Loaded ${data.length} archived extracurriculars');

      final archivedExtracurriculars =
          data.map((json) => Extracurricular.fromJson(json)).toList();

      // Debug: Print all items and their deletedAt status
      for (var item in archivedExtracurriculars) {
        print(
            '🔍 [DEBUG ARCHIVED] Item ID: ${item.id}, Name: ${item.name}, deletedAt: ${item.deletedAt}');
      }

      print(
          '📊 [EXTRACURRICULAR REPO] Successfully loaded ${archivedExtracurriculars.length} archived items');

      return archivedExtracurriculars;
    } catch (e) {
      print('❌ [EXTRACURRICULAR REPO] Exception: $e');
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
      print('➕ [EXTRACURRICULAR REPO] Creating: $name');

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
        print('❌ [EXTRACURRICULAR REPO] Create failed: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to create extracurricular');
      }

      print('✅ [EXTRACURRICULAR REPO] Created successfully');
    } catch (e) {
      print('❌ [EXTRACURRICULAR REPO] Create exception: $e');
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
      print('✏️ [EXTRACURRICULAR REPO] Updating ID $id: $name');

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
        print('❌ [EXTRACURRICULAR REPO] Update failed: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to update extracurricular');
      }

      print('✅ [EXTRACURRICULAR REPO] Updated successfully');
    } catch (e) {
      print('❌ [EXTRACURRICULAR REPO] Update exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Soft delete (Archive) extracurricular
  Future<void> deleteExtracurricular(int id) async {
    try {
      print('🗂️ [EXTRACURRICULAR REPO] Archiving ID: $id');

      final response = await Api.delete(
        url: '${Api.deleteExtracurricular}/$id',
        useAuthToken: true,
        body: {},
        queryParameters: {'mode': 'archive'},
      );

      if (response['error'] == true) {
        print(
            '❌ [EXTRACURRICULAR REPO] Archive failed: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to archive extracurricular');
      }

      print('✅ [EXTRACURRICULAR REPO] Archived successfully');
    } catch (e) {
      print('❌ [EXTRACURRICULAR REPO] Archive exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Restore archived extracurricular
  Future<void> restoreExtracurricular(int id) async {
    try {
      print('🔄 [EXTRACURRICULAR REPO] Restoring ID: $id');

      // Use dedicated restore endpoint
      final response = await Api.post(
        url: '${Api.restoreExtracurricular}/$id',
        useAuthToken: true,
        body: {},
      );

      print('🔍 [EXTRACURRICULAR REPO] Restore response: $response');

      // Check for success field (similar to trashed endpoint)
      if (response['success'] != true && response['error'] == true) {
        print(
            '❌ [EXTRACURRICULAR REPO] Restore failed: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to restore extracurricular');
      }

      print('✅ [EXTRACURRICULAR REPO] Restored successfully');
    } catch (e) {
      print('❌ [EXTRACURRICULAR REPO] Restore exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Force delete (Permanent delete) extracurricular
  Future<void> forceDeleteExtracurricular(int id) async {
    try {
      print('🗑️ [EXTRACURRICULAR REPO] Permanent delete ID: $id');

      final response = await Api.delete(
        url: '${Api.forceDeleteExtracurricular}/$id',
        useAuthToken: true,
        body: {},
        queryParameters: {'mode': 'permanent'}, // Optional parameter
      );

      print('🔍 [EXTRACURRICULAR REPO] Permanent delete response: $response');

      if (response['error'] == true) {
        print(
            '❌ [EXTRACURRICULAR REPO] Permanent delete failed: ${response['message']}');
        throw ApiException(response['message'] ??
            'Failed to permanently delete extracurricular');
      }

      print('✅ [EXTRACURRICULAR REPO] Permanently deleted successfully');
    } catch (e) {
      print('❌ [EXTRACURRICULAR REPO] Permanent delete exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Get list of teachers and staff
  Future<List<User>> getTeachersStaffList() async {
    try {
      print('🔍 [EXTRACURRICULAR REPO] API Call: ${Api.getTeachersStaffList}');

      final response = await Api.get(
        url: Api.getTeachersStaffList,
        useAuthToken: true,
        queryParameters: {
          'role': 'teacher,staff',
        },
      );

      print(
          '✅ [EXTRACURRICULAR REPO] Teachers/Staff Response: ${response['message'] ?? 'Success'}');

      if (response['error'] == true) {
        print('❌ [EXTRACURRICULAR REPO] API Error: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to load teachers/staff');
      }

      // Handle paginated response structure
      final responseData = response['data'];
      final List<dynamic> data = responseData is Map
          ? (responseData['data'] ?? [])
          : (responseData ?? []);

      print('📊 [EXTRACURRICULAR REPO] Loaded ${data.length} users');

      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      print('❌ [EXTRACURRICULAR REPO] Exception: $e');
      throw ApiException(e.toString());
    }
  }
}
