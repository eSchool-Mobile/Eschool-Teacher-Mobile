import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/teacherMyTimetableCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customErrorWidget.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/ui/widgets/timetableSlotContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

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

class _TeacherMyTimetableScreenState extends State<TeacherMyTimetableScreen>
    with TickerProviderStateMixin {
  late String _selectedDayKey = Utils.weekDays[DateTime.now().weekday - 1];

  // Animation controller for app bar effects
  late AnimationController _fabAnimationController;
  final ScrollController _scrollController = ScrollController();

  // Theme colors
  final Color _maroonPrimary = const Color(0xFF800020);

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scrollController.addListener(_scrollListener);

    Future.delayed(Duration.zero, () {
      if (mounted) {
        // Initially fetch with the selected day key
        context.read<TeacherMyTimetableCubit>().getTeacherMyTimetable(
              dayKey: _selectedDayKey,
            );
        context.read<ClassesCubit>().getAllClasses();
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.offset > 50) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Widget _buildDaySelector(BuildContext context) {
    List<Map<String, String>> weekDays = [
      {'key': 'monday', 'short': 'SEN', 'long': 'Senin'},
      {'key': 'tuesday', 'short': 'SEL', 'long': 'Selasa'},
      {'key': 'wednesday', 'short': 'RAB', 'long': 'Rabu'},
      {'key': 'thursday', 'short': 'KAM', 'long': 'Kamis'},
      {'key': 'friday', 'short': 'JUM', 'long': 'Jumat'},
      {'key': 'saturday', 'short': 'SAB', 'long': 'Sabtu'},
      {'key': 'sunday', 'short': 'MIN', 'long': 'Minggu'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: weekDays.map((day) {
            bool isSelected = _selectedDayKey == day['key'];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      _selectedDayKey = day['key']!;
                    });
                    context
                        .read<TeacherMyTimetableCubit>()
                        .getTeacherMyTimetable(
                            isRefresh: true, dayKey: day['key']!);
                  },
                  highlightColor: Colors.white.withOpacity(0.1),
                  splashColor: Colors.white.withOpacity(0.2),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? Colors.white.withOpacity(0.9)
                            : Colors.white.withOpacity(0.3),
                        width: isSelected ? 1 : 0.5,
                      ),
                    ),
                    child: Text(
                      day['short']!,
                      style: GoogleFonts.poppins(
                        color: isSelected ? _maroonPrimary : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            )
                .animate(
                  autoPlay: false,
                  target: isSelected ? 1 : 0,
                )
                .scale(
                  begin: Offset(1.0, 1.0),
                  end: Offset(1.05, 1.05),
                  curve: Curves.easeOutCubic,
                  duration: Duration(milliseconds: 300),
                );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TeacherMyTimetableCubit>().state;
    print("Current state: $state");
    if (state is TeacherMyTimetableFetchSuccess) {
      print("Total slots in state: ${state.timeTableSlots.length}");
      print("Selected day: $_selectedDayKey");
      print("Days in data: ${state.timeTableSlots.map((s) => s.day).toSet()}");
    }

    return Scaffold(
      appBar: CustomModernAppBar(
        title: Utils.getTranslatedLabel(myTimetableKey),
        icon: Icons.schedule_rounded,
        fabAnimationController: _fabAnimationController,
        primaryColor: _maroonPrimary,
        onBackPressed: () => Navigator.of(context).pop(),
        height: 140, // Increased height for tab content
        tabBuilder: _buildDaySelector,
      ),
      body: BlocBuilder<TeacherMyTimetableCubit, TeacherMyTimetableState>(
        builder: (context, state) {
          if (state is TeacherMyTimetableFetchSuccess) {
            // Display all returned slots without filtering by day
            // Since the API already returns the correct slots for the selected day
            final slots = state.timeTableSlots;

            print("Total slots: ${slots.length}");
            slots.forEach((slot) {
              print(
                  "Slot - Day: ${slot.day}, ID: ${slot.id}, ClassSectionId: ${slot.classSectionId}");
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
                controller: _scrollController,
                padding: EdgeInsets.only(bottom: 25, top: 25),
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
              child: CustomErrorWidget(
                message: state.errorMessage,
                onRetry: () {
                  context
                      .read<TeacherMyTimetableCubit>()
                      .getTeacherMyTimetable();
                },
                primaryColor: _maroonPrimary,
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
          return primaryClass.name ?? "";
        }

        // Then check in other classes
        final classSection = classState.classes.firstWhere(
          (element) => element.id == classSectionId,
          orElse: () => ClassSection(id: 0, name: "-", classId: 0),
        );

        print(
            "Found class section: ${classSection.name} for ID: $classSectionId");
        return classSection.name ?? "";
      } catch (e) {
        print("Error finding class section: $e");
        return "-";
      }
    }
    return "-";
  }
}
