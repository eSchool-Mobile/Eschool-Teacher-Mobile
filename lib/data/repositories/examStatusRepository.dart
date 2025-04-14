import 'package:eschool_saas_staff/data/models/studentExamStatus.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class ExamStatusRepository {
  Future<StudentExamStatusResponse> getStudentExamStatus(int examId) async {
    try {
      final result = await Api.get(
        url: Api.getOnlineExamStatus,
        queryParameters: {
          'online_exam_id': examId,
        },
      );

      return StudentExamStatusResponse.fromJson(result);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Add new method to delete student exam status
  Future<Map<String, dynamic>> deleteStudentExamStatus(
      int examId, int studentId) async {
    try {
      final result = await Api.delete(
        url: Api.resetOnlineExamStatus,
        body: {
          'online_exam_id': examId,
          'student_id': studentId,
        },
        useAuthToken: true,
      );

      return result;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
