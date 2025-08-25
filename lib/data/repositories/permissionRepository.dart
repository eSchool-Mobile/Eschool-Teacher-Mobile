// import 'package:dio/dio.dart';

import 'package:eschool_saas_staff/data/models/permissionDetails.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:intl/intl.dart';

class PermissionRepository {
  Future<List<PermissionDetails>> getPermission(
      {required LeaveDayType leaveDayType, DateTime? date}) async {
    try {
      final result = await Api.get(url: Api.getPermission, queryParameters: {
        "type": getLeaveDayTypeStatus(leaveDayType: leaveDayType),
        if (date != null) 'date': DateFormat('yyyy-MM-dd').format(date),
      });

      print("Raw API Response: ${result['data']}");

      return ((result['data'] ?? []) as List).map((permissionDetails) {
        print("Processing item: $permissionDetails");

        // Check if this is the new API structure with student_name, from_date, etc.
        if (permissionDetails['student_name'] != null) {
          print("Using new API data structure");
          return PermissionDetails.fromApiData(
              Map.from(permissionDetails ?? {}));
        } else {
          print("Using legacy data structure");
          return PermissionDetails.fromJson(Map.from(permissionDetails ?? {}));
        }
      }).toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
