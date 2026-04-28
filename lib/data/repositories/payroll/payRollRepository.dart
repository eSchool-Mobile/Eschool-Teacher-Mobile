import 'dart:convert';

import 'package:eschool_saas_staff/data/models/payroll/payRoll.dart';
import 'package:eschool_saas_staff/data/models/payroll/staffPayRoll.dart';
import 'package:eschool_saas_staff/data/models/payroll/staffSalary.dart';
import 'package:eschool_saas_staff/data/models/auth/userDetails.dart';
import 'package:eschool_saas_staff/utils/system/api.dart';
import 'package:flutter/foundation.dart';

class PayRollRepository {
  Future<List<PayRoll>> getMyPayRoll({required int sessionYearId}) async {
    try {
      final result = await Api.get(
          url: Api.getMyPayRolls,
          queryParameters: {"session_year_id": sessionYearId});

      return ((result['data'] ?? []) as List)
          .map((payRoll) => PayRoll.fromJson(Map.from(payRoll ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<String> downloadPayRollSlip({required int payRollId}) async {
    try {
      // Print request details
      debugPrint("=== DOWNLOAD PAYROLL PDF REQUEST ===");
      debugPrint("URL: ${Api.downloadPayRollSlip}");
      debugPrint("Parameters: slip_id=$payRollId");

      final result = await Api.get(
          url: Api.downloadPayRollSlip,
          queryParameters: {"slip_id": payRollId});

      // Print response info (not the full PDF content as it would be too large)
      debugPrint("=== DOWNLOAD PAYROLL PDF RESPONSE ===");
      debugPrint("Response keys: ${result.keys.toList()}");

      final pdfContent = (result['pdf'] ?? "").toString();
      debugPrint("PDF content length: ${pdfContent.length}");

      // Log first and last few characters to help debug format issues
      if (pdfContent.isNotEmpty) {
        const previewLength = 50;
        debugPrint(
            "PDF content start: ${pdfContent.substring(0, pdfContent.length < previewLength ? pdfContent.length : previewLength)}");
        if (pdfContent.length > previewLength * 2) {
          debugPrint(
              "PDF content end: ${pdfContent.substring(pdfContent.length - previewLength)}");
        }
      }

      // Validate that we actually received PDF content
      if (pdfContent.isEmpty) {
        throw ApiException("Server returned empty PDF content");
      }

      // The PDF content appears to be base64 encoded JSON, let's decode it
      try {
        debugPrint("Attempting to decode nested JSON structure...");
        final decodedJson = base64Decode(pdfContent);
        final jsonString = utf8.decode(decodedJson);
        debugPrint(
            "Decoded JSON: ${jsonString.substring(0, jsonString.length > 100 ? 100 : jsonString.length)}...");

        final nestedResponse = json.decode(jsonString);
        if (nestedResponse is Map && nestedResponse.containsKey('pdf')) {
          final actualPdfContent = nestedResponse['pdf'].toString();
          debugPrint(
              "Found nested PDF content, length: ${actualPdfContent.length}");

          if (actualPdfContent.isEmpty) {
            throw ApiException("Nested PDF content is empty");
          }

          return actualPdfContent;
        } else {
          throw ApiException("Invalid nested JSON structure");
        }
      } catch (e) {
        debugPrint("Failed to decode nested JSON: $e");
        debugPrint("Falling back to original content...");
        return pdfContent;
      }
    } catch (e) {
      debugPrint("=== DOWNLOAD PAYROLL PDF ERROR ===");
      debugPrint("Error: ${e.toString()}");
      throw ApiException(e.toString());
    }
  }

  Future<List<int>> getPayRollYears() async {
    try {
      final result = await Api.get(url: Api.getPayRollYears);

      return ((result['data'] ?? []) as List)
          .map((e) => int.parse(e.toString()))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<({double allowedLeaves, List<StaffPayRoll> staffsPayRoll})>
      getStaffsPayroll({required int year, required int month}) async {
    try {
      final result = await Api.get(
          url: Api.getStaffsPayroll,
          queryParameters: {"month": month, "year": year});

      return (
        allowedLeaves: result['leave_master'] != null
            ? double.parse((result['leave_master']['leaves'] ?? 0).toString())
            : 0.0,
        staffsPayRoll: ((result['data'] ?? []) as List)
            .map((staffPayRoll) =>
                StaffPayRoll.fromJson(Map.from(staffPayRoll ?? {})))
            .toList(),
      );
    } catch (e, stc) {
      if (kDebugMode) {
        debugPrint(stc.toString());
      }
      throw ApiException(e.toString());
    }
  }

  Future<void> submitStaffsPayRoll(
      {required int month,
      required int year,
      required double allowedLeaves,
      required List<Map<String, dynamic>> staffPayRolls}) async {
    try {
      await Api.post(body: {
        "month": month,
        "year": year,
        "allowed_leaves": allowedLeaves,
        "payroll": staffPayRolls
      }, url: Api.submitStaffsPayroll);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<({List<StaffSalary> allowances, List<StaffSalary> deductions})>
      getAllowancesAndDeductions() async {
    try {
      final result = await Api.get(url: Api.getAllowancesAndDeductions);
      final UserDetails userDetails =
          UserDetails.fromJson(Map.from(result['data'] ?? {}));
      final isTeacher = userDetails.teacher?.id != null;

      return (
        allowances: isTeacher
            ? (userDetails.teacher?.staffSalaries ?? []).where((staffSalary) {
                return (staffSalary.payRollSetting?.isAllowance() ?? false);
              }).toList()
            : (userDetails.staff?.staffSalaries ?? [])
                .where((staffSalary) =>
                    (staffSalary.payRollSetting?.isAllowance() ?? false))
                .toList(),
        deductions: isTeacher
            ? (userDetails.teacher?.staffSalaries ?? [])
                .where((staffSalary) =>
                    (staffSalary.payRollSetting?.isDeduction() ?? false))
                .toList()
            : (userDetails.staff?.staffSalaries ?? [])
                .where((staffSalary) =>
                    (staffSalary.payRollSetting?.isDeduction() ?? false))
                .toList(),
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}

