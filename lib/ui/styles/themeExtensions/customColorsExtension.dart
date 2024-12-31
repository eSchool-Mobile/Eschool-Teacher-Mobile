import 'package:flutter/material.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  final Color? successColor;
  final Color? redColor;
  final Color? leaveRequestOverviewBackgroundColor;
  final Color? totalTeacherOverviewBackgroundColor;
  final Color? totalStudentOverviewBackgroundColor;
  final Color? totalStaffOverviewBackgroundColor;
  final Color? sickBackgroundColor;
  final Color? permissionBackgroundColor;

  const CustomColors(
      {required this.redColor,
      required this.successColor,
      required this.leaveRequestOverviewBackgroundColor,
      required this.totalStaffOverviewBackgroundColor,
      required this.totalStudentOverviewBackgroundColor,
      required this.totalTeacherOverviewBackgroundColor,
      required this.sickBackgroundColor,
      required this.permissionBackgroundColor});
  @override
  ThemeExtension<CustomColors> copyWith(
      {Color? successColor,
      Color? redColor,
      Color? leaveRequestOverviewBackgroundColor,
      Color? totalTeacherOverviewBackgroundColor,
      Color? totalStudentOverviewBackgroundColor,
      Color? totalStaffOverviewBackgroundColor}) {
    return CustomColors(
      successColor: successColor ?? this.successColor,
      redColor: redColor ?? this.redColor,
      leaveRequestOverviewBackgroundColor:
          leaveRequestOverviewBackgroundColor ??
              this.leaveRequestOverviewBackgroundColor,
      totalStaffOverviewBackgroundColor: totalStaffOverviewBackgroundColor ??
          this.totalStaffOverviewBackgroundColor,
      totalStudentOverviewBackgroundColor:
          totalStudentOverviewBackgroundColor ??
              this.totalStudentOverviewBackgroundColor,
      totalTeacherOverviewBackgroundColor:
          totalTeacherOverviewBackgroundColor ??
              this.totalTeacherOverviewBackgroundColor,
      sickBackgroundColor: sickBackgroundColor ?? this.sickBackgroundColor,
      permissionBackgroundColor:
          permissionBackgroundColor ?? this.permissionBackgroundColor,
    );
  }

  @override
  ThemeExtension<CustomColors> lerp(
      ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      redColor: Color.lerp(redColor, other.redColor, t),
      leaveRequestOverviewBackgroundColor: Color.lerp(
          leaveRequestOverviewBackgroundColor,
          other.leaveRequestOverviewBackgroundColor,
          t),
      totalStaffOverviewBackgroundColor: Color.lerp(
          totalStaffOverviewBackgroundColor,
          other.totalStaffOverviewBackgroundColor,
          t),
      totalStudentOverviewBackgroundColor: Color.lerp(
          totalStudentOverviewBackgroundColor,
          other.totalStudentOverviewBackgroundColor,
          t),
      totalTeacherOverviewBackgroundColor: Color.lerp(
          totalTeacherOverviewBackgroundColor,
          other.totalTeacherOverviewBackgroundColor,
          t),
      successColor: Color.lerp(successColor, other.successColor, t),
      sickBackgroundColor:
          Color.lerp(sickBackgroundColor, other.sickBackgroundColor, t),
      permissionBackgroundColor: Color.lerp(
          permissionBackgroundColor, other.permissionBackgroundColor, t),
    );
  }
}
