import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/models/academic/studyMaterial.dart';
import 'package:eschool_saas_staff/utils/system/api.dart';
import 'package:eschool_saas_staff/utils/system/constants.dart';
import 'package:flutter/foundation.dart';

class StudyMaterialRepository {
  Future<void> deleteStudyMaterial({required int fileId}) async {
    try {
      await Api.post(
        body: {
          "file_id": fileId,
        },
        url: Api.deleteStudyMaterial,
        useAuthToken: true,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<StudyMaterial> updateStudyMaterial({
    required int fileId,
    required Map<String, dynamic> fileDetails,
  }) async {
    try {
      Map<String, dynamic> body = {
        "file_id": fileId,
      };
      body.addAll(fileDetails);

      final result = await Api.post(
        body: body,
        url: Api.updateStudyMaterial,
        useAuthToken: true,
      );

      return StudyMaterial.fromJson(Map.from(result['data']));
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> downloadStudyMaterialFile({
    required String url,
    required String savePath,
    required CancelToken cancelToken,
    required Function updateDownloadedPercentage,
  }) async {
    try {

      final regex = RegExp(r'https?:\/\/[^\/]+\/storage\/\/storage\/');
      if (regex.hasMatch(url)) {
        url = storageUrl + url.replaceFirst(regex, '');
      }


      await Api.download(
        cancelToken: cancelToken,
        url: url,
        savePath: savePath,
        updateDownloadedPercentage: updateDownloadedPercentage,
      );
      debugPrint("OK GA ERROR");
    } catch (e) {
      debugPrint("OK ERROR");
      debugPrint(e.toString());
      throw ApiException(e.toString());
    }
  }
}
