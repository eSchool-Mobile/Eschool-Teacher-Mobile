import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/classSectionsAndSubjects.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/lesson/deleteLessonCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/lesson/lessonsCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/lesson.dart';
import 'package:eschool_saas_staff/data/models/teacherSubject.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherAddEditLessonScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherManageTopicScreen.dart';
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

class TeacherManageLessonScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LessonsCubit(),
        ),
        BlocProvider(
          create: (context) => ClassSectionsAndSubjectsCubit(),
        ),
      ],
      child: const TeacherManageLessonScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const TeacherManageLessonScreen({super.key});

  @override
  State<TeacherManageLessonScreen> createState() =>
      _TeacherManageLessonScreenState();
}

class _TeacherManageLessonScreenState extends State<TeacherManageLessonScreen> {
  ClassSection? _selectedClassSection;
  TeacherSubject? _selectedSubject;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<ClassSectionsAndSubjectsCubit>()
            .getClassSectionsAndSubjects();
      }
    });
    super.initState();
  }

  void changeSelectedClassSection(ClassSection? classSection,
      {bool fetchNewSubjects = true}) {
    if (_selectedClassSection != classSection) {
      _selectedClassSection = classSection;
      //fetching new subjects after user changes the selected class
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

  Widget _buildLessonItem({required Lesson lesson}) {
    return BlocProvider(
      create: (context) => DeleteLessonCubit(),
      child: Builder(builder: (context) {
        return BlocConsumer<DeleteLessonCubit, DeleteLessonState>(
          listener: (context, state) {
            if (state is DeleteLessonSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      "${Utils.getTranslatedLabel(lessonDeletedSuccessfullyKey)} ${lesson.name}",
                      style: TextStyle(
                      color: Colors.white, 
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      ),
                    ),
                    ],
                  ),
                  ),
                  backgroundColor: Colors.green.shade400,
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                );
              context.read<LessonsCubit>().deleteLesson(lesson.id);
            } else if (state is DeleteLessonFailure) {
              Utils.showSnackBar(
                context: context,
                message:
                    "${Utils.getTranslatedLabel(unableToDeleteLessonKey)} ${lesson.name}",
              );
            }
          },
          builder: (context, state) {
            return CustomExpandableContainer(
              key: ValueKey(lesson.id),
              studyMaterials: lesson.studyMaterials,
              isDeleteLoading: state is DeleteLessonInProgress,
              titleText: lesson.name,
              contractedContentWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTitleDescriptionContainer(
                      titleKey: descriptionKey,
                      description: lesson.description),
                  const SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        Routes.teacherManageTopicScreen,
                        arguments: TeacherManageTopicScreen.buildArguments(
                            selectedLesson: lesson,
                            selectedClassSection: _selectedClassSection,
                            selectedSubject: _selectedSubject),
                      )?.then((value) {
                        if (value != null && value is bool && value) {
                          getLessons();
                        }
                      });
                    },
                    child: CustomTextContainer(
                      textKey:
                          "${Utils.getTranslatedLabel(viewTopicsKey)}${lesson.topicsCount != 0 ? ' (${lesson.topicsCount})' : ''}",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: Utils.getScaledValue(context, 13.5)),
                    ),
                  )
                ],
              ),
              onDelete: () {
                if (state is DeleteLessonInProgress) {
                  return;
                }
                showDialog<bool>(
                  context: context,
                  builder: (_) => const ConfirmDeleteDialog(),
                ).then((value) {
                  if (value != null && value) {
                    if (context.mounted) {
                      context.read<DeleteLessonCubit>().deleteLesson(lesson.id);
                    }
                  }
                });
              },
              onEdit: () {
                Get.toNamed(Routes.teacherAddEditLessonScreen,
                        arguments: TeacherAddEditLessonScreen.buildArguments(
                            lesson: lesson,
                            selectedClassSection: _selectedClassSection,
                            selectedSubject: _selectedSubject))
                    ?.then((value) {
                  if (value != null && value is bool && value) {
                    //re-fetch lessons if they edit or add
                    getLessons();
                  }
                });
              },
            );
          },
        );
      }),
    );
  }

  Widget _buildLessonList() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
            bottom: 70,
            top: Utils.appContentTopScrollPadding(context: context) + 85),
        child: BlocBuilder<LessonsCubit, LessonsState>(
          builder: (context, state) {
            if (state is LessonsFetchSuccess) {
              if (state.lessons.isEmpty) {
                // Menampilkan pesan "Belum ada pelajaran" jika kosong
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: CustomTextContainer(
                      textKey: Utils.getTranslatedLabel(noLessonKey),
                    ),
                  ),
                );
              }
              return Container(
                padding: EdgeInsets.all(appContentHorizontalPadding),
                color: Theme.of(context).colorScheme.surface,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    CustomTextContainer(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textKey: lessonListLey,
                      style: TextStyle(
                        fontSize: Utils.getScaledValue(context, 17),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    ...List.generate(
                      state.lessons.length,
                      (index) => _buildLessonItem(lesson: state.lessons[index]),
                    ),
                  ],
                ),
              );
            } else if (state is LessonsFetchFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer),
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      getLessons();
                    },
                  ),
                ),
              );
            } else {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer),
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
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
        decoration: BoxDecoration(boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 1, spreadRadius: 1)
        ], color: Theme.of(context).colorScheme.surface),
        width: MediaQuery.of(context).size.width,
        height: 70,
        child: CustomRoundedButton(
          height: 40,
          widthPercentage: 1.0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          buttonTitle: createLessonKey,
          showBorder: false,
          onTap: () {
            Get.toNamed(Routes.teacherAddEditLessonScreen,
                    arguments: TeacherAddEditLessonScreen.buildArguments(
                        lesson: null,
                        selectedClassSection: _selectedClassSection,
                        selectedSubject: _selectedSubject))
                ?.then((value) {
              if (value != null && value is bool && value) {
                getLessons();
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildAppbarAndFilters() {
    return Align(
      alignment: Alignment.topCenter,
      child: BlocConsumer<ClassSectionsAndSubjectsCubit,
          ClassSectionsAndSubjectsState>(
        listener: (context, state) {
          if (state is ClassSectionsAndSubjectsFetchSuccess) {
            if (_selectedClassSection == null) {
              changeSelectedClassSection(state.classSections.firstOrNull,
                  fetchNewSubjects: false);
            }
            if (_selectedSubject == null) {
              changeSelectedTeacherSubject(state.subjects.firstOrNull);
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              const CustomAppbar(titleKey: manageLessonKey),
              AppbarFilterBackgroundContainer(
                child: LayoutBuilder(builder: (context, boxConstraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilterButton(
                        onTap: () {
                          if (state is ClassSectionsAndSubjectsFetchSuccess) {
                            Utils.showBottomSheet(
                                child: FilterSelectionBottomsheet<ClassSection>(
                                  onSelection: (value) {
                                    changeSelectedClassSection(value!);
                                    Get.back();
                                  },
                                  selectedValue: _selectedClassSection!,
                                  titleKey: classKey,
                                  values: state.classSections,
                                ),
                                context: context);
                          }
                        },
                        titleKey: _selectedClassSection?.id == null
                            ? classKey
                            : _selectedClassSection?.name ?? "",
                        width: boxConstraints.maxWidth * (0.48),
                      ),
                      FilterButton(
                          onTap: () {
                            if (state is ClassSectionsAndSubjectsFetchSuccess) {
                              Utils.showBottomSheet(
                                  child: FilterSelectionBottomsheet<
                                      TeacherSubject>(
                                    selectedValue: _selectedSubject!,
                                    titleKey: subjectKey,
                                    values: state.subjects,
                                    onSelection: (value) {
                                      changeSelectedTeacherSubject(value!);
                                      Get.back();
                                    },
                                  ),
                                  context: context);
                            }
                          },
                          titleKey: _selectedSubject?.id == null
                              ? subjectKey
                              : _selectedSubject?.subject
                                      .getSybjectNameWithType() ??
                                  "",
                          width: boxConstraints.maxWidth * (0.48)),
                    ],
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<ClassSectionsAndSubjectsCubit,
              ClassSectionsAndSubjectsState>(
            builder: (context, state) {
              if (state is ClassSectionsAndSubjectsFetchSuccess) {
                return _buildLessonList();
              }

              if (state is ClassSectionsAndSubjectsFetchFailure) {
                return Center(
                    child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context
                        .read<ClassSectionsAndSubjectsCubit>()
                        .getClassSectionsAndSubjects();
                  },
                ));
              }

              return Center(
                child: CustomCircularProgressIndicator(
                  indicatorColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
          _buildSubmitButton(),
          _buildAppbarAndFilters(),
        ],
      ),
    );
  }
}
