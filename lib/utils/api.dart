import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/repositories/authRepository.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:http/http.dart' as http;
import 'package:eschool_saas_staff/utils/logger.dart';
import 'package:image_picker/image_picker.dart';
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
  static String get login => "${databaseUrl}teacher/login";
  static String get logout => "${databaseUrl}logout";

  static String get passwordResetEmail => "${databaseUrl}forgot-password";
  static String get changepassword => "${databaseUrl}change-password";
  static String get editProfile => "${databaseUrl}update-profile";
  static String get getStaffPermissionAndFeatures =>
      "${databaseUrl}staff/features-permission";
  static String get getSystemStatistics => "${databaseUrl}staff/counter";
  static String get getTeachers => "${databaseUrl}staff/teachers";
  static String get getLeaves => "${databaseUrl}leaves";
  static String get applyLeave => "${databaseUrl}leaves";

  static String get getSettings => "${databaseUrl}settings";
  static String get getHolidays => "${databaseUrl}holidays";
  static String get getLeaveRequests => "${databaseUrl}staff/leave-request";
  static String get submitLeaveStudentRequests =>
      "${databaseUrl}staff/student-leave-approve";
  static String get getLeaveStudentRequests =>
      "${databaseUrl}staff/student-leave-request";
  static String get getPermission => "${databaseUrl}teacher/student-leaves";
  static String get submitStudentPermission =>
      "${databaseUrl}teacher/student-leave-approve";
  static String get approveOrRejectLeaveRequest =>
      "${databaseUrl}staff/leave-approve";
  static String get getClasses => "${databaseUrl}classes";
  static String get getSessionYears => "${databaseUrl}session-years";

  static String get getAssignmentMonitoring =>
      "${databaseUrl}staff/assignment-monitoring/show";
  static String get getTeacherAssignmentMonitoring =>
      "${databaseUrl}staff/assignment-monitoring/teacher";
  static String get getStudents => "${databaseUrl}teacher/student-list";
  static String get getStaffs => "${databaseUrl}staff/staffs";
  static String get getTimeTableOfTeacher =>
      "${databaseUrl}staff/teacher-timetable";
  static String get getUserLeaves => "${databaseUrl}staff-leaves-details";
  static String get getStudentAttendanceForStaff =>
      "${databaseUrl}staff/student/attendance";
  static String get getClassTimetable => "${databaseUrl}staff/class-timetable";
  static String get getMediums => "${databaseUrl}medium";
  static String get getOfflineExamStudentResults =>
      "${databaseUrl}staff/student-offline-exam-result";
  static String get getNotifications => "${databaseUrl}staff/notification";
  static String get deleteNotification =>
      "${databaseUrl}staff/notification-delete";
  static String get getAnnouncements => "${databaseUrl}staff/get-announcement";
  static String get deleteGeneralAnnouncement =>
      "${databaseUrl}staff/delete-announcement";
  static String get sendNotification => "${databaseUrl}staff/notification";
  static String get sendGeneralAnnouncement =>
      "${databaseUrl}staff/send-announcement";
  static String get editGeneralAnnouncement =>
      "${databaseUrl}staff/update-announcement";

  static String get getMyPayRolls => "${databaseUrl}staff/my-payroll";
  static String get downloadPayRollSlip => "${databaseUrl}staff/payroll-slip";
  static String get getPayRollYears => "${databaseUrl}staff/payroll-year";
  static String get getRoles => "${databaseUrl}staff/roles";
  static String get searchUsers => "${databaseUrl}staff/users";
  static String get getFees => "${databaseUrl}staff/get-fees";
  static String get getStudentsFeeStatus =>
      "${databaseUrl}staff/fees-paid-list";
  static String get getStaffsPayroll =>
      "${databaseUrl}staff/payroll-staff-list";
  static String get submitStaffsPayroll => "${databaseUrl}staff/payroll-create";
  static String get downloadStudentFeeReceipt =>
      "${databaseUrl}staff/student-fees-receipt";

  static String get getAllowancesAndDeductions =>
      "${databaseUrl}staff/allowances-deductions";

  static String get getLeaveSettings => "${databaseUrl}leave-settings";

  ///[teacher-related APIs]
  //-------------
  static String get getTeacherMyTimetable =>
      "${databaseUrl}teacher/teacher_timetable";
  static String get getClassesWithTeacherDetails =>
      "${databaseUrl}teacher/class-detail";
  static String get getExams => "${databaseUrl}teacher/get-exam-list";
  static String get getLessons => "${databaseUrl}teacher/get-lesson";
  static String get getSubjects => "${databaseUrl}teacher/subjects";
  static String get getClassDetails => "${databaseUrl}teacher/class-detail";

  static String get createLesson => "${databaseUrl}teacher/create-lesson";
  static String get updateLesson => "${databaseUrl}teacher/update-lesson";
  static String get deleteLesson => "${databaseUrl}teacher/delete-lesson";

  static String get deleteStudyMaterial => "${databaseUrl}teacher/delete-file";
  static String get updateStudyMaterial => "${databaseUrl}teacher/update-file";

  static String get getTopics => "${databaseUrl}teacher/get-topic";
  static String get createTopic => "${databaseUrl}teacher/create-topic";
  static String get updateTopic => "${databaseUrl}teacher/update-topic";
  static String get deleteTopic => "${databaseUrl}teacher/delete-topic";

  static String get getReviewAssignment =>
      "${databaseUrl}teacher/get-assignment-submission";
  static String get updateReviewAssignment =>
      "${databaseUrl}teacher/update-assignment-submission";

  static String get getAssignment => "${databaseUrl}teacher/get-assignment";
  static String get uploadAssignment =>
      "${databaseUrl}teacher/update-assignment";
  static String get deleteAssignment =>
      "${databaseUrl}teacher/delete-assignment";
  static String get createAssignment =>
      "${databaseUrl}teacher/create-assignment";
  static String get getAssignmentFileTypes =>
      "${databaseUrl}teacher/get-assignment-filetype";

  static String get getAnnouncement => "${databaseUrl}teacher/get-announcement";
  static String get createAnnouncement =>
      "${databaseUrl}teacher/send-announcement";
  static String get deleteAnnouncement =>
      "${databaseUrl}teacher/delete-announcement";
  static String get updateAnnouncement =>
      "${databaseUrl}teacher/update-announcement";

  static String get getAttendance => "${databaseUrl}teacher/get-attendance";
  static String get getSubjectAttendance =>
      "${databaseUrl}teacher/get-subject-attendance";
  static String get submitAttendance =>
      "${databaseUrl}teacher/submit-attendance";
  static String get submitSubjectAttendance =>
      "${databaseUrl}teacher/submit-subject-attendance";
  static String get getAttendanceRanking =>
      "${databaseUrl}teacher/attendance-ranking";

  static String get examList => "${databaseUrl}teacher/get-exam-list";
  static String get submitExamMarks =>
      "${databaseUrl}teacher/submit-exam-marks/subject";

  /// Chat
  static String get chatMessages => "${databaseUrl}message";
  static String get readMessages => "${databaseUrl}message/read";
  static String get deleteMessages => "${databaseUrl}delete/message";
  static String get getUsers => "${databaseUrl}users";
  static String get getUserChatHistory => "${databaseUrl}users/chat/history";

  //-------------

  static String get downloadStudentResult =>
      "${databaseUrl}student-exan-result-pdf";
  static String get getTeacherSubjectId =>
      "${databaseUrl}teacher/bank-soal/getTeacherSubject";

  // Question Bank APIs
  static String get getTeacherSubject =>
      "${databaseUrl}teacher/bank-soal/getTeacherSubject";
  static String get getOnlineExamQuestionListCorrection =>
      "${databaseUrl}teacher/get-online-exam-question-list-correction";
  static String get getOnlineExamAnswerCorrection =>
      "${databaseUrl}teacher/get-online-exam-answer-list-correction";
  static String get updateOnlineExamAnswerCorrection =>
      "${databaseUrl}teacher/update-online-exam-answer-correction";
  static String get getBankSoal => "${databaseUrl}teacher/bank-soal/get";
  static String get getBankQuestions =>
      "${databaseUrl}teacher/bank-soal/getSoal";
  static String get createQuestionBank =>
      "${databaseUrl}teacher/bank-soal/create";
  static String get createQuestion =>
      "${databaseUrl}teacher/bank-soal/createSoal";
  static String get updateQuestionBank =>
      "${databaseUrl}teacher/bank-soal/update";
  static String get updateQuestion =>
      "${databaseUrl}teacher/bank-soal/updateSoal";
  static String get deleteQuestionBank =>
      "${databaseUrl}teacher/bank-soal/delete";
  static String get deleteQuestion =>
      "${databaseUrl}teacher/bank-soal/deleteSoal";

  // Online Exam APIs
  static String get getOnlineExamList =>
      "${databaseUrl}teacher/get-online-exam-list";
  static String get createOnlineExam =>
      "${databaseUrl}teacher/store-online-exam";
  static String get updateOnlineExam =>
      "${databaseUrl}teacher/update-online-exam";
  static String get deleteOnlineExam =>
      "${databaseUrl}teacher/delete-online-exam";
  static String get deleteQuestionOnlineExam =>
      "${databaseUrl}teacher/delete-online-exam-questions";
  static String get getOnlineExamQuestions =>
      "${databaseUrl}teacher/get-online-exam-questions";
  static String get storeOnlineExamQuestions =>
      "${databaseUrl}teacher/store-online-exam-questions";
  static String get getOnlineExamStatus =>
      "${databaseUrl}teacher/get-online-exam-status";
  static String get resetOnlineExamStatus =>
      "${databaseUrl}teacher/reset-online-exam-status";
  static String get gradeLevel => "${databaseUrl}teacher/get-grade-levels";
  static String get getTeachersStaffList => "${databaseUrl}staff/users";

  // Extracurricular APIs
  static String get getExtracurriculars =>
      "${databaseUrl}staff/extracurricular/show";
  static String get getExtracurricularTimetable =>
      "${databaseUrl}staff/extracurricular/timetable";
  static String get createExtracurricular =>
      "${databaseUrl}staff/extracurricular/store";
  static String get updateExtracurricular =>
      "${databaseUrl}staff/extracurricular/update";
  static String get deleteExtracurricular =>
      "${databaseUrl}staff/extracurricular/destroy";
  static String get forceDeleteExtracurricular =>
      "${databaseUrl}staff/extracurricular/force-delete";
  static String get getTrashedExtracurriculars =>
      "${databaseUrl}staff/extracurricular/trashed";
  static String get restoreExtracurricular =>
      "${databaseUrl}staff/extracurricular/restore";

  // Extracurricular Timetable APIs
  static String get createExtracurricularTimetable =>
      "${databaseUrl}staff/extracurricular/timetable/save";
  static String get updateExtracurricularTimetable =>
      "${databaseUrl}staff/extracurricular/timetable/update";
  static String get resetExtracurricularTimetable =>
      "${databaseUrl}staff/extracurricular/timetable/reset";

  // Extracurricular Member APIs
  static String get getExtracurricularMembers =>
      "${databaseUrl}staff/extracurricular/members";
  static String get approveExtracurricularMember =>
      "${databaseUrl}staff/extracurricular/members/approve";
  static String get rejectExtracurricularMember =>
      "${databaseUrl}staff/extracurricular/members/reject";

  // Extracurricular Attendance APIs
  static String get getExtracurricularAttendance =>
      "${databaseUrl}staff/extracurricular/attendance/{id}";
  static String get saveExtracurricularAttendance =>
      "${databaseUrl}staff/extracurricular/attendance/store/{id}";
  static String get getExtracurricularAttendanceHistory =>
      "${databaseUrl}staff/extracurricular/attendance/history";

  /// Contact APIs
  static String get submitContact => "${databaseUrl}contact/submit";
  static String get getContacts => "${databaseUrl}contacts";

  static String get getContactDetail => "${databaseUrl}contacts"; // /{id}
  static String get replyContact => "${databaseUrl}contacts"; // /{id}/reply
  static String get getContactStats => "${databaseUrl}contacts/stats";

  static Map<String, String> headers({bool useAuthToken = false}) {
    final String jwtToken = AuthRepository.getAuthToken();
    final schoolCode = AuthRepository().schoolCode;

    // Log bearer token for debugging
    if (useAuthToken) {
      print(
          '🔑 [API] Bearer Token: ${jwtToken.isNotEmpty ? "Bearer $jwtToken" : "NO TOKEN"}');
      print('🏫 [API] School Code: ${schoolCode ?? "NO SCHOOL CODE"}');
    }

    print(
        '🔑 [API] Auth Token: ${jwtToken.isNotEmpty ? "Present" : "Missing"}, School: $schoolCode');

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

  static Future<XFile> fetchImg(String url) async {
    var response = await http.get(Uri.parse("${storageUrl}${url}"));

    if (response.statusCode == 200) {
      return XFile.fromData(response.bodyBytes, mimeType: 'image/jpeg');
    } else {
      throw Exception("Gagal mengunduh gambar");
    }
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
      if (kDebugMode || true) {
        AppLogger.debug('Api.post', 'Request', data: {
          'url': url,
          'body': body,
          'queryParameters': queryParameters,
        });
      }
      final Dio dio = Dio();
      final FormData formData =
          FormData.fromMap(body, ListFormat.multiCompatible);

      final response = await dio.post(url,
          data: formData,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          options: (useAuthToken ?? true) ? Options(headers: headers()) : null);

      AppLogger.debug('Api.post', 'Response meta', data: {
        'statusCode': response.statusCode,
        'dataType': response.data.runtimeType.toString(),
        'hasErrorKey':
            response.data is Map && (response.data as Map).containsKey('error'),
      });

      if (response.data.containsKey('error') &&
          response.data['error'] == true) {
        throw ApiException(response.data['message'].toString());
      }

      return Map.from(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        AppLogger.error('Api.post', 'DioException',
            data: {
              'url': url,
              'statusCode': e.response?.statusCode,
              'response': e.response?.data,
            },
            error: e);
      }
      throw ApiException(
          e.error is SocketException ? noInternetKey : defaultErrorMessageKey);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Api.post', 'Unknown exception',
            data: {'url': url}, error: e);
      }
      throw ApiException(defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> postJson({
    required Map<String, dynamic> body,
    required String url,
    bool? useAuthToken,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      if (kDebugMode || true) {
        AppLogger.debug('Api.postJson', 'Request', data: {
          'url': url,
          'body': body,
          'queryParameters': queryParameters,
        });
      }
      final Dio dio = Dio();

      final response = await dio.post(url,
          data: body, // Send as JSON directly, not FormData
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          options: Options(
            headers: {
              ...((useAuthToken ?? true) ? headers() : {}),
              'Content-Type': 'application/json',
            },
          ));

      AppLogger.debug('Api.postJson', 'Response meta', data: {
        'statusCode': response.statusCode,
        'dataType': response.data.runtimeType.toString(),
        'hasErrorKey':
            response.data is Map && (response.data as Map).containsKey('error'),
        'errorValue': response.data is Map ? response.data['error'] : null,
      });

      // Check for API errors - only throw if error is true
      if (response.data is Map &&
          response.data.containsKey('error') &&
          response.data['error'] == true) {
        throw ApiException(response.data['message'].toString());
      }

      AppLogger.debug('Api.postJson', 'Response successful', data: {
        'hasData': response.data is Map && response.data.containsKey('data'),
        'message': response.data is Map ? response.data['message'] : null,
      });

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (kDebugMode) {
        AppLogger.error('Api.postJson', 'DioException',
            data: {
              'url': url,
              'statusCode': e.response?.statusCode,
              'response': e.response?.data,
            },
            error: e.toString());
      }
      throw ApiException(
          e.error is SocketException ? noInternetKey : defaultErrorMessageKey);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Api.postJson', 'Unknown exception',
            data: {'url': url}, error: e);
      }
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

      // Get headers
      final requestHeaders = headers(useAuthToken: useAuthToken ?? true);

      // Set response type based on URL
      final bool isPdfEndpoint = url.contains('pdf') ||
          url == downloadPayRollSlip ||
          url == downloadStudentFeeReceipt ||
          url == downloadStudentResult;

      final response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(
            headers: requestHeaders,
            validateStatus: (status) => status! < 500,
            responseType:
                isPdfEndpoint ? ResponseType.bytes : ResponseType.json),
      );

      AppLogger.debug('Api.get', 'Response meta', data: {
        'url': url,
        'statusCode': response.statusCode,
        'query': queryParameters,
        'responseDataType': response.data.runtimeType.toString(),
        'responseDataPreview': response.data is String
            ? (response.data.length > 200
                ? response.data.substring(0, 200) + '...<truncated>'
                : response.data)
            : response.data.toString().length > 200
                ? response.data.toString().substring(0, 200) + '...<truncated>'
                : response.data.toString(),
      });
      if (response.statusCode == 200) {
        if (isPdfEndpoint && response.data is List<int>) {
          // Handle PDF binary data
          return {'pdf': base64Encode(response.data), 'error': false};
        } else if (response.data is Map) {
          // Handle regular JSON response
          if (response.data['error'] == true) {
            String errorMessage =
                response.data['message'] ?? defaultErrorMessageKey;
            String details = '';

            // Add server details if available
            if (response.data['details'] != null) {
              details = ' | Server Details: ${response.data['details']}';
            }
            if (response.data['code'] != null) {
              details += ' | Error Code: ${response.data['code']}';
            }

            AppLogger.error('Api.get', 'Server returned error response', data: {
              'url': url,
              'errorMessage': errorMessage,
              'errorCode': response.data['code'],
              'serverDetails': response.data['details'],
              'fullResponse': response.data.toString(),
            });

            throw ApiException(errorMessage + details);
          }
          return Map<String, dynamic>.from(response.data);
        }
        // Log detailed information about unexpected response format
        AppLogger.error('Api.get', 'Invalid response format', data: {
          'url': url,
          'statusCode': response.statusCode,
          'expectedFormat': 'Map or PDF bytes',
          'actualType': response.data.runtimeType.toString(),
          'responseData': response.data.toString().length > 500
              ? response.data.toString().substring(0, 500) + '...<truncated>'
              : response.data.toString(),
          'isPdfEndpoint': isPdfEndpoint,
        });
        throw ApiException(
            "Invalid response format: expected Map but got ${response.data.runtimeType}");
      } else {
        throw ApiException(response.data['message'] ?? defaultErrorMessageKey);
      }
    } catch (e, st) {
      AppLogger.error('Api.get', 'Request failed',
          data: {
            'url': url,
            'query': queryParameters,
          },
          error: e,
          stack: st);
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
      print(e);
      throw ApiException(
          e.error is SocketException ? noInternetKey : defaultErrorMessageKey);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      print(e);
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
      AppLogger.debug('Api.delete', 'Request', data: {
        'url': url,
        'body': body,
        'query': queryParameters,
      });

      final Dio dio = Dio();
      final response = await dio.delete(
        url,
        data: body,
        queryParameters: queryParameters,
        options: Options(
          headers: headers(useAuthToken: useAuthToken ?? false),
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      AppLogger.debug('Api.delete', 'Response meta', data: {
        'statusCode': response.statusCode,
        'hasErrorKey':
            response.data is Map && (response.data as Map).containsKey('error'),
      });

      if (response.statusCode == 404) {
        throw ApiException(response.data['message'] ?? 'Exam not found');
      }

      if (response.data is Map) {
        return response.data;
      }

      throw ApiException('Invalid response format');
    } on DioException catch (e) {
      AppLogger.error('Api.delete', 'DioException',
          data: {
            'url': url,
            'statusCode': e.response?.statusCode,
            'response': e.response?.data,
          },
          error: e);
      if (e.response?.data is Map) {
        throw ApiException(
            e.response?.data['message'] ?? defaultErrorMessageKey);
      }
      throw ApiException(e.message ?? defaultErrorMessageKey);
    } catch (e) {
      AppLogger.error('Api.delete', 'Unknown exception',
          data: {'url': url}, error: e);
      throw ApiException(e.toString());
    }
  }

  static Future<Map<String, dynamic>> put({
    required Map<String, dynamic> body,
    required String url,
    bool? useAuthToken,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      if (kDebugMode || true) {
        AppLogger.debug('Api.put', 'Request', data: {
          'url': url,
          'body': body,
          'queryParameters': queryParameters,
        });
      }
      final Dio dio = Dio();

      // For PUT requests, send JSON data instead of FormData
      final response = await dio.put(url,
          data: body, // Send as JSON instead of FormData
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          options: Options(
            headers: {
              ...headers(useAuthToken: useAuthToken ?? true),
              'Content-Type':
                  'application/json', // Explicitly set content type to JSON
            },
          ));

      AppLogger.debug('Api.put', 'Response meta', data: {
        'statusCode': response.statusCode,
        'dataType': response.data.runtimeType.toString(),
      });

      if (response.data.containsKey('error') &&
          response.data['error'] == true) {
        throw ApiException(response.data['message'].toString());
      }

      return Map.from(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        AppLogger.error('Api.put', 'DioException',
            data: {
              'url': url,
              'statusCode': e.response?.statusCode,
              'response': e.response?.data,
            },
            error: e);
      }
      throw ApiException(
          e.error is SocketException ? noInternetKey : defaultErrorMessageKey);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Api.put', 'Unknown exception',
            data: {'url': url}, error: e);
      }
      throw ApiException(defaultErrorMessageKey);
    }
  }
}
