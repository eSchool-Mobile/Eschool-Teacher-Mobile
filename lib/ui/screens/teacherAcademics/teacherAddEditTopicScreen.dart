import 'package:eschool_saas_staff/cubits/teacherAcademics/classSectionsAndSubjects.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/lesson/lessonsCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/topic/createTopicCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/topic/editTopicCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/lesson.dart';
import 'package:eschool_saas_staff/data/models/pickedStudyMaterial.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/data/models/teacherSubject.dart';
import 'package:eschool_saas_staff/data/models/topic.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/addStudyMaterialBottomsheet.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/addedStudyMaterialFileContainer.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/studyMaterialContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customDropdownSelectionButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/uploadImageOrFileButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class TeacherAddEditTopicScreen extends StatefulWidget {
  final Topic? topic;
  final ClassSection? selectedClassSection;
  final TeacherSubject? selectedSubject;
  final Lesson? selectedLesson;
  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => EditTopicCubit(),
        ),
        BlocProvider(
          create: (context) => CreateTopicCubit(),
        ),
        BlocProvider(
          create: (context) => LessonsCubit(),
        ),
        BlocProvider(
          create: (context) => ClassSectionsAndSubjectsCubit(),
        ),
      ],
      child: TeacherAddEditTopicScreen(
        topic: arguments?['topic'],
        selectedClassSection: arguments?['selectedClassSection'],
        selectedSubject: arguments?['selectedSubject'],
        selectedLesson: arguments?['selectedLesson'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required Topic? topic,
      required ClassSection? selectedClassSection,
      required TeacherSubject? selectedSubject,
      required Lesson? selectedLesson}) {
    return {
      "topic": topic,
      "selectedClassSection": selectedClassSection,
      "selectedSubject": selectedSubject,
      "selectedLesson": selectedLesson,
    };
  }

  const TeacherAddEditTopicScreen(
      {super.key,
      required this.topic,
      this.selectedClassSection,
      this.selectedSubject,
      this.selectedLesson});

  @override
  State<TeacherAddEditTopicScreen> createState() =>
      _TeacherAddEditTopicScreenState();
}

class _TeacherAddEditTopicScreenState extends State<TeacherAddEditTopicScreen> {
  late ClassSection? _selectedClassSection = widget.selectedClassSection;
  late TeacherSubject? _selectedSubject = widget.selectedSubject;
  late Lesson? _selectedLesson = widget.selectedLesson;

  //This will determine if need to refresh the previous page
  //topics data. If teacher remove the the any study material
  //so we need to fetch the list again
  late bool refreshTopicsInPreviousPage = false;

  late final TextEditingController _topicNameTextEditingController =
      TextEditingController(
    text: widget.topic?.name,
  );
  late final TextEditingController _topicDescriptionTextEditingController =
      TextEditingController(
    text: widget.topic?.description,
  );

  List<PickedStudyMaterial> _addedStudyMaterials = [];

  late List<StudyMaterial> studyMaterials = widget.topic?.studyMaterials ?? [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<ClassSectionsAndSubjectsCubit>()
            .getClassSectionsAndSubjects(
                classSectionId: _selectedClassSection?.id);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _topicNameTextEditingController.dispose();
    _topicDescriptionTextEditingController.dispose();
    super.dispose();
  }

  void deleteStudyMaterial(int studyMaterialId) {
    studyMaterials.removeWhere((element) => element.id == studyMaterialId);
    refreshTopicsInPreviousPage = true;
    setState(() {});
  }

  void updateStudyMaterials(StudyMaterial studyMaterial) {
    final studyMaterialIndex =
        studyMaterials.indexWhere((element) => element.id == studyMaterial.id);
    studyMaterials[studyMaterialIndex] = studyMaterial;
    refreshTopicsInPreviousPage = true;
    setState(() {});
  }

  void _addStudyMaterial(PickedStudyMaterial pickedStudyMaterial) {
    setState(() {
      _addedStudyMaterials.add(pickedStudyMaterial);
    });
  }

  void showErrorMessage(String errorMessageKey) {
    Utils.showSnackBar(
      context: context,
      message: errorMessageKey,
    );
  }

