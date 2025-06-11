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
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/uploadImageOrFileButton.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

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

class _TeacherAddEditTopicScreenState extends State<TeacherAddEditTopicScreen>
    with TickerProviderStateMixin {
  late ClassSection? _selectedClassSection = widget.selectedClassSection;
  late TeacherSubject? _selectedSubject = widget.selectedSubject;
  late Lesson? _selectedLesson = widget.selectedLesson;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController
      _fabAnimationController; // Added for CustomModernAppBar

  // Theme colors - Softer Maroon palette
  final Color _primaryColor = Color(0xFF7A1E23); // Softer deep maroon
  final Color _accentColor = Color(0xFF9D3C3C); // Softer medium maroon
  final Color _highlightColor = Color(0xFFB84D4D); // Softer bright maroon

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
    super.initState();
    // Debug: Check study materials
    print("=== Topic Study Materials Debug ===");
    print("Topic is null: ${widget.topic == null}");
    print("Study materials count: ${studyMaterials.length}");
    if (widget.topic != null) {
      print("Topic name: ${widget.topic!.name}");
      print(
          "Topic studyMaterials count: ${widget.topic!.studyMaterials.length}");
      widget.topic!.studyMaterials.forEach((material) {
        print(
            "Study Material: ${material.fileName} - Type: ${material.studyMaterialType}");
      });
    }
    print("================================");

    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<ClassSectionsAndSubjectsCubit>()
            .getClassSectionsAndSubjects(
                classSectionId: _selectedClassSection?.id);
      }
    }); // Add animation controllers initialization
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();

    // Controller for pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    // Initialize fabAnimationController for CustomModernAppBar
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _fabAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _topicNameTextEditingController.dispose();
    _topicDescriptionTextEditingController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    _fabAnimationController.dispose(); // Added to dispose the controller
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

  // Helper methods for attachment type styling
  Color _getAttachmentTypeColor(StudyMaterialType type) {
    switch (type) {
      case StudyMaterialType.youtubeVideo:
        return Colors.red.shade600;
      case StudyMaterialType.uploadedVideoUrl:
        return Colors.purple.shade600;
      case StudyMaterialType.file:
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getAttachmentIcon(StudyMaterialType type) {
    switch (type) {
      case StudyMaterialType.youtubeVideo:
        return Icons.play_circle_fill;
      case StudyMaterialType.uploadedVideoUrl:
        return Icons.video_file;
      case StudyMaterialType.file:
        return Icons.attach_file;
      default:
        return Icons.attachment;
    }
  }

  String _getAttachmentTypeLabel(StudyMaterialType type) {
    switch (type) {
      case StudyMaterialType.youtubeVideo:
        return 'Video YouTube';
      case StudyMaterialType.uploadedVideoUrl:
        return 'Video Upload';
      case StudyMaterialType.file:
        return 'File/Dokumen';
      default:
        return 'Lampiran';
    }
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
                                  'Topik berhasil diperbarui!',
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
                                  'Topik berhasil ditambahkan!',
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

                      // Clear form and pop with slight delay
                      Future.delayed(Duration(milliseconds: 2200), () {
                        if (context.mounted) {
                          Navigator.pop(context, true);
                        }
                      });
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
    int? maxLength,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    bool expandable =
        false, // Tambahkan parameter untuk input yang dapat mengembang
  }) {
    return TextFormField(
      controller: controller,
      maxLines:
          expandable ? null : maxLines, // Set null agar bisa ekspansi otomatis
      minLines: expandable
          ? 3
          : maxLines, // Set minimal line untuk input yang expandable
      maxLength: maxLength,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType ??
          (expandable ? TextInputType.multiline : TextInputType.text),
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
        counterText: "", // Menyembunyikan indikator jumlah karakter
        alignLabelWithHint:
            expandable, // Agar label selaras dengan baris pertama pada input multiline
      ),
      validator: (v) => v!.isEmpty ? 'Required' : null,
      textAlignVertical:
          expandable ? TextAlignVertical.top : TextAlignVertical.center,
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
                        maxLength: 128),
                    SizedBox(height: 15),
                    _buildAnimatedTextField(
                      controller: _topicDescriptionTextEditingController,
                      label: 'Deskripsi',
                      icon: Icons.description,
                      maxLength: 1024,
                      expandable: true, // Aktifkan fitur ekspansi otomatis
                      keyboardType: TextInputType.multiline,
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

                    // Existing study materials/attachments - Show when editing topic
                    if (studyMaterials.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.attachment_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Lampiran yang Sudah Ada',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${studyMaterials.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),

                      // Display existing attachments in enhanced card format
                      ...studyMaterials.map(
                        (studyMaterial) => Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: _getAttachmentTypeColor(
                                      studyMaterial.studyMaterialType)
                                  .withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Attachment type indicator
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _getAttachmentTypeColor(
                                          studyMaterial.studyMaterialType)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getAttachmentIcon(
                                          studyMaterial.studyMaterialType),
                                      color: _getAttachmentTypeColor(
                                          studyMaterial.studyMaterialType),
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      _getAttachmentTypeLabel(
                                          studyMaterial.studyMaterialType),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _getAttachmentTypeColor(
                                            studyMaterial.studyMaterialType),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Study material content
                              StudyMaterialContainer(
                                onDeleteStudyMaterial: deleteStudyMaterial,
                                onEditStudyMaterial: updateStudyMaterials,
                                showEditAndDeleteButton: true,
                                studyMaterial: studyMaterial,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),
                    ],

                    // Added study materials (new ones being added)
                    if (_addedStudyMaterials.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Lampiran Baru',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_addedStudyMaterials.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      ..._addedStudyMaterials.asMap().entries.map(
                            (entry) => Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: AddedStudyMaterialContainer(
                                backgroundColor: Colors.blue.shade50,
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
                    ],

                    // Add study material button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: UploadImageOrFileButton(
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
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  Widget _buildGlowingIconButton(IconData icon, VoidCallback onTap) {
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

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.15),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: CircleBorder(),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
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
        Get.back(result: refreshTopicsInPreviousPage);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true, // Allow content behind status bar
        appBar: CustomModernAppBar(
          title: widget.topic != null ? "Edit Topik" : "Tambah Topik",
          icon: Icons.topic_rounded,
          fabAnimationController: _fabAnimationController,
          onBackPressed: () {
            Get.back(result: refreshTopicsInPreviousPage);
          },
          primaryColor: _primaryColor,
          lightColor: _accentColor,
          height: 80,
        ),
        body: Container(
          color: Colors.grey[50], // White background for the entire screen
          child: Column(
            children: [
              SizedBox(
                  height: 80 +
                      MediaQuery.of(context).padding.top), // Space for app bar

              // Main content section
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Form Content
                      BlocConsumer<ClassSectionsAndSubjectsCubit,
                          ClassSectionsAndSubjectsState>(
                        listener: (context, state) {
                          if (state is ClassSectionsAndSubjectsFetchSuccess) {
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
            ],
          ),
        ),
      ),
    );
  }
}
