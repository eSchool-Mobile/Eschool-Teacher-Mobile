// import 'package:dio/dio.dart';

import 'package:eschool_saas_staff/data/models/auth/permissionDetails.dart';
import 'package:eschool_saas_staff/utils/system/api.dart';
import 'package:eschool_saas_staff/utils/system/constants.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class PermissionRepository {
  Future<List<PermissionDetails>> getPermission(
      {required LeaveDayType leaveDayType, DateTime? date}) async {
    try {
      final result = await Api.get(url: Api.getPermission, queryParameters: {
        "type": getLeaveDayTypeStatus(leaveDayType: leaveDayType),
        if (date != null) 'date': DateFormat('yyyy-MM-dd').format(date),
      });

      debugPrint("Raw API Response: ${result['data']}");

      return ((result['data'] ?? []) as List).map((permissionDetails) {
        debugPrint("Processing item: $permissionDetails");

        // Check if this is the new API structure with student_name, from_date, etc.
        if (permissionDetails['student_name'] != null) {
          debugPrint("Using new API data structure");
          return PermissionDetails.fromApiData(
              Map.from(permissionDetails ?? {}));
        } else {
          debugPrint("Using legacy data structure");
          return PermissionDetails.fromJson(Map.from(permissionDetails ?? {}));
        }
      }).toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> approveOrRejectStudentPermission({
    required int leaveId,
    required int status,
    String? rejectionReason,
  }) async {
    try {
      // Validation: rejection_reason is required when status = 2 (rejected)
      if (status == 2 &&
          (rejectionReason == null || rejectionReason.trim().isEmpty)) {
        throw ApiException(
            "Alasan penolakan wajib diisi saat menolak izin siswa");
      }

      Map<String, dynamic> body = {"leave_id": leaveId, "status": status};

      // Add rejection_reason to body if status = rejected
      if (status == 2 && rejectionReason != null) {
        body["rejection_reason"] = rejectionReason.trim();
      }

      debugPrint("DEBUG: Student Permission Approve Request Body: $body");
      debugPrint(
          "DEBUG: Student Permission Approve URL: ${Api.submitStudentPermission}");
      debugPrint("DEBUG: Student Permission Approve Request Method: POST JSON");

      await Api.postJson(url: Api.submitStudentPermission, body: body);
    } catch (e) {
      debugPrint("DEBUG: Student Permission Approve Error: $e");
      debugPrint("DEBUG: Student Permission Approve Error Type: ${e.runtimeType}");
      if (e is ApiException) {
        debugPrint(
            "DEBUG: Student Permission Approve ApiException Message: ${e.errorMessage}");
      }
      throw ApiException(e.toString());
    }
  }
}
