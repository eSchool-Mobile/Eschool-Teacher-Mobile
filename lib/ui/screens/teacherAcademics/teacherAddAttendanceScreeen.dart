import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/studentsByClassSectionCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/attendence/attendanceCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/attendence/submitAttendanceCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/studentAttendance.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/holidayAttendanceContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customErrorWidget.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/studentAttendanceContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class TeacherAddAttendanceScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SubmitAttendanceCubit(),
        ),
        BlocProvider(
          create: (context) => AttendanceCubit(),
        ),
        BlocProvider(create: (context) => StudentsByClassSectionCubit()),
        BlocProvider(
          create: (context) => ClassesCubit(),
        ),
      ],
      child: const TeacherAddAttendanceScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const TeacherAddAttendanceScreen({super.key});

  @override
  State<TeacherAddAttendanceScreen> createState() =>
      _TeacherAddAttendanceScreenState();
}

class _TeacherAddAttendanceScreenState extends State<TeacherAddAttendanceScreen>
    with TickerProviderStateMixin {
  List<({StudentAttendanceStatus status, int studentId})> attendanceReport = [];

  DateTime _selectedDateTime = DateTime.now();
  ClassSection? _selectedClassSection;

  bool _isSendNotificationToGuardian = false;
  bool _isHoliday = false;

  // Color scheme for maroon theme matching subject screen
  final Color _maroonPrimary = const Color(0xFF800020);
  final Color _maroonLight = const Color(0xFFAA6976);

  // Animation controllers
  late AnimationController _fabAnimationController;
  late final ScrollController _scrollController = ScrollController()
    ..addListener(scrollListener);

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    _fabAnimationController.dispose();

    super.dispose();
  }

  void scrollListener() {
    // Animate elements based on scroll
    if (_scrollController.offset > 50) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fabAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    Future.delayed(Duration.zero, () {
      if (mounted) {
        // Load classes first
        context.read<ClassesCubit>().getClasses();

        // Listen to ClassesCubit state changes to automatically select a class when loaded
        context.read<ClassesCubit>().stream.listen((state) {
          if (state is ClassesFetchSuccess && _selectedClassSection == null) {
            if (state.primaryClasses.isNotEmpty) {
              print(
                  "Auto-selecting first class: ${state.primaryClasses.first.fullName}");
              changeClassSectionSelection(state.primaryClasses.first);
            } else if (state.primaryClasses.isNotEmpty) {
              print(
                  "Auto-selecting first available class: ${state.primaryClasses.first.fullName}");
              changeClassSectionSelection(state.primaryClasses.first);
            }
          }
        });

        // Listen to StudentsByClassSectionCubit state changes for debugging
        context.read<StudentsByClassSectionCubit>().stream.listen((state) {
          if (state is StudentsByClassSectionFetchSuccess) {
            print(
                "✅ Students loaded successfully: ${state.studentDetailsList.length} students");
          } else if (state is StudentsByClassSectionFetchFailure) {
            print("❌ Failed to load students: ${state.errorMessage}");
          } else if (state is StudentsByClassSectionFetchInProgress) {
            print("⌛ Loading students...");
          }
        });
      }
    });
  }

  void getAttendance() {
    context
        .read<AttendanceCubit>()
        .fetchAttendance(
          date: _selectedDateTime,
          classSectionId: _selectedClassSection?.id ?? 0,
          type: null,
        )
        .catchError((error) {
      print('Error: $error');
    });
  }

  void getStudentList() {
    attendanceReport.clear();
    context.read<StudentsByClassSectionCubit>().fetchStudents(
          status:
              StudentListStatus.all, // Tampilkan semua siswa termasuk non-aktif
          classSectionId: _selectedClassSection?.id ?? 0,
        );
  }

  void changeClassSectionSelection(ClassSection? newSelectedClassSection) {
    _selectedClassSection = newSelectedClassSection;

    setState(() {});
    if (newSelectedClassSection != null) {
      getAttendance();
      getStudentList();
    }
  }

  Widget _buildStudents({required List<StudentAttendance> attendance}) {
    return BlocBuilder<StudentsByClassSectionCubit,
        StudentsByClassSectionState>(
      builder: (BuildContext context, StudentsByClassSectionState state) {
        if (state is StudentsByClassSectionFetchSuccess) {
          if (state.studentDetailsList.isEmpty) {
            return const SizedBox.shrink();
          }
          if (_isHoliday) {
            return const SizedBox.shrink();
          }
          return StudentAttendanceContainer(
            studentAttendances: state.studentDetailsList.map((e) {
              final matchedAttendance = attendance
                  .firstWhereOrNull((element) => element.studentId == e.id);

              print(matchedAttendance);

              print('Found attendance record: ${matchedAttendance?.type}');

              return StudentAttendance.fromStudentDetails(
                  studentDetails: e, type: matchedAttendance?.type);
            }).toList(),
            onStatusChanged: (attendanceStatuses) {
              attendanceReport = attendanceStatuses;
            },
            isForAddAttendance: true,
          );
        } else if (state is StudentsByClassSectionFetchFailure) {
          return Center(
            child: Padding(
              padding:
                  EdgeInsets.only(top: topPaddingOfErrorAndLoadingContainer),
              child: CustomErrorWidget(
                message: state.errorMessage,
                onRetry: () {
                  getStudentList();
                },
                primaryColor: _maroonPrimary,
              ),
            ),
          );
        } else {
          return Center(
            child: Padding(
              padding:
                  EdgeInsets.only(top: topPaddingOfErrorAndLoadingContainer),
              child: CustomCircularProgressIndicator(
                indicatorColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildStudentsContainer() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 160, bottom: 90),
        child: BlocBuilder<AttendanceCubit, AttendanceState>(
          builder: (context, state) {
            if (state is AttendanceFetchSuccess) {
              if (state.isHoliday) {
                return HolidayAttendanceContainer(
                  holiday: state.holidayDetails,
                );
              }

              // Title and subtitle section
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and subtitle section
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kehadiran Siswa',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _maroonPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.1, end: 0, curve: Curves.easeOutQuad),

                  // Students attendance list
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // List header with modern design
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _maroonPrimary.withOpacity(0.9),
                                _maroonPrimary,
                                _maroonLight,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                            boxShadow: [
                              BoxShadow(
                                color: _maroonPrimary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Animated icon
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.people_alt_rounded,
                                  color: Colors.white,
                                  size: 20,
                                )
                                    .animate()
                                    .fadeIn(duration: 300.ms)
                                    .slideX(begin: -0.2, end: 0),
                              ),

                              const SizedBox(width: 16),

                              // Title text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daftar Kehadiran Siswa',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Student list
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: _buildStudents(attendance: state.attendance),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 200.ms)
                      .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad),
                ],
              );
            } else if (state is AttendanceFetchFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.2),
                  child: CustomErrorWidget(
                    message: state.errorMessage,
                    onRetry: () {
                      getAttendance();
                    },
                    primaryColor: _maroonPrimary,
                  ),
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                    CustomCircularProgressIndicator(
                      indicatorColor: _maroonPrimary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Memuat data kehadiran...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, state) {
        if (state is AttendanceFetchSuccess) {
          if (state.isHoliday) {
            // Hide button completely
            return const SizedBox();
          }
          return BlocConsumer<SubmitAttendanceCubit, SubmitAttendanceState>(
              listener: (context, submitAttendanceState) {
            if (submitAttendanceState is SubmitAttendanceSuccess) {
              CustomSuccessMessage.show(
                context: context,
                message: "Berhasil menyimpan Kehadiran!",
                backgroundColor: Colors.green,
                textColor: Colors.white,
              );

              // Optional: Add haptic feedback
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
            } else if (submitAttendanceState is SubmitAttendanceFailure) {
              Utils.showSnackBar(
                context: context,
                message: submitAttendanceState.errorMessage,
              );
            }
          }, builder: (context, submitAttendanceState) {
            // Always enable the submit button (removing the disabled state)
            final bool isSubmitActive = true;

            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.8),
                      Colors.white,
                      Colors.white,
                    ],
                    stops: [0.0, 0.2, 0.5, 1.0],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      // Always use the active button colors
                      colors: [
                        _maroonPrimary,
                        Color(0xFF9A1E3C),
                        _maroonLight,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    // Always show the shadow
                    boxShadow: [
                      BoxShadow(
                        color: _maroonPrimary.withOpacity(0.3),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      highlightColor: Colors.white.withOpacity(0.1),
                      splashColor: Colors.white.withOpacity(0.2),
                      onTap: () {
                        if (!isSubmitActive) {
                          return;
                        }

                        // Log detailed submission data
                        print('=== ATTENDANCE SUBMISSION DATA ===');
                        print(
                            '📅 Date: ${Utils.formatDate(_selectedDateTime)}');
                        print(
                            '🏫 Class: ${_selectedClassSection?.fullName} (ID: ${_selectedClassSection?.id})');
                        print(
                            '🔔 Send Notification: $_isSendNotificationToGuardian');
                        print('📅 Is Holiday: $_isHoliday');
                        print('👥 Attendance Report:');

                        for (var attendance in attendanceReport) {
                          String status = '';
                          switch (attendance.status) {
                            case StudentAttendanceStatus.present:
                              status = '✅ Present';
                              break;
                            case StudentAttendanceStatus.absent:
                              status = '❌ Absent';
                              break;
                            default:
                              status = '❓ Unknown';
                          }
                          print(
                              '   Student ID: ${attendance.studentId} - Status: $status');
                        }
                        print('================================');

                        try {
                          context
                              .read<SubmitAttendanceCubit>()
                              .submitAttendance(
                                isHoliday: _isHoliday,
                                sendAbsentNotification:
                                    _isSendNotificationToGuardian,
                                dateTime: _selectedDateTime,
                                classSectionId: _selectedClassSection?.id ?? 0,
                                attendanceReport:
                                    _isHoliday ? [] : attendanceReport,
                              );
                        } catch (e) {
                          print('Error submitting attendance: $e');
                          print('Error details: ${e.toString()}');
                        }
                      },
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            );
                          },
                          child: submitAttendanceState
                                  is SubmitAttendanceInProgress
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  key: ValueKey<String>("loading"),
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : Row(
                                  key: ValueKey<String>("button"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      Utils.getTranslatedLabel(submitKey),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    if (attendanceReport.isNotEmpty)
                                      Container(
                                        margin: EdgeInsets.only(left: 12),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          "${attendanceReport.length}",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 500.ms);
          });
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: MediaQuery.of(context).padding.top +
            150, // Increased height to accommodate filters
        child: Stack(
          children: [
            // Fancy gradient background with animated particles
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

            // Decorative design elements
            Positioned.fill(
              child: CustomPaint(
                painter: AppBarDecorationPainter(
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),

            // Animated glowing effect
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

            // Main app bar content with frosted glass effect - TOP ROW
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
                        // Back button with ripple effect
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

                        // Animated divider
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

                        // Title with animated badge
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Main title
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
                                              Icons.edit_calendar_rounded,
                                              color: _maroonPrimary,
                                              size: 20,
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    SizedBox(width: 12),

                                    // Title text with glowing effect
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
                                        'Kehadiran Khusus Siswa',
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
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

                        // Animated divider
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
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // BOTTOM ROW - Filters with frosted glass effect
            Positioned(
              bottom: 10,
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
                        // Date filter
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                final selectedDate = await Utils.openDatePicker(
                                  context: context,
                                  inititalDate: _selectedDateTime,
                                  lastDate: DateTime.now(),
                                  firstDate: DateTime.now()
                                      .subtract(const Duration(days: 30)),
                                );

                                if (selectedDate != null) {
                                  _selectedDateTime = selectedDate;
                                  setState(() {});
                                  getAttendance();
                                }
                              },
                              highlightColor: Colors.white.withOpacity(0.1),
                              splashColor: Colors.white.withOpacity(0.2),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        Utils.formatDate(_selectedDateTime),
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Vertical divider
                        Container(
                          height: 24,
                          width: 1.5,
                          margin: EdgeInsets.symmetric(horizontal: 8),
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

                        // Class selection filter
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                final state =
                                    context.read<ClassesCubit>().state;
                                if (state is ClassesFetchSuccess) {
                                  if (state.primaryClasses.isNotEmpty) {
                                    Utils.showBottomSheet(
                                      child: FilterSelectionBottomsheet<
                                          ClassSection>(
                                        onSelection: (value) {
                                          changeClassSectionSelection(value);
                                          Get.back();
                                        },
                                        selectedValue: _selectedClassSection ??
                                            state.primaryClasses.first,
                                        titleKey: classKey,
                                        values: state.primaryClasses,
                                      ),
                                      context: context,
                                    );
                                  }
                                }
                              },
                              highlightColor: Colors.white.withOpacity(0.1),
                              splashColor: Colors.white.withOpacity(0.2),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.class_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        _selectedClassSection?.fullName ??
                                            'Pilih Kelas',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: -0.2, end: 0, curve: Curves.easeOutQuad),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<ClassesCubit, ClassesState>(
            builder: (context, state) {
              if (state is ClassesFetchSuccess) {
                if (state.primaryClasses.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Stack(children: [
                  _buildStudentsContainer(),
                  _buildSubmitButton(),
                ]);
              }
              if (state is ClassesFetchFailure) {
                return Center(
                    child: CustomErrorWidget(
                  message: state.errorMessage,
                  onRetry: () {
                    context.read<ClassesCubit>().getClasses();
                  },
                  primaryColor: _maroonPrimary,
                ));
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

class SnackBarUtils {
  static void showSnackBar({
    required BuildContext context,
    required String message,
    Color backgroundColor = Colors.black87, // Default color
    Color textColor = Colors.white, // Default text color
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class CustomSuccessMessage {
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = Colors.green,
    Color textColor = Colors.white,
    VoidCallback? onDismiss,
  }) {
    // Add haptic feedback for better UX
    HapticFeedback.mediumImpact();

    // Create overlay entry
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 30,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: textColor, size: 24),
                  SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Add to overlay
    overlayState.insert(overlayEntry);

    // Remove after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
        if (onDismiss != null) {
          onDismiss();
        }
      }
    });
  }
}
