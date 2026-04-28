import 'dart:convert';

import 'package:eschool_saas_staff/data/models/student/attendanceRanking.dart';
import 'package:eschool_saas_staff/utils/system/api.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AttendanceRankingRepository {
  Future<AttendanceRanking> getAttendanceRankings({String? search}) async {
    try {
      final headers = Api.headers();
      
      // Pastikan URL valid
      final url = Uri.parse(Api.getAttendanceRanking);
      
      debugPrint("Request URL: ${url.toString()}"); // Debug log
      debugPrint("Headers: $headers"); // Debug log

      final response = await http.get(
        url,
        headers: headers.cast<String, String>(),
      ).timeout(
        const Duration(seconds: 30), // Tambahkan timeout
        onTimeout: () {
          throw ApiException("Connection timeout");
        },
      );

      debugPrint("Response status: ${response.statusCode}"); // Debug log
      debugPrint("Response body: ${response.body}"); // Debug log

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result != null) {
          return AttendanceRanking.fromJson(result);
        }
        throw ApiException("Empty response from server");
      } else {
        throw ApiException("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching attendance ranking: $e");
      throw ApiException(e.toString());
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}

