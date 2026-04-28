import 'dart:convert';

import 'package:eschool_saas_staff/data/models/academic/assignmentSubmission.dart';
import 'package:eschool_saas_staff/utils/system/api.dart';
import 'package:flutter/foundation.dart';

class AssignmentSubmissionsRepository {
  Future<List<AssignmentSubmission>> fetchAssignmentSubmissions({
    required int assignmentId,
  }) async {
    try {
      final body = {
        "assignment_id": assignmentId,
      };
      final result = await Api.get(
        url: Api.getReviewAssignment,
        useAuthToken: true,
        queryParameters: body,
      );

      debugPrint(body.toString());

      for (var line
          in const JsonEncoder.withIndent("  ").convert(result).split("\n")) {
        debugPrint(line.toString());
      }

      return (result['data'] as List)
          .map(
            (reviewAssignment) =>
                AssignmentSubmission.fromJson(Map.from(reviewAssignment)),
          )
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      throw ApiException(e.toString());
    }
  }

  Future<void> updateAssignmentSubmission({
    required int assignmentSubmissionId,
    required int assignmentSubmissionStatus,
    required int assignmentSubmissionPoints,
    required String assignmentSubmissionFeedBack,
  }) async {
    try {
      final body = {
        "assignment_submission_id": assignmentSubmissionId,
        "status": assignmentSubmissionStatus,
        "points": assignmentSubmissionPoints,
        "feedback": assignmentSubmissionFeedBack,
      };
      if (assignmentSubmissionFeedBack.isEmpty) {
        body.remove("feedback");
      }
      await Api.post(
        body: body,
        url: Api.updateReviewAssignment,
        useAuthToken: true,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