  void editTopic() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_topicNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseEnterTopicNameKey);
      return;
    }

    if (_topicDescriptionTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseEnterTopicDescriptionKey);
      return;
    }

    context.read<EditTopicCubit>().editTopic(
          topicDescription: _topicDescriptionTextEditingController.text.trim(),
          topicName: _topicNameTextEditingController.text.trim(),
          lessonId: _selectedLesson?.id ?? 0,
          classSectionId: _selectedClassSection?.id ?? 0,
          subjectId: _selectedSubject?.id ?? 0,
          topicId: widget.topic?.id ?? 0,
          files: _addedStudyMaterials,
        );
  }

  void createTopic() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_selectedSubject == null) {
      showErrorMessage(noSubjectSelectedKey);
      return;
    }
    if (_selectedLesson == null) {
      showErrorMessage(noLessonSelectedKey);
      return;
    }
    if (_selectedClassSection == null) {
      showErrorMessage(noClassSectionSelectedKey);
      return;
    }
    if (_topicNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseEnterTopicNameKey);
      return;
    }

    if (_topicDescriptionTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseEnterTopicDescriptionKey);
      return;
    }

    context.read<CreateTopicCubit>().createTopic(
          topicName: _topicNameTextEditingController.text.trim(),
          lessonId: _selectedLesson?.id ?? 0,
          classSectionId: _selectedClassSection?.id ?? 0,
          subjectId: _selectedSubject?.id ?? 0,
          topicDescription: _topicDescriptionTextEditingController.text.trim(),
          files: _addedStudyMaterials,
        );
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
              final successState = (context
                  .read<ClassSectionsAndSubjectsCubit>()
                  .state as ClassSectionsAndSubjectsFetchSuccess);
              changeSelectedTeacherSubject(successState.subjects.firstOrNull);
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

  Widget _buildButtonContent({
    required VoidCallback onTap,
    required bool isLoading,
    required String title,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      splashColor: Colors.white.withOpacity(0.2),
      highlightColor: Colors.white.withOpacity(0.1),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
            ],
            Text(
              isLoading ? 'Memproses...' : title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            if (!isLoading) ...[
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 22,
              ).animate(onPlay: (controller) {
                controller.repeat(reverse: true);
              }).slideX(
                begin: 0,
                end: 0.3,
                duration: Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: widget.topic != null
              ? BlocConsumer<EditTopicCubit, EditTopicState>(
                  listener: (context, state) {
                    if (state is EditTopicSuccess) {
                      Get.back(result: true);
                      Utils.showSnackBar(
                          context: context,
                          message: topicEditedSuccessfullyKey);
                    } else if (state is EditTopicFailure) {
                      Utils.showSnackBar(
                          context: context, message: state.errorMessage);
                    }
                  },
                  builder: (context, state) {
                    return _buildButtonContent(
                      onTap: () {
                        if (state is EditTopicInProgress) return;
                        editTopic();
                      },
                      isLoading: state is EditTopicInProgress,
                      title: 'Perbarui Topik',
                    );
                  },
                )
              : BlocConsumer<CreateTopicCubit, CreateTopicState>(
                  listener: (context, state) {
                    if (state is CreateTopicSuccess) {
                      Utils.showSnackBar(
                          context: context, message: topicAddedSuccessfullyKey);
                      _topicNameTextEditingController.text = "";
                      _topicDescriptionTextEditingController.text = "";
                      _addedStudyMaterials = [];
                      refreshTopicsInPreviousPage = true;
                      setState(() {});
                      Navigator.pop(context, true);
                    } else if (state is CreateTopicFailure) {
                      Utils.showSnackBar(
                          context: context, message: state.errorMessage);
                    }
                  },
                  builder: (context, state) {
                    return _buildButtonContent(
                      onTap: () {
                        if (state is CreateTopicInProgress) return;
                        createTopic();
                      },
                      isLoading: state is CreateTopicInProgress,
                      title: 'Buat Topik',
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildFormContent(ClassSectionsAndSubjectsState state) {
    return state is ClassSectionsAndSubjectsFetchFailure
        ? Center(
            child: ErrorContainer(
            errorMessage: state.errorMessage,
            onTapRetry: () {
              context
                  .read<ClassSectionsAndSubjectsCubit>()
                  .getClassSectionsAndSubjects();
            },
          ))
        : Column(
            children: [
              // Basic Info Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Dasar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Class Selection
                    _buildAnimatedTextField(
                      controller: TextEditingController(
                          text:
                              _selectedClassSection?.fullName ?? 'Pilih Kelas'),
                      label: 'Bagian Kelas',
                      icon: Icons.class_,
                      readOnly: true,
                      onTap: () {
                        if (state is ClassSectionsAndSubjectsFetchSuccess) {
                          Utils.showBottomSheet(
                              child: FilterSelectionBottomsheet<ClassSection>(
                                showFilterByLabel: false,
                                onSelection: (value) {
                                  changeSelectedClassSection(value);
                                  Get.back();
                                },
                                selectedValue: _selectedClassSection!,
                                titleKey: classKey,
                                values: state.classSections,
                              ),
                              context: context);
                        }
                      },
                    ),
                    SizedBox(height: 15),

                    // Subject Selection
                    _buildAnimatedTextField(
                      controller: TextEditingController(
                          text: _selectedSubject?.subject
                                  .getSybjectNameWithType() ??
                              'Pilih Mata Pelajaran'),
                      label: 'Mata Pelajaran',
                      icon: Icons.subject,
                      readOnly: true,
                      onTap: () {
                        if (state is ClassSectionsAndSubjectsFetchSuccess) {
                          Utils.showBottomSheet(
                              child: FilterSelectionBottomsheet<TeacherSubject>(
                                showFilterByLabel: false,
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
                    ),
                    SizedBox(height: 15),

                    // Lesson Selection
                    BlocBuilder<LessonsCubit, LessonsState>(
                      builder: (context, lessonState) {
                        return _buildAnimatedTextField(
                          controller: TextEditingController(
                              text: _selectedLesson?.name ?? 'Pilih Pelajaran'),
                          label: 'Pelajaran',
                          icon: Icons.book_outlined,
                          readOnly: true,
                          onTap: () {
                            if (lessonState is LessonsFetchSuccess) {
                              Utils.showBottomSheet(
                                  child: FilterSelectionBottomsheet<Lesson>(
                                    showFilterByLabel: false,
                                    selectedValue: _selectedLesson!,
                                    titleKey: lessonKey,
                                    values: lessonState.lessons,
                                    onSelection: (value) {
                                      if (_selectedLesson != value) {
                                        _selectedLesson = value;
                                        setState(() {});
                                      }
                                      Get.back();
                                    },
                                  ),
                                  context: context);
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Topic Details Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Topik',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildAnimatedTextField(
                      controller: _topicNameTextEditingController,
                      label: 'Nama Topik',
                      icon: Icons.topic,
                    ),
                    SizedBox(height: 15),
                    _buildAnimatedTextField(
                      controller: _topicDescriptionTextEditingController,
                      label: 'Deskripsi',
                      icon: Icons.description,
                      maxLines: 5,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Study Materials Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Materi Pembelajaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Existing study materials
                    if (widget.topic != null) ...[
                      ...studyMaterials.map(
                        (studyMaterial) => Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: StudyMaterialContainer(
                            onDeleteStudyMaterial: deleteStudyMaterial,
                            onEditStudyMaterial: updateStudyMaterials,
                            showEditAndDeleteButton: true,
                            studyMaterial: studyMaterial,
                          ),
                        ),
                      ),
                    ],

                    // Added study materials
                    ..._addedStudyMaterials.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: AddedStudyMaterialContainer(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              onDelete: (index) {
                                _addedStudyMaterials.removeAt(index);
                                setState(() {});
                              },
                              onEdit: (index, file) {
                                _addedStudyMaterials[index] = file;
                                setState(() {});
                              },
                              file: entry.value,
                              fileIndex: entry.key,
                            ),
                          ),
                        ),

                    SizedBox(height: 15),

                    // Add study material button
                    UploadImageOrFileButton(
                      uploadFile: true,
                      customTitleKey: addStudyMaterialKey,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        Utils.showBottomSheet(
                          child: AddStudyMaterialBottomsheet(
                            editFileDetails: false,
                            onTapSubmit: _addStudyMaterial,
                          ),
                          context: context,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        Get.back(result: refreshTopicsInPreviousPage);
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF8B0000).withOpacity(0.9),
                Color(0xFF6B0000),
                Color(0xFF4B0000),
                Theme.of(context).colorScheme.secondary,
              ],
              stops: [0.2, 0.4, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () =>
                            Get.back(result: refreshTopicsInPreviousPage),
                      ),
                      Text(
                        widget.topic != null ? 'Edit Topik' : 'Buat Topik',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Header with Icon
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.9),
                                  Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.topic_rounded,
                                  size: 42,
                                  color: Colors.white,
                                )
                                    .animate()
                                    .scale(duration: 500.ms)
                                    .then()
                                    .shimmer(duration: 1000.ms),
                                SizedBox(height: 15),
                                Text(
                                  widget.topic != null
                                      ? "Edit Topik"
                                      : "Buat Topik",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10,
                                        color: Colors.black26,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 25),

                          // Form Content
                          BlocConsumer<ClassSectionsAndSubjectsCubit,
                              ClassSectionsAndSubjectsState>(
                            listener: (context, state) {
                              if (state
                                  is ClassSectionsAndSubjectsFetchSuccess) {
                                if (_selectedClassSection == null) {
                                  changeSelectedClassSection(
                                      state.classSections.firstOrNull,
                                      fetchNewSubjects: false);
                                }
                                if (_selectedSubject == null) {
                                  changeSelectedTeacherSubject(
                                      state.subjects.firstOrNull);
                                }
                              }
                            },
                            builder: (context, state) {
                              return _buildFormContent(state);
                            },
                          ),

                          SizedBox(height: 30),

                          // Submit Button
                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
