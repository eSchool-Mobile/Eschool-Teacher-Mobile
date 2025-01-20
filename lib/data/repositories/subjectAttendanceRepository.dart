import 'package:eschool_saas_staff/data/models/attendanceStudent.dart';
import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:convert';

class SubjectAttendanceRepository {
  Future<
      ({
        List<AttendanceStudent> attendance,
        bool isHoliday,
        Holiday holidayDetails,
        String? materi,
        String? lampiran,
      })> getAttendance({
    required int classSectionId,
    required String date,
    required int timetableId,
  }) async {
    try {
      print(
          'Class Section ID: $classSectionId, Date: $date, Timetable ID: $timetableId');
      final result = await Api.get(
        url: Api.getSubjectAttendance,
        useAuthToken: true,
        queryParameters: {
          "class_section_id": classSectionId,
          "date": date,
          "timetable_id": timetableId,
        },
      );

      print(classSectionId);
      print(date);
      print(timetableId);

      print("CREDDDDDDDDDDDDDDDDDDSSSSSSSSSSSSSSSSSSSSSS");

      // Tambahkan logging untuk mencetak respons dari server
      print("DATA ASELI: $result");

      // Pretty print full response
      final JsonEncoder encoder = JsonEncoder.withIndent('  ');
      print("\n=== DATA ASELI (Full Response) ===");
      print(encoder.convert(result));

      // Print detailed keys
      print("\n=== Response Keys Detail ===");
      result.forEach((key, value) {
        print("\nKey: $key");
        print(encoder.convert(value));
      });

      if (result['data'] == null) {
        throw ApiException('Data is null');
      }

      // Akses array attendance_student di dalam objek data
      final attendanceData = (result['data'] as List)
          .expand((data) => data['attendance_student'] as List)
          .map((attendanceReport) =>
              AttendanceStudent.fromJson(attendanceReport))
          .toList();

      // Pastikan bahwa lampiran diparsing dengan benar
      final lampiran = (result['data'] as List).isNotEmpty
          ? (result['data'][0]['lampiran'] as String?)
          : null;

      final materi = (result['data'] as List).isNotEmpty
          ? (result['data'][0]['materi'] as String?)
          : null;

      print("Lampiran di repository: $lampiran");
      print("Materi di repository: $materi");

      return (
        attendance: attendanceData,
        isHoliday: result['is_holiday'] as bool,
        holidayDetails: Holiday.fromJson(
          Map.from(result['holiday'] == null
              ? {}
              : (result['holiday'] as List).firstOrNull ?? {}),
        ),
        materi: materi,
        lampiran: lampiran,
      );
    } catch (e) {
      print("Error in getAttendance: $e");
      throw ApiException(e.toString());
    }
  }

  Future<void> submitSubjectAttendance({
    required int classSectionId,
    required String date,
    required int timetableId,
    required int jumlahJp,
    required String materi,
    required String lampiran,
    required List<Map<String, dynamic>> attendance,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Api.submitSubjectAttendance),
      );

      // Tambahkan header otentikasi
      request.headers.addAll(Api.headers(useAuthToken: true));

      request.fields['class_section_id'] = classSectionId.toString();
      request.fields['timetable_id'] = timetableId.toString();
      request.fields['date'] = date;
      request.fields['jumlah_jp'] = jumlahJp.toString();
      request.fields['materi'] = materi;

      // Convert attendance list to form data format
      for (int i = 0; i < attendance.length; i++) {
        request.fields['attendance[$i][student_id]'] =
            attendance[i]['student_id'].toString();
        request.fields['attendance[$i][type]'] =
            attendance[i]['type'].toString();
      }

      final JsonEncoder encoder = JsonEncoder.withIndent('  ');
      print('\n=== Request Fields as JSON ===');
      print(encoder.convert(request.fields));

      if (lampiran.isNotEmpty) {
        print('\n=== Request Files ===');
        final filesInfo = {
          'lampiran': {'filename': basename(lampiran), 'path': lampiran}
        };
        print(encoder.convert(filesInfo));
        request.files.add(await http.MultipartFile.fromPath(
          'lampiran',
          lampiran,
          filename: basename(lampiran),
        ));
      }

      var response = await request.send();

      // Tambahkan logging untuk mencetak respons dari server
      var responseData = await http.Response.fromStream(response);
      print("Response status: ${response.statusCode}");
      print("Response body: ${responseData.body}");

      if (response.statusCode != 200) {
        throw ApiException('Failed to submit attendance');
      }
    } catch (e) {
      print("error : $e");
      throw ApiException(e.toString());
    }
  }
}
