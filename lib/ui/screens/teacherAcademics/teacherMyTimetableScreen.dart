import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/teacherMyTimetableCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/timetableSlotContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

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
  final Color _maroonLight = const Color(0xFFAA6976);

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

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: MediaQuery.of(context).padding.top +
            150, // Adjusted height for app bar with filters
        child: Stack(
          children: [
            // Gradient background with animated shader
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _fabAnimationController,
                builder: (context, _) {
                  return ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF690013),
                          _maroonPrimary,
                          Color(0xFFA12948),
                          _maroonLight,
                        ],
                        stops: [0.0, 0.3, 0.6, 1.0],
                        transform: GradientRotation(
                            _fabAnimationController.value * 0.02),
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF800020),
                            Color(0xFF9A1E3C),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Decorative elements
            Positioned.fill(
              child: CustomPaint(
                painter: AppBarDecorationPainter(
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),

            // Animated decorative circle
            AnimatedBuilder(
              animation: _fabAnimationController,
              builder: (context, _) {
                return Positioned(
                  top: -100 + (_fabAnimationController.value * 20),
                  right: -60 + (_fabAnimationController.value * 10),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.0),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),

            // App bar with blur effect - Title
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Back button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              highlightColor: Colors.white.withOpacity(0.1),
                              splashColor: Colors.white.withOpacity(0.2),
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Separator
                        Container(
                          height: 24,
                          width: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.4),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),

                        // Title
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Animated icon
                                    AnimatedBuilder(
                                      animation: _fabAnimationController,
                                      builder: (context, child) {
                                        return Transform.rotate(
                                          angle: _fabAnimationController.value *
                                              0.05,
                                          child: Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.white.withOpacity(0.9),
                                                  Colors.white.withOpacity(0.4),
                                                ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.schedule_rounded,
                                              color: _maroonPrimary,
                                              size: 20,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(width: 12),
                                    // Title text with gradient
                                    ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white,
                                            Colors.white.withOpacity(0.9),
                                          ],
                                        ).createShader(bounds);
                                      },
                                      blendMode: BlendMode.srcIn,
                                      child: Text(
                                        Utils.getTranslatedLabel(
                                            myTimetableKey),
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 1),
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Horizontal day selector with elegant design
            Positioned(
              bottom: 10,
              left: 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildHorizontalDaySelector(),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 200.ms)
                .slideY(begin: -0.2, end: 0, curve: Curves.easeOutQuad),
          ],
        ),
      ),
    );
  }

  // New horizontal day selector
  Widget _buildHorizontalDaySelector() {
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
    final state = context.watch<TeacherMyTimetableCubit>().state;
    print("Current state: $state");
    if (state is TeacherMyTimetableFetchSuccess) {
      print("Total slots in state: ${state.timeTableSlots.length}");
      print("Selected day: $_selectedDayKey");
      print("Days in data: ${state.timeTableSlots.map((s) => s.day).toSet()}");
    }

    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<TeacherMyTimetableCubit, TeacherMyTimetableState>(
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
          _buildAppBar(),
        ],
      ),
    );
  }
}

// Custom painter for decorative elements
class AppBarDecorationPainter extends CustomPainter {
  final Color color;

  AppBarDecorationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.2), 30, paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), 20, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.15), 15, paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), 10, paint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.4), 8, paint);

    // Draw arc
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final arcRect = Rect.fromLTRB(size.width * 0.1, size.height * 0.2,
        size.width * 0.6, size.height * 0.6);
    canvas.drawArc(arcRect, 0.2, 1.5, false, arcPaint);

    // Draw another arc
    final arcRect2 = Rect.fromLTRB(size.width * 0.5, size.height * 0.4,
        size.width * 0.9, size.height * 0.8);
    canvas.drawArc(arcRect2, 3, 1.5, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
