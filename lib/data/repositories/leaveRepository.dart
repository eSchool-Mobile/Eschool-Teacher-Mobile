import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/models/leaveDetails.dart';
import 'package:eschool_saas_staff/data/models/leaveRequest.dart';
import 'package:eschool_saas_staff/data/models/leaveSettings.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/utils/constants.dart';

class LeaveRepository {
  Future<List<LeaveDetails>> getLeaves(
      {required LeaveDayType leaveDayType}) async {
    try {
      print('\n=== DEBUG: LeaveRepository.getLeaves() ===');
      print('LeaveDayType: $leaveDayType');
      print('API URL: ${Api.getLeaves}');
      print(
          'Query params: {"type": ${getLeaveDayTypeStatus(leaveDayType: leaveDayType)}}');

      final result = await Api.get(url: Api.getLeaves, queryParameters: {
        "type": getLeaveDayTypeStatus(leaveDayType: leaveDayType)
      });

      print('Raw API response:');
      final prettyJson = JsonEncoder.withIndent('  ').convert(result);
      print(prettyJson);

      final leaves = ((result['data'] ?? []) as List)
          .map((leaveDetails) =>
              LeaveDetails.fromJson(Map.from(leaveDetails ?? {})))
          .toList();

      print('Number of leaves parsed: ${leaves.length}');
      if (leaves.isEmpty) {
        print('WARNING: No leaves parsed from response');
      } else {
        print('First leave details: ${leaves.first.toJson()}');
      }
      print('=== DEBUG: End LeaveRepository.getLeaves() ===\n');

      return leaves;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<LeaveRequest>> getLeaveRequests() async {
    try {
      final result = await Api.get(url: Api.getLeaveRequests);

      return ((result['data'] ?? []) as List)
          .map((leaveRequest) =>
              LeaveRequest.fromJson(Map.from(leaveRequest ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> approveOrRejectLeaveRequest(
      {required int leaveRequestId,
      required int status,
      String? rejectReason}) async {
    try {
      // Validasi: reject_reason wajib diisi jika status = 2 (rejected)
      if (status == 2 &&
          (rejectReason == null || rejectReason.trim().isEmpty)) {
        throw ApiException(
            "Alasan penolakan wajib diisi saat menolak permohonan cuti");
      }

      Map<String, dynamic> body = {
        "leave_id": leaveRequestId,
        "status": status
      };

      // Tambahkan reject_reason ke body jika status = rejected
      if (status == 2 && rejectReason != null) {
        body["reject_reason"] = rejectReason.trim();
      }

      await Api.post(url: Api.approveOrRejectLeaveRequest, body: body);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> applyLeave(
      {required String reason,
      required List<Map<String, String>> leaves,
      List<String>? attachmentPaths}) async {
    try {
      List<MultipartFile> attachments = [];

      for (var attachmentPath in attachmentPaths ?? []) {
        attachments.add(await MultipartFile.fromFile(attachmentPath));
      }

      await Api.post(url: Api.applyLeave, body: {
        "reason": reason,
        "leave_details": leaves,
        "files": attachments,
      });
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<
          ({
            List<LeaveRequest> leaves,
            double takenLeaves,
            double monthlyAllowedLeaves
          })>
      getUserLeaves(
          {required int sessionYearId,
          int? monthNumber,
          required int userId}) async {
    try {
      final result = await Api.get(url: Api.getUserLeaves, queryParameters: {
        "session_year_id": sessionYearId,
        "staff_id": userId,
        "month": monthNumber
      });

      final prettyJson = JsonEncoder.withIndent('  ').convert(result);

      // Memecah JSON menjadi baris-baris
      final lines = prettyJson.split('\n');

      // Mencetak setiap baris
      for (final line in lines) {
        print(line);
      }

      return (
        leaves: ((result['data']['leave_details'] ?? []) as List)
            .map((leaveRequest) =>
                LeaveRequest.fromJson(Map.from(leaveRequest ?? {})))
            .toList(),
        takenLeaves: double.parse((result['data']['taken_leaves']).toString()),
        monthlyAllowedLeaves:
            double.parse((result['data']['monthly_allowed_leaves']).toString()),
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<LeaveSettings> getLeaveSettings() async {
    try {
      final result = await Api.get(url: Api.getLeaveSettings);
      final dataList = (result['data'] as List);

      return dataList.isEmpty
          ? LeaveSettings.fromJson({})
          : LeaveSettings.fromJson(Map.from(dataList.first ?? {}));
    } catch (e, _) {
      throw ApiException(e.toString());
    }
  }
}
