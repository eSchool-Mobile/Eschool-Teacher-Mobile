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
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

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
  bool didCreateNewTopic = false; // Animation controller for app bar effects
  late AnimationController _fabAnimationController;

  // For header collapsing effect
  final ScrollController _scrollController = ScrollController();

  // Define color constants for the app bar
  final Color _maroonPrimary = const Color(0xFF8B1F41);
  final Color _maroonLight = const Color(0xFFAC3B5C);
  final Color _maroonDark = const Color(0xFF6A0F2A);
  @override
  void initState() {
    super.initState();

    // Initialize app bar animation controller
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Start animation
    _fabAnimationController.forward();

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
    _scrollController.dispose();
    _fabAnimationController.dispose();
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
                  backgroundColor: Colors.red.shade600,
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
            return Container(
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(
                  topic.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  topic.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Get.toNamed(
                        Routes.teacherAddEditTopicScreen,
                        arguments: TeacherAddEditTopicScreen.buildArguments(
                          topic: topic,
                          selectedClassSection: _selectedClassSection,
                          selectedLesson: _selectedLesson,
                          selectedSubject: _selectedSubject,
                        ),
                      )?.then((value) {
                        if (value != null && value is bool && value) {
                          getTopics();
                        }
                      });
                    } else if (value == 'delete') {
                      if (state is DeleteTopicInProgress) return;
                      showDialog<bool>(
                        context: context,
                        builder: (_) => const ConfirmDeleteDialog(),
                      ).then((value) {
                        if (value != null && value) {
                          if (context.mounted) {
                            context
                                .read<DeleteTopicCubit>()
                                .deleteTopic(topicId: topic.id);
                          }
                        }
                      });
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildTopicList() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(
          bottom: 80,
          // Increased top padding to accommodate the new larger app bar with three filters
          top: MediaQuery.of(context).padding.top + 200,
        ),
        child: BlocBuilder<TopicsCubit, TopicsState>(
          builder: (context, state) {
            if (state is TopicsFetchSuccess) {
                if (state.topics.isEmpty) {
                return Center(
                  child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    Icon(
                      Icons.topic_outlined,
                      color: _maroonPrimary,
                      size: 56,
                    ),
                    SizedBox(height: 16),
                    Text(
                      Utils.getTranslatedLabel(noTopicKey),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Silahkan tambahkan topik baru",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      ),
                    ),
                    ],
                  ),
                  ),
                );
                }
              return Column(
                children: List.generate(
                  state.topics.length,
                  (index) => _buildTopicItem(topic: state.topics[index]),
                ),
              );
            } else if (state is TopicsFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage:
                      Utils.getTranslatedLabel(defaultErrorMessageKey),
                  onTapRetry: () {
                    getTopics();
                  },
                ),
              );
            } else {
              // Instead of showing loading indicator, show message to select class, subject and chapter
              if (_selectedClassSection == null ||
                  _selectedSubject == null ||
                  _selectedLesson == null) {
                return Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: _maroonPrimary,
                          size: 40,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Silahkan pilih kelas, mata pelajaran, dan bab terlebih dahulu",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Gunakan filter di atas untuk memilih",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              // Show loading indicator only when all selections are made
              return Center(
                child: CircularProgressIndicator(),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              Get.toNamed(
                Routes.teacherAddEditTopicScreen,
                arguments: TeacherAddEditTopicScreen.buildArguments(
                  topic: null,
                  selectedClassSection: _selectedClassSection,
                  selectedLesson: _selectedLesson,
                  selectedSubject: _selectedSubject,
                ),
              )?.then((value) {
                if (value != null && value is bool && value) {
                  getTopics();
                  didCreateNewTopic = true;
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _maroonPrimary,
                    Color(0xFF9A1E3C),
                    _maroonLight,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _maroonPrimary.withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      Utils.getTranslatedLabel(createTopicKey),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 500.ms),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: MediaQuery.of(context).padding.top +
            180, // Increased height to accommodate three filters
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
                            _maroonPrimary,
                            _maroonDark,
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
                              onTap: () {
                                Get.back(result: didCreateNewTopic);
                              },
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
                                              Icons.topic_rounded,
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
                                        Utils.getTranslatedLabel(
                                            manageTopicKey),
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

                        // Optional space for action buttons
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // BOTTOM ROW - Filters with frosted glass effect (now with THREE filters)
            Positioned(
              bottom: 10,
              left: 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    height: 100, // Increased height for three filters
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Top row with two filters
                        Expanded(
                          child: Row(
                            children: [
                              // Class Section filter
                              Expanded(
                                child: BlocBuilder<
                                    ClassSectionsAndSubjectsCubit,
                                    ClassSectionsAndSubjectsState>(
                                  builder: (context, state) {
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          if (state
                                              is ClassSectionsAndSubjectsFetchSuccess) {
                                            if (state.classSections.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      "Tidak ada kelas yang tersedia"),
                                                  backgroundColor:
                                                      _maroonPrimary,
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
                                                  if (value != null) {
                                                    changeSelectedClassSection(
                                                        value);
                                                    Get.back();
                                                  }
                                                },
                                                selectedValue:
                                                    _selectedClassSection ??
                                                        state.classSections
                                                            .first,
                                                values: state.classSections,
                                                titleKey: classKey,
                                              ),
                                              context: context,
                                            );
                                          }
                                        },
                                        highlightColor:
                                            Colors.white.withOpacity(0.1),
                                        splashColor:
                                            Colors.white.withOpacity(0.2),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.class_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  _selectedClassSection?.name ??
                                                      "Pilih Kelas",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
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

                              // Subject filter
                              Expanded(
                                child: BlocBuilder<
                                    ClassSectionsAndSubjectsCubit,
                                    ClassSectionsAndSubjectsState>(
                                  builder: (context, state) {
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          if (state
                                              is ClassSectionsAndSubjectsFetchSuccess) {
                                            if (state.subjects.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      "Tidak ada mata pelajaran yang tersedia"),
                                                  backgroundColor:
                                                      _maroonPrimary,
                                                ),
                                              );
                                              return;
                                            }

                                            HapticFeedback.lightImpact();
                                            Utils.showBottomSheet(
                                              child: FilterSelectionBottomsheet<
                                                  TeacherSubject>(
                                                onSelection: (value) {
                                                  if (value != null) {
                                                    changeSelectedTeacherSubject(
                                                        value);
                                                    Get.back();
                                                  }
                                                },
                                                selectedValue:
                                                    _selectedSubject ??
                                                        state.subjects.first,
                                                values: state.subjects,
                                                titleKey: subjectKey,
                                              ),
                                              context: context,
                                            );
                                          }
                                        },
                                        highlightColor:
                                            Colors.white.withOpacity(0.1),
                                        splashColor:
                                            Colors.white.withOpacity(0.2),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.book_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  _selectedSubject?.subject
                                                          .getSybjectNameWithType() ??
                                                      "Pilih Mapel",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Horizontal divider
                        Container(
                          height: 1.5,
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.4),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),

                        // Bottom row with lesson filter
                        Expanded(
                          child: BlocConsumer<LessonsCubit, LessonsState>(
                            listener: (context, state) {
                              if (state is LessonsFetchSuccess) {
                                if (state.lessons.isNotEmpty &&
                                    _selectedLesson == null) {
                                  _selectedLesson = state.lessons.first;
                                  getTopics();
                                  setState(() {});
                                }
                              }
                            },
                            builder: (context, state) {
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (state is LessonsFetchSuccess) {
                                      if (state.lessons.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Tidak ada bab pelajaran yang tersedia"),
                                            backgroundColor: _maroonPrimary,
                                          ),
                                        );
                                        return;
                                      }

                                      HapticFeedback.lightImpact();
                                      Utils.showBottomSheet(
                                        child:
                                            FilterSelectionBottomsheet<Lesson>(
                                          onSelection: (value) {
                                            if (value != _selectedLesson) {
                                              _selectedLesson = value;
                                              getTopics();
                                              setState(() {});
                                            }
                                            Get.back();
                                          },
                                          selectedValue: _selectedLesson ??
                                              state.lessons.first,
                                          values: state.lessons,
                                          titleKey: lessonKey,
                                        ),
                                        context: context,
                                      );
                                    }
                                  },
                                  highlightColor: Colors.white.withOpacity(0.1),
                                  splashColor: Colors.white.withOpacity(0.2),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.menu_book_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            _selectedLesson?.name ??
                                                "Pilih Bab Pelajaran",
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
                              );
                            },
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
          _buildTopicList(),
          _buildSubmitButton(),
          _buildAppBar(),
        ],
      ),
    );
  }
}

// Custom painter for decorative elements in the AppBar
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
