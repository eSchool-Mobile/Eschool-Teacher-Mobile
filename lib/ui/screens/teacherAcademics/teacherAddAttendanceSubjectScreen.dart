import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/studentsByClassSectionCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/attendence/attendanceSubjectCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/attendence/submitAttendanceSubjectCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/teacherMyTimetableCubit.dart';
import 'package:eschool_saas_staff/data/models/attendanceStudent.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/studentAttendance.dart';
import 'package:eschool_saas_staff/data/models/timeTableSlot.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customFileContainer.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/holidayAttendanceContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/studentAttendanceContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/uploadImageOrFileLimitButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TeacherAddAttendanceSubjectScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SubmitAttendanceSubjectCubit(),
        ),
        BlocProvider(
          create: (context) => SubjectAttendanceCubit(),
        ),
        BlocProvider(create: (context) => StudentsByClassSectionCubit()),
        BlocProvider(
          create: (context) => ClassesCubit(),
        ),
        BlocProvider(create: (context) => TeacherMyTimetableCubit()),
      ],
      child: const TeacherAddAttendanceSubjectScreen(),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required ClassSection? classSection,
      required TimeTableSlot? timeTableSlot,
      required bool isWithinTeachingHours // Tambahkan parameter ini
      }) {
    return {
      "classSection": classSection,
      "timeTableSlot": timeTableSlot,
      "isWithinTeachingHours": isWithinTeachingHours
    };
  }

  const TeacherAddAttendanceSubjectScreen({super.key});

  @override
  State<TeacherAddAttendanceSubjectScreen> createState() =>
      _TeacherAddAttendanceScreenSubjectState();
}

