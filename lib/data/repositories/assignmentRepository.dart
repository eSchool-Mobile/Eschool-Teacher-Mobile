import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/models/assignment.dart';
import 'package:eschool_saas_staff/data/models/assignmentFiletype.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class AssignmentRepository {
  Future<({List<Assignment> assignments, int currentPage, int totalPage})>
      fetchAssignment({
    required int classSectionId,
    required int classSubjectId,
    int? page,
  }) async {
    try {
      final result = await Api.get(
        url: Api.getAssignment,
        useAuthToken: true,
        queryParameters: {
          "class_section_id": classSectionId,
          "class_subject_id": classSubjectId,
          "page": page ?? 0,
        },
      );

      print("Dari API le");
      print(result);

      return (
        assignments: ((result['data']['data'] ?? []) as List)
            .map((e) => Assignment.fromJson(e))
            .toList(),
        currentPage: (result["data"]["current_page"] as int),
        totalPage: (result["data"]["last_page"] as int)
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> deleteAssignment({
    required int assignmentId,
  }) async {
    try {
      final body = {"assignment_id": assignmentId};

      await Api.post(
        url: Api.deleteAssignment,
        useAuthToken: true,
        body: body,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      throw ApiException(e.toString());
    }
  }

  Future<void> editAssignment({
    required int assignmentId,
    required int classSelectionId,
    required int classSubjectId,
    required String name,
    required String dateTime,
    required String startDate,
    required String endDate,
    required String description,
    required int points,
    required int minPoints,
    required int maxFile, // Add this line
    required int resubmission,
    required int extraDayForResubmission,
    List<PlatformFile>? filePaths,
    required List<String> acceptedFile,
  }) async {
    try {
      List<MultipartFile> files = [];
      for (var filePath in filePaths!) {
        files.add(await MultipartFile.fromFile(filePath.path!));
      }

      var body = {
        "class_section_id": classSelectionId,
        "assignment_id": assignmentId,
        "class_subject_id": classSubjectId,
        "name": name,
        "description": description,
        "due_date": dateTime,
        "start_date": startDate,
        "end_date": endDate,
        "points": points,
        "min_points": minPoints,
        "max_file": maxFile, // Add this line
        "resubmission": resubmission,
        "extra_days_for_resubmission": extraDayForResubmission,
        "file": files,
        "accepted_file": acceptedFile,
        "text": "text",
      };
      if (description.isEmpty) {
        body.remove("description");
      }
      if (points == 0) {
        body.remove("points");
      }
      if (filePaths.isEmpty) {
        body.remove("file");
      }
      if (resubmission == 0) {
        body.remove("extra_days_for_resubmission");
      }
      await Api.post(
        body: body,
        url: Api.uploadAssignment,
        useAuthToken: true,
      );
    } catch (e) {
      ApiException(e.toString());
    }
  }

  Future<void> createAssignment({
    required int classSectionId,
    required int classSubjectId,
    required String name,
    required String description,
    required String dateTime,
    required String startDate,
    required String endDate,
    required int points,
    required int minPoints,
    required int maxFile,
    required bool resubmission,
    required int extraDayForResubmission,
    required List<PlatformFile>? filePaths,
    required List<String> acceptedFile,
    required String text,
  }) async {
    try {
      List<MultipartFile> files = [];
      for (var filePath in filePaths!) {
        files.add(await MultipartFile.fromFile(filePath.path!));
      }

      // Create base body
      var bodyMap = {
        "class_section_id": classSectionId,
        "class_subject_id": classSubjectId,
        "name": name,
        "description": description,
        "due_date": dateTime,
        "start_date": startDate,
        "end_date": endDate,
        "points": points,
        "min_points": minPoints,
        "max_file": maxFile,
        "resubmission": resubmission ? 1 : 0,
        "extra_days_for_resubmission": extraDayForResubmission,
        "file": files,
        "text": text, // Pass the text value directly
      };

      // Add accepted file types in array format
      for (int i = 0; i < acceptedFile.length; i++) {
        bodyMap["accepted_file[$i]"] = acceptedFile[i];
      }

      // Remove optional fields if empty
      if (description.isEmpty) {
        bodyMap.remove("description");
      }
      if (points == 0) {
        bodyMap.remove("points");
      }
      if (files.isEmpty) {
        bodyMap.remove("file");
      }
      if (!resubmission) {
        bodyMap.remove("extra_days_for_resubmission");
      }

      // Convert to FormData
      final formData = FormData.fromMap(bodyMap);

      await Api.post(
        url: Api.createAssignment,
        body: formData.fields.fold<Map<String, dynamic>>({}, (map, field) {
          map[field.key] = field.value;
          return map;
        }),
        useAuthToken: true,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<AssignmentFileType>> fetchAssignmentFileTypes() async {
    try {
      final result = await Api.get(
        url: Api.getAssignmentFileTypes,
        useAuthToken: true,
      );

      return (result['data'] as List)
          .map((e) => AssignmentFileType.fromJson(e))
          .toList();
    } catch (e) {
      print('Repository error: $e');
      throw ApiException(e.toString());
    }
  }
}
