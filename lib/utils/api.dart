import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/repositories/authRepository.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/foundation.dart';

class ApiException implements Exception {
  String errorMessage;

  ApiException(this.errorMessage);

  @override
  String toString() {
    return errorMessage;
  }
}

class Api {
  static String login = "${databaseUrl}teacher/login";
  static String logout = "${databaseUrl}logout";

  static String passwordResetEmail = "${databaseUrl}forgot-password";
  static String changepassword = "${databaseUrl}change-password";
  static String editProfile = "${databaseUrl}update-profile";
  static String getStaffPermissionAndFeatures =
      "${databaseUrl}staff/features-permission";
  static String getSystemStatistics = "${databaseUrl}staff/counter";
  static String getTeachers = "${databaseUrl}staff/teachers";
  static String getLeaves = "${databaseUrl}leaves";
  static String applyLeave = "${databaseUrl}leaves";

  static String getSettings = "${databaseUrl}settings";
  static String getHolidays = "${databaseUrl}holidays";
  static String getLeaveRequests = "${databaseUrl}staff/leave-request";
  static String getPermission = "${databaseUrl}teacher/student-leaves";
  static String approveOrRejectLeaveRequest =
      "${databaseUrl}staff/leave-approve";
  static String getClasses = "${databaseUrl}classes";
  static String getSessionYears = "${databaseUrl}session-years";

  static String getStudents = "${databaseUrl}teacher/student-list";
  static String getStaffs = "${databaseUrl}staff/staffs";
  static String getTimeTableOfTeacher = "${databaseUrl}staff/teacher-timetable";
  static String getUserLeaves = "${databaseUrl}staff-leaves-details";
  static String getStudentAttendanceForStaff =
      "${databaseUrl}staff/student/attendance";
  static String getClassTimetable = "${databaseUrl}staff/class-timetable";
  static String getMediums = "${databaseUrl}medium";
  static String getOfflineExamStudentResults =
      "${databaseUrl}staff/student-offline-exam-result";
  static String getNotifications = "${databaseUrl}staff/notification";
  static String deleteNotification = "${databaseUrl}staff/notification-delete";
  static String getAnnouncements = "${databaseUrl}staff/get-announcement";
  static String deleteGeneralAnnouncement =
      "${databaseUrl}staff/delete-announcement";
  static String sendNotification = "${databaseUrl}staff/notification";
  static String sendGeneralAnnouncement =
      "${databaseUrl}staff/send-announcement";
  static String editGeneralAnnouncement =
      "${databaseUrl}staff/update-announcement";

  static String getMyPayRolls = "${databaseUrl}staff/my-payroll";
  static String downloadPayRollSlip = "${databaseUrl}staff/payroll-slip";
  static String getPayRollYears = "${databaseUrl}staff/payroll-year";
  static String getRoles = "${databaseUrl}staff/roles";
  static String searchUsers = "${databaseUrl}staff/users";
  static String getFees = "${databaseUrl}staff/get-fees";
  static String getStudentsFeeStatus = "${databaseUrl}staff/fees-paid-list";
  static String getStaffsPayroll = "${databaseUrl}staff/payroll-staff-list";
  static String submitStaffsPayroll = "${databaseUrl}staff/payroll-create";
  static String downloadStudentFeeReceipt =
      "${databaseUrl}staff/student-fees-receipt";

  static String getAllowancesAndDeductions =
      "${databaseUrl}staff/allowances-deductions";

  static String getLeaveSettings = "${databaseUrl}leave-settings";

  ///[teacher-related APIs]
  //-------------
  static String getTeacherMyTimetable =
      "${databaseUrl}teacher/teacher_timetable";
  static String getClassesWithTeacherDetails =
      "${databaseUrl}teacher/class-detail";
  static String getExams = "${databaseUrl}teacher/get-exam-list";
  static String getLessons = "${databaseUrl}teacher/get-lesson";
  static String getSubjects = "${databaseUrl}teacher/subjects";
  static String getClassDetails = "${databaseUrl}teacher/class-detail";

  static String createLesson = "${databaseUrl}teacher/create-lesson";
  static String updateLesson = "${databaseUrl}teacher/update-lesson";
  static String deleteLesson = "${databaseUrl}teacher/delete-lesson";

