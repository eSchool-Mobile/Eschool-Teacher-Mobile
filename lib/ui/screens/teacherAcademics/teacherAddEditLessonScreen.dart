import 'package:eschool_saas_staff/cubits/teacherAcademics/classSectionsAndSubjects.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/lesson/createLessonCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/lesson/editLessonCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/lesson.dart';
import 'package:eschool_saas_staff/data/models/pickedStudyMaterial.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/data/models/teacherSubject.dart';
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
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TeacherAddEditLessonScreen extends StatefulWidget {
  final Lesson? lesson;
  final ClassSection? selectedClassSection;
  final TeacherSubject? selectedSubject;
  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CreateLessonCubit(),
        ),
        BlocProvider(
          create: (context) => EditLessonCubit(),
        ),
        BlocProvider(
          create: (context) => ClassSectionsAndSubjectsCubit(),
        ),
      ],
      child: TeacherAddEditLessonScreen(
        lesson: arguments?['lesson'],
        selectedClassSection: arguments?['selectedClassSection'],
        selectedSubject: arguments?['selectedSubject'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required Lesson? lesson,
      required ClassSection? selectedClassSection,
      required TeacherSubject? selectedSubject}) {
    return {
      "lesson": lesson,
      "selectedClassSection": selectedClassSection,
      "selectedSubject": selectedSubject
    };
  }

  const TeacherAddEditLessonScreen(
      {super.key,
      required this.lesson,
      this.selectedClassSection,
      this.selectedSubject});

  @override
  State<TeacherAddEditLessonScreen> createState() =>
      _TeacherAddEditLessonScreenState();
}