class _TeacherAddAttendanceScreenSubjectState
    extends State<TeacherAddAttendanceSubjectScreen>
    with TickerProviderStateMixin {
  List<({StudentAttendanceStatus status, int studentId})> attendanceReport = [];

  final TextEditingController _materiController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  ClassSection? _selectedClassSection;
  int _selectedTimeTableId = 0;
  int _selectedJumlahJp = 0;
  String _selectedMateri = '';
  String? _selectedLampiran;
  bool _isWithinTeachingHours = false;

  @override
  void dispose() {
    _materiController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime.now();
    _selectedClassSection = null; // Reset selected class section
    _selectedTimeTableId = 0; // Reset selected timetable ID
    _selectedJumlahJp = 0; // Reset jumlah JP
    _selectedMateri = ''; // Reset materi
    _selectedLampiran = null; // Reset lampiran

    Future.delayed(Duration.zero, () {
      final arguments = Get.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        _selectedClassSection = arguments['classSection'] as ClassSection?;
        final timeTableSlot = arguments['timeTableSlot'] as TimeTableSlot?;
        if (timeTableSlot != null) {
          _selectedTimeTableId = timeTableSlot.id!;
        }
        _isWithinTeachingHours = arguments['isWithinTeachingHours'] as bool;
      }

      context.read<ClassesCubit>().getClasses();
      context.read<TeacherMyTimetableCubit>().getTeacherMyTimetable();
      if (_selectedClassSection != null) {
        getAttendance();
        getStudentList();
      }
    });

    // Listen to attendance cubit state changes
    context.read<SubjectAttendanceCubit>().stream.listen((state) {
      if (state is SubjectAttendanceFetchSuccess) {
        setState(() {
          _materiController.text = state.materi ?? ''; // Set saved materi
          _selectedMateri = state.materi ?? '';
        });
      }
    });
  }

  void getAttendance() {
    context.read<SubjectAttendanceCubit>().fetchSubjectAttendance(
          date: _selectedDateTime,
          classSectionId: _selectedClassSection?.id ?? 0,
          timetableId: _selectedTimeTableId,
        );
  }

  void getStudentList() {
    attendanceReport.clear();
    print(
        "Fetching students for class section ID: ${_selectedClassSection?.id}");
    print("Getting student list");
    print("Selected class section: ${_selectedClassSection?.id}");
    print("Selected timetable: $_selectedTimeTableId");
    if (_selectedClassSection?.id != null) {
      context.read<StudentsByClassSectionCubit>().fetchStudents(
            status: StudentListStatus.active,
            classSectionId: _selectedClassSection?.id ?? 0,
          );
    } else {
      print("No class section selected!");
    }
    // context.read<StudentsByClassSectionCubit>().fetchStudents(
    //       status: StudentListStatus.active,
    //       classSectionId: _selectedClassSection?.id ?? 0,
    //     );
  }

  void changeClassSectionSelection(ClassSection? newSelectedClassSection) {
    _selectedClassSection = newSelectedClassSection;
    _selectedTimeTableId = 0; // Reset jadwal pelajaran ketika kelas berubah

    setState(() {});
    if (newSelectedClassSection != null) {
      getAttendance();
      getStudentList();
      context
          .read<TeacherMyTimetableCubit>()
          .getTeacherMyTimetable(); // Perbarui jadwal pelajaran
    }
  }

  void resetForm() {
    setState(() {
      _selectedMateri = '';
      _selectedLampiran = null;
      attendanceReport.clear();
    });
  }

  void changeTimetableSlotSelection(int? newSelectedTimetableId) {
    _selectedTimeTableId = newSelectedTimetableId ?? 0;

    setState(() {});
    if (newSelectedTimetableId != null) {
      getAttendance();
    }
  }

  String formatTime(String time) {
    return time.substring(0, 5).replaceAll(':', '.');
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = result.files.single;
      final fileSizeInMB = file.size / (1024 * 1024);

      if (fileSizeInMB > 2.5) {
        Utils.showSnackBar(message: maximumAttachmentKey, context: context);
        return;
      }
      setState(() {
        _selectedLampiran = file.path;
        uploadedFiles.add(file);
      });
    }
  }

  List<PlatformFile> uploadedFiles = [];

  Widget _buildStudents({required List<AttendanceStudent> attendance}) {
    return BlocBuilder<StudentsByClassSectionCubit,
        StudentsByClassSectionState>(
      builder: (BuildContext context, StudentsByClassSectionState state) {
        if (state is StudentsByClassSectionFetchSuccess) {
          if (state.studentDetailsList.isEmpty) {
            return const SizedBox.shrink();
          }
          return StudentAttendanceContainer(
            studentAttendances: state.studentDetailsList.map((e) {
              // Find matching attendance from previous submission
              final matchedAttendance = attendance
                  .firstWhereOrNull((element) => element.studentId == e.id);

              print(matchedAttendance);

              print('Found attendance record 1: ${matchedAttendance?.type}');

              return StudentAttendance.fromStudentDetails(
                studentDetails: e,
                type: matchedAttendance?.type ??
                    1, // Use stored type or default to present (1)
              );
            }).toList(),
            isForAddAttendance: true,
            isReadOnly: !_isWithinTeachingHours,
            onStatusChanged:
                (List<({StudentAttendanceStatus status, int studentId})>
                    attendanceStatuses) {
              print('Status changed:');
              attendanceStatuses.forEach((status) {
                print('Student ${status.studentId}: ${status.status}');
              });
              attendanceReport = attendanceStatuses;
            },
          );
        } else if (state is StudentsByClassSectionFetchFailure) {
          print("Failed to fetch students: ${state.errorMessage}");
          return Center(
            child: Padding(
              padding:
                  EdgeInsets.only(top: topPaddingOfErrorAndLoadingContainer),
              child: ErrorContainer(
                errorMessage: state.errorMessage,
                onTapRetry: () {
                  getStudentList();
                },
              ),
            ),
          );
        } else {
          print("Loading students...");
          return Center(
            child: Padding(
              padding:
                  EdgeInsets.only(top: topPaddingOfErrorAndLoadingContainer),
              child: CustomCircularProgressIndicator(
                indicatorColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildStudentsContainer() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
            top: Utils.appContentTopScrollPadding(context: context) +
                Utils().getResponsiveHeight(
                    context, _isWithinTeachingHours ? 345 : 225),
            bottom: 75),
        child: BlocBuilder<SubjectAttendanceCubit, SubjectAttendanceState>(
          builder: (context, state) {
            if (state is SubjectAttendanceFetchSuccess) {
              if (state.isHoliday) {
                return HolidayAttendanceContainer(
                  holiday: state.holidayDetails,
                );
              }
              return _buildStudents(attendance: state.attendance);
            } else if (state is SubjectAttendanceFetchFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer),
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      getAttendance();
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
    return BlocBuilder<SubjectAttendanceCubit, SubjectAttendanceState>(
      builder: (context, state) {
        if (state is SubjectAttendanceFetchSuccess) {
          if (state.isHoliday || !_isWithinTeachingHours) {
            // Add check for teaching hours
            return const SizedBox(); // Hide button completely
          }
          return BlocConsumer<SubmitAttendanceSubjectCubit,
                  SubmitAttendanceSubjectState>(
              listener: (context, submitAttendanceSubjectState) {
            if (submitAttendanceSubjectState
                is SubmitAttendanceSubjectSuccess) {
              SnackBarUtils.showSnackBar(
                context: context,
                message: "✅ Berhasil menyimpan Kehadiran pelajaran!",
                backgroundColor: Colors.green.shade700,
                textColor: Colors.white,
              );

              // Optional: Add haptic feedback
              HapticFeedback.mediumImpact();
              resetForm();
              Navigator.pop(context);
            } else if (submitAttendanceSubjectState
                is SubmitAttendanceSubjectFailure) {
              Utils.showSnackBar(
                context: context,
                message: submitAttendanceSubjectState.errorMessage,
              );
            }
          }, builder: (context, submitAttendanceSubjectState) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.all(appContentHorizontalPadding),
                decoration: BoxDecoration(boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 1, spreadRadius: 1)
                ], color: Theme.of(context).colorScheme.surface),
                width: MediaQuery.of(context).size.width,
                height: 70,
                child: CustomRoundedButton(
                  height: 40,
                  widthPercentage: 1.0,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  buttonTitle: submitKey,
                  showBorder: false,
                  onTap: () {
                    if (submitAttendanceSubjectState
                        is SubmitAttendanceSubjectInProgress) {
                      return;
                    }

                    if (attendanceReport.isEmpty) {
                      return;
                    }

                    // Log detailed submission data
                    print('=== ATTENDANCE SUBMISSION DATA ===');
                    print('📅 Date: ${Utils.formatDate(_selectedDateTime)}');
                    print(
                        '🏫 Class: ${_selectedClassSection?.fullName} (ID: ${_selectedClassSection?.id})');
                    print('📚 Timetable ID: $_selectedTimeTableId');
                    print('⏱️ JP Count: $_selectedJumlahJp');
                    print(
                        '📝 Materi: ${_selectedMateri.isEmpty ? "(empty)" : _selectedMateri}');
                    print('📎 Lampiran: ${_selectedLampiran ?? "(none)"}');
                    print('👥 Attendance Report:');

                    for (var attendance in attendanceReport) {
                      String status = '';
                      switch (attendance.status) {
                        case StudentAttendanceStatus.present:
                          status = '✅ Present';
                          break;
                        case StudentAttendanceStatus.absent:
                          status = '❌ Absent';
                          break;
                        // case StudentAttendanceStatus.leave:
                        //   status = '🏝️ Leave';
                        //   break;
                        default:
                          status = '❓ Unknown';
                      }
                      print(
                          '   Student ID: ${attendance.studentId} - Status: $status');
                    }
                    print('================================');

                    context
                        .read<SubmitAttendanceSubjectCubit>()
                        .submitSubjectAttendance(
                          date: _selectedDateTime,
                          classSectionId: _selectedClassSection?.id ?? 0,
                          attendanceReport: attendanceReport,
                          timetableId: _selectedTimeTableId,
                          jumlahJp: _selectedJumlahJp,
                          materi: _selectedMateri,
                          lampiran: _selectedLampiran ?? '',
                        );
                  },
                  child: submitAttendanceSubjectState
                          is SubmitAttendanceSubjectInProgress
                      ? const CustomCircularProgressIndicator(
                          strokeWidth: 2,
                          widthAndHeight: 20,
                        )
                      : null,
                ),
              ),
            );
          });
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
            if (_selectedClassSection == null &&
                state.primaryClasses.isNotEmpty) {
              changeClassSectionSelection(state.primaryClasses.first);
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              const CustomAppbar(titleKey: addAttendanceSubjectKey),
              AppbarFilterBackgroundContainer(
                height: Utils().getResponsiveHeight(
                    context, _isWithinTeachingHours ? 338 : 215),
                child: LayoutBuilder(
                  builder: (context, boxConstraints) {
                    return Column(
                      children: [
                        // Tanggal filter
                        SizedBox(
                          height: 40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FilterButton(
                                onTap: () {},
                                titleKey: Utils.formatDate(_selectedDateTime),
                                width: boxConstraints.maxWidth *
                                    0.98, // Full width for the date dropdown
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),

                        SizedBox(
                          height: 40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Filter Kelas
                              BlocBuilder<TeacherMyTimetableCubit,
                                  TeacherMyTimetableState>(
                                builder: (context, timetableState) {
                                  if (timetableState
                                      is TeacherMyTimetableFetchSuccess) {
                                    final classState =
                                        context.read<ClassesCubit>().state;
                                    if (classState is ClassesFetchSuccess) {
                                      // Get primary classes (wali kelas)
                                      final primaryClasses =
                                          classState.primaryClasses;

                                      // Get classes from timetable
                                      final classSections = timetableState
                                          .timeTableSlots
                                          .where((slot) =>
                                              slot.day ==
                                              weekDays[
                                                  DateTime.now().weekday - 1])
                                          .map((slot) => slot.classSection)
                                          .whereType<ClassSection>()
                                          .toSet()
                                          .toList();

                                      // Combine primary and timetable classes
                                      final allClasses = {
                                        ...primaryClasses,
                                        ...classSections
                                      }.toList();

                                      print(
                                          "Primary Classes: ${primaryClasses.map((e) => '${e.name} (${e.id})')}");
                                      print(
                                          "Timetable Classes: ${classSections.map((e) => '${e.name} (${e.id})')}");
                                      print(
                                          "All Classes: ${allClasses.map((e) => '${e.name} (${e.id})')}");

                                      // Set default selected class if not already set
                                      if (_selectedClassSection == null &&
                                          allClasses.isNotEmpty) {
                                        _selectedClassSection =
                                            allClasses.first;
                                        getAttendance();
                                        getStudentList();
                                      }

                                      return FilterButton(
                                        onTap: () {},
                                        titleKey:
                                            _selectedClassSection?.id == null
                                                ? classKey
                                                : Utils().cleanClassName(
                                                    _selectedClassSection
                                                            ?.fullName ??
                                                        ""),
                                        width: boxConstraints.maxWidth * 0.48,
                                      );
                                    }
                                  }
                                  return const SizedBox();
                                },
                              ),

                              // Jadwal Filter
                              BlocBuilder<TeacherMyTimetableCubit,
                                  TeacherMyTimetableState>(
                                builder: (context, timetableState) {
                                  if (timetableState
                                      is TeacherMyTimetableFetchSuccess) {
                                    // Filter slots based on current day and selected class
                                    final slots = timetableState.timeTableSlots
                                        .where((element) {
                                      print(
                                          "Checking slot: ID=${element.id}, ClassID=${element.classSectionId}, Day=${element.day}");
                                      return element.day ==
                                              weekDays[
                                                  DateTime.now().weekday - 1] &&
                                          element.classSectionId ==
                                              _selectedClassSection?.id;
                                    }).toList();

                                    print("Filtered slots: ${slots.length}");
                                    print(
                                        "Selected timetable ID: $_selectedTimeTableId");
                                    print(
                                        "Selected class section: ${_selectedClassSection?.id}");

                                    // Add safety check
                                    if (slots.isEmpty) {
                                      return FilterButton(
                                        onTap: () {},
                                        titleKey: timeTableKey,
                                        width: boxConstraints.maxWidth * 0.48,
                                      );
                                    }

                                    // Find selected slot with safety
                                    final selectedSlot = slots.firstWhere(
                                      (slot) => slot.id == _selectedTimeTableId,
                                      orElse: () => slots
                                          .first, // Use first slot if selected not found
                                    );

                                    return FilterButton(
                                      onTap: () {},
                                      titleKey: _selectedTimeTableId == 0
                                          ? timeTableKey
                                          : "${selectedSlot.subject?.name ?? '-'} : ${formatTime(selectedSlot.startTime ?? '')} - ${formatTime(selectedSlot.endTime ?? '')}",
                                      width: boxConstraints.maxWidth * 0.48,
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.98,
                          child: TextFormField(
                            controller: _materiController,
                            enabled:
                                _isWithinTeachingHours, // Disable editing if outside teaching hours
                            readOnly:
                                !_isWithinTeachingHours, // Make readonly when outside teaching hours
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              hintText: _isWithinTeachingHours
                                  ? 'Isi Materi'
                                  : 'Tidak Ada Materi',
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                            ),
                            keyboardType: TextInputType.text,
                            onChanged: _isWithinTeachingHours
                                ? (value) {
                                    // Update _selectedMateri with the new value
                                    setState(() {
                                      _selectedMateri = value;
                                    });
                                  }
                                : null,
                            maxLines: 2,
                            style: TextStyle(
                              color: _isWithinTeachingHours
                                  ? Colors.black
                                  : Colors.grey[
                                      700], // Adjust text color for readonly state
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(
                                  300), // Limit to 300 characters
                            ],
                          ),
                        ),
                        if (_isWithinTeachingHours) const SizedBox(height: 20),
                        if (_isWithinTeachingHours)
                          SizedBox(
                            width: boxConstraints.maxWidth *
                                0.98, // 50% width for text field
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (uploadedFiles.isEmpty)
                                  UploadImageOrFileLimitButton(
                                    uploadFile: true,
                                    includeImageFileOnlyAllowedNoteLimit:
                                        uploadedFiles.isEmpty,
                                    onTap: () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles();
                                      if (result != null) {
                                        setState(() {
                                          uploadedFiles
                                              .add(result.files.single);
                                          _selectedLampiran = result.files
                                              .single.path; // Simpan file path
                                        });
                                      }
                                    },
                                  ),
                                // User's added study materials
                                ...List.generate(
                                    uploadedFiles.length, (index) => index).map(
                                  (index) => CustomFileContainer(
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    onDelete: () {
                                      setState(() {
                                        uploadedFiles.removeAt(index);
                                        if (uploadedFiles.isEmpty) {
                                          _selectedLampiran =
                                              null; // Reset file path jika tidak ada file
                                        }
                                      });
                                    },
                                    title: uploadedFiles[index].name,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          BlocBuilder<ClassesCubit, ClassesState>(
            builder: (context, state) {
              print("EMITT");
              print(state);
              if (state is ClassesFetchSuccess) {
                return Stack(children: [
                  _buildStudentsContainer(),
                  _buildSubmitButton(),
                ]);
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
              print("LOADING");
              return Center(
                child: CustomCircularProgressIndicator(
                  indicatorColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
          _buildAppbarAndFilters(),
        ],
      ),
    );
  }
}

class SnackBarUtils {
  static void showSnackBar({
    required BuildContext context,
    required String message,
    Color backgroundColor = Colors.black87, // Default color
    Color textColor = Colors.white, // Default text color
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
