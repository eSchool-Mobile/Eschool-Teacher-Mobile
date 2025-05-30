import 'package:eschool_saas_staff/cubits/teacherAcademics/assignment/createAssignmentCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/assignment/editAssignmentCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/classSectionsAndSubjects.dart';
import 'package:eschool_saas_staff/data/repositories/assignmentRepository.dart';
import 'package:eschool_saas_staff/data/models/assignment.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/data/models/teacherSubject.dart';
import 'package:eschool_saas_staff/data/models/AssignmentFiletype.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customFileContainer.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/studyMaterialContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCheckboxContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customDropdownSelectionButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/uploadImageOrFileButton.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TeacherAddEditAssignmentScreen extends StatefulWidget {
  final Assignment? assignment;
  final ClassSection? selectedClassSection;
  final TeacherSubject? selectedSubject;
  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CreateAssignmentCubit(),
        ),
        BlocProvider(
          create: (context) => EditAssignmentCubit(),
        ),
        BlocProvider(
          create: (context) => ClassSectionsAndSubjectsCubit(),
        ),
      ],
      child: TeacherAddEditAssignmentScreen(
        assignment: arguments?['assignment'],
        selectedClassSection: arguments?['selectedClassSection'],
        selectedSubject: arguments?['selectedSubject'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required Assignment? assignment,
      required ClassSection? selectedClassSection,
      required TeacherSubject? selectedSubject}) {
    return {
      "assignment": assignment,
      "selectedClassSection": selectedClassSection,
      "selectedSubject": selectedSubject
    };
  }

  const TeacherAddEditAssignmentScreen(
      {super.key,
      required this.assignment,
      this.selectedClassSection,
      this.selectedSubject});

  @override
  State<TeacherAddEditAssignmentScreen> createState() =>
      _TeacherAddEditAssignmentScreenState();
}

