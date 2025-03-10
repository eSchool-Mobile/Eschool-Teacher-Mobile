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
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCheckboxContainer.dart';
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
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

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
    extends State<TeacherAddEditAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late ClassSection? _selectedClassSection = widget.selectedClassSection;
  late TeacherSubject? _selectedSubject = widget.selectedSubject;

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

  late bool _allowedReSubmissionOfRejectedAssignment =
      widget.assignment?.resubmission == 0;

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

  @override
  void initState() {
    super.initState();

    // Add EditAssignment state listener
    context.read<EditAssignmentCubit>().stream.listen((state) {
      if (state is EditAssignmentSuccess) {
        setState(() {
          _assignmentNameTextEditingController.text =
              widget.assignment?.name ?? '';
        });
      }
    });

    // Remove duplicate initialization since it's already initialized as final

    // Initialize dates from existing assignment if editing
    if (widget.assignment != null) {
      start_date = widget.assignment!.startDate;
      end_date = widget.assignment!.endDate;

      // Update the text controllers with formatted dates
      _startDateTextEditingController.text =
          DateFormat('dd-MM-yyyy').format(widget.assignment!.startDate);
      _endDateTextEditingController.text =
          DateFormat('dd-MM-yyyy').format(widget.assignment!.endDate);
    }

    // Inisialisasi text controller dengan nilai dari assignment jika ada
    _startDateTextEditingController.text = widget.assignment != null
        ? DateFormat('dd-MM-yyyy').format(widget.assignment!.startDate)
        : '';

    _endDateTextEditingController.text = widget.assignment != null
        ? DateFormat('dd-MM-yyyy').format(widget.assignment!.endDate)
        : '';

    if (widget.assignment != null) {
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

  @override
  void dispose() {
    _assignmentNameTextEditingController.dispose();
    _assignmentDescriptionTextEditingController.dispose();
    _assignmentPointsTextEditingController.dispose();
    _extraResubmissionDaysTextEditingController.dispose();
    _minPointsTextEditingController.dispose(); // Add this line
    _startDateTextEditingController.dispose(); // Add this line
    // _endDateTextEditingController.dispose(); // Add this line
    _maxFileSizeTextEditingController.dispose(); // Add this line
    _maxFileTextEditingController.dispose();
    super.dispose();
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

  void _showOverlayMessage({required BuildContext context, required String message}) {
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
                    "Tugas Berhasil Ditambahkan",
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
                        Utils.showSnackBar(
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
            void showOverlayMessage({required BuildContext context, required String message}) {
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
                        _allowedReSubmissionOfRejectedAssignment = false;
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        "Teks",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      value: _isTextAnswerAllowed,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      checkColor: Theme.of(context).colorScheme.background,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      onChanged: (value) {
                        setState(() {
                          _isTextAnswerAllowed = value ?? false;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        "File",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      value: _isFileAnswerAllowed,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      checkColor: Theme.of(context).colorScheme.background,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      onChanged: (value) {
                        setState(() {
                          _isFileAnswerAllowed = value ?? false;
                        });
                      },
                    ),
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
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: 100,
          left: appContentHorizontalPadding,
          right: appContentHorizontalPadding,
          top: Utils.appContentTopScrollPadding(context: context) + 20,
        ),
        child: FadeInUp(
          duration: Duration(milliseconds: 800),
          child: Column(
            children: [
              // Header Section with Gradient
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.9),
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
                    ]),
                child: Column(
                  children: [
                    FadeInDown(
                      duration: Duration(milliseconds: 400),
                      child: Icon(
                        Icons.assignment_rounded,
                        size: 42,
                        color: Colors.white,
                      )
                          .animate()
                          .scale(duration: 500.ms)
                          .then()
                          .shimmer(duration: 1000.ms),
                    ),
                    SizedBox(height: 15),
                    FadeInUp(
                      duration: Duration(milliseconds: 600),
                      child: Text(
                        widget.assignment != null
                            ? "Edit Assignment"
                            : "Create Assignment",
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                  blurRadius: 10,
                                  color: Colors.black26,
                                  offset: Offset(2, 2))
                            ]),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Form Fields with Glassmorphism
              GlassmorphicContainer(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.7,
                borderRadius: 20,
                blur: 20,
                alignment: Alignment.center,
                border: 2,
                linearGradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      for (var field in _buildFormFields())
                        field
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideX(begin: -0.2, end: 0),
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

  List<Widget> _buildFormFields() {
    return [
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
              : Column(
                  children: [
                    CustomSelectionDropdownSelectionButton(
                      isDisabled: widget.assignment !=
                          null, //if user is editing, they can't change class
                      onTap: () {
                        if (state is ClassSectionsAndSubjectsFetchSuccess) {
                          Utils.showBottomSheet(
                              child: FilterSelectionBottomsheet<ClassSection>(
                                showFilterByLabel: false,
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
                          : (_selectedClassSection?.fullName ?? ""),
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CustomSelectionDropdownSelectionButton(
                      isDisabled: widget.assignment !=
                          null, //if user is editing, they can't change subject
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
                      titleKey: _selectedSubject?.id == null
                          ? subjectKey
                          : _selectedSubject?.subject
                                  .getSybjectNameWithType() ??
                              "",
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CustomTextFieldContainer(
                        textEditingController:
                            _assignmentNameTextEditingController,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        hintTextKey: assignmentNameKey),
                    CustomTextFieldContainer(
                        textEditingController:
                            _assignmentDescriptionTextEditingController,
                        maxLines: 5,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        hintTextKey: instructionsKey),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CustomSelectionDropdownSelectionButton(
                                onTap: () {
                                  _selectStartDate(context); // Update this line
                                },
                                titleKey: start_date != null
                                    ? DateFormat('dd-MM-yyyy')
                                        .format(start_date!)
                                    : "Tanggal di Mulai",
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: CustomSelectionDropdownSelectionButton(
                                onTap: () {
                                  _selectEndDate(context); // Update this line
                                },
                                titleKey: end_date != null
                                    ? DateFormat('dd-MM-yyyy').format(end_date!)
                                    : "Tanggal Berakhir",
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        // Due Date and Due Time
                        Row(
                          children: [
                            Expanded(
                              child: CustomSelectionDropdownSelectionButton(
                                onTap: () {
                                  openDatePicker();
                                },
                                titleKey: dueDate != null
                                    ? Utils.getFormattedDate(dueDate!)
                                    : dueDateKey,
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: CustomSelectionDropdownSelectionButton(
                                onTap: () {
                                  openTimePicker();
                                },
                                titleKey: dueTime != null
                                    ? Utils.getFormattedDayOfTime(dueTime!)
                                    : dueTimeKey,
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CustomTextFieldContainer(
                      keyboardType: TextInputType.number,
                      textEditingController:
                          _assignmentPointsTextEditingController,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      hintTextKey: pointsKey,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),

                    CustomTextFieldContainer(
                      textEditingController: _minPointsTextEditingController,
                      hintTextKey: "Nilai Syarat Kelulusan",
                      keyboardType: TextInputType.number,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),

                    CustomTextFieldContainer(
                        textEditingController:
                            _extraResubmissionDaysTextEditingController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        hintTextKey: extraDaysForResubmissionKey),

                    //pre-added study materials
                    widget.assignment != null
                        ? Column(
                            children: assignmentAttachments
                                .map(
                                  (studyMaterial) => Padding(
                                    padding: const EdgeInsets.only(bottom: 15),
                                    child: StudyMaterialContainer(
                                      onDeleteStudyMaterial: (fileId) {
                                        assignmentAttachments.removeWhere(
                                            (element) => element.id == fileId);
                                        refreshAssignmentsInPreviousPage = true;
                                        setState(() {});
                                      },
                                      showOnlyStudyMaterialTitles: true,
                                      showEditAndDeleteButton: true,
                                      studyMaterial: studyMaterial,
                                    ),
                                  ),
                                )
                                .toList(),
                          )
                        : const SizedBox(),

                    _buildAnswerTypeSelection(),

                    const SizedBox(height: 15),

                    CustomTextFieldContainer(
                      textEditingController: _maxFileSizeTextEditingController,
                      hintTextKey: "Maximum File Size (MB)",
                      keyboardType: TextInputType.number,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),

                    const SizedBox(height: 15),

                    const SizedBox(height: 15),

                    UploadImageOrFileButton(
                      uploadFile: true,
                      includeImageFileOnlyAllowedNote: true,
                      onTap: () {
                        _addFiles();
                      },
                    ),

                    //user's added study materials
                    ...List.generate(uploadedFiles.length, (index) => index)
                        .map(
                      (index) => Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: CustomFileContainer(
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          onDelete: () {
                            uploadedFiles.removeAt(index);
                            setState(() {});
                          },
                          title: uploadedFiles[index].name,
                        ),
                      ),
                    ),

                    // ...List.generate(
                    //     _assignmentUploadedFilesEditingController.length,
                    //     (index) => index).map(
                    //   (index) => Padding(
                    //     padding: const EdgeInsets.only(top: 15),
                    //     child: CustomFileContainer(
                    //       backgroundColor:
                    //           Theme.of(context).scaffoldBackgroundColor,
                    //       onDelete: () {
                    //         _assignmentUploadedFilesEditingController
                    //             .removeAt(index);
                    //         setState(() {});
                    //       },
                    //       title:
                    //           _assignmentUploadedFilesEditingController[index]
                    //               .fileName,
                    //     ),
                    //   ),
                    // ),
                  ],
                );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    print("OK FETCHED");
    print(_assignmentUploadedFilesEditingController);
    print(widget.assignment?.studyMaterial);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8B0000).withOpacity(0.9), // Dark red
              Color(0xFF6B0000), // Darker red
              Color(0xFF4B0000), // Very dark red
              Theme.of(context).colorScheme.secondary,
            ],
            stops: [0.2, 0.4, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              FadeInDown(
                duration: Duration(milliseconds: 600),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      Text(
                        widget.assignment != null
                            ? 'Edit Assignment'
                            : 'Create Assignment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Form Content
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Basic Info Section
                          FadeInUp(
                            duration: Duration(milliseconds: 800),
                            child: _buildBasicInfoSection(),
                          ),

                          SizedBox(height: 25),

                          // Assignment Details Section
                          FadeInUp(
                            duration: Duration(milliseconds: 1000),
                            child: _buildAssignmentDetailsSection(),
                          ),

                          SizedBox(height: 25),

                          _buildSubmissionDetailsSection(),

                          SizedBox(height: 25),

                          // Submission Settings Section
                          FadeInUp(
                            duration: Duration(milliseconds: 1200),
                            child: _buildSubmissionSettingsSection(),
                          ),

                          SizedBox(height: 30),

                          // Submit Button
                          _buildSubmitButton(),

                          SizedBox(height: 20),
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
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
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
          _buildAnimatedTextField(
            controller: _assignmentNameTextEditingController,
            label: 'Nama Tugas',
            icon: Icons.assignment,
          ),
          SizedBox(height: 15),
          _buildClassSectionDropdown(),
          SizedBox(height: 15),
          _buildSubjectDropdown(),
        ],
      ),
    );
  }

  Widget _buildClassSectionDropdown() {
    return BlocBuilder<ClassSectionsAndSubjectsCubit,
        ClassSectionsAndSubjectsState>(
      builder: (context, state) {
        if (state is ClassSectionsAndSubjectsFetchSuccess) {
          return _buildAnimatedTextField(
            controller: TextEditingController(
                text:
                    _selectedClassSection?.fullName ?? 'Select Class Section'),
            label: 'Bagian Kelas',
            icon: Icons.class_,
            readOnly: true,
            onTap: () {
              Utils.showBottomSheet(
                  child: FilterSelectionBottomsheet<ClassSection>(
                    showFilterByLabel: false,
                    onSelection: (value) {
                      changeSelectedClassSection(value!);
                      Get.back();
                    },
                    selectedValue: _selectedClassSection!,
                    titleKey: classKey,
                    values: state.classSections,
                  ),
                  context: context);
            },
          );
        }
        return _buildAnimatedTextField(
          controller: TextEditingController(text: 'Loading...'),
          label: 'Bagian Kelas',
          icon: Icons.class_,
          readOnly: true,
        );
      },
    );
  }

  Widget _buildSubjectDropdown() {
    return BlocBuilder<ClassSectionsAndSubjectsCubit,
        ClassSectionsAndSubjectsState>(
      builder: (context, state) {
        if (state is ClassSectionsAndSubjectsFetchSuccess) {
          return _buildAnimatedTextField(
            controller: TextEditingController(
                text: _selectedSubject?.subject.getSybjectNameWithType() ??
                    'Select Subject'),
            label: 'Mata pelajaran',
            icon: Icons.subject,
            readOnly: true,
            onTap: () {
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
                  context: context);
            },
          );
        }
        return _buildAnimatedTextField(
          controller: TextEditingController(text: 'Loading...'),
          label: 'Mata Pelajaran',
          icon: Icons.subject,
          readOnly: true,
        );
      },
    );
  }

  Widget _buildAssignmentDetailsSection() {
    return Container(
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
          _buildAnimatedTextField(
            controller: _assignmentDescriptionTextEditingController,
            label: 'Keterangan',
            icon: Icons.description,
            maxLines: 3,
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildAnimatedTextField(
                  controller: _startDateTextEditingController,
                  label: 'Tanggal Mulai',
                  icon: Icons.calendar_today,
                  onTap: () => _selectStartDate(context),
                  readOnly: true,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _buildAnimatedTextField(
                  controller: _endDateTextEditingController,
                  label: 'Tanggal Berakhir',
                  icon: Icons.calendar_today,
                  onTap: () => _selectEndDate(context),
                  readOnly: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionSettingsSection() {
    return Container(
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
            'Pengaturan Pengiriman',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: Text('Text'),
                  value: _isTextAnswerAllowed,
                  onChanged: (value) {
                    setState(() {
                      _isTextAnswerAllowed = value ?? false;
                    });
                  },
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: Text('File'),
                  value: _isFileAnswerAllowed,
                  onChanged: (value) {
                    setState(() {
                      _isFileAnswerAllowed = value ?? false;
                    });
                  },
                ),
              ),
            ],
          ),
          if (_isFileAnswerAllowed) ...[
            SizedBox(height: 15),
            _buildFileTypeSelection(),
          ],
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildAnimatedTextField(
                  controller: _assignmentPointsTextEditingController,
                  label: 'Nilai',
                  icon: Icons.star,
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _buildAnimatedTextField(
                  controller: _minPointsTextEditingController,
                  label: 'Minimum Nilai',
                  icon: Icons.star_border,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis File yang Diizinkan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: fileTypes
              .map(
                (type) => FilterChip(
                  selected: type.isSelected,
                  label: Text(type.name.toUpperCase()),
                  onSelected: (selected) {
                    setState(() {
                      type.isSelected = selected;
                    });
                  },
                ),
              )
              .toList(),
        ),
      ],
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
    Color? iconColor,
    Color? labelColor,
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
          // Add this
          color: labelColor ?? Theme.of(context).colorScheme.secondary,
        ),
        prefixIcon: Icon(
          icon,
          color: iconColor ??
              Theme.of(context)
                  .colorScheme
                  .primary, // Use passed color or theme color
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

  Widget _buildSubmissionDetailsSection() {
    return FadeInUp(
      duration: Duration(milliseconds: 1000),
      child: Container(
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
              'Detail Pengiriman',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(height: 20),

            // Due Date & Time
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: dueDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != dueDate) {
                        setState(() {
                          dueDate = picked;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Tenggat Tanggal',
                      prefixIcon: Icon(Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    controller: TextEditingController(
                      text: dueDate != null
                          ? DateFormat('dd-MM-yyyy').format(dueDate!)
                          : '',
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: dueTime ?? TimeOfDay.now(),
                      );
                      if (picked != null && picked != dueTime) {
                        setState(() {
                          dueTime = picked;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Tenggat waktu',
                      prefixIcon: Icon(Icons.access_time,
                          color: Theme.of(context).colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    controller: TextEditingController(
                      text: dueTime != null ? dueTime!.format(context) : '',
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 15),

            // Max File Settings
            Row(
              children: [
                Expanded(
                  child: _buildAnimatedTextField(
                    controller: _maxFileSizeTextEditingController,
                    label: 'Max File Size (MB)',
                    icon: Icons.file_copy,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: _buildAnimatedTextField(
                    controller: _extraResubmissionDaysTextEditingController,
                    label: 'Pengiriman Ulang',
                    icon: Icons.replay,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // File Upload Section
            Text(
              'File Terlampir',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),

            // Display uploaded files
            if (uploadedFiles.isNotEmpty) ...[
              ...uploadedFiles
                  .map((file) => ListTile(
                        leading: Icon(Icons.insert_drive_file),
                        title: Text(file.name),
                        trailing: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              uploadedFiles.remove(file);
                            });
                          },
                        ),
                      ))
                  .toList(),
              SizedBox(height: 10),
            ],

            if (_assignmentUploadedFilesEditingController.isNotEmpty) ...[
              ..._assignmentUploadedFilesEditingController
                  .map((file) => ListTile(
                        leading: Icon(Icons.insert_drive_file),
                        title: Text(file.fileName),
                        trailing: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _assignmentUploadedFilesEditingController
                                  .remove(file);
                            });
                          },
                        ),
                      ))
                  .toList(),
              SizedBox(height: 10),
            ],

            // Upload button
            ElevatedButton.icon(
              onPressed: _addFiles,
              icon: Icon(Icons.upload_file),
              label: Text('Tambahkan File'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