class _TeacherAddEditLessonScreenState extends State<TeacherAddEditLessonScreen>
    with TickerProviderStateMixin {
  late ClassSection? _selectedClassSection = widget.selectedClassSection;
  late TeacherSubject? _selectedSubject = widget.selectedSubject;

  //This will determine if need to refresh the previous page
  //lesson data. If teacher remove the the any study material
  //so we need to fetch the list again
  late bool refreshLessonsInPreviousPage = false;

  late final TextEditingController _lessonNameTextEditingController =
      TextEditingController(
    text: widget.lesson?.name,
  );
  late final TextEditingController _lessonDescriptionTextEditingController =
      TextEditingController(
    text: widget.lesson?.description,
  );

  List<PickedStudyMaterial> _addedStudyMaterials = [];

  late List<StudyMaterial> studyMaterials = widget.lesson?.studyMaterials ?? [];

  // Animation controllers for the glowing effects
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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

    // Add this with your other controller initialization
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    super.initState();
  }

  @override
  void dispose() {
    _lessonNameTextEditingController.dispose();
    _lessonDescriptionTextEditingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void deleteStudyMaterial(int studyMaterialId) {
    studyMaterials.removeWhere((element) => element.id == studyMaterialId);
    refreshLessonsInPreviousPage = true;
    setState(() {});
  }

  void updateStudyMaterials(StudyMaterial studyMaterial) {
    final studyMaterialIndex =
        studyMaterials.indexWhere((element) => element.id == studyMaterial.id);
    studyMaterials[studyMaterialIndex] = studyMaterial;
    refreshLessonsInPreviousPage = true;
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

  void changeSelectedTeacherSubject(TeacherSubject? teacherSubject,
      {bool fetchNewLessons = true}) {
    if (_selectedSubject != teacherSubject) {
      _selectedSubject = teacherSubject;
      setState(() {});
    }
  }

  void editLesson() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_selectedSubject == null) {
      showErrorMessage(noSubjectSelectedKey);
      return;
    }

    if (_selectedClassSection == null) {
      showErrorMessage(noClassSectionSelectedKey);
      return;
    }

    if (_lessonNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseEnterLessonNameKey);
      return;
    }

    if (_lessonDescriptionTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseEnterLessonDescriptionKey);
      return;
    }

    context.read<EditLessonCubit>().editLesson(
          lessonDescription:
              _lessonDescriptionTextEditingController.text.trim(),
          lessonName: _lessonNameTextEditingController.text.trim(),
          lessonId: widget.lesson!.id,
          classSectionId: widget.lesson!.classSectionId,
          classSubjectId: _selectedSubject?.classSubjectId ?? 0,
          files: _addedStudyMaterials,
        );
  }

  void createLesson() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_selectedSubject == null) {
      showErrorMessage(noSubjectSelectedKey);
      return;
    }
    if (_lessonNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseEnterLessonNameKey);
      return;
    }

    if (_lessonDescriptionTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseEnterLessonDescriptionKey);
      return;
    }

    context.read<CreateLessonCubit>().createLesson(
          classSectionId: _selectedClassSection?.id ?? 0,
          files: _addedStudyMaterials,
          classSubjectId: _selectedSubject?.classSubjectId ?? 0,
          lessonDescription:
              _lessonDescriptionTextEditingController.text.trim(),
          lessonName: _lessonNameTextEditingController.text.trim(),
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
          child: widget.lesson != null
              ? BlocConsumer<EditLessonCubit, EditLessonState>(
                  listener: (context, state) {
                    if (state is EditLessonSuccess) {
                      // Show auto-dismissing success banner
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
                                  'Pelajaran berhasil diperbarui!',
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
                          margin: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                      );

                      // Add slight delay before popping
                      Future.delayed(Duration(milliseconds: 2200), () {
                        if (context.mounted) {
                          Navigator.pop(context, true);
                        }
                      });
                    } else if (state is EditLessonFailure) {
                      Utils.showSnackBar(
                          context: context, message: state.errorMessage);
                    }
                  },
                  builder: (context, state) {
                    return _buildButtonContent(
                      onTap: () {
                        if (state is EditLessonInProgress) return;
                        editLesson();
                      },
                      isLoading: state is EditLessonInProgress,
                      title: 'Perbarui Pelajaran',
                    );
                  },
                )
              : BlocConsumer<CreateLessonCubit, CreateLessonState>(
                  listener: (context, state) {
                    if (state is CreateLessonSuccess) {
                      // Show auto-dismissing success banner
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
                                  'Pelajaran berhasil ditambahkan!',
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
                          margin: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                      );
                      _lessonDescriptionTextEditingController.text = "";
                      _lessonNameTextEditingController.text = "";
                      _addedStudyMaterials = [];
                      refreshLessonsInPreviousPage = true;
                      setState(() {});
                      Navigator.pop(context, true);
                    } else if (state is CreateLessonFailure) {
                      Utils.showSnackBar(
                          context: context, message: state.errorMessage);
                    }
                  },
                  builder: (context, state) {
                    return _buildButtonContent(
                      onTap: () {
                        if (state is CreateLessonInProgress) return;
                        createLesson();
                      },
                      isLoading: state is CreateLessonInProgress,
                      title: 'Buat Pelajaran',
                    );
                  },
                ),
        ),
      ),
    );
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

  Widget _buildAddEditLessonForm() {
    return SingleChildScrollView(
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
                  Theme.of(context).colorScheme.primary.withOpacity(0.9),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.7),
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
                  Icons.school_rounded,
                  size: 42,
                  color: Colors.white,
                )
                    .animate()
                    .scale(duration: 500.ms)
                    .then()
                    .shimmer(duration: 1000.ms),
                SizedBox(height: 15),
                Text(
                  widget.lesson != null ? "Edit Pelajaran" : "Buat Pelajaran",
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
              // Add listener implementation if needed
            },
            builder: (context, state) {
              return state is ClassSectionsAndSubjectsFetchFailure
                  ? Center(
                      child: ErrorContainer(
                      errorMessage:
                          (state as ClassSectionsAndSubjectsFetchFailure)
                              .errorMessage,
                      onTapRetry: () {
                        context
                            .read<ClassSectionsAndSubjectsCubit>()
                            .getClassSectionsAndSubjects();
                      },
                    ))
                  : _buildFormContent(state);
            },
          ),

          SizedBox(height: 30),

          // Submit Button
          _buildSubmitButton(),
        ],
      ),
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
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Lesson Details Section
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
                      'Detail Pelajaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildAnimatedTextField(
                      controller: _lessonNameTextEditingController,
                      label: 'Nama Pelajaran',
                      icon: Icons.book,
                    ),
                    SizedBox(height: 15),
                    _buildAnimatedTextField(
                      controller: _lessonDescriptionTextEditingController,
                      label: 'Deskripsi',
                      icon: Icons.description,
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
                    // Existing study materials (only show in edit mode)
                    if (widget.lesson != null) ...[
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

  // Add this helper method for consistent text field styling
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
      maxLines: label == 'Deskripsi'
          ? null
          : maxLines, // null allows unlimited lines for description
      readOnly: readOnly,
      onTap: onTap,
      keyboardType:
          label == 'Deskripsi' ? TextInputType.multiline : keyboardType,
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
        // Add alignment for multiline inputs
        alignLabelWithHint: label == 'Deskripsi',
        contentPadding: EdgeInsets.symmetric(
            horizontal: 15, vertical: label == 'Deskripsi' ? 20 : 15),
      ),
      validator: (v) => v!.isEmpty ? 'Required' : null,
      minLines: label == 'Deskripsi'
          ? 3
          : 1, // Start with at least 3 lines for description
    );
  }

  Widget _buildGlowingIconButton(IconData icon, VoidCallback onTap) {
    // Define your color constants
    final Color _highlightColor = Color(0xFFB84D4D); // Softer bright maroon

    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12),
              boxShadow: [
                BoxShadow(
                  color: _highlightColor
                      .withOpacity(0.1 + 0.1 * _pulseAnimation.value),
                  blurRadius: 12 * (1 + _pulseAnimation.value),
                  spreadRadius: 2 * _pulseAnimation.value,
                )
              ],
              border: Border.all(
                color: Colors.white
                    .withOpacity(0.1 + 0.05 * _pulseAnimation.value),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          );
        },
      ),
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
        Get.back(result: refreshLessonsInPreviousPage);
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF7A1E23), // Softer deep maroon
                Color(0xFF5A2223), // Softer deeper maroon
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                SlideInDown(
                  duration: Duration(milliseconds: 800),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        // Back button with glowing effect
                        _buildGlowingIconButton(
                          Icons.arrow_back_rounded,
                          () {
                            HapticFeedback.mediumImpact();
                            Get.back(result: refreshLessonsInPreviousPage);
                          },
                        ),

                        SizedBox(width: 16),

                        // Title and subtitle in column
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.lesson != null
                                    ? 'Edit Pelajaran'
                                    : 'Buat Pelajaran',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Kelola materi pembelajaran',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                    child: _buildAddEditLessonForm(),
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