  static String deleteStudyMaterial = "${databaseUrl}teacher/delete-file";
  static String updateStudyMaterial = "${databaseUrl}teacher/update-file";

  static String getTopics = "${databaseUrl}teacher/get-topic";
  static String createTopic = "${databaseUrl}teacher/create-topic";
  static String updateTopic = "${databaseUrl}teacher/update-topic";
  static String deleteTopic = "${databaseUrl}teacher/delete-topic";

  static String getReviewAssignment =
      "${databaseUrl}teacher/get-assignment-submission";
  static String updateReviewAssignment =
      "${databaseUrl}teacher/update-assignment-submission";

  static String getAssignment = "${databaseUrl}teacher/get-assignment";
  static String uploadAssignment = "${databaseUrl}teacher/update-assignment";
  static String deleteAssignment = "${databaseUrl}teacher/delete-assignment";
  static String createAssignment = "${databaseUrl}teacher/create-assignment";
  static String getAssignmentFileTypes =
      "${databaseUrl}teacher/get-assignment-filetype";

  static String getAnnouncement = "${databaseUrl}teacher/get-announcement";
  static String createAnnouncement = "${databaseUrl}teacher/send-announcement";
  static String deleteAnnouncement =
      "${databaseUrl}teacher/delete-announcement";
  static String updateAnnouncement =
      "${databaseUrl}teacher/update-announcement";

  static String getAttendance = "${databaseUrl}teacher/get-attendance";
  static String getSubjectAttendance =
      "${databaseUrl}teacher/get-subject-attendance";
  static String submitAttendance = "${databaseUrl}teacher/submit-attendance";
  static String submitSubjectAttendance =
      "${databaseUrl}teacher/submit-subject-attendance";
  static String getAttendanceRanking =
      "${databaseUrl}teacher/attendance-ranking";

  static String examList = "${databaseUrl}teacher/get-exam-list";
  static String submitExamMarks =
      "${databaseUrl}teacher/submit-exam-marks/subject";

  /// Chat
  static String chatMessages = "${databaseUrl}message";
  static String readMessages = "${databaseUrl}message/read";
  static String deleteMessages = "${databaseUrl}delete/message";
  static String getUsers = "${databaseUrl}users";
  static String getUserChatHistory = "${databaseUrl}users/chat/history";

  //-------------

  static String downloadStudentResult = "${databaseUrl}student-exan-result-pdf";
  static String getTeacherSubjectId =
      "${databaseUrl}teacher/bank-soal/getTeacherSubject";

  // Question Bank APIs
  static String getTeacherSubject =
      "${databaseUrl}teacher/bank-soal/getTeacherSubject";
  static String getOnlineExamQuestionListCorrection =
      "${databaseUrl}teacher/get-online-exam-question-list-correction";
  static String getOnlineExamAnswerCorrection =
      "${databaseUrl}teacher/get-online-exam-answer-list-correction";
  static String updateOnlineExamAnswerCorrection = "${databaseUrl}teacher/update-online-exam-answer-correction";
  static String getBankSoal = "${databaseUrl}teacher/bank-soal/get";
  static String getBankQuestions = "${databaseUrl}teacher/bank-soal/getSoal";
  static String createQuestionBank = "${databaseUrl}teacher/bank-soal/create";
  static String createQuestion = "${databaseUrl}teacher/bank-soal/createSoal";
  static String updateQuestionBank = "${databaseUrl}teacher/bank-soal/update";
  static String updateQuestion = "${databaseUrl}teacher/bank-soal/updateSoal";
  static String deleteQuestionBank = "${databaseUrl}teacher/bank-soal/delete";
  static String deleteQuestion = "${databaseUrl}teacher/bank-soal/deleteSoal";

  // Online Exam APIs
  static String getOnlineExamList =
      "${databaseUrl}teacher/get-online-exam-list";
  static String createOnlineExam = "${databaseUrl}teacher/store-online-exam";
  static String updateOnlineExam = "${databaseUrl}teacher/update-online-exam";
  static String deleteOnlineExam = "${databaseUrl}teacher/delete-online-exam";
  static String getOnlineExamQuestions =
      "${databaseUrl}teacher/get-online-exam-questions";
  static String storeOnlineExamQuestions =
      "${databaseUrl}teacher/store-online-exam-questions";

