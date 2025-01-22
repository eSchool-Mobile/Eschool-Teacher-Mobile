import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/menusWithTitleContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customMenuTile.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TeacherAcademicsContainer extends StatefulWidget {
  const TeacherAcademicsContainer({super.key});

  @override
  State<TeacherAcademicsContainer> createState() =>
      _TeacherAcademicsContainerState();
}

class _TeacherAcademicsContainerState extends State<TeacherAcademicsContainer> {
  @override
  void initState() {
    super.initState();
    // Load class data when widget initializes
    context.read<ClassesCubit>().getClasses();
  }

  @override
  Widget build(BuildContext context) {
    final StaffAllowedPermissionsAndModulesCubit
        staffAllowedPermissionsAndModulesCubit =
        context.read<StaffAllowedPermissionsAndModulesCubit>();

    return BlocBuilder<ClassesCubit, ClassesState>(
      builder: (context, classState) {
        print("ClassState: $classState");

        // Debug data yang diterima
        if (classState is ClassesFetchSuccess) {
          print(
              "Primary Classes: ${classState.primaryClasses.map((e) => e.name).toList()}");
          print(
              "Other Classes: ${classState.classes.map((e) => e.name).toList()}");
        }

        final isWalas = classState is ClassesFetchSuccess &&
            classState.primaryClasses.isNotEmpty;

        print("Is Wali Kelas: $isWalas");
        return Column(
          children: [
            MenusWithTitleContainer(title: timetableKey, menus: [
              if (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                  moduleId: timetableManagementModuleId.toString()))
                CustomMenuTile(
                    iconImageName: "timetable.svg",
                    titleKey: myTimetableKey,
                    onTap: () {
                      Get.toNamed(Routes.teacherMyTimetableScreen);
                    }),
              if (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                      moduleId: timetableManagementModuleId.toString()) &&
                  isWalas) ...[
                CustomMenuTile(
                    iconImageName: "class_section.svg",
                    titleKey: classSectionKey,
                    onTap: () {
                      Get.toNamed(Routes.teacherClassSectionScreen);
                    }),
              ]
            ]),
            if (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                    moduleId: attendanceManagementModuleId.toString()) &&
                isWalas) ...[
              MenusWithTitleContainer(title: attendanceKey, menus: [
                CustomMenuTile(
                    iconImageName: "add_attendance.svg",
                    titleKey: addAttendanceKey,
                    onTap: () {
                      Get.toNamed(Routes.teacherAddAttendanceScreen);
                    }),
                CustomMenuTile(
                    iconImageName: "view_attendance.svg",
                    titleKey: viewAttendanceKey,
                    onTap: () {
                      Get.toNamed(Routes.teacherViewAttendanceScreen);
                    }),
                CustomMenuTile(
                    iconImageName: "view_attendance_subject.svg",
                    titleKey: viewAttendanceSubjectKey,
                    onTap: () {
                      Get.toNamed(Routes.teacherViewAttendanceSubjectScreen);
                    }),
                CustomMenuTile(
                    iconImageName: "recap_attendance.svg",
                    titleKey: recapAttendanceSubjectKey,
                    onTap: () {
                      Get.toNamed(Routes.recapAttendanceSubjectScreen);
                    }),
                CustomMenuTile(
                    iconImageName: "ranking_absent.svg",
                    titleKey: rankingAbsentKey,
                    onTap: () {
                      Get.toNamed(Routes.attendanceRankingScreen);
                    }),
              ]),
            ],
            if (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                moduleId: lessonManagementModuleId.toString()))
              MenusWithTitleContainer(title: subjectLessonKey, menus: [
                CustomMenuTile(
                    iconImageName: "manage_lesson.svg",
                    titleKey: manageLessonKey,
                    onTap: () {
                      Get.toNamed(Routes.teacherManageLessonScreen);
                    }),
                CustomMenuTile(
                    iconImageName: "manage_topic.svg",
                    titleKey: manageTopicKey,
                    onTap: () {
                      Get.toNamed(Routes.teacherManageTopicScreen);
                    }),
                CustomMenuTile(
                    iconImageName: "question_bank.svg",
                    titleKey: "Question Bank",
                    onTap: () {
                      print("Navigating to Question Bank"); // Add debug print
                      Get.toNamed(Routes.questionBankScreen);
                    }),
              ]),
            if (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                moduleId: assignmentManagementModuleId.toString()))
              MenusWithTitleContainer(title: studentAssignmentKey, menus: [
                CustomMenuTile(
                    iconImageName: "manage_assignment.svg",
                    titleKey: manageAssignmentKey,
                    onTap: () {
                      Get.toNamed(Routes.teacherManageAssignmentScreen);
                    }),
              ]),
            if (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                moduleId: announcementManagementModuleId.toString()))
              MenusWithTitleContainer(title: messageKey, menus: [
                CustomMenuTile(
                    iconImageName: "announcement.svg",
                    titleKey: manageAnnouncementKey,
                    onTap: () {
                      Get.toNamed(Routes.teacherManageAnnouncementScreen);
                    }),
              ]),
            if (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                moduleId: examManagementModuleId.toString()))
              MenusWithTitleContainer(title: offlineExamKey, menus: [
                CustomMenuTile(
                    iconImageName: "exam.svg",
                    titleKey: examsKey,
                    onTap: () {
                      Get.toNamed(Routes.examsScreen);
                    }),
                CustomMenuTile(
                    iconImageName: "result.svg",
                    titleKey: examResultKey,
                    onTap: () {
                      Get.toNamed(Routes.teacherExamResultScreen);
                    }),
              ]),
          ],
        );
      },
    );
  }
}
