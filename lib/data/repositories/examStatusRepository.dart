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
}
