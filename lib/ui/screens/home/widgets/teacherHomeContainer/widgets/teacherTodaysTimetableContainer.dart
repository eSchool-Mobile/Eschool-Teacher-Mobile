import 'dart:math';

import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/teacherMyTimetableCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/contentTitleWithViewmoreButton.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/teacherHomeContainer/widgets/roundedBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherAddAttendanceSubjectScreen.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/timetableSlotContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TeacherTodaysTimetableContainer extends StatefulWidget {
  const TeacherTodaysTimetableContainer({super.key});

  @override
  State<TeacherTodaysTimetableContainer> createState() =>
      _TeacherTodaysTimetableContainerState();
}

class _TeacherTodaysTimetableContainerState
    extends State<TeacherTodaysTimetableContainer>
    with TickerProviderStateMixin {
  final int itemsToShowWithoutExpansion = 2;
  int appearDisappearAnimationDurationMilliseconds = 600;

  final ValueNotifier<bool> _isExpanded = ValueNotifier(false);

  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _iconAngleAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      duration:
          Duration(milliseconds: appearDisappearAnimationDurationMilliseconds),
      vsync: this,
    );
    _iconAngleAnimation = Tween<double>(begin: 0, end: 180)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastLinearToSlowEaseIn,
    );
    super.initState();
  }

  @override
  void dispose() {
    _isExpanded.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleContainer() {
    if (_animation.status != AnimationStatus.completed) {
      _controller.forward();
      _isExpanded.value = true;
    } else {
      _controller.animateBack(
        0,
        duration: Duration(
            milliseconds: appearDisappearAnimationDurationMilliseconds),
        curve: Curves.fastLinearToSlowEaseIn,
      );
      _isExpanded.value = false;
    }
  }

  String getClassSectionName(int? classSectionId) {
    if (classSectionId == null) {
      print("ClassSectionId is null");
      return "-";
    }

    final classState = context.read<ClassesCubit>().state;
    print("ClassState: $classState");

    if (classState is ClassesFetchSuccess) {
      try {
        print("Checking class section ID: $classSectionId");
        print(
            "Primary classes: ${classState.primaryClasses.map((e) => '${e.name} (${e.id})')}");
        print(
            "Other classes: ${classState.classes.map((e) => '${e.name} (${e.id})')}");

        // Check in primary classes first
        final primaryClass = classState.primaryClasses.firstWhere(
          (element) => element.id == classSectionId,
          orElse: () => ClassSection(id: 0, name: "", classId: 0),
        );

        if (primaryClass.id != 0) {
          print("Found in primary classes: ${primaryClass.name}");
          return primaryClass?.name ?? "";
        }

        // Then check in other classes
        final classSection = classState.classes.firstWhere(
          (element) => element.id == classSectionId,
          orElse: () => ClassSection(id: 0, name: "-", classId: 0),
        );

        print(
            "Found class section: ${classSection.name} for ID: $classSectionId");
        return classSection?.name ?? "";
      } catch (e) {
        print("Error finding class section: $e");
        return "-";
      }
    }
    return "-";
  }

  bool isCurrentTimeWithinSlot(String startTime, String endTime) {
    DateTime now = DateTime.now();
    DateTime start = DateFormat('HH:mm:ss').parse(startTime);
    DateTime end = DateFormat('HH:mm:ss').parse(endTime);

    // Convert start and end times to today's date
    DateTime todayStart = DateTime(
        now.year, now.month, now.day, start.hour, start.minute, start.second);
    DateTime todayEnd = DateTime(
        now.year, now.month, now.day, end.hour, end.minute, end.second);

    print("Current time: $now");
    print("Slot start time: $todayStart");
    print("Slot end time: $todayEnd");

    return now.isAfter(todayStart) && now.isBefore(todayEnd);
  }

  bool isCurrentTimeBeforeSlot(String startTime) {
    DateTime now = DateTime.now();
    DateTime start = DateFormat('HH:mm:ss').parse(startTime);

    DateTime todayStart = DateTime(
        now.year, now.month, now.day, start.hour, start.minute, start.second);

    return now.isBefore(todayStart);
  }

  Widget _viewMoreViewLessContainer(
      {required bool isExpanded, required Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: SizedBox(
          width: double.maxFinite,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextContainer(
                textKey: isExpanded ? viewLessKey : viewMoreKey,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 10.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AnimatedBuilder(
                animation: _iconAngleAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: (pi * _iconAngleAnimation.value) / 180,
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String Datenow = DateFormat('HH:mm:ss').format(now);

    return BlocBuilder<TeacherMyTimetableCubit, TeacherMyTimetableState>(
      builder: (context, state) {
        if (state is TeacherMyTimetableFetchSuccess) {
          final slots = state.timeTableSlots.where((element) {
            bool isSameDay =
                element.day == weekDays[DateTime.now().weekday - 1];

            if (element.endTime != null) {
              DateTime endTime = DateFormat('HH:mm:ss').parse(element.endTime!);
              DateTime currentDateTime = DateFormat('HH:mm:ss').parse(Datenow);

              if (currentDateTime.isAfter(endTime)) {
                return false;
              }
            }
            return isSameDay;
          }).toList();

          if (slots.isEmpty) {
            return const SizedBox();
          }

          return Padding(
            padding: const EdgeInsets.only(top: 15),
            child: RoundedBackgroundContainer(
              child: Column(
                children: [
                  const ContentTitleWithViewMoreButton(
                      showViewMoreButton: false,
                      contentTitleKey: todaysTimetableKey),
                  const SizedBox(
                    height: 15,
                  ),
                  ...List.generate(
                    slots.length > itemsToShowWithoutExpansion
                        ? itemsToShowWithoutExpansion
                        : slots.length,
                    (index) {
                      final timeTableSlot = slots[index];
                      final isWithinSlot = isCurrentTimeWithinSlot(
                          timeTableSlot.startTime ?? "",
                          timeTableSlot.endTime ?? "");
                      final isBeforeSlot = isCurrentTimeBeforeSlot(
                          timeTableSlot.startTime ?? "");

                      // Update GestureDetector onTap
                      return GestureDetector(
                        onTap: isWithinSlot
                            ? () {
                                if (timeTableSlot.classSectionId != null) {
                                  final classState =
                                      context.read<ClassesCubit>().state;
                                  if (classState is ClassesFetchSuccess) {
                                    // Find class section from either primary or other classes
                                    final classSection = [
                                      ...classState.primaryClasses,
                                      ...classState.classes
                                    ].firstWhere(
                                      (element) =>
                                          element.id ==
                                          timeTableSlot.classSectionId,
                                      orElse: () => ClassSection(
                                          id: 0, name: "-", classId: 0),
                                    );

                                    print(
                                        "Found class section: ${classSection.name} (${classSection.id})");
                                    print("TimeTableSlot: ${timeTableSlot.id}");

                                    Get.toNamed(
                                      Routes.teacherAddAttendanceSubjectScreen,
                                      arguments:
                                          TeacherAddAttendanceSubjectScreen
                                              .buildArguments(
                                        classSection: classSection,
                                        timeTableSlot: timeTableSlot,
                                      ),
                                    );
                                  }
                                }
                              }
                            : () {
                                if (isBeforeSlot) {
                                  Utils.showSnackBar(
                                      message: "Belum masuk jam mengajar",
                                      context: context);
                                }
                              },
                        child: TimetableSlotContainer(
                          note: timeTableSlot.note ?? "",
                          endTime: timeTableSlot.endTime ?? "",
                          startTime: timeTableSlot.startTime ?? "",
                          subjectName: timeTableSlot.subject?.name ?? "-",
                          isForClass: false,
                          classSectionName:
                              getClassSectionName(timeTableSlot.classSectionId),
                          backgroundColor: isWithinSlot
                              ? Theme.of(context).scaffoldBackgroundColor
                              : Colors.grey[300],
                        ),
                      );
                    },
                  ),
                  if (slots.length > itemsToShowWithoutExpansion)
                    SizeTransition(
                      sizeFactor: _animation,
                      axis: Axis.vertical,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          ...List.generate(
                            slots.length > itemsToShowWithoutExpansion
                                ? slots.length - itemsToShowWithoutExpansion
                                : 0,
                            (index) {
                              final timeTableSlot =
                                  slots[index + itemsToShowWithoutExpansion];
                              final isWithinSlot = isCurrentTimeWithinSlot(
                                  timeTableSlot.startTime ?? "",
                                  timeTableSlot.endTime ?? "");
                              final isBeforeSlot = isCurrentTimeBeforeSlot(
                                  timeTableSlot.startTime ?? "");

                              return GestureDetector(
                                onTap: isWithinSlot
                                    ? () {
                                        Get.toNamed(Routes
                                            .teacherAddAttendanceSubjectScreen);
                                      }
                                    : () {
                                        if (isBeforeSlot) {
                                          Utils.showSnackBar(
                                              message:
                                                  "Belum masuk jam mengajar",
                                              context: context);
                                        }
                                      },
                                child: TimetableSlotContainer(
                                  note: timeTableSlot.note ?? "",
                                  endTime: timeTableSlot.endTime ?? "",
                                  isForClass: false,
                                  classSectionName:
                                      timeTableSlot.classSection?.fullName ??
                                          "-",
                                  startTime: timeTableSlot.startTime ?? "",
                                  subjectName:
                                      timeTableSlot.subject?.name ?? "-",
                                  backgroundColor: isBeforeSlot
                                      ? Theme.of(context)
                                          .scaffoldBackgroundColor
                                      : Colors.grey[300]!,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  if (slots.length > itemsToShowWithoutExpansion)
                    ValueListenableBuilder(
                      valueListenable: _isExpanded,
                      builder: (context, isExpanded, _) {
                        return _viewMoreViewLessContainer(
                            isExpanded: isExpanded,
                            onTap: () {
                              _toggleContainer();
                            });
                      },
                    ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