class _TeacherAddEditAssignmentScreenState
    extends State<TeacherAddEditAssignmentScreen>
    with TickerProviderStateMixin {
  late ClassSection? _selectedClassSection = widget.selectedClassSection;
  late TeacherSubject? _selectedSubject = widget.selectedSubject;

  // Animation controllers
  late AnimationController _fabAnimationController;
  late AnimationController _animationController;
  late AnimationController _pulseController;

  // Theme colors
  final Color _primaryColor = Color(0xFF7A1E23); // Deep maroon
  final Color _accentColor = Color(0xFF9D3C3C); // Medium maroon
  final Color _highlightColor = Color(0xFFB84D4D); // Bright maroon
  final Color _energyColor = Color(0xFFCE6D6D); // Light maroon
  final Color _glowColor = Color(0xFFAF4F4F); // Rich maroon  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomModernAppBar(
        title: widget.assignment != null ? "Edit Tugas" : "Buat Tugas",
        icon: Icons.assignment_rounded,
        fabAnimationController: _fabAnimationController,
        onBackPressed: () {
          Get.back(result: refreshAssignmentsInPreviousPage);
        },
        // Not showing any of the optional buttons as requested
        showAddButton: false,
        showArchiveButton: false,
        showFilterButton: false,
        showHelperButton: false,
      ),
      body: _buildAddEditAssignmentForm(),
    );
  }

  //This will determine if need to refresh the previous page
  //assignments data. If teacher remove the the any file
  //so we need to fetch the list again
  late bool refreshAssignmentsInPreviousPage = false;

  late final TextEditingController _assignmentNameTextEditingController =
      TextEditingController(
    text: widget.assignment?.name,
  );
  late final TextEditingController _assignmentDescriptionTextEditingController =
      TextEditingController(
    text: widget.assignment?.description ?? '', // Add null safety
  );

  late final List<StudyMaterial> _assignmentUploadedFilesEditingController =
      List.from(widget.assignment?.studyMaterial ?? []);

  late final TextEditingController _assignmentPointsTextEditingController =
      TextEditingController(
    text: widget.assignment?.points.toString(),
  );

  late final TextEditingController _extraResubmissionDaysTextEditingController =
      TextEditingController(
          text: widget.assignment?.extraDaysForResubmission.toString() ?? "0");
  // Using resubmission information from assignment
  bool _getResubmissionStatus() => widget.assignment?.resubmission == 0;

  late DateTime? dueDate =
      DateTime.tryParse(widget.assignment?.dueDate.toString() ?? "");

  late TimeOfDay? dueTime = widget.assignment != null
      ? TimeOfDay.fromDateTime(widget.assignment!.dueDate)
      : null;

  List<PlatformFile> uploadedFiles = [];

  late List<StudyMaterial> assignmentAttachments =
      widget.assignment?.studyMaterial ?? [];

  List<AssignmentFileType> fileTypes = [];

  late final TextEditingController _minPointsTextEditingController =
      TextEditingController(
    text: widget.assignment?.minPoints != null &&
            widget.assignment!.minPoints != 0
        ? widget.assignment!.minPoints.toString()
        : '',
  );
  final TextEditingController _startDateTextEditingController =
      TextEditingController(); // Add this line
  final TextEditingController _endDateTextEditingController =
      TextEditingController(); // Add this line
  late final TextEditingController _maxFileSizeTextEditingController =
      TextEditingController(
          text: widget.assignment?.maxFile != null &&
                  widget.assignment!.maxFile != 0
              ? widget.assignment!.maxFile.toString()
              : '');
  late final TextEditingController _maxFileTextEditingController =
      TextEditingController(
    text: widget.assignment?.maxFile != null && widget.assignment!.maxFile != 0
        ? widget.assignment!.maxFile.toString()
        : '',
  );

  late DateTime? start_date =
      widget.assignment != null ? widget.assignment!.startDate : null;

  late DateTime? end_date =
      widget.assignment != null ? widget.assignment!.endDate : null;

  String? selectedAnswerType = "dokumen"; // Default to dokumen

  late bool _isTextAnswerAllowed;
  late bool _isFileAnswerAllowed;
  // These variables are already declared above, no need to redeclare
  // Just using the existing animation controllers

  // These colors are used in the UI elements
  Color get primaryColorUI => _primaryColor;
  Color get accentColorUI => _accentColor;
  Color get highlightColorUI => _highlightColor;
  Color get energyColorUI => _energyColor;
  Color get glowColorUI => _glowColor;
  @override
  void initState() {
    super
        .initState(); // Initialize the animation controller for the modern app bar
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    );
    _fabAnimationController.repeat();

    // Add EditAssignment state listener
    context.read<EditAssignmentCubit>().stream.listen((state) {
      if (state is EditAssignmentSuccess) {
        setState(() {
          _assignmentNameTextEditingController.text =
              widget.assignment?.name ?? '';
        });
      }
    });

    // Initialize dates from existing assignment if editing
    if (widget.assignment != null) {
      start_date = widget.assignment!.startDate;
      end_date = widget.assignment!.endDate;

      // Update the text controllers with formatted dates
      _startDateTextEditingController.text =
          DateFormat('dd-MM-yyyy').format(widget.assignment!.startDate);
      _endDateTextEditingController.text =
          DateFormat('dd-MM-yyyy').format(widget.assignment!.endDate);

      // Set description from existing assignment
      _assignmentDescriptionTextEditingController.text =
          widget.assignment!.description;
    }

    _isTextAnswerAllowed = widget.assignment?.text == "1";
    _isFileAnswerAllowed = widget.assignment?.acceptedFile.isNotEmpty ?? false;

    if (_isFileAnswerAllowed && widget.assignment != null) {
      for (var fileType in fileTypes) {
        fileType.isSelected = widget.assignment!.acceptedFile
            .contains(fileType.name.toLowerCase());
      }
    }

    _loadFileTypes().then((_) {
      if (widget.assignment != null) {
        setState(() {
          for (var type in fileTypes) {
            type.isSelected = widget.assignment!.acceptedFile
                .map((e) => e.toLowerCase())
                .contains(type.name.toLowerCase());
          }
        });
      }
    });
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<ClassSectionsAndSubjectsCubit>()
            .getClassSectionsAndSubjects(
                classSectionId: _selectedClassSection?.id);
      }
    });

    // Initialize file types from saved assignment
    if (widget.assignment != null) {
      final savedTypes = widget.assignment!.acceptedFile;
      fileTypes.forEach((type) {
        type.isSelected = savedTypes.contains(type.name.toLowerCase());
      });
    }

    // Initialize animation controllers
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();

    // Add pulse animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    _assignmentNameTextEditingController.dispose();
    _assignmentDescriptionTextEditingController.dispose();
    _assignmentPointsTextEditingController.dispose();
    _extraResubmissionDaysTextEditingController.dispose();
    _minPointsTextEditingController.dispose();
    _startDateTextEditingController.dispose();
    _endDateTextEditingController.dispose();
    _maxFileSizeTextEditingController.dispose();
    _maxFileTextEditingController.dispose();
    super.dispose();
  }

  Future<void> _loadFileTypes() async {
    try {
      final types = await AssignmentRepository().fetchAssignmentFileTypes();
      setState(() {
        fileTypes = types;
      });
    } catch (e) {
      Utils.showSnackBar(
        context: context,
        message: e.toString(),
      );
    }
  }

  Future<void> _addFiles() async {
    final result = await Utils.openFilePicker(context: context);
    if (result != null) {
      uploadedFiles.addAll(result.files);
      setState(() {});
    }
  }

  Future<void> openDatePicker() async {
    final temp = await Utils.openDatePicker(context: context);
    if (temp != null) {
      dueDate = temp;
      setState(() {});
    }
  }

  Future<void> openTimePicker() async {
    final temp = await Utils.openTimePicker(context: context);
    if (temp != null) {
      dueTime = temp;
      setState(() {});
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    start_date = (start_date ?? DateTime.now()).isBefore(DateTime.now())
        ? DateTime.now()
        : start_date;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: start_date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != start_date) {
      setState(() {
        start_date = picked;
        _startDateTextEditingController.text =
            DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: end_date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != end_date) {
      setState(() {
        end_date = picked;
        _endDateTextEditingController.text =
            DateFormat('dd-MM-yyyy').format(picked);
      });
    }
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

  void _showOverlayMessage(
      {required BuildContext context, required String message}) {
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    "Tugas Ditambahkan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void createAssignment() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_selectedSubject == null) {
      showErrorMessage(noSubjectSelectedKey);
      return;
    }

    if (_selectedClassSection == null) {
      showErrorMessage(noClassSectionSelectedKey);
      return;
    }

    if (_assignmentNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseEnterAssignmentNameKey);
      return;
    }
    if (_assignmentPointsTextEditingController.text.length >= 10) {
      showErrorMessage(invalidPointsLengthKey);
      return;
    }
    if (dueDate == null) {
      showErrorMessage(pleaseSelectDateKey);
      return;
    }
    if (dueTime == null) {
      showErrorMessage(pleaseSelectTimeKey);
      return;
    }
    if (start_date == null) {
      // Add this line
      showErrorMessage("Silahkan mengisi Tanggal Penugasan");
      return;
    }

    if (end_date == null) {
      // Add this line
      showErrorMessage("Isi Tanggal Mulai Penugasan.");
      return;
    }

    // Add this validation instead if needed
    if (_extraResubmissionDaysTextEditingController.text.trim().isNotEmpty) {
      final resubmissionCount = int.tryParse(
              _extraResubmissionDaysTextEditingController.text.trim()) ??
          0;
      if (resubmissionCount < 0) {
        showErrorMessage("Jumlah pengumpulan ulang tidak boleh negatif");
        return;
      }
    }

    // Get selected file types
    final selectedFileTypes = _isFileAnswerAllowed
        ? fileTypes
            .where((type) => type.isSelected)
            .map((type) => type.name)
            .toList()
        : [];

    // Prepare text value
    final textValue = _isTextAnswerAllowed ? "1" : "0";

    if (!_isTextAnswerAllowed && !_isFileAnswerAllowed) {
      showErrorMessage("Pilih minimal satu tipe jawaban");
      return;
    }

    if (_isFileAnswerAllowed && selectedFileTypes.isEmpty) {
      showErrorMessage("Pilih minimal satu jenis file yang diizinkan");
      return;
    }

    context.read<CreateAssignmentCubit>().createAssignment(
          classSectionId: _selectedClassSection?.id ?? 0,
          classSubjectId: _selectedSubject?.classSubjectId ?? 0,
          name: _assignmentNameTextEditingController.text.trim(),
          dateTime:
              "${DateFormat('dd-MM-yyyy').format(dueDate!).toString()} ${dueTime!.hour}:${dueTime!.minute}",
          startDate:
              "${DateFormat('dd-MM-yyyy').format(start_date!).toString()}", // Add this line
          endDate:
              "${DateFormat('dd-MM-yyyy').format(end_date!).toString()}", // Add this line
          extraDayForResubmission:
              _extraResubmissionDaysTextEditingController.text.trim(),
          description: _assignmentDescriptionTextEditingController.text.trim(),
          points: _assignmentPointsTextEditingController.text.trim(),
          minPoints:
              _minPointsTextEditingController.text.trim(), // Add this line
          maxFile:
              _maxFileSizeTextEditingController.text.trim(), // Add this line
          resubmission: (int.tryParse(
                      _extraResubmissionDaysTextEditingController.text
                          .trim()) ??
                  0) >
              0,
          file: uploadedFiles,
          acceptedFile: selectedFileTypes.cast<String>(),
          text: textValue,
        );
  }

  void editAssignment() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_assignmentNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseEnterAssignmentNameKey);
      return;
    }
    if (dueDate == null) {
      showErrorMessage(pleaseSelectDateKey);
      return;
    }
    if (_assignmentPointsTextEditingController.text.length >= 10) {
      return;
    }
    if (dueTime == null) {
      showErrorMessage(pleaseSelectDateKey);
      return;
    }
    if (start_date == null) {
      showErrorMessage("Please select start date");
      return;
    }
    if (end_date == null) {
      showErrorMessage("Please select end date");
      return;
    }

    // Add this validation instead if needed
    if (_extraResubmissionDaysTextEditingController.text.trim().isNotEmpty) {
      final resubmissionCount = int.tryParse(
              _extraResubmissionDaysTextEditingController.text.trim()) ??
          0;
      if (resubmissionCount < 0) {
        showErrorMessage("Jumlah pengumpulan ulang tidak boleh negatif");
        return;
      }
    }

    print("File allowed?");
    print(_isFileAnswerAllowed);

    final selectedFileTypes = _isFileAnswerAllowed
        ? fileTypes
            .where((type) => type.isSelected)
            .map((type) => type.name)
            .toList()
        : [];

    if (_isFileAnswerAllowed && selectedFileTypes.isEmpty) {
      showErrorMessage("Pilih minimal satu jenis file yang diizinkan");
      return;
    }

    // Format dates properly for API
    final formattedStartDate = DateFormat('dd-MM-yyyy').format(start_date!);
    final formattedEndDate = DateFormat('dd-MM-yyyy').format(end_date!);
    final textValue = _isTextAnswerAllowed ? "1" : "0";

    print("Must Upload");
    print(uploadedFiles);
    print("====");
    print(_assignmentUploadedFilesEditingController);

    context.read<EditAssignmentCubit>().editAssignment(
          classSelectionId: _selectedClassSection?.id ?? 0,
          classSubjectId: _selectedSubject?.classSubjectId ?? 0,
          name: _assignmentNameTextEditingController.text.trim(),
          dateTime:
              "${DateFormat('dd-MM-yyyy').format(dueDate!).toString()} ${dueTime!.hour}:${dueTime!.minute}",
          extraDayForResubmission:
              _extraResubmissionDaysTextEditingController.text.trim(),
          description: _assignmentDescriptionTextEditingController.text.trim(),
          points: _assignmentPointsTextEditingController.text.trim(),
          minPoints: _minPointsTextEditingController.text.trim(),
          resubmission:
              (_extraResubmissionDaysTextEditingController.text.trim() != '' &&
                      _extraResubmissionDaysTextEditingController.text.trim() !=
                          '0' &&
                      int.tryParse(_extraResubmissionDaysTextEditingController
                              .text
                              .trim()) !=
                          0)
                  ? 1
                  : 0,
          filePaths: uploadedFiles,
          studyMaterials: _assignmentUploadedFilesEditingController,
          assignmentId: widget.assignment!.id,
          // Update these lines to use the actual DateTime objects
          startDate: formattedStartDate,
          endDate: formattedEndDate,
          acceptedFile: selectedFileTypes.cast<String>(),
          text: textValue,
          maxFile:
              int.tryParse(_maxFileSizeTextEditingController.text.trim()) ?? 0,
        );
  }

  Widget _buildSubmitButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: FadeInUp(
        duration: Duration(milliseconds: 600),
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
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: widget.assignment != null
                ? BlocConsumer<EditAssignmentCubit, EditAssignmentState>(
                    listener: (context, state) {
                      if (state is EditAssignmentSuccess) {
                        Get.back(result: true);
                        // Show custom success overlay
                        _showOverlayMessage(
                          context: context,
                          message: assignmentEditedSuccessfullyKey,
                        );
                      } else if (state is EditAssignmentFailure) {
                        Utils.showSnackBar(
                          context: context,
                          message: state.errorMessage,
                        );
                      }
                    },
                    builder: (context, state) {
                      return _buildButtonContent(
                        onTap: () {
                          if (state is EditAssignmentInProgress) return;
                          editAssignment();
                        },
                        isLoading: state is EditAssignmentInProgress,
                        title: 'Perbarui Tugas',
                      );
                    },
                  )
                : BlocConsumer<CreateAssignmentCubit, CreateAssignmentState>(
                    listener: (context, state) {
                      // if (state is CreateAssignmentSuccess) {
                      //   // Utils.showSnackBar(
                      //   //   context: context,
                      //   //   message: assignmentAddedSuccessfullyKey,
                      //   // );
                      if (state is CreateAssignmentSuccess) {
                        // Show custom success overlay
                        _showOverlayMessage(
                          context: context,
                          message: assignmentAddedSuccessfullyKey,
                        );

                        // Add this function somewhere in the class:
                        void showOverlayMessage(
                            {required BuildContext context,
                            required String message}) {
                          OverlayEntry overlayEntry;

                          overlayEntry = OverlayEntry(
                            builder: (context) => Positioned(
                              top: MediaQuery.of(context).size.height * 0.1,
                              width: MediaQuery.of(context).size.width,
                              child: Material(
                                color: Colors.transparent,
                                child: Center(
                                  child: Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade400,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.white),
                                        SizedBox(width: 12),
                                        Text(
                                          message,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );

                          Overlay.of(context).insert(overlayEntry);

                          Future.delayed(Duration(seconds: 2), () {
                            overlayEntry.remove();
                          });
                        }

                        _assignmentNameTextEditingController.text = "";
                        _assignmentDescriptionTextEditingController.text = "";
                        _assignmentPointsTextEditingController.text = "";
                        _extraResubmissionDaysTextEditingController.text = "";
                        // Reset resubmission status
                        dueDate = null;
                        dueTime = null;
                        uploadedFiles = [];
                        assignmentAttachments = [];
                        refreshAssignmentsInPreviousPage = true;
                        setState(() {});
                        Navigator.pop(context, true);
                      } else if (state is CreateAssignmentFailure) {
                        Utils.showSnackBar(
                          context: context,
                          message: state.errorMessage,
                        );
                      }
                    },
                    builder: (context, state) {
                      return _buildButtonContent(
                        onTap: () {
                          if (state is CreateAssignmentInProcess) return;
                          createAssignment();
                        },
                        isLoading: state is CreateAssignmentInProcess,
                        title: 'Buat Tugas',
                      );
                    },
                  ),
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

  Widget _buildAnswerTypeSelection() {
    return Card(
      elevation: 4,
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.assignment_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  "Tipe Jawaban",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomCheckboxContainer(
                    titleKey: 'Teks',
                    backgroundColor: Colors.grey.shade50,
                    value: _isTextAnswerAllowed,
                    onValueChanged: (value) {
                      setState(() {
                        _isTextAnswerAllowed = value ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: CustomCheckboxContainer(
                    titleKey: 'File',
                    backgroundColor: Colors.grey.shade50,
                    value: _isFileAnswerAllowed,
                    onValueChanged: (value) {
                      setState(() {
                        _isFileAnswerAllowed = value ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
            if (_isFileAnswerAllowed) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Jenis File yang Diizinkan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: MediaQuery.of(context).size.width * 0.15,
                        runSpacing: 12,
                        children: List.generate(
                          fileTypes.length,
                          (index) => SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.01,
                              ),
                              decoration: BoxDecoration(
                                color: fileTypes[index].isSelected
                                    ? Theme.of(context).colorScheme.surface
                                    : Theme.of(context).colorScheme.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              child: CheckboxListTile(
                                title: Text(
                                  fileTypes[index].name.toUpperCase(),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: fileTypes[index].isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                value: fileTypes[index].isSelected,
                                activeColor:
                                    Theme.of(context).colorScheme.secondary,
                                checkColor:
                                    Theme.of(context).colorScheme.background,
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                onChanged: (bool? value) {
                                  setState(() {
                                    fileTypes[index].isSelected =
                                        value ?? false;
                                    print(
                                        "CHANGED: ${fileTypes[index].name} : ${fileTypes[index].isSelected}");
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddEditAssignmentForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          // Header with Icon
          Container(
            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
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
                  Icons.assignment_rounded,
                  size: 42,
                  color: Colors.white,
                )
                    .animate()
                    .scale(duration: 500.ms)
                    .then()
                    .shimmer(duration: 1000.ms),
                SizedBox(height: 15),
                Text(
                  widget.assignment != null ? "Edit Tugas" : "Buat Tugas",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
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
    return Column(
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
              SizedBox(height: 20), // Class Section
              // Added label for class section
              Text(
                'Kelas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 8),
              CustomSelectionDropdownSelectionButton(
                isDisabled: widget.assignment != null,
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
                      context: context,
                    );
                  }
                },
                titleKey: _selectedClassSection?.fullName ?? 'Pilih Kelas',
                backgroundColor: Colors.grey.shade50,
              ),
              SizedBox(height: 15), // Subject
              // Added label for subject
              Text(
                'Mata Pelajaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 8),
              CustomSelectionDropdownSelectionButton(
                isDisabled: widget.assignment != null,
                onTap: () {
                  if (state is ClassSectionsAndSubjectsFetchSuccess) {
                    Utils.showBottomSheet(
                      child: FilterSelectionBottomsheet<TeacherSubject>(
                        showFilterByLabel: false,
                        onSelection: (value) {
                          changeSelectedTeacherSubject(value!);
                          Get.back();
                        },
                        selectedValue: _selectedSubject!,
                        titleKey: subjectKey,
                        values: state.subjects,
                      ),
                      context: context,
                    );
                  }
                },
                titleKey: _selectedSubject?.subject.getSybjectNameWithType() ??
                    'Pilih Mata Pelajaran',
                backgroundColor: Colors.grey.shade50,
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Details Section
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
                'Detail Tugas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 20),

              // Assignment Name
              // Added label for assignment name
              Text(
                'Judul Tugas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 8),
              CustomTextFieldContainer(
                textEditingController: _assignmentNameTextEditingController,
                hintTextKey: '',
                backgroundColor: Colors.grey.shade50,
              ),
              SizedBox(height: 15),

              // Description
              // Added label for assignment description
              Text(
                'Deskripsi Tugas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 8),
              CustomTextFieldContainer(
                textEditingController:
                    _assignmentDescriptionTextEditingController,
                maxLines: 5,
                hintTextKey: '',
                backgroundColor: Colors.grey.shade50,
              ),
              SizedBox(height: 15), // Dates
              // Added label for dates
              Text(
                'Tanggal Mulai dan Berakhir',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomSelectionDropdownSelectionButton(
                      onTap: () {
                        _selectStartDate(context);
                      },
                      titleKey: start_date != null
                          ? DateFormat('dd-MM-yyyy').format(start_date!)
                          : "Tanggal Mulai",
                      backgroundColor: Colors.grey.shade50,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CustomSelectionDropdownSelectionButton(
                      onTap: () {
                        _selectEndDate(context);
                      },
                      titleKey: end_date != null
                          ? DateFormat('dd-MM-yyyy').format(end_date!)
                          : "Tanggal Berakhir",
                      backgroundColor: Colors.grey.shade50,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15), // Due Date & Time
              // Added label for due date and time
              Text(
                'Tenggat Waktu Pengumpulan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomSelectionDropdownSelectionButton(
                      onTap: () {
                        openDatePicker();
                      },
                      titleKey: dueDate != null
                          ? Utils.getFormattedDate(dueDate!)
                          : "Tenggat Waktu",
                      backgroundColor: Colors.grey.shade50,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CustomSelectionDropdownSelectionButton(
                      onTap: () {
                        openTimePicker();
                      },
                      titleKey: dueTime != null
                          ? Utils.getFormattedDayOfTime(dueTime!)
                          : "Pilih Jam",
                      backgroundColor: Colors.grey.shade50,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Points Section
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
                'Pengaturan Nilai',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 20),

              // Points
              // Added label for points
              Text(
                'Nilai Maksimal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 8),
              CustomTextFieldContainer(
                keyboardType: TextInputType.number,
                textEditingController: _assignmentPointsTextEditingController,
                hintTextKey: '',
                backgroundColor: Colors.grey.shade50,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 15),

              // Min Points
              // Added label for min points
              Text(
                'Nilai Minimal Kelulusan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 8),
              CustomTextFieldContainer(
                keyboardType: TextInputType.number,
                textEditingController: _minPointsTextEditingController,
                hintTextKey: '',
                backgroundColor: Colors.grey.shade50,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 15),

              // Extra Resubmission Days
              // Added label for resubmission days
              Text(
                'Hari untuk Pengumpulan Ulang',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 8),
              CustomTextFieldContainer(
                keyboardType: TextInputType.number,
                textEditingController:
                    _extraResubmissionDaysTextEditingController,
                hintTextKey: '',
                backgroundColor: Colors.grey.shade50,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Answer Types Section
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
                'Jenis Jawaban',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 20), // Answer Types
              // Added label for text answer
              Text(
                'Jenis Jawaban yang Diizinkan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomCheckboxContainer(
                      titleKey: 'Teks',
                      backgroundColor: Colors.grey.shade50,
                      value: _isTextAnswerAllowed,
                      onValueChanged: (value) {
                        setState(() {
                          _isTextAnswerAllowed = value ?? false;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: CustomCheckboxContainer(
                      titleKey: 'File',
                      backgroundColor: Colors.grey.shade50,
                      value: _isFileAnswerAllowed,
                      onValueChanged: (value) {
                        setState(() {
                          _isFileAnswerAllowed = value ?? false;
                        });
                      },
                    ),
                  ),
                ],
              ),

              // File Types if file answer is allowed
              if (_isFileAnswerAllowed) ...[
                SizedBox(height: 20),

                Text(
                  'Jenis File Yang Diizinkan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),

                SizedBox(height: 15),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: fileTypes.map((type) {
                    return FilterChip(
                      selected: type.isSelected,
                      label: Text(type.name.toUpperCase()),
                      backgroundColor: Colors.grey.shade50,
                      selectedColor: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.2),
                      checkmarkColor: Theme.of(context).colorScheme.secondary,
                      onSelected: (selected) {
                        setState(() {
                          type.isSelected = selected;
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 15),

                // Max File Size
                // Added label for max file size
                Text(
                  'Ukuran Maksimal File (MB)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                SizedBox(height: 8),
                CustomTextFieldContainer(
                  keyboardType: TextInputType.number,
                  textEditingController: _maxFileSizeTextEditingController,
                  hintTextKey: 'Ukuran Maksimal File (MB)',
                  backgroundColor: Colors.grey.shade50,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: 20),

        // Attachment Section
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
                'Lampiran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 20),

              // Existing files if editing
              if (widget.assignment != null) ...[
                ...assignmentAttachments.map(
                  (attachment) => Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: StudyMaterialContainer(
                      onDeleteStudyMaterial: (fileId) {
                        assignmentAttachments
                            .removeWhere((element) => element.id == fileId);
                        refreshAssignmentsInPreviousPage = true;
                        setState(() {});
                      },
                      showOnlyStudyMaterialTitles: true,
                      showEditAndDeleteButton: true,
                      studyMaterial: attachment,
                    ),
                  ),
                ),
                if (assignmentAttachments.isNotEmpty) SizedBox(height: 15),
              ],

              // Newly uploaded files
              ...uploadedFiles.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CustomFileContainer(
                        backgroundColor: Colors.grey.shade50,
                        onDelete: () {
                          uploadedFiles.removeAt(entry.key);
                          setState(() {});
                        },
                        title: entry.value.name,
                      ),
                    ),
                  ),
              SizedBox(height: 15),

              // Upload button
              // Added label for attachment upload
              Text(
                'Tambahkan Lampiran (Opsional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 8),
              UploadImageOrFileButton(
                uploadFile: true,
                includeImageFileOnlyAllowedNote: true,
                onTap: () {
                  _addFiles();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
