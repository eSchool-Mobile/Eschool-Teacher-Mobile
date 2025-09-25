
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/utils/hiveBoxKeys.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthRepository {
  Future<void> signOutUser() async {
    logout();
    setIsLogIn(false);
    setUserDetails(UserDetails());
    setAuthToken("");
    setSchoolsData([]);
    schoolCode = "";
  }

  static String getAuthToken() {
    return Hive.box(authBoxKey).get(authTokenKey) ?? "";
  }

  Future<void> setAuthToken(String value) async {
    return Hive.box(authBoxKey).put(authTokenKey, value);
  }

  String get schoolCode => Hive.box(authBoxKey).get('schoolCode') ?? "";

  set schoolCode(String value) => Hive.box(authBoxKey).put('schoolCode', value);

  static bool getIsLogIn() {
    return Hive.box(authBoxKey).get(isLogInKey) ?? false;
  }

  Future<void> setIsLogIn(bool value) async {
    return Hive.box(authBoxKey).put(isLogInKey, value);
  }

  static UserDetails getUserDetails() {
    return UserDetails.fromJson(
        Map.from(Hive.box(authBoxKey).get(userDetailsKey) ?? {}));
  }

  Future<void> setUserDetails(UserDetails value) async {
    return Hive.box(authBoxKey).put(userDetailsKey, value.toJson());
  }

  Future<List<Map<String, dynamic>>> getSchoolsData() async {
    print('DEBUG: getSchoolsData called');
    final schoolsData = Hive.box(authBoxKey).get(schoolsDataKey);
    print('DEBUG: Raw schoolsData from Hive: $schoolsData');
    print('DEBUG: schoolsData type: ${schoolsData.runtimeType}');

    if (schoolsData == null) {
      print('DEBUG: schoolsData is null, returning empty list');
      return [];
    }

    final result = List<Map<String, dynamic>>.from(schoolsData);
    print('DEBUG: Converted schoolsData: $result');
    print('DEBUG: Result length: ${result.length}');
    return result;
  }

  Future<void> setSchoolsData(List<Map<String, dynamic>> schools) async {
    print('DEBUG: setSchoolsData called with: $schools');
    print('DEBUG: schools length: ${schools.length}');
    final result = await Hive.box(authBoxKey).put(schoolsDataKey, schools);
    print('DEBUG: Schools data stored in Hive');

    // Verify storage immediately
    final stored = await getSchoolsData();
    print('DEBUG: Verification - stored schools: $stored');
    print('DEBUG: Verification - stored schools length: ${stored.length}');

    return result;
  }

  Future<String> getFcmToken() async {
    try {
      return (await FirebaseMessaging.instance.getToken()) ?? "";
    } catch (e) {
      return "";
    }
  }

  Future<
      ({
        UserDetails userDetails,
        String token,
        Map<String, dynamic> responseJson
      })> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final result = await Api.post(body: {
        "email": email,
        "password": password,
        "fcm_id": await getFcmToken(),
      }, url: Api.login, useAuthToken: false);

      JsonEncoder.withIndent('  ').convert(result).split('\n').forEach(print);

      return (
        token: (result['token'] ?? "").toString(),
        userDetails: UserDetails.fromJson(Map.from(result['data'] ?? {})),
        responseJson: Map<String, dynamic>.from(result),
      );
    } on ApiException catch (e) {
      throw ApiException(e.toString());
    } catch (e) {
      print(e);
      throw ApiException(defaultErrorMessageKey);
    }
  }

  Future<void> logout() async {
    try {
      await Api.post(
        body: {},
        url: Api.logout,
        useAuthToken: true,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await Api.post(
          url: Api.passwordResetEmail,
          useAuthToken: false,
          body: {"email": email});
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<String> changePassword(
      {required String oldPassword,
      required String newPassword,
      required String confirmPassword}) async {
    try {
      final result =
          await Api.post(url: Api.changepassword, useAuthToken: true, body: {
        "current_password": oldPassword,
        "new_password": newPassword,
        "new_confirm_password": confirmPassword
      });
      return (result['message'] ?? "").toString();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<({UserDetails userDetails, String successmessage})> editProfile(
      {required String firstName,
      required String lastName,
      required String mobileNumber,
      required String email,
      required String dateOfBirth,
      required String currentAddress,
      required String permanentAddress,
      required String gender,
      String? image}) async {
    try {
      if (kDebugMode) {
        print(image);
      }
      final result = await Api.post(body: {
        "first_name": firstName,
        "last_name": lastName,
        "mobile": mobileNumber,
        "email": email,
        "dob": dateOfBirth,
        "current_address": currentAddress.isEmpty ? "-" : currentAddress,
        "permanent_address": permanentAddress.isEmpty ? "-" : permanentAddress,
        "gender": gender,
        "image":
            (image ?? "").isEmpty ? null : await MultipartFile.fromFile(image!),
      }, useAuthToken: true, url: Api.editProfile);

      if (kDebugMode) {
        print(result['data']);
      }
      return (
        successmessage: (result['message'] ?? "").toString(),
        userDetails: UserDetails.fromJson(Map.from(result['data'] ?? {})),
      );
    } on ApiException catch (e) {
      throw ApiException(e.toString());
    } catch (e) {
      throw ApiException(defaultErrorMessageKey);
    }
  }

  /*


 

  Future<void> setNewPassword(
      {required String email, required String password}) async {
    try {
      await Api.post(
          body: {"email": email, "new_password": password},
          url: Api.setNewPassword,
          useAuthToken: false);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> changePassword(
      {required String currentPassword,
      required String newPassword,
      required String newConfirmPassword}) async {
    try {
      await Api.post(body: {
        "current_password": currentPassword,
        "new_password": newPassword,
        "new_confirm_password": newConfirmPassword,
      }, url: Api.setNewPassword, useAuthToken: true);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

 

 

  */
}
