import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/teacherMyTimetableCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/timetableSlotContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/weekdaysContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherMyTimetableScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    return const TeacherMyTimetableScreen();
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const TeacherMyTimetableScreen({super.key});

  @override
  State<TeacherMyTimetableScreen> createState() =>
      _TeacherMyTimetableScreenState();
}

class _TeacherMyTimetableScreenState extends State<TeacherMyTimetableScreen> {
  late String _selectedDayKey = Utils.weekDays[DateTime.now().weekday - 1];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<TeacherMyTimetableCubit>().getTeacherMyTimetable();
        context.read<ClassesCubit>().getAllClasses();
      }
    });
  }

  Widget _buildDaysContainer() {
    return WeekdaysContainer(
      selectedDayKey: _selectedDayKey,
      onSelectionChange: (String newSelection) {
        setState(() {
          _selectedDayKey = newSelection;
        });
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<TeacherMyTimetableCubit, TeacherMyTimetableState>(
            builder: (context, state) {
              if (state is TeacherMyTimetableFetchSuccess) {
                final slots = state.timeTableSlots
                    .where((element) =>
                        element.day ==
                        weekDays[Utils.weekDays.indexOf(_selectedDayKey)])
                    .toList();

                print("Total slots: ${slots.length}");
                slots.forEach((slot) {
                  print(
                      "Slot - ID: ${slot.id}, ClassSectionId: ${slot.classSectionId}");
                });

                if (slots.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: CustomTextContainer(
                        textKey: Utils.getTranslatedLabel(noTimeTableKey),
                      ),
                    ),
                  );
                }
                return Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                        bottom: 25,
                        top:
                            Utils.appContentTopScrollPadding(context: context) +
                                110),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(appContentHorizontalPadding),
                      color: Theme.of(context).colorScheme.surface,
                      child: Column(
                        children: slots
                            .map((timeTableSlot) => TimetableSlotContainer(
                                  note: timeTableSlot.note ?? "",
                                  endTime: timeTableSlot.endTime ?? "",
                                  isForClass: false,
                                  classSectionName: getClassSectionName(
                                      timeTableSlot.classSectionId),
                                  startTime: timeTableSlot.startTime ?? "",
                                  subjectName: timeTableSlot.subject
                                          ?.getSybjectNameWithType() ??
                                      "-",
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                );
              }

              if (state is TeacherMyTimetableFetchFailure) {
                return Center(
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      context
                          .read<TeacherMyTimetableCubit>()
                          .getTeacherMyTimetable();
                    },
                  ),
                );
              }

              return Center(
                child: CustomCircularProgressIndicator(
                  indicatorColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                const CustomAppbar(titleKey: myTimetableKey),
                _buildDaysContainer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
