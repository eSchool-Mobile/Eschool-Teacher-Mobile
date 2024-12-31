import 'package:eschool_saas_staff/cubits/teacherAcademics/announcement/teacherCreateAnnouncementCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/announcement/teacherEditAnnouncementCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/classSectionsAndSubjects.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/data/models/teacherAnnouncement.dart';
import 'package:eschool_saas_staff/data/models/teacherSubject.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customFileContainer.dart';
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
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TeacherAddEditAnnouncementScreen extends StatefulWidget {
  final TeacherAnnouncement? announcement;
  final ClassSection? selectedClassSection;
  final TeacherSubject? selectedSubject;
  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TeacherCreateAnnouncementCubit(),
        ),
        BlocProvider(
          create: (context) => TeacherEditAnnouncementCubit(),
        ),
        BlocProvider(
          create: (context) => ClassSectionsAndSubjectsCubit(),
        ),
      ],
      child: TeacherAddEditAnnouncementScreen(
        announcement: arguments?['announcement'],
        selectedClassSection: arguments?['selectedClassSection'],
        selectedSubject: arguments?['selectedSubject'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required TeacherAnnouncement? announcement,
      required ClassSection? selectedClassSection,
      required TeacherSubject? selectedSubject}) {
    return {
      "announcement": announcement,
      "selectedClassSection": selectedClassSection,
      "selectedSubject": selectedSubject
    };
  }

  const TeacherAddEditAnnouncementScreen(
      {super.key,
      required this.announcement,
      this.selectedClassSection,
      this.selectedSubject});

  @override
  State<TeacherAddEditAnnouncementScreen> createState() =>
      _TeacherAddEditAnnouncementScreenState();
}

class _TeacherAddEditAnnouncementScreenState
    extends State<TeacherAddEditAnnouncementScreen> {
  late ClassSection? _selectedClassSection = widget.selectedClassSection;
  late TeacherSubject? _selectedSubject = widget.selectedSubject;

  //This will determine if need to refresh the previous page
  //announcement data. If teacher remove the the any files
  //so we need to fetch the list again
  late bool refreshAnnouncementsInPreviousPage = false;

  late final TextEditingController _announcementTitleTextEditingController =
      TextEditingController(
    text: widget.announcement?.title,
  );
  late final TextEditingController
      _announcementDescriptionTextEditingController = TextEditingController(
    text: widget.announcement?.description,
  );

  List<PlatformFile> uploadedFiles = [];

  late List<StudyMaterial> announcementAttachments =
      widget.announcement?.files ?? [];

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
    _announcementTitleTextEditingController.dispose();
    _announcementDescriptionTextEditingController.dispose();
    super.dispose();
  }

  Future<void> _addFiles() async {
    final result = await Utils.openFilePicker(context: context);
    if (result != null) {
      uploadedFiles.addAll(result.files);
      setState(() {});
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

  void createAnnouncement() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_selectedSubject == null) {
      showErrorMessage(noSubjectSelectedKey);
      return;
    }

    if (_selectedClassSection == null) {
      showErrorMessage(noClassSectionSelectedKey);
      return;
    }

    if (_announcementTitleTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseAddAnnouncementTitleKey);
      return;
    }
    if (_announcementDescriptionTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseAddAnnouncementDescriptionKey);
      return;
    }

    context.read<TeacherCreateAnnouncementCubit>().createAnnouncement(
          classSectionId: _selectedClassSection?.id ?? 0,
          classSubjectId: _selectedSubject?.classSubjectId ?? 0,
          title: _announcementTitleTextEditingController.text,
          description: _announcementDescriptionTextEditingController.text,
          attachments: uploadedFiles,
        );
  }

  void editAnnouncement() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_announcementTitleTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseAddAnnouncementTitleKey);
      return;
    }
    if (_announcementDescriptionTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseAddAnnouncementDescriptionKey);
      return;
    }

    context.read<TeacherEditAnnouncementCubit>().editAnnouncement(
          announcementId: widget.announcement?.id ?? 0,
          classSectionId: _selectedClassSection?.id ?? 0,
          classSubjectId: _selectedSubject?.classSubjectId ?? 0,
          title: _announcementTitleTextEditingController.text,
          description: _announcementDescriptionTextEditingController.text,
          attachments: uploadedFiles,
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
        height: Utils().getResponsiveHeight(context, 80),
        child: widget.announcement != null
            ? BlocConsumer<TeacherEditAnnouncementCubit,
                TeacherEditAnnouncementState>(
                listener: (context, state) {
                  if (state is TeacherEditAnnouncementSuccess) {
                    Get.back(result: true);
                    Utils.showSnackBar(
                        context: context,
                        message: announcementEditedSuccessfullyKey);
                  } else if (state is TeacherEditAnnouncementFailure) {
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
                        if (state is TeacherEditAnnouncementInProgress) {
                          return;
                        }
                        editAnnouncement();
                      },
                      child: state is TeacherEditAnnouncementInProgress
                          ? const CustomCircularProgressIndicator(
                              strokeWidth: 2,
                              widthAndHeight: 20,
                            )
                          : null);
                },
              )
            : BlocConsumer<TeacherCreateAnnouncementCubit,
                TeacherCreateAnnouncementState>(
                listener: (context, state) {
                  if (state is TeacherCreateAnnouncementSuccess) {
                    Utils.showSnackBar(
                        context: context,
                        message: announcementAddedSuccessfullyKey);
                    _announcementTitleTextEditingController.text = "";
                    _announcementDescriptionTextEditingController.text = "";
                    uploadedFiles = [];
                    announcementAttachments = [];
                    refreshAnnouncementsInPreviousPage = true;
                    Navigator.pop(context, true);
                    setState(() {});
                  } else if (state is TeacherCreateAnnouncementFailure) {
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
                        if (state is TeacherCreateAnnouncementInProgress) {
                          return;
                        }
                        createAnnouncement();
                      },
                      child: state is TeacherCreateAnnouncementInProgress
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

  Widget _buildAddEditAnnouncementForm() {
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
                        isDisabled: widget.announcement !=
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
                        isDisabled: widget.announcement !=
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
                              _announcementTitleTextEditingController,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          hintTextKey: titleKey),
                      CustomTextFieldContainer(
                          textEditingController:
                              _announcementDescriptionTextEditingController,
                          maxLines: 5,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          hintTextKey: descriptionKey),

                      //pre-added study materials
                      widget.announcement != null
                          ? Column(
                              children: announcementAttachments
                                  .map(
                                    (studyMaterial) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: StudyMaterialContainer(
                                        onDeleteStudyMaterial: (fileId) {
                                          announcementAttachments.removeWhere(
                                              (element) =>
                                                  element.id == fileId);
                                          refreshAnnouncementsInPreviousPage =
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
    return WillPopScope(
      onWillPop: () async {
        Get.back(result: refreshAnnouncementsInPreviousPage);
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Stack(
          children: [
            _buildAddEditAnnouncementForm(),
            _buildSubmitButton(),
            Align(
              alignment: Alignment.topCenter,
              child: CustomAppbar(
                titleKey: widget.announcement != null
                    ? editAnnouncementKey
                    : addAnnouncementKey,
                onBackButtonTap: () {
                  Get.back(result: refreshAnnouncementsInPreviousPage);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
