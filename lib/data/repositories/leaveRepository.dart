import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/models/leaveDetails.dart';
import 'package:eschool_saas_staff/data/models/leaveRequest.dart';
import 'package:eschool_saas_staff/data/models/leaveSettings.dart';
import 'package:eschool_saas_staff/data/models/user.dart' as user_model;
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

  Future<List<LeaveRequest>> getStudentLeaveRequests() async {
    try {
      final result = await Api.get(url: Api.getLeaveStudentRequests);

      // Handle pagination structure: result['data']['data'] contains the actual list
      final data = result['data'];
      if (data is Map && data.containsKey('data')) {
        return ((data['data'] ?? []) as List)
            .map((leaveRequest) =>
                LeaveRequest.fromJson(Map.from(leaveRequest ?? {})))
            .toList();
      } else {
        // Fallback for direct list structure if pagination is not used
        return ((result['data'] ?? []) as List)
            .map((leaveRequest) =>
                LeaveRequest.fromJson(Map.from(leaveRequest ?? {})))
            .toList();
      }
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

      // Tambahkan rejection_reason ke body jika status = rejected
      if (status == 2 && rejectReason != null) {
        body["reason"] = rejectReason.trim(); // Coba field 'reason'
        body["rejection_reason"] =
            rejectReason.trim(); // Backup dengan rejection_reason
      }

      print("DEBUG: Staff Leave Approve Request Body: $body");
      print(
          "DEBUG: Staff Leave Approve URL: ${Api.approveOrRejectLeaveRequest}");
      print("DEBUG: Staff Leave Approve Request Method: POST JSON");

      await Api.postJson(url: Api.approveOrRejectLeaveRequest, body: body);
    } catch (e) {
      print("DEBUG: Staff Leave Approve Error: $e");
      print("DEBUG: Staff Leave Approve Error Type: ${e.runtimeType}");
      if (e is ApiException) {
        print(
            "DEBUG: Staff Leave Approve ApiException Message: ${e.errorMessage}");
      }
      throw ApiException(e.toString());
    }
  }

  Future<void> approveOrRejectStudentLeaveRequest(
      {required int leaveRequestId,
      required int status,
      String? rejectReason}) async {
    try {
      // Validasi: reject_reason wajib diisi jika status = 2 (rejected)
      if (status == 2 &&
          (rejectReason == null || rejectReason.trim().isEmpty)) {
        throw ApiException(
            "Alasan penolakan wajib diisi saat menolak permohonan izin siswa");
      }

      Map<String, dynamic> body = {
        "leave_id": leaveRequestId,
        "status": status
      };

      // Tambahkan rejection_reason ke body jika status = rejected (untuk student leave)
      if (status == 2 && rejectReason != null) {
        body["reason"] = rejectReason.trim(); // Coba field 'reason'
        body["rejection_reason"] =
            rejectReason.trim(); // Backup dengan rejection_reason
      }

      print("DEBUG: Student Leave Approve Request Body: $body");
      print(
          "DEBUG: Student Leave Approve URL: ${Api.submitLeaveStudentRequests}");
      print("DEBUG: Student Leave Approve Request Method: POST JSON");

      await Api.postJson(url: Api.submitLeaveStudentRequests, body: body);
    } catch (e) {
      print("DEBUG: Student Leave Approve Error: $e");
      print("DEBUG: Student Leave Approve Error Type: ${e.runtimeType}");
      if (e is ApiException) {
        print(
            "DEBUG: Student Leave Approve ApiException Message: ${e.errorMessage}");
      }
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

  Future<user_model.User?> getStudentInfo({required int studentId}) async {
    try {
      final result = await Api.get(url: Api.getStudents, queryParameters: {
        "student_id": studentId,
      });

      final data = result['data'];
      if (data is Map<String, dynamic>) {
        // API returns single student object, not a list
        return user_model.User.fromJson(data);
      }
      return null;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