  static Map<String, String> headers({bool useAuthToken = false}) {
    final String jwtToken = AuthRepository.getAuthToken();
    final schoolCode = AuthRepository().schoolCode;

    return {
      "Authorization": "Bearer $jwtToken",
      "school_code": schoolCode,
      "Content-Type": "application/json",
      "Accept": "application/json",
      "X-Requested-With": "XMLHttpRequest",
      "role": "teacher",
      "view_type": "teacher",
      "all": "true",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
      "Access-Control-Allow-Headers":
          "Origin, Content-Type, Accept, Authorization, X-Request-With, role, view_type, all",
    };
  }

  static Future<Map<String, dynamic>> post({
    required Map<String, dynamic> body,
    required String url,
    bool? useAuthToken,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      print(url);
      print(body);

      final Dio dio = Dio();
      final options = Options(
        headers: (useAuthToken ?? true) ? headers() : null,
        contentType: Headers.formUrlEncodedContentType, // Ubah content type
      );

      final response = await dio.post(
        url,
        data: FormData.fromMap(body),
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        options: options,
      );

      print("Response Data: ${response.data}");

      if (response.statusCode != 200) {
        throw Exception('Failed to create exam: ${response.statusMessage}');
      }

      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      print("Dio Error: ${e.response?.data}");
      throw ApiException(
        e.error is SocketException ? noInternetKey : defaultErrorMessageKey,
      );
    } catch (e) {
      print("General Error: $e");
      throw ApiException(defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> get({
    required String url,
    bool? useAuthToken,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Dio dio = Dio();

      // Add default parameters
      queryParameters = {
        'role': 'teacher',
        'view_type': 'teacher',
        'all': 'true',
        ...?queryParameters,
      };

      final response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(
          headers: headers(useAuthToken: useAuthToken ?? true),
          validateStatus: (status) => status! < 500,
        ),
      );

      print(url);
      print("Response Status Code: ${response.statusCode}");
      print("Full Response Data: ${response.data}");

      if (response.statusCode == 200) {
        if (response.data is Map) {
          if (response.data['error'] == true) {
            throw ApiException(
                response.data['message'] ?? defaultErrorMessageKey);
          }
          return Map<String, dynamic>.from(response.data);
        }
        throw ApiException("Invalid response format");
      } else {
        throw ApiException(response.data['message'] ?? defaultErrorMessageKey);
      }
    } on DioException catch (e) {
      print("Dio Error: ${e.message}");
      print("Dio Error Response: ${e.response?.data}");
      throw ApiException(e.message ?? defaultErrorMessageKey);
    } catch (e) {
      print("General Error: $e");
      throw ApiException(e.toString());
    }
  }

  static Future<void> download(
      {required String url,
      required CancelToken cancelToken,
      required String savePath,
      required Function updateDownloadedPercentage}) async {
    try {
      final Dio dio = Dio();
      await dio.download(url, savePath, cancelToken: cancelToken,
          onReceiveProgress: ((count, total) {
        updateDownloadedPercentage((count / total) * 100);
      }));
    } on DioException catch (e) {
      throw ApiException(
          e.error is SocketException ? noInternetKey : defaultErrorMessageKey);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> delete({
    required String url,
    required Map<String, dynamic> body,
    bool? useAuthToken,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      print('DELETE Request to: $url');
      print('Body: $body');
      print('Query Parameters: $queryParameters');

      final Dio dio = Dio();
      final response = await dio.delete(
        url,
        data: body,
        queryParameters: queryParameters,
        options: (useAuthToken ?? true) ? Options(headers: headers()) : null,
      );

      print('Delete Response Raw: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        final responseData = Map<String, dynamic>.from(response.data);
        print('Delete Response Processed: $responseData');
        return responseData;
      }

      throw ApiException('Invalid response format');
    } on DioException catch (e) {
      print('DioError: ${e.message}');
      print('DioError Response: ${e.response?.data}');
      throw ApiException(
          e.error is SocketException ? noInternetKey : defaultErrorMessageKey);
    } catch (e) {
      print('General Error: $e');
      throw ApiException(e.toString());
    }
  }
}
