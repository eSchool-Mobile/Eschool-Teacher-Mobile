import 'dart:convert';

import 'package:eschool_saas_staff/data/models/attendanceRanking.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:http/http.dart' as http;

class AttendanceRankingRepository {
  Future<AttendanceRanking> getAttendanceRankings({String? search}) async {
    try {
      final headers = await Api.headers();
      
      // Pastikan URL valid
      final url = Uri.parse(Api.getAttendanceRanking);
      
      print("Request URL: ${url.toString()}"); // Debug log
      print("Headers: $headers"); // Debug log

      final response = await http.get(
        url,
        headers: headers.cast<String, String>(),
      ).timeout(
        const Duration(seconds: 30), // Tambahkan timeout
        onTimeout: () {
          throw ApiException("Connection timeout");
        },
      );

      print("Response status: ${response.statusCode}"); // Debug log
      print("Response body: ${response.body}"); // Debug log

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
      print("Error fetching attendance ranking: $e");
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
