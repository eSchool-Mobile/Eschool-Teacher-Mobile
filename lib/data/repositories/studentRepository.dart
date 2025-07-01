import 'package:eschool_saas_staff/data/models/exam.dart';
import 'package:eschool_saas_staff/data/models/studentAttendance.dart';
import 'package:eschool_saas_staff/data/models/studentDetails.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/foundation.dart';

class StudentRepository {
  Future<List<StudentDetails>> getStudentsByClassSectionAndSubject({
    required int classSectionId,
    required int? classSubjectId,
    required int? examId,
    StudentListStatus? status,
    String? search,
  }) async {
    try {
      ///[0 - view all, 1 - Active, 2 - Inactive]
      int studentViewStatus = 0;
      if (status != null) {
        if (status == StudentListStatus.active) {
          studentViewStatus = 1;
        } else if (status == StudentListStatus.inactive) {
          studentViewStatus = 2;
        }
      }
      final result = await Api.get(
        url: Api.getStudents,
        useAuthToken: true,
        queryParameters: {
          "paginate": 0,
          "status": studentViewStatus,
          "class_section_id": classSectionId,
          if (search != null) "search": search,
          if (classSubjectId != null) "class_subject_id": classSubjectId,
          if (examId != null) "exam_id": examId
        },
      );

      // Handle different response structures
      List<dynamic> studentsData;
      if (result['data'] is Map && result['data']['data'] != null) {
        // Paginated response structure
        studentsData = result['data']['data'] as List;
      } else if (result['data'] is List) {
        // Non-paginated response structure
        studentsData = result['data'] as List;
      } else {
        studentsData = [];
      }

      return studentsData.map((e) {
        return StudentDetails.fromJson(Map.from(e ?? {}));
      }).toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<({List<StudentDetails> students, int currentPage, int totalPage})>
      getStudents(
          {required int classSectionId,
          int? page,
          int? sessionYearId,
          String? search,
          String? status,
          bool getAllData = false}) async {
    try {
      ///[0 - view all, 1 - Active, 2 - Inactive]
      int? studentViewStatus;
      if (status != null) {
        if (status == '1') {
          studentViewStatus = 1; // Active
        } else if (status == '0') {
          studentViewStatus = 0; // Inactive
        }
      }
      final Map<String, dynamic> queryParameters = {
        "class_section_id": classSectionId,
        "session_year_id": sessionYearId,
        "search": search,
      };

      // Add pagination parameters only if not getting all data
      if (!getAllData) {
        queryParameters["page"] = page ?? 1;
      } else {
        queryParameters["paginate"] = 0; // Get all data without pagination
      }

      if (studentViewStatus != null) {
        queryParameters["status"] = studentViewStatus;
      }
      final result =
          await Api.get(url: Api.getStudents, queryParameters: queryParameters);

      // Handle different response structures based on pagination
      List<dynamic> studentsData;
      int currentPage = 1;
      int totalPage = 1;

      if (getAllData) {
        // When paginate=0, response structure is different
        if (result['data'] is List) {
          studentsData = result['data'] as List;
        } else if (result['data'] is Map && result['data']['data'] != null) {
          studentsData = result['data']['data'] as List;
        } else {
          studentsData = [];
        }
        // For non-paginated data, set page info
        currentPage = 1;
        totalPage = 1;
      } else {
        // Normal paginated response
        studentsData = (result['data']['data'] ?? []) as List;
        currentPage = (result['data']['current_page'] as int);
        totalPage = (result['data']['last_page'] as int);
      }

      return (
        students: studentsData
            .map((studentDetails) =>
                StudentDetails.fromJson(Map.from(studentDetails ?? {})))
            .toList(),
        currentPage: currentPage,
        totalPage: totalPage,
      );
    } catch (e, stk) {
      if (kDebugMode) {
        print(stk.toString());
      }
      throw ApiException(e.toString());
    }
  }

  Future<
          ({
            List<StudentAttendance> studentAttendances,
            int currentPage,
            int totalPage
          })>
      getStudentAttendance(
          {required int classSectionId,
          required String date,
          int? status,
          int? page}) async {
    try {
      final result = await Api.get(
          url: Api.getStudentAttendanceForStaff,
          queryParameters: {
            "class_section_id": classSectionId,
            "page": page ?? 1,
            "date": date,
            "status": status
          });

      return (
        studentAttendances: ((result['data']['data'] ?? []) as List)
            .map((studentAttendance) =>
                StudentAttendance.fromJson(Map.from(studentAttendance ?? {})))
            .toList(),
        currentPage: (result['data']['current_page'] as int),
        totalPage: (result['data']['last_page'] as int),
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<Exam>> fetchExamsList(
      {required int examStatus,
      int? studentID,
      int? publishStatus,
      int? classSectionId}) async {
    try {
      var queryParameter = {
        'status': examStatus,
        if (studentID != null) 'student_id': studentID,
      };
      print('ID Siswa : $studentID');
      if (classSectionId != null) {
        queryParameter["class_section_id"] = classSectionId;
      }
      if (publishStatus != null) queryParameter['publish'] = publishStatus;

      final result = await Api.get(
        url: Api.examList,
        useAuthToken: true,
        queryParameters: queryParameter,
      );

      print(Api.examList);
      print("::::");
      print(queryParameter);

      return (result['data'] as List)
          .map((e) => Exam.fromExamJson(Map.from(e)))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> addOfflineExamMarks({
    required int examId,
    required int classSubjectId,
    required Map<String, dynamic> marksDataValue,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {
        "exam_id": examId,
        "class_subject_id": classSubjectId,
      };
      await Api.post(
        body: marksDataValue,
        url: Api.submitExamMarks,
        useAuthToken: true,
        queryParameters: queryParameters,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<StudentDetails>> getAllStudents({
    required int classSectionId,
    int? sessionYearId,
    String? search,
    String? status,
  }) async {
    try {
      ///[0 - view all, 1 - Active, 2 - Inactive]
      int? studentViewStatus;
      if (status != null) {
        if (status == '1') {
          studentViewStatus = 1; // Active
        } else if (status == '0') {
          studentViewStatus = 0; // Inactive
        }
      }

      final Map<String, dynamic> queryParameters = {
        "class_section_id": classSectionId,
        "paginate": 0, // This will return all data without pagination
        "session_year_id": sessionYearId,
        "search": search,
      };

      if (studentViewStatus != null) {
        queryParameters["status"] = studentViewStatus;
      }

      final result = await Api.get(
          url: Api.getStudents,
          useAuthToken: true,
          queryParameters: queryParameters);

      // Handle both paginated and non-paginated response structure
      List<dynamic> studentsData;
      if (result['data'] is Map && result['data']['data'] != null) {
        studentsData = result['data']['data'] as List;
      } else if (result['data'] is List) {
        studentsData = result['data'] as List;
      } else {
        studentsData = [];
      }

      return studentsData
          .map((studentDetails) =>
              StudentDetails.fromJson(Map.from(studentDetails ?? {})))
          .toList();
    } catch (e, stk) {
      if (kDebugMode) {
        print(stk.toString());
      }
      throw ApiException(e.toString());
    }
  }
}
