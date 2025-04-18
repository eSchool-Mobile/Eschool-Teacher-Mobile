import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/studentsByClassSectionCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/exam/examCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/exam/submitExamMarksCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/exam.dart';
import 'package:eschool_saas_staff/data/models/studentDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TeacherExamResultScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ClassesCubit(),
        ),
        BlocProvider(
          create: (context) => ExamsCubit(),
        ),
        BlocProvider(
          create: (context) => StudentsByClassSectionCubit(),
        ),
        BlocProvider(
          create: (context) => SubmitExamMarksCubit(),
        ),
      ],
      child: const TeacherExamResultScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const TeacherExamResultScreen({super.key});

  @override
  State<TeacherExamResultScreen> createState() =>
      _TeacherExamResultScreenState();
}

class _TeacherExamResultScreenState extends State<TeacherExamResultScreen> {
  ClassSection? _selectedClassSection;
  ExamTimeTable? _selectedExamTimetableSubject;
  Exam? _selectedExam;

  List<TextEditingController> marksControllers = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<ClassesCubit>().getClasses();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    for (var element in marksControllers) {
      element.dispose();
    }
    super.dispose();
  }

  void changeSelectedClassSection(ClassSection? classSection,
      {bool fetchNewSubjects = true}) {
    if (_selectedClassSection != classSection) {
      _selectedClassSection = classSection;
      getExams();
      setState(() {});
    }
  }

  void getExams() {
    print("Fetching exams for class section: ${_selectedClassSection?.id}");
    context.read<ExamsCubit>().fetchExamsList(
          examStatus: 2, //exam should be finished
          publishStatus: 0, //exam should not be published
          classSectionId: _selectedClassSection?.id ?? 0,
        );
  }

  void getStudents() {
    // Check if we have a valid subject
    if (_selectedExamTimetableSubject == null &&
        _selectedExam?.examTimetable?.isNotEmpty == true) {
      // Try to select the first valid subject
      _selectedExamTimetableSubject = _selectedExam?.examTimetable?.firstOrNull;
    }

    // Only fetch if we have a valid subject
    if (_selectedExamTimetableSubject != null) {
      print(
          "Fetching students with params: classSectionId= ${_selectedClassSection?.id}, "
          "examId= ${_selectedExam?.examID}, classSubjectId= ${_selectedExamTimetableSubject?.subjectId}");

      context.read<StudentsByClassSectionCubit>().fetchStudents(
          status: StudentListStatus.active,
          classSectionId: _selectedClassSection?.id ?? 0,
          examId: _selectedExam?.examID ?? 0,
          classSubjectId: _selectedExamTimetableSubject?.subjectId ?? 0);
    } else {
      // Handle case when no subject is available
      context.read<StudentsByClassSectionCubit>().updateState(
          StudentsByClassSectionFetchFailure(
              "Tidak ada mata pelajaran dalam ujian ini. Silakan pilih ujian lain."));
    }
  }

  void setupMarksInitialValues(List<StudentDetails> students) {
    for (var element in marksControllers) {
      element.dispose();
    }
    marksControllers.clear();
    for (int i = 0; i < students.length; i++) {
      //pre-filling marks if already there for the user for selected subject
      marksControllers.add(TextEditingController(
          text: students[i]
              .examMarks
              ?.firstWhereOrNull((element) =>
                  element.examTimetableId == _selectedExamTimetableSubject?.id)
              ?.obtainedMarks
              .toString()));
    }
  }

  Widget _buildStudentContainer(
      {required StudentDetails studentDetails,
      required TextEditingController controller,
      required int index}) {
    final border = BorderSide(color: Theme.of(context).colorScheme.tertiary);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: Utils().getResponsiveHeight(context, 70),
      padding: EdgeInsets.symmetric(
          horizontal: appContentHorizontalPadding, vertical: 10),
      decoration: BoxDecoration(
          border: Border(left: border, bottom: border, right: border)),
      child: Row(
        children: [
          CustomTextContainer(
            textKey: (index + 1).toString().padLeft(2, '0'),
            style: TextStyle(fontSize: Utils.getScaledValue(context, 15)),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: CustomTextContainer(
              textKey: studentDetails.fullName ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: Utils.getScaledValue(context, 15)),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          SizedBox(
            width: 85,
            height: 50,
            child: CustomTextFieldContainer(
              hintTextKey: "",
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              bottomPadding: 0,
              textEditingController: controller,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsContainer() {
    TextStyle titleStyle = TextStyle(
      fontSize: Utils.getScaledValue(context, 16),
      fontWeight: FontWeight.w600,
    );
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
            top: Utils.appContentTopScrollPadding(context: context) + 145,
            bottom: 70),
        child: BlocConsumer<StudentsByClassSectionCubit,
            StudentsByClassSectionState>(
          listener: (context, state) {
            if (state is StudentsByClassSectionFetchSuccess) {
              //Setting up marks text editing controllers before build
              setupMarksInitialValues(state.studentDetailsList);
            }
          },
          builder: (context, state) {
            if (state is StudentsByClassSectionFetchSuccess) {
              if (state.studentDetailsList.isEmpty) {
                return Center(
                  child: Text(
                    "Tidak ada hasil ujian",
                    style: TextStyle(
                      fontSize: Utils.getScaledValue(context, 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(appContentHorizontalPadding),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 45,
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(5.0),
                                  topLeft: Radius.circular(5.0)),
                              color: Theme.of(context).colorScheme.tertiary),
                          padding: EdgeInsets.symmetric(
                              horizontal: appContentHorizontalPadding,
                              vertical: 10),
                          child: Row(
                            children: [
                              CustomTextContainer(
                                textKey: "No",
                                style: titleStyle,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: CustomTextContainer(
                                  textKey: nameKey,
                                  style: titleStyle,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              CustomTextContainer(
                                textKey:
                                    "${Utils.getTranslatedLabel(totalMarksKey)} ${_selectedExamTimetableSubject?.totalMarks}",
                                style: titleStyle,
                              ),
                            ],
                          ),
                        ),
                        ...List.generate(state.studentDetailsList.length,
                            (index) {
                          return _buildStudentContainer(
                            controller: marksControllers[index],
                            studentDetails: state.studentDetailsList[index],
                            index: index,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              );
            } else if (state is StudentsByClassSectionFetchFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer),
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      if (state.errorMessage.contains("Ujian belum selesai")) {
                        // For this specific error, guide the user to select a different exam
                        Utils.showSnackBar(
                            message:
                                "Silakan pilih ujian yang telah selesai untuk menginput nilai",
                            context: context);
                      } else {
                        // For other errors, retry
                        getStudents();
                      }
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
    return BlocBuilder<StudentsByClassSectionCubit,
        StudentsByClassSectionState>(
      builder: (context, studentState) {
        if (studentState is StudentsByClassSectionFetchSuccess) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(appContentHorizontalPadding),
              decoration: BoxDecoration(boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 1, spreadRadius: 1)
              ], color: Theme.of(context).colorScheme.surface),
              width: MediaQuery.of(context).size.width,
              height: 70,
              child: BlocConsumer<SubmitExamMarksCubit, SubmitExamMarksState>(
                listener: (context, state) {
                  if (state is SubmitExamMarksSubmitSuccess) {
                    Utils.showSnackBar(
                        message: resultAddedSuccessfullyKey, context: context);
                  } else if (state is SubmitExamMarksSubmitFailure) {
                    Utils.showSnackBar(
                        message: state.errorMessage, context: context);
                  }
                },
                builder: (context, state) {
                  return CustomRoundedButton(
                    height: 40,
                    widthPercentage: 1.0,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    buttonTitle: submitResultKey,
                    showBorder: false,
                    onTap: () {
                      if (state is SubmitExamMarksSubmitInProgress) {
                        return;
                      } else {
                        for (int i = 0; i < marksControllers.length; i++) {
                          //checking for empty or wrong values
                          if (marksControllers[i].text.trim().isEmpty) {
                            Utils.showSnackBar(
                                message: pleaseAddMarksToAllStudentsKey,
                                context: context);
                            return;
                          } else if ((int.tryParse(marksControllers[i].text) ??
                                  0) >
                              (_selectedExamTimetableSubject?.totalMarks ??
                                  0)) {
                            Utils.showSnackBar(
                                message: cannotAddMoreMarksThenTotalKey,
                                context: context);
                            return;
                          }
                        }
                        if (marksControllers
                            .any((element) => element.text.trim().isEmpty)) {
                          return;
                        }
                        context
                            .read<SubmitExamMarksCubit>()
                            .submitOfflineExamMarks(
                              classSubjectId:
                                  _selectedExamTimetableSubject?.subjectId ?? 0,
                              examId: _selectedExam?.examID ?? 0,
                              marksDetails: List.generate(
                                marksControllers.length,
                                (index) => (
                                  obtainedMarks: int.tryParse(
                                          marksControllers[index].text) ??
                                      0,
                                  studentId: studentState
                                          .studentDetailsList[index].id ??
                                      0
                                ),
                              ),
                            );
                      }
                    },
                    child: state is SubmitExamMarksSubmitInProgress
                        ? const CustomCircularProgressIndicator(
                            strokeWidth: 2,
                            widthAndHeight: 20,
                          )
                        : null,
                  );
                },
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildAppbarAndFilters() {
    return Align(
      alignment: Alignment.topCenter,
      child: BlocConsumer<ClassesCubit, ClassesState>(
        listener: (context, state) {
          if (state is ClassesFetchSuccess) {
            if (_selectedClassSection == null) {
              print("Initializing selected class section");
              changeSelectedClassSection(
                  context.read<ClassesCubit>().getAllClasses().firstOrNull,
                  fetchNewSubjects: false);
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              const CustomAppbar(titleKey: offlineExamResultKey),
              AppbarFilterBackgroundContainer(
                height: 130,
                child: LayoutBuilder(builder: (context, boxConstraints) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FilterButton(
                              onTap: () {
                                if (state is ClassesFetchSuccess &&
                                    context
                                        .read<ClassesCubit>()
                                        .getAllClasses()
                                        .isNotEmpty) {
                                  Utils.showBottomSheet(
                                      child: FilterSelectionBottomsheet<
                                          ClassSection>(
                                        onSelection: (value) {
                                          changeSelectedClassSection(value!);
                                          Get.back();
                                        },
                                        selectedValue: _selectedClassSection!,
                                        titleKey: classKey,
                                        values: context
                                            .read<ClassesCubit>()
                                            .getAllClasses(),
                                      ),
                                      context: context);
                                }
                              },
                              titleKey: _selectedClassSection?.id == null
                                  ? classKey
                                  : Utils().cleanClassName(
                                      (_selectedClassSection?.fullName ?? "")),
                              width: boxConstraints.maxWidth * (0.48),
                            ),
                            BlocConsumer<ExamsCubit, ExamsState>(
                              listener: (context, state) {
                                if (state is ExamsFetchSuccess) {
                                  print(
                                      "Exams fetched successfully. Total exams: ${state.examList.length}");
                                  _selectedExam = state.examList.firstOrNull;
                                  print(
                                      "Selected exam: ${_selectedExam?.examName}, ID: ${_selectedExam?.examID}");
                                  _selectedExamTimetableSubject =
                                      _selectedExam?.examTimetable?.firstOrNull;
                                  print(
                                      "Selected subject: ${_selectedExamTimetableSubject?.subjectName}, ID: ${_selectedExamTimetableSubject?.subjectId}");
                                  setState(() {});

                                  getStudents();
                                }
                              },
                              builder: (context, state) {
                                return FilterButton(
                                  onTap: () {
                                    if (state is ExamsFetchSuccess &&
                                        state.examList.isNotEmpty) {
                                      Utils.showBottomSheet(
                                          child:
                                              FilterSelectionBottomsheet<Exam>(
                                            selectedValue: _selectedExam!,
                                            titleKey: examKey,
                                            values: state.examList,
                                            onSelection: (value) {
                                              Get.back();
                                              if (value != _selectedExam) {
                                                _selectedExam = value;
                                                _selectedExamTimetableSubject =
                                                    _selectedExam?.examTimetable
                                                        ?.firstOrNull;
                                                getStudents();
                                                setState(() {});
                                              }
                                            },
                                          ),
                                          context: context);
                                    }
                                  },
                                  titleKey: _selectedExam?.examID == null
                                      ? examKey
                                      : _selectedExam?.examName ?? "",
                                  width: boxConstraints.maxWidth * 0.48,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 40,
                        child: BlocBuilder<ExamsCubit, ExamsState>(
                          builder: (context, examState) {
                            return FilterButton(
                              // Perbaikan aziz
                              onTap: () {
                                if (examState is ExamsFetchSuccess) {
                                  if ((_selectedExam?.examTimetable ?? [])
                                      .isEmpty) {
                                    return;
                                  }
                                  Utils.showBottomSheet(
                                    child: FilterSelectionBottomsheet<
                                        ExamTimeTable>(
                                      selectedValue:
                                          _selectedExamTimetableSubject!,
                                      titleKey: subjectKey,
                                      values: _selectedExam?.examTimetable
                                              ?.where((timetable) =>
                                                  timetable.subjectName
                                                      ?.isNotEmpty ??
                                                  false)
                                              .toList() ??
                                          [],
                                      onSelection: (value) {
                                        _selectedExamTimetableSubject = value;
                                        getStudents();
                                        Get.back();
                                        setState(() {});
                                      },
                                    ),
                                    context: context,
                                  );
                                }
                              },
                              titleKey:
                                  _selectedExamTimetableSubject?.id == null
                                      ? subjectKey
                                      : _selectedExamTimetableSubject
                                              ?.subjectName ??
                                          "",
                              width: boxConstraints.maxWidth,
                            );
                          },
                        ),
                      ),
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
    print('TeacherExamResultScreen()');
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<ExamsCubit, ExamsState>(builder: (context, examState) {
            return BlocBuilder<ClassesCubit, ClassesState>(
              builder: (context, state) {
                if (state is ClassesFetchSuccess &&
                    examState is ExamsFetchSuccess) {
                  if (examState.examList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: Utils.appContentTopScrollPadding(
                                  context: context) +
                              10,
                        ),
                        child: CustomTextContainer(
                          textKey: Utils.getTranslatedLabel(
                              'Tidak Ada Hasil Ujian Offline'),
                        ),
                      ),
                    );
                  }
                  return Stack(
                    children: [
                      _buildStudentsContainer(),
                      _buildSubmitButton(),
                    ],
                  );
                }
                if (state is ClassesFetchFailure) {
                  return Center(
                      child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      context.read<ClassesCubit>().getClasses();
                    },
                  ));
                }
                if (examState is ExamsFetchFailure) {
                  return Center(
                      child: ErrorContainer(
                    errorMessage: examState.errorMessage,
                    onTapRetry: () {
                      getExams();
                    },
                  ));
                }
                return Center(
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            );
          }),
          _buildAppbarAndFilters(),
        ],
      ),
    );
  }
}

// Wherever your API call is handled (likely in the studentRepository.dart file)
// Update the error handling to provide a more user-friendly message for this specific error

