import 'dart:convert';

import 'package:eschool_saas_staff/data/models/attendanceRanking.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:http/http.dart' as http;

class AttendanceRankingRepository {
  Future<AttendanceRanking> getAttendanceRankings({String? search}) async {
    try {
      print("Starting API call...");
      print("URL: ${Api.getAttendanceRanking}");

      // Log headers
      final headers = await Api.headers();
      print("Headers: $headers");

      // Make direct HTTP call to debug
      final response = await http.get(
        Uri.parse("${Api.getAttendanceRanking}"),
        headers: headers.cast<String, String>(),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode != 200) {
        throw ApiException(
            "Server returned ${response.statusCode}: ${response.body}");
      }

      final result = jsonDecode(response.body);
      print("Decoded Response: $result");

      if (result == null) {
        print("Error: Null response received");
        throw ApiException("Empty response from server");
      }

      final attendanceRanking = AttendanceRanking.fromJson(result);
      print(
          "Parsed Response: ${attendanceRanking.groupedByClassLevel?.length} class levels");

      return attendanceRanking;
    } catch (e) {
      print("API Error Details: $e");
      throw ApiException(e.toString());
    }
  }
}
