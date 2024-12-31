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

      return ((result['data'] ?? []) as List)
          .map((permissionDetails) =>
              PermissionDetails.fromJson(Map.from(permissionDetails ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
