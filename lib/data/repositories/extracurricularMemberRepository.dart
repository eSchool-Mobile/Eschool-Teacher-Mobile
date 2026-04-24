import 'package:eschool_saas_staff/data/models/extracurricular/extracurricularMember.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:flutter/foundation.dart';

class ExtracurricularMemberRepository {
  // Get all extracurricular members
  Future<List<ExtracurricularMember>> getExtracurricularMembers() async {
    try {
      debugPrint('🔍 [MEMBER REPO] Fetching extracurricular members');

      final response = await Api.get(
        url: Api.getExtracurricularMembers,
        useAuthToken: true,
      );

      debugPrint('🔍 [MEMBER REPO] Response: $response');

      if (response['error'] == true) {
        debugPrint('❌ [MEMBER REPO] Error: ${response['message']}');
        throw ApiException(response['message'] ?? 'Failed to fetch members');
      }

      // API mengembalikan data di field 'rows', bukan 'data'
      final List<dynamic> membersData =
          response['rows'] ?? response['data'] ?? [];
      final List<ExtracurricularMember> members = membersData
          .map((memberJson) => ExtracurricularMember.fromJson(memberJson))
          .toList();

      debugPrint('✅ [MEMBER REPO] Successfully fetched ${members.length} members');
      debugPrint('🔍 [MEMBER REPO] Raw data count: ${membersData.length}');
      return members;
    } catch (e) {
      debugPrint('❌ [MEMBER REPO] Exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Approve extracurricular member
  Future<void> approveMember(int memberId) async {
    try {
      debugPrint('🔍 [MEMBER REPO] Approving member ID: $memberId');

      final response = await Api.put(
        url: '${Api.approveExtracurricularMember}/$memberId',
        useAuthToken: true,
        body: {
          'status': '1',
        },
      );

      debugPrint('🔍 [MEMBER REPO] Approve response: $response');

      if (response['error'] == true) {
        debugPrint('❌ [MEMBER REPO] Approve failed: ${response['message']}');
        throw ApiException(response['message'] ?? 'Failed to approve member');
      }

      debugPrint('✅ [MEMBER REPO] Member approved successfully');
    } catch (e) {
      debugPrint('❌ [MEMBER REPO] Approve exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Reject extracurricular member
  Future<void> rejectMember(int memberId) async {
    try {
      debugPrint('🔍 [MEMBER REPO] Rejecting member ID: $memberId');

      final response = await Api.put(
        url: '${Api.rejectExtracurricularMember}/$memberId',
        useAuthToken: true,
        body: {
          'status': '2',
        },
      );

      debugPrint('🔍 [MEMBER REPO] Reject response: $response');

      if (response['error'] == true) {
        debugPrint('❌ [MEMBER REPO] Reject failed: ${response['message']}');
        throw ApiException(response['message'] ?? 'Failed to reject member');
      }

      debugPrint('✅ [MEMBER REPO] Member rejected successfully');
    } catch (e) {
      debugPrint('❌ [MEMBER REPO] Reject exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Get members by status (filter)
  Future<List<ExtracurricularMember>> getMembersByStatus(String status) async {
    try {
      debugPrint('🔍 [MEMBER REPO] Fetching members with status: $status');

      final response = await Api.get(
        url: '${Api.getExtracurricularMembers}?status=$status',
        useAuthToken: true,
      );

      debugPrint('🔍 [MEMBER REPO] Response: $response');

      if (response['error'] == true) {
        debugPrint('❌ [MEMBER REPO] Error: ${response['message']}');
        throw ApiException(
            response['message'] ?? 'Failed to fetch members by status');
      }

      // API mengembalikan data di field 'rows', bukan 'data'
      final List<dynamic> membersData =
          response['rows'] ?? response['data'] ?? [];
      final List<ExtracurricularMember> members = membersData
          .map((memberJson) => ExtracurricularMember.fromJson(memberJson))
          .toList();

      debugPrint(
          '✅ [MEMBER REPO] Successfully fetched ${members.length} members with status $status');
      return members;
    } catch (e) {
      debugPrint('❌ [MEMBER REPO] Exception: $e');
      throw ApiException(e.toString());
    }
  }

  // Get members by extracurricular ID
  Future<List<ExtracurricularMember>> getMembersByExtracurricular(
      int extracurricularId) async {
    try {
      debugPrint(
          '🔍 [MEMBER REPO] Fetching members for extracurricular ID: $extracurricularId');

      final response = await Api.get(
        url:
            '${Api.getExtracurricularMembers}?extracurricular_id=$extracurricularId',
        useAuthToken: true,
      );

      debugPrint('🔍 [MEMBER REPO] Response: $response');

      if (response['error'] == true) {
        debugPrint('❌ [MEMBER REPO] Error: ${response['message']}');
        throw ApiException(response['message'] ??
            'Failed to fetch members by extracurricular');
      }

      // API mengembalikan data di field 'rows', bukan 'data'
      final List<dynamic> membersData =
          response['rows'] ?? response['data'] ?? [];
      final List<ExtracurricularMember> members = membersData
          .map((memberJson) => ExtracurricularMember.fromJson(memberJson))
          .toList();

      debugPrint(
          '✅ [MEMBER REPO] Successfully fetched ${members.length} members for extracurricular $extracurricularId');
      return members;
    } catch (e) {
      debugPrint('❌ [MEMBER REPO] Exception: $e');
      throw ApiException(e.toString());
    }
  }
}
