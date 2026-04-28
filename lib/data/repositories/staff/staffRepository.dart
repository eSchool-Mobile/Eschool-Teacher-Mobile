import 'package:eschool_saas_staff/data/models/auth/userDetails.dart';
import 'package:eschool_saas_staff/utils/system/api.dart';

class StaffRepository {
  Future<List<UserDetails>> getStaffs({String? search, int? status}) async {
    try {
      final result = await Api.get(
          url: Api.getStaffs,
          queryParameters: {"search": search, "status": status});

      return ((result['data'] ?? []) as List)
          .map((staff) => UserDetails.fromJson(Map.from(staff ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
