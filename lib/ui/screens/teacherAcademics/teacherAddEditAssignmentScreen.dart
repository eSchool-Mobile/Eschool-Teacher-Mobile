import 'package:eschool_saas_staff/cubits/teacherAcademics/assignment/createAssignmentCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/assignment/editAssignmentCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/classSectionsAndSubjects.dart';
import 'package:eschool_saas_staff/data/repositories/assignmentRepository.dart';
import 'package:eschool_saas_staff/data/models/assignment.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/data/models/teacherSubject.dart';
import 'package:eschool_saas_staff/data/models/assignmentFiletype.dart';
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
    text: widget.assignment?.description,
  );

  late final TextEditingController _assignmentPointsTextEditingController =
      TextEditingController(
    text: widget.assignment?.points.toString(),
  );

  late final TextEditingController _extraResubmissionDaysTextEditingController =
      TextEditingController(
    text: widget.assignment?.extraDaysForResubmission.toString(),
  );

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

  final TextEditingController _minPointsTextEditingController = TextEditingController();
  final TextEditingController _startDateTextEditingController = TextEditingController(); // Add this line
  final TextEditingController _endDateTextEditingController = TextEditingController(); // Add this line
  final TextEditingController _maxFileSizeTextEditingController = TextEditingController(); // Add this line

  DateTime? start_date; // Add this line
 
  DateTime? end_date; // Add this line
  
  String? selectedAnswerType = "dokumen"; // Default to dokumen

  bool _isTextAnswerAllowed = false;
  bool _isFileAnswerAllowed = false;

  @override
  void initState() {
    super.initState();
    _loadFileTypes();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<ClassSectionsAndSubjectsCubit>()
            .getClassSectionsAndSubjects(
                classSectionId: _selectedClassSection?.id);
      }
    });
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
    _endDateTextEditingController.dispose(); // Add this line
    _maxFileSizeTextEditingController.dispose(); // Add this line
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

  Future<void> _selectStartDate(BuildContext context) async { // Add this method
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: start_date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != start_date)
      setState(() {
        start_date = picked;
      });
  }

 

  Future<void> _selectEndDate(BuildContext context) async { // Add this method
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: end_date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != end_date)
      setState(() {
       end_date = picked;
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
    if (start_date == null) { // Add this line
      showErrorMessage("Silahkan mengisi Tanggal Penugasan");
      return;
    }
    
    if (end_date == null) { // Add this line
      showErrorMessage("Isi Tanggal Mulai Penugasan.");
      return;
    }
    if (_extraResubmissionDaysTextEditingController.text.trim().isEmpty &&
        _allowedReSubmissionOfRejectedAssignment) {
      showErrorMessage(pleaseEnterExtraDaysForResubmissionKey);
      return;
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
      startDate: "${DateFormat('dd-MM-yyyy').format(start_date!).toString()}", // Add this line
     endDate: "${DateFormat('dd-MM-yyyy').format(end_date!).toString()}", // Add this line
      extraDayForResubmission:
          _extraResubmissionDaysTextEditingController.text.trim(),
      description: _assignmentDescriptionTextEditingController.text.trim(),
      points: _assignmentPointsTextEditingController.text.trim(),
      minPoints: _minPointsTextEditingController.text.trim(), // Add this line
      maxFile: _maxFileSizeTextEditingController.text.trim(), // Add this line
      resubmission: _allowedReSubmissionOfRejectedAssignment,
      file: uploadedFiles,
      acceptedFile: selectedFileTypes.cast<String>(),
      text: textValue,
    );
  }

  void editAssignment() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_assignmentNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseEnterAssignmentNameKey);
    }
    if (dueDate == null) {
      showErrorMessage(pleaseSelectDateKey);
    }
    if (_assignmentPointsTextEditingController.text.length >= 10) {
      // showErrorMessage(invalidPointsLengthKey);
      return;
    }
    if (dueTime == null) {
      showErrorMessage(pleaseSelectDateKey);
    }
    if (_extraResubmissionDaysTextEditingController.text.trim().isEmpty &&
        _allowedReSubmissionOfRejectedAssignment) {
      showErrorMessage(pleaseEnterExtraDaysForResubmissionKey);
      return;
    }

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
          resubmission: _allowedReSubmissionOfRejectedAssignment ? 1 : 0,
          filePaths: uploadedFiles,
          assignmentId: widget.assignment!.id,
          startDate: _startDateTextEditingController.text.trim(),
          endDate: _endDateTextEditingController.text.trim(),
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
        child: widget.assignment != null
            ? BlocConsumer<EditAssignmentCubit, EditAssignmentState>(
                listener: (context, state) {
                  if (state is EditAssignmentSuccess) {
                    Get.back(result: true);
                    Utils.showSnackBar(
                        context: context,
                        message: assignmentEditedSuccessfullyKey);
                  } else if (state is EditAssignmentFailure) {
                    Utils.showSnackBar(
                        context: context, message: state.errorMessage);
                  }
                },
                builder: (context, state) {
                  return CustomRoundedButton(
                      height: 40,
                      widthPercentage: 1.0,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      buttonTitle: submitKey,
                      showBorder: false,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (state is EditAssignmentInProgress) {
                          return;
                        }
                        editAssignment();
                      },
                      child: state is EditAssignmentInProgress
                          ? const CustomCircularProgressIndicator(
                              strokeWidth: 2,
                              widthAndHeight: 20,
                            )
                          : null);
                },
              )
            : BlocConsumer<CreateAssignmentCubit, CreateAssignmentState>(
                listener: (context, state) {
                  if (state is CreateAssignmentSuccess) {
                    Utils.showSnackBar(
                        context: context,
                        message: assignmentAddedSuccessfullyKey);
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
                  return CustomRoundedButton(
                      height: 40,
                      widthPercentage: 1.0,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      buttonTitle: submitKey,
                      showBorder: false,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (state is CreateAssignmentInProcess) {
                          return;
                        }
                        createAssignment();
                      },
                      child: state is CreateAssignmentInProcess
                          ? const CustomCircularProgressIndicator(
                              strokeWidth: 2,
                              widthAndHeight: 20,
                            )
                          : null);
                },
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
                                horizontal: MediaQuery.of(context).size.width * 0.01,
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
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                value: fileTypes[index].isSelected,
                                activeColor: Theme.of(context).colorScheme.secondary,
                                checkColor: Theme.of(context).colorScheme.background,
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                contentPadding: EdgeInsets.zero,
                                controlAffinity: ListTileControlAffinity.leading,
                                onChanged: (bool? value) {
                                  setState(() {
                                    fileTypes[index].isSelected = value ?? false;
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
            top: Utils.appContentTopScrollPadding(context: context) + 20),
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
                                child:
                                    FilterSelectionBottomsheet<TeacherSubject>(
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
                                  ? DateFormat('dd-MM-yyyy').format(start_date!)
                                  : "Tanggal di Mulai",
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                     
                       CustomTextFieldContainer(
                        textEditingController: _minPointsTextEditingController,
                        hintTextKey: "Nilai Syarat Kelulusan",
                        keyboardType: TextInputType.number,
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      CustomCheckboxContainer(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        titleKey: resubmissionAllowedKey,
                        value: _allowedReSubmissionOfRejectedAssignment,
                        onValueChanged: (bool? value) {
                          if (value != null) {
                            setState(() {
                              _allowedReSubmissionOfRejectedAssignment = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      if (_allowedReSubmissionOfRejectedAssignment) ...[
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
                      ],

                      //pre-added study materials
                      widget.assignment != null
                          ? Column(
                              children: assignmentAttachments
                                  .map(
                                    (studyMaterial) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: StudyMaterialContainer(
                                        onDeleteStudyMaterial: (fileId) {
                                          assignmentAttachments.removeWhere(
                                              (element) =>
                                                  element.id == fileId);
                                          refreshAssignmentsInPreviousPage =
                                              true;
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
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      ),

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
                    ],
                  );
          },
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
        Get.back(result: refreshAssignmentsInPreviousPage);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Stack(
          children: [
            _buildAddEditAssignmentForm(),
            _buildSubmitButton(),
            Align(
              alignment: Alignment.topCenter,
              child: CustomAppbar(
                titleKey: widget.assignment != null
                    ? editAssignmentKey
                    : createAssignmentKey,
                onBackButtonTap: () {
                  Get.back(result: refreshAssignmentsInPreviousPage);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
