import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/classSectionsAndSubjects.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/lesson/lessonsCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/topic/deleteTopicCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/topic/topicsCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/lesson.dart';
import 'package:eschool_saas_staff/data/models/teacherSubject.dart';
import 'package:eschool_saas_staff/data/models/topic.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherAddEditTopicScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/confirmDeleteDialog.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customExpandableContainer.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customTitleDescriptionContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Define our theme colors
final Color maroonPrimary = Color(0xFF8B1F41);
final Color maroonLight = Color(0xFFAC3B5C);
final Color maroonDark = Color(0xFF6A0F2A);
final Color accentColor = Color(0xFFF5EBE0);
final Color bgColor = Color(0xFFFAF6F2);
final Color cardColor = Colors.white;
final Color textDarkColor = Color(0xFF2D2D2D);
final Color textMediumColor = Color(0xFF717171);
final Color borderColor = Color(0xFFE8E8E8);

class TeacherManageTopicScreen extends StatefulWidget {
  final ClassSection? selectedClassSection;
  final TeacherSubject? selectedSubject;
  final Lesson? selectedLesson;

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LessonsCubit()),
        BlocProvider(create: (context) => ClassSectionsAndSubjectsCubit()),
        BlocProvider(create: (context) => TopicsCubit()),
      ],
      child: TeacherManageTopicScreen(
        selectedClassSection: arguments?['selectedClassSection'],
        selectedSubject: arguments?['selectedSubject'],
        selectedLesson: arguments?['selectedLesson'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments({
    required ClassSection? selectedClassSection,
    required TeacherSubject? selectedSubject,
    required Lesson? selectedLesson,
  }) {
    return {
      "selectedClassSection": selectedClassSection,
      "selectedSubject": selectedSubject,
      "selectedLesson": selectedLesson,
    };
  }

  const TeacherManageTopicScreen({
    super.key,
    this.selectedClassSection,
    this.selectedSubject,
    this.selectedLesson,
  });

  @override
  State<TeacherManageTopicScreen> createState() =>
      _TeacherManageTopicScreenState();
}

class _TeacherManageTopicScreenState extends State<TeacherManageTopicScreen>
    with TickerProviderStateMixin {
  ClassSection? _selectedClassSection;
  TeacherSubject? _selectedSubject;
  Lesson? _selectedLesson;
  bool didCreateNewTopic = false;

  // Animation controllers
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  // For header collapsing effect
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutQuint,
      ),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    if (widget.selectedLesson == null) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          context
              .read<ClassSectionsAndSubjectsCubit>()
              .getClassSectionsAndSubjects();
        }
      });
    } else {
      _selectedLesson = widget.selectedLesson;
      _selectedSubject = widget.selectedSubject;
      _selectedClassSection = widget.selectedClassSection;
      getTopics();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void changeSelectedClassSection(ClassSection? classSection,
      {bool fetchNewSubjects = true}) {
    if (_selectedClassSection != classSection) {
      _selectedClassSection = classSection;
      if (fetchNewSubjects && _selectedClassSection != null) {
        context
            .read<ClassSectionsAndSubjectsCubit>()
            .getNewSubjectsFromSelectedClassSectionIndex(
                newClassSectionId: classSection?.id ?? 0)
            .then((value) {
          if (mounted) {
            if (context.read<ClassSectionsAndSubjectsCubit>().state
                is ClassSectionsAndSubjectsFetchSuccess) {
              changeSelectedTeacherSubject((context
                      .read<ClassSectionsAndSubjectsCubit>()
                      .state as ClassSectionsAndSubjectsFetchSuccess)
                  .subjects
                  .firstOrNull);
            }
          }
        });
      }
      setState(() {});
    }
  }

  void changeSelectedTeacherSubject(TeacherSubject? teacherSubject) {
    if (_selectedSubject != teacherSubject) {
      _selectedSubject = teacherSubject;
      setState(() {});
      getLessons();
    }
  }

  void getLessons() {
    context.read<LessonsCubit>().fetchLessons(
        classSubjectId: _selectedSubject?.classSubjectId ?? 0,
        classSectionId: _selectedClassSection?.id ?? 0);
  }

  void getTopics() {
    context.read<TopicsCubit>().fetchTopics(lessonId: _selectedLesson?.id ?? 0);
  }

  Widget _buildTopicItem({required Topic topic}) {
    return BlocProvider(
      create: (context) => DeleteTopicCubit(),
      child: Builder(builder: (context) {
        return BlocConsumer<DeleteTopicCubit, DeleteTopicState>(
          listener: (context, state) {
            if (state is DeleteTopicSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 24),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "${Utils.getTranslatedLabel(topicDeletedSuccessfullyKey)} ${topic.name}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  backgroundColor: Colors.green.shade600,
                  duration: Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                ),
              );
              context.read<TopicsCubit>().deleteTopic(topic.id);
            } else if (state is DeleteTopicFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "${Utils.getTranslatedLabel(unableToDeleteTopicKey)} ${topic.name}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  backgroundColor: maroonPrimary,
                  duration: Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                ),
              );
            }
          },
          builder: (context, state) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: maroonPrimary.withOpacity(0.1),
                      blurRadius: 25,
                      offset: Offset(0, 12),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Premium header with enhanced design
                      Stack(
                        children: [
                          // Sophisticated background with animated gradient
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: 130,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFF9F0F5),
                                  Color(0xFFFDF7FA),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),

                          // Dynamic decorative elements
                          Positioned(
                            top: -30,
                            right: -30,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    maroonPrimary.withOpacity(0.08),
                                    maroonPrimary.withOpacity(0.03)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -25,
                            left: -15,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    maroonPrimary.withOpacity(0.06),
                                    maroonPrimary.withOpacity(0.02)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),

                          // Elegant accent bar
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [maroonPrimary, maroonLight],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: maroonPrimary.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                    spreadRadius: -2,
                                  )
                                ],
                              ),
                            ),
                          ),

                          // Enhanced content layout
                          Padding(
                            padding: EdgeInsets.fromLTRB(26, 24, 20, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Enhanced typography and layout for topic title
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        topic.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: textDarkColor,
                                          height: 1.2,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                ),

                                // Refined action menu with visual feedback
                                Material(
                                  color: Colors.transparent,
                                  child: PopupMenuButton<String>(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 12,
                                    offset: Offset(0, 50),
                                    color: Colors.white,
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        HapticFeedback.lightImpact();
                                        Get.toNamed(
                                          Routes.teacherAddEditTopicScreen,
                                          arguments: TeacherAddEditTopicScreen
                                              .buildArguments(
                                            topic: topic,
                                            selectedClassSection:
                                                _selectedClassSection,
                                            selectedLesson: _selectedLesson,
                                            selectedSubject: _selectedSubject,
                                          ),
                                        )?.then((value) {
                                          if (value != null &&
                                              value is bool &&
                                              value) {
                                            getTopics();
                                          }
                                        });
                                      } else if (value == 'delete') {
                                        if (state is DeleteTopicInProgress)
                                          return;
                                        HapticFeedback.mediumImpact();
                                        showDialog<bool>(
                                          context: context,
                                          builder: (_) =>
                                              const ConfirmDeleteDialog(),
                                        ).then((value) {
                                          if (value != null && value) {
                                            if (context.mounted) {
                                              context
                                                  .read<DeleteTopicCubit>()
                                                  .deleteTopic(
                                                      topicId: topic.id);
                                            }
                                          }
                                        });
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      // Enhanced Edit button with gradient style
                                      PopupMenuItem<String>(
                                        value: 'edit',
                                        height: 64,
                                        child: TweenAnimationBuilder<double>(
                                          tween: Tween<double>(
                                              begin: 0.9, end: 1.0),
                                          duration: Duration(milliseconds: 200),
                                          builder: (context, value, child) {
                                            return Transform.scale(
                                              scale: value,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 8, horizontal: 8),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.blue.shade400,
                                                      Colors.blue.shade600
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors
                                                          .blue.shade500
                                                          .withOpacity(0.3),
                                                      blurRadius: 12,
                                                      offset: Offset(0, 4),
                                                      spreadRadius: -2,
                                                    )
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.25),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Icon(
                                                        Icons.edit_rounded,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        'Edit',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 15,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      // Enhanced Delete button with gradient style
                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        height: 64,
                                        child: TweenAnimationBuilder<double>(
                                          tween: Tween<double>(
                                              begin: 0.9, end: 1.0),
                                          duration: Duration(milliseconds: 300),
                                          builder: (context, value, child) {
                                            return Transform.scale(
                                              scale: value,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 8, horizontal: 8),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.red.shade400,
                                                      Colors.red.shade700
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.red.shade500
                                                          .withOpacity(0.3),
                                                      blurRadius: 12,
                                                      offset: Offset(0, 4),
                                                      spreadRadius: -2,
                                                    )
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.25),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .delete_outline_rounded,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        'Delete',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 15,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                    // Also update the more options button to match style
                                    child: TweenAnimationBuilder<double>(
                                      tween:
                                          Tween<double>(begin: 0.8, end: 1.0),
                                      duration: Duration(milliseconds: 300),
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              gradient: state
                                                      is DeleteTopicInProgress
                                                  ? LinearGradient(
                                                      colors: [
                                                        Colors.grey.shade300,
                                                        Colors.grey.shade400
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    )
                                                  : LinearGradient(
                                                      colors: [
                                                        Colors.white,
                                                        Colors.grey.shade100
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: maroonPrimary
                                                      .withOpacity(0.1),
                                                  blurRadius: 10,
                                                  offset: Offset(0, 4),
                                                  spreadRadius: -2,
                                                ),
                                              ],
                                            ),
                                            child: state
                                                    is DeleteTopicInProgress
                                                ? Center(
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: maroonPrimary,
                                                        strokeWidth: 2,
                                                      ),
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.more_vert_rounded,
                                                    color: maroonPrimary,
                                                    size: 22,
                                                  ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Enhanced description section with refined styling
                      Container(
                        padding: EdgeInsets.fromLTRB(26, 22, 26, 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade100,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: maroonPrimary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.description_outlined,
                                    color: maroonPrimary,
                                    size: 18,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  Utils.getTranslatedLabel(descriptionKey),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textDarkColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Elegant description container with enhanced readability
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                topic.description,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.5,
                                  color: textMediumColor,
                                  height: 1.6,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Study materials section with enhanced styling
                      if (topic.studyMaterials.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(26),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade100,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: maroonPrimary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.attach_file_rounded,
                                      color: maroonPrimary,
                                      size: 18,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Materi Pembelajaran",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: textDarkColor,
                                    ),
                                  ),
                                  SizedBox(width: 10),

                                  // Animated counter badge
                                  TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0.8, end: 1.0),
                                    duration: Duration(milliseconds: 300),
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color:
                                                maroonPrimary.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            "${topic.studyMaterials.length}",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: maroonPrimary,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),

                              // Enhanced file list container
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Column(
                                    children: topic.studyMaterials
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final index = entry.key;
                                      final material = entry.value;

                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: index <
                                                    topic.studyMaterials
                                                            .length -
                                                        1
                                                ? BorderSide(
                                                    color: Colors.grey.shade200,
                                                    width: 1)
                                                : BorderSide.none,
                                          ),
                                        ),
                                        padding: EdgeInsets.all(18),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                _getFileTypeIcon(
                                                    material.fileName),
                                                color: maroonPrimary,
                                                size: 20,
                                              ),
                                            ),
                                            SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    material.fileName,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: textDarkColor,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    _getFileType(
                                                        material.fileName),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: textMediumColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              Icons.download_rounded,
                                              color: maroonPrimary,
                                              size: 22,
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  IconData _getFileTypeIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_outlined;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image_outlined;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file_outlined;
      case 'mp3':
      case 'wav':
        return Icons.audio_file_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return 'PDF Document';
      case 'doc':
      case 'docx':
        return 'Word Document';
      case 'xls':
      case 'xlsx':
        return 'Excel Spreadsheet';
      case 'ppt':
      case 'pptx':
        return 'PowerPoint Presentation';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'Image File';
      case 'mp4':
      case 'avi':
      case 'mov':
        return 'Video File';
      case 'mp3':
      case 'wav':
        return 'Audio File';
      default:
        return extension.toUpperCase() + ' File';
    }
  }

  Widget _buildTopicList() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(
            bottom: 70,
            // Increase the top padding to create more space between header and cards
            top: Utils.appContentTopScrollPadding(context: context) +
                185), // Increased from 145 to 185
        child: BlocBuilder<TopicsCubit, TopicsState>(
          builder: (context, state) {
            if (state is TopicsFetchSuccess) {
              if (state.topics.isEmpty) {
                return Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            color: textMediumColor,
                            size: 80,
                          ),
                          SizedBox(height: 16),
                          Text(
                            Utils.getTranslatedLabel(noTopicKey),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                              color: textMediumColor,
                            ),
                          ),
                          SizedBox(height: 20),
                          CustomRoundedButton(
                            height: 46,
                            widthPercentage: 0.6,
                            backgroundColor: maroonPrimary,
                            buttonTitle: createTopicKey,
                            radius: 16,
                            textSize: 14,
                            fontWeight: FontWeight.w600,
                            showBorder: false,
                            onTap: () {
                              Get.toNamed(Routes.teacherAddEditTopicScreen,
                                  arguments:
                                      TeacherAddEditTopicScreen.buildArguments(
                                    topic: null,
                                    selectedClassSection: _selectedClassSection,
                                    selectedLesson: _selectedLesson,
                                    selectedSubject: _selectedSubject,
                                  ))?.then((value) {
                                if (value != null && value is bool && value) {
                                  getTopics();
                                  didCreateNewTopic = true;
                                }
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_circle_outline,
                                    color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  Utils.getTranslatedLabel(createTopicKey),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: appContentHorizontalPadding),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Increase the top padding at the beginning of the list
                      SizedBox(height: 40), // Changed from 20 to 40

                      // Topics
                      ...List.generate(
                          state.topics.length,
                          (index) =>
                              _buildTopicItem(topic: state.topics[index])),
                    ],
                  ),
                ),
              );
            } else if (state is TopicsFetchFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer),
                  child: ErrorContainer(
                    errorMessage:
                        "Gagal mendapatkan topik pelajaran, mohon coba lagi",
                    onTapRetry: () {
                      getTopics();
                    },
                  ),
                ),
              );
            } else {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Icon(
                          Icons.assignment_outlined,
                          size: 40,
                          color: maroonPrimary,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Pilih bab pelajaran terlebih dahulu",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: textMediumColor,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.all(appContentHorizontalPadding),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, -4),
              spreadRadius: 2,
            )
          ],
          color: cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        width: MediaQuery.of(context).size.width,
        height: 90,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.95, end: 1.0),
          duration: Duration(milliseconds: 500),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: CustomRoundedButton(
                height: 56,
                widthPercentage: 1.0,
                backgroundColor: maroonPrimary,
                buttonTitle: createTopicKey,
                radius: 16,
                textSize: 16,
                fontWeight: FontWeight.w600,
                showBorder: false,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Utils.getTranslatedLabel(createTopicKey),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Get.toNamed(Routes.teacherAddEditTopicScreen,
                          arguments: TeacherAddEditTopicScreen.buildArguments(
                              topic: null,
                              selectedClassSection: _selectedClassSection,
                              selectedLesson: _selectedLesson,
                              selectedSubject: _selectedSubject))
                      ?.then((value) {
                    if (value != null && value is bool && value) {
                      getTopics();
                      didCreateNewTopic = true;
                    }
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      // Increasing the height to better accommodate the filters
      height: 270.0, // Changed from 200.0 to 240.0
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [maroonPrimary, maroonDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: maroonPrimary.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content with better spacing
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  24, 12, 24, 0), // Increased top padding
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button and title row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () {
                          Get.back(result: didCreateNewTopic);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Title and subtitle in a column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Utils.getTranslatedLabel(manageTopicKey),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            // Always show subtitle
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                "Kelola topik untuk bab pelajaran Anda",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Increased spacing for better layout
                  SizedBox(height: 24), // Increased from using Spacer

                  // Filter buttons with better spacing
                  if (widget.selectedLesson == null)
                    BlocConsumer<ClassSectionsAndSubjectsCubit,
                        ClassSectionsAndSubjectsState>(
                      listener: (context, state) {
                        if (state is ClassSectionsAndSubjectsFetchSuccess) {
                          if (_selectedClassSection == null &&
                              state.classSections.isNotEmpty) {
                            changeSelectedClassSection(
                                state.classSections.first,
                                fetchNewSubjects: false);
                          }
                          if (_selectedSubject == null &&
                              state.subjects.isNotEmpty) {
                            changeSelectedTeacherSubject(state.subjects.first);
                          }
                        }
                      },
                      builder: (context, state) {
                        if (state is ClassSectionsAndSubjectsFetchSuccess) {
                          return Container(
                            height:
                                56, // Increased height for better touch targets
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (state.classSections.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Tidak ada kelas yang tersedia"),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        return;
                                      }

                                      if (_selectedClassSection == null) {
                                        changeSelectedClassSection(
                                            state.classSections.first,
                                            fetchNewSubjects: false);
                                      }

                                      HapticFeedback.lightImpact();
                                      Utils.showBottomSheet(
                                          child: FilterSelectionBottomsheet<
                                              ClassSection>(
                                            onSelection: (value) {
                                              changeSelectedClassSection(value);
                                              Get.back();
                                            },
                                            selectedValue:
                                                _selectedClassSection!,
                                            titleKey: classKey,
                                            values: state.classSections,
                                          ),
                                          context: context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical:
                                              14), // Increased vertical padding
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.class_outlined,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _selectedClassSection?.name ??
                                                  'Pilih Kelas',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (state.subjects.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Tidak ada mata pelajaran yang tersedia"),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        return;
                                      }

                                      if (_selectedSubject == null) {
                                        changeSelectedTeacherSubject(
                                            state.subjects.first);
                                      }

                                      HapticFeedback.lightImpact();
                                      Utils.showBottomSheet(
                                          child: FilterSelectionBottomsheet<
                                              TeacherSubject>(
                                            onSelection: (value) {
                                              changeSelectedTeacherSubject(
                                                  value);
                                              Get.back();
                                            },
                                            selectedValue: _selectedSubject!,
                                            titleKey: subjectKey,
                                            values: state.subjects,
                                          ),
                                          context: context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical:
                                              14), // Increased vertical padding
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.book_outlined,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _selectedSubject?.subject.name ??
                                                  'Pilih Mata Pelajaran',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return Container();
                      },
                    ),

                  // Show lesson filter with better spacing
                  if (widget.selectedLesson == null)
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 16), // Increased from 12 to 16
                      child: SizedBox(
                        height: 56, // Increased from 52 to 56 for consistency
                        child: BlocConsumer<LessonsCubit, LessonsState>(
                          listener: (context, state) {
                            if (state is LessonsFetchSuccess) {
                              if (state.lessons.isNotEmpty) {
                                _selectedLesson = state.lessons.first;
                                getTopics();
                                setState(() {});
                              }
                            }
                          },
                          builder: (context, state) {
                            return GestureDetector(
                              onTap: () {
                                if (state is LessonsFetchSuccess) {
                                  if (state.lessons.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Tidak ada bab pelajaran yang tersedia"),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    return;
                                  }

                                  HapticFeedback.lightImpact();
                                  Utils.showBottomSheet(
                                    child: FilterSelectionBottomsheet<Lesson>(
                                      selectedValue: _selectedLesson!,
                                      titleKey: lessonKey,
                                      values: state.lessons,
                                      onSelection: (value) {
                                        if (value != _selectedLesson) {
                                          _selectedLesson = value;
                                          getTopics();
                                          setState(() {});
                                        }
                                        Get.back();
                                      },
                                    ),
                                    context: context,
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14), // Increased vertical padding
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.menu_book_outlined,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedLesson?.name ??
                                            'Pilih Bab Pelajaran',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // Add bottom padding to ensure content doesn't touch the bottom edge
                  SizedBox(height: 16), // Increased from 10 to 16
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      primaryColor: maroonPrimary,
      scaffoldBackgroundColor: bgColor,
      textTheme: GoogleFonts.poppinsTextTheme(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: maroonPrimary,
        primary: maroonPrimary,
        secondary: maroonLight,
      ),
    );

    return Theme(
      data: theme,
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          Get.back(result: didCreateNewTopic);
        },
        child: Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              if (widget.selectedLesson == null) ...[
                BlocBuilder<LessonsCubit, LessonsState>(
                    builder: (context, lessonState) {
                  return BlocBuilder<ClassSectionsAndSubjectsCubit,
                      ClassSectionsAndSubjectsState>(
                    builder: (context, state) {
                      if (state is ClassSectionsAndSubjectsFetchSuccess &&
                          lessonState is LessonsFetchSuccess) {
                        if (lessonState.lessons.isEmpty) {
                          return Center(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 50),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.menu_book_outlined,
                                      color: textMediumColor,
                                      size: 80,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "Tidak ada bab pelajaran yang tersedia",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                        color: textMediumColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return _buildTopicList();
                      }
                      if (state is ClassSectionsAndSubjectsFetchFailure) {
                        return Center(
                            child: ErrorContainer(
                          errorMessage:
                              "Gagal mendapatkan data kelas dan mata pelajaran, mohon coba lagi",
                          onTapRetry: () {
                            context
                                .read<ClassSectionsAndSubjectsCubit>()
                                .getClassSectionsAndSubjects();
                          },
                        ));
                      }
                      if (lessonState is LessonsFetchFailure) {
                        return Center(
                            child: ErrorContainer(
                          errorMessage:
                              "Gagal mendapatkan bab pelajaran, mohon coba lagi",
                          onTapRetry: () {
                            getLessons();
                          },
                        ));
                      }
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                color: maroonPrimary,
                                strokeWidth: 4,
                              ),
                            ),
                            SizedBox(height: 24),
                            Text(
                              "Memuat data...",
                              style: TextStyle(
                                fontSize: 16,
                                color: textMediumColor,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ] else ...[
                _buildTopicList(),
              ],
              _buildSubmitButton(),
              if (widget.selectedLesson == null) ...[
                _buildHeaderSection(),
              ] else ...[
                _buildHeaderSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
