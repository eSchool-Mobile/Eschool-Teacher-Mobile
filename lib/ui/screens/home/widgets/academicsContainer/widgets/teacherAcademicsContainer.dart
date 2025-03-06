import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/menusWithTitleContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customMenuTile.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

class TeacherAcademicsContainer extends StatefulWidget {
  const TeacherAcademicsContainer({super.key});

  @override
  State<TeacherAcademicsContainer> createState() =>
      _TeacherAcademicsContainerState();
}

class _TeacherAcademicsContainerState extends State<TeacherAcademicsContainer>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );

    _fadeController.forward();
    setState(() => _isInitialized = true);
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ClassesCubit>().getClasses();
      }
    });
  }

  // Add BackgroundPainter for consistent styling
  Widget _buildBackground() {
    return AnimatedPositioned(
      duration: Duration(seconds: 2),
      curve: Curves.easeInOut,
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height,
      child: AnimatedOpacity(
        duration: Duration(seconds: 1),
        opacity: 0.1,
        child: CustomPaint(
          painter: BackgroundPainter(
            color: AppColorPalette.primaryMaroon,
          ),
        ),
      ),
    );
  }

  // Updated modern menu container
  Widget _buildModernMenuContainer({
    required String title,
    required List<Widget> menus,
    required int index,
  }) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 475),
      child: SlideAnimation(
        horizontalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Card(
              elevation: 12,
              shadowColor: AppColorPalette.primaryMaroon.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColorPalette.primaryMaroon.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(title),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: menus.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: AppColorPalette.primaryMaroon.withOpacity(0.1),
                      ),
                      itemBuilder: (context, index) =>
                          _buildEnhancedMenuItem(menus[index]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Updated header card
  Widget _buildHeaderCard(String title) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorPalette.primaryMaroon,
            AppColorPalette.secondaryMaroon,
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForTitle(title),
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              _getIconForTitle(title),
              size: 80,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  // Updated menu item
  Widget _buildEnhancedMenuItem(Widget menuItem) {
    if (menuItem is CustomMenuTile) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticFeedback.lightImpact();
              menuItem.onTap?.call();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColorPalette.primaryMaroon.withOpacity(0.1),
                          AppColorPalette.secondaryMaroon.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      'assets/images/${menuItem.iconImageName}',
                      height: 24,
                      width: 24,
                      color: AppColorPalette.primaryMaroon,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      menuItem.titleKey.tr,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColorPalette.primaryMaroon.withOpacity(0.5),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return menuItem;
  }

  void _onTapDown() {
    if (_isInitialized && mounted) {
      HapticFeedback.mediumImpact();
      _scaleController.reverse();
    }
  }

  void _onTapUp() {
    if (_isInitialized && mounted) {
      _scaleController.forward();
    }
  }

  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'timetable':
        return Icons.schedule;
      case 'attendance':
        return Icons.people;
      case 'subject lesson':
        return Icons.book;
      case 'bank soal':
        return Icons.quiz;
      case 'student assignment':
        return Icons.assignment;
      case 'message':
        return Icons.message;
      case 'offline exam':
        return Icons.edit_note;
      case 'ujian online':
        return Icons.computer;
      default:
        return Icons.menu_book;
    }
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
        return AnimationLimiter(
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildModernMenuContainer(
                title: timetableKey,
                index: 0,
                menus: [
                  if (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                      moduleId: timetableManagementModuleId.toString()))
                    CustomMenuTile(
                      iconImageName: "timetable.svg",
                      titleKey: myTimetableKey,
                      onTap: () {
                        Get.toNamed(Routes.teacherMyTimetableScreen);
                      },
                    ),
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
                ],
              ),
              if (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                      moduleId: attendanceManagementModuleId.toString()) &&
                  isWalas) ...[
                _buildModernMenuContainer(
                  title: attendanceKey,
                  index: 1,
                  menus: [
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
                          Get.toNamed(
                              Routes.teacherViewAttendanceSubjectScreen);
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
                  ],
                ),
              ],
              if (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                  moduleId: lessonManagementModuleId.toString()))
                _buildModernMenuContainer(
                  title: subjectLessonKey,
                  index: 2,
                  menus: [
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
                  ],
                ),
              _buildModernMenuContainer(
                title: "Bank Soal",
                index: 3,
                menus: [
                  CustomMenuTile(
                      iconImageName: "question_bank.svg",
                      titleKey: "Bank Soal",
                      onTap: () {
                        Get.toNamed(Routes.questionSubjectScreen);
                      }),
                ],
              ),
              if (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                  moduleId: assignmentManagementModuleId.toString()))
                _buildModernMenuContainer(
                  title: studentAssignmentKey,
                  index: 4,
                  menus: [
                    CustomMenuTile(
                        iconImageName: "manage_assignment.svg",
                        titleKey: manageAssignmentKey,
                        onTap: () {
                          Get.toNamed(Routes.teacherManageAssignmentScreen);
                        }),
                  ],
                ),
              if (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                  moduleId: announcementManagementModuleId.toString()))
                _buildModernMenuContainer(
                  title: messageKey,
                  index: 5,
                  menus: [
                    CustomMenuTile(
                        iconImageName: "announcement.svg",
                        titleKey: manageAnnouncementKey,
                        onTap: () {
                          Get.toNamed(Routes.teacherManageAnnouncementScreen);
                        }),
                  ],
                ),
              if (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                  moduleId: examManagementModuleId.toString()))
                _buildModernMenuContainer(
                  title: offlineExamKey,
                  index: 6,
                  menus: [
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
                  ],
                ),
              _buildModernMenuContainer(
                title: "Ujian Online",
                index: 7,
                menus: [
                  CustomMenuTile(
                      iconImageName: "online_exam.svg",
                      titleKey: "Ujian Online",
                      onTap: () {
                        Get.toNamed(Routes.onlineExamScreen);
                      }),
                  if (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                      moduleId: assignmentManagementModuleId.toString()))
                    CustomMenuTile(
                        iconImageName: "online_exam.svg",
                        titleKey: "Hasil Ujian Online",
                        onTap: () {
                          Get.toNamed(Routes.onlineExamResultScreen);
                        }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class AppColorPalette {
  static const Color primaryMaroon = Color(0xFF8B1F41);
  static const Color secondaryMaroon = Color(0xFFA84B5C);
  static const Color lightMaroon = Color(0xFFE7C8CD);
  static const Color accentPink = Color(0xFFF4D0D9);
  static const Color warmBeige = Color(0xFFF5E6E8);
}

class BackgroundPainter extends CustomPainter {
  final Color color;
  BackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) => color != oldDelegate.color;
}
