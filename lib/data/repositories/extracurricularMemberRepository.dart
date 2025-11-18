import 'package:eschool_saas_staff/data/models/extracurricularMember.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class ExtracurricularMemberRepository {
  // Get all extracurricular members
  Future<List<ExtracurricularMember>> getExtracurricularMembers() async {
    try {
      print('🔍 [MEMBER REPO] Fetching extracurricular members');

      final response = await Api.get(
        url: Api.getExtracurricularMembers,
        useAuthToken: true,
      );

      print('🔍 [MEMBER REPO] Response: $response');

      if (response['error'] == true) {
        print('❌ [MEMBER REPO] Error: ${response['message']}');
        throw ApiException(response['message'] ?? 'Failed to fetch members');
      }

      // API mengembalikan data di field 'rows', bukan 'data'
      final List<dynamic> membersData =
          response['rows'] ?? response['data'] ?? [];
      final List<ExtracurricularMember> members = membersData
          .map((memberJson) => ExtracurricularMember.fromJson(memberJson))
          .toList();

      print('✅ [MEMBER REPO] Successfully fetched ${members.length} members');
      print('🔍 [MEMBER REPO] Raw data count: ${membersData.length}');
      return members;
    } catch (e) {
      print('❌ [MEMBER REPO] Exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Approve extracurricular member
  Future<void> approveMember(int memberId) async {
    try {
      print('🔍 [MEMBER REPO] Approving member ID: $memberId');

      final response = await Api.put(
        url: '${Api.approveExtracurricularMember}/$memberId',
        useAuthToken: true,
        body: {
          'status': '1',
        },
      );

      print('🔍 [MEMBER REPO] Approve response: $response');

      if (response['error'] == true) {
        print('❌ [MEMBER REPO] Approve failed: ${response['message']}');
        throw ApiException(response['message'] ?? 'Failed to approve member');
      }

      print('✅ [MEMBER REPO] Member approved successfully');
    } catch (e) {
      print('❌ [MEMBER REPO] Approve exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Reject extracurricular member
  Future<void> rejectMember(int memberId) async {
    try {
      print('🔍 [MEMBER REPO] Rejecting member ID: $memberId');

      final response = await Api.put(
        url: '${Api.rejectExtracurricularMember}/$memberId',
        useAuthToken: true,
        body: {
          'status': '2',
        },
      );

      print('🔍 [MEMBER REPO] Reject response: $response');

      if (response['error'] == true) {
        print('❌ [MEMBER REPO] Reject failed: ${response['message']}');
        throw ApiException(response['message'] ?? 'Failed to reject member');
      }

      print('✅ [MEMBER REPO] Member rejected successfully');
    } catch (e) {
      print('❌ [MEMBER REPO] Reject exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Get members by status (filter)
  Future<List<ExtracurricularMember>> getMembersByStatus(String status) async {
    try {
      print('🔍 [MEMBER REPO] Fetching members with status: $status');

      final response = await Api.get(
        url: '${Api.getExtracurricularMembers}?status=$status',
        useAuthToken: true,
      );

      print('🔍 [MEMBER REPO] Response: $response');

      if (response['error'] == true) {
        print('❌ [MEMBER REPO] Error: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to fetch members by status');
      }

      // API mengembalikan data di field 'rows', bukan 'data'
      final List<dynamic> membersData =
          response['rows'] ?? response['data'] ?? [];
      final List<ExtracurricularMember> members = membersData
          .map((memberJson) => ExtracurricularMember.fromJson(memberJson))
          .toList();

      print(
          '✅ [MEMBER REPO] Successfully fetched ${members.length} members with status $status');
      return members;
    } catch (e) {
      print('❌ [MEMBER REPO] Exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Get members by extracurricular ID
  Future<List<ExtracurricularMember>> getMembersByExtracurricular(
      int extracurricularId) async {
    try {
      print(
          '🔍 [MEMBER REPO] Fetching members for extracurricular ID: $extracurricularId');

      final response = await Api.get(
        url:
            '${Api.getExtracurricularMembers}?extracurricular_id=$extracurricularId',
        useAuthToken: true,
      );

      print('🔍 [MEMBER REPO] Response: $response');

      if (response['error'] == true) {
        print('❌ [MEMBER REPO] Error: ${response['message']}');
        throw ApiException(response['message'] ??
            'Failed to fetch members by extracurricular');
      }

      // API mengembalikan data di field 'rows', bukan 'data'
      final List<dynamic> membersData =
          response['rows'] ?? response['data'] ?? [];
      final List<ExtracurricularMember> members = membersData
          .map((memberJson) => ExtracurricularMember.fromJson(memberJson))
          .toList();

      print(
          '✅ [MEMBER REPO] Successfully fetched ${members.length} members for extracurricular $extracurricularId');
      return members;
    } catch (e) {
      print('❌ [MEMBER REPO] Exception: $e');
      throw ApiException(e.toString());
    }
  }
}
