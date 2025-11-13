import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/models/extracurricular.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/utils/constants.dart';

class ExtracurricularRepository {
  // Get list of active extracurriculars
  Future<List<Extracurricular>> getExtracurriculars() async {
    try {
      print('🔍 [EXTRACURRICULAR REPO] Starting getExtracurriculars API call');
      print('🔍 [EXTRACURRICULAR REPO] API URL: ${Api.getExtracurriculars}');

      final response = await Dio().get(
        Api.getExtracurriculars,
        options: Options(headers: Api.headers()),
      );

      print(
          '🔍 [EXTRACURRICULAR REPO] Response status: ${response.statusCode}');
      print(
          '🔍 [EXTRACURRICULAR REPO] Response data type: ${response.data.runtimeType}');
      print('🔍 [EXTRACURRICULAR REPO] Response data: ${response.data}');

      if (response.data['error'] == true) {
        print(
            '❌ [EXTRACURRICULAR REPO] API returned error: ${response.data['message']}');
        throw ApiException(
            response.data['message'] ?? 'Failed to load extracurriculars');
      }

      final List<dynamic> data = response.data['data'] ?? [];
      print(
          '✅ [EXTRACURRICULAR REPO] Successfully loaded ${data.length} extracurriculars');

      return data.map((json) => Extracurricular.fromJson(json)).toList();
    } catch (e) {
      print('❌ [EXTRACURRICULAR REPO] Exception in getExtracurriculars: $e');
      print('❌ [EXTRACURRICULAR REPO] Exception type: ${e.runtimeType}');
      if (e is DioException) {
        print('❌ [EXTRACURRICULAR REPO] DioException details:');
        print('  - Type: ${e.type}');
        print('  - Message: ${e.message}');
        print('  - Status Code: ${e.response?.statusCode}');
        print('  - Response Data: ${e.response?.data}');
        print('  - Request URL: ${e.requestOptions.uri}');
        print('  - Headers: ${e.requestOptions.headers}');
      }
      throw ApiException(e.toString());
    }
  }

  // Get list of archived extracurriculars
  Future<List<Extracurricular>> getArchivedExtracurriculars() async {
    try {
      final response = await Dio().get(
        Api.getArchivedExtracurriculars,
        options: Options(headers: Api.headers()),
      );

      if (response.data['error'] == true) {
        throw ApiException(response.data['message'] ??
            'Failed to load archived extracurriculars');
      }

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Extracurricular.fromJson(json)).toList();
    } catch (e) {
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
      final response = await Dio().post(
        Api.createExtracurricular,
        data: {
          'name': name,
          'description': description,
          'coach_id': coachId,
        },
        options: Options(headers: Api.headers()),
      );

      if (response.data['error'] == true) {
        throw ApiException(
            response.data['message'] ?? 'Failed to create extracurricular');
      }
    } catch (e) {
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
      final response = await Dio().put(
        '${Api.updateExtracurricular}/$id',
        data: {
          'name': name,
          'description': description,
          'coach_id': coachId,
        },
        options: Options(headers: Api.headers()),
      );

      if (response.data['error'] == true) {
        throw ApiException(
            response.data['message'] ?? 'Failed to update extracurricular');
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Soft delete (Archive) extracurricular
  Future<void> deleteExtracurricular(int id) async {
    try {
      final response = await Dio().delete(
        '${Api.deleteExtracurricular}/$id',
        queryParameters: {'mode': 'archive'},
        options: Options(headers: Api.headers()),
      );

      if (response.data['error'] == true) {
        throw ApiException(
            response.data['message'] ?? 'Failed to archive extracurricular');
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Restore archived extracurricular
  Future<void> restoreExtracurricular(int id) async {
    try {
      final response = await Dio().post(
        '${Api.restoreExtracurricular}/$id',
        options: Options(headers: Api.headers()),
      );

      if (response.data['error'] == true) {
        throw ApiException(
            response.data['message'] ?? 'Failed to restore extracurricular');
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Force delete (Permanent delete) extracurricular
  Future<void> forceDeleteExtracurricular(int id) async {
    try {
      final response = await Dio().delete(
        '${Api.forceDeleteExtracurricular}/$id',
        queryParameters: {'mode': 'permanent'},
        options: Options(headers: Api.headers()),
      );

      if (response.data['error'] == true) {
        throw ApiException(response.data['message'] ??
            'Failed to permanently delete extracurricular');
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
