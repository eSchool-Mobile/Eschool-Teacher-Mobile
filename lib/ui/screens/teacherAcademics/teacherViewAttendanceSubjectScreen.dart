import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/studentsByClassSectionCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/attendence/attendanceSubjectCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/teacherMyTimetableCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/timeTableSlot.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/holidayAttendanceContainer.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/studentSubjectAttendanceContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class TeacherViewAttendanceSubjectScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SubjectAttendanceCubit(),
        ),
        BlocProvider(create: (context) => StudentsByClassSectionCubit()),
        BlocProvider(
          create: (context) => ClassesCubit(),
        ),
        BlocProvider(create: (context) => TeacherMyTimetableCubit()),
      ],
      child: const TeacherViewAttendanceSubjectScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const TeacherViewAttendanceSubjectScreen({
    super.key,
  });

  @override
  State<TeacherViewAttendanceSubjectScreen> createState() =>
      _TeacherViewAttendanceSubjectScreenState();
}

class _TeacherViewAttendanceSubjectScreenState
    extends State<TeacherViewAttendanceSubjectScreen> {
  bool? isPresentStatusOnly;
  DateTime _selectedDateTime = DateTime.now();
  ClassSection? _selectedClassSection;
  StudentAttendanceStatus? selectedStatus;
  int _selectedTimetableId = 0;

  final TextEditingController _materiController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isStudentDataLoading = true;

  @override
  void dispose() {
    _materiController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime.now();

    Future.delayed(Duration.zero, () async {
      if (mounted) {
        // Load classes first
        await context.read<ClassesCubit>().getAllClasses();
        final classState = context.read<ClassesCubit>().state;

        if (classState is ClassesFetchSuccess) {
          setState(() {
            if (classState.primaryClasses.isNotEmpty) {
              _selectedClassSection = classState.primaryClasses.first;
            }
          });

          // Load timetable after class selection
          context.read<TeacherMyTimetableCubit>().getTeacherMyTimetable();
          final timetableState = context.read<TeacherMyTimetableCubit>().state;

          if (timetableState is TeacherMyTimetableFetchSuccess) {
            // Get slots for selected class and day
            final slots = timetableState.timeTableSlots.where((slot) {
              print(
                  "Checking slot: ${slot.id} for class ${slot.classSectionId} on ${slot.day}");
              return slot.day == weekDays[_selectedDateTime.weekday - 1] &&
                  slot.classSectionId == _selectedClassSection?.id;
            }).toList();

            print("Found slots: ${slots.length}");
            slots.forEach(
                (slot) => print("Slot: ${slot.id} - ${slot.subject?.name}"));

            if (slots.isNotEmpty) {
              setState(() {
                _selectedTimetableId = slots.first.id!;
                print("Selected timetable ID: $_selectedTimetableId");
              });

              // Get attendance with found slot
              if (_selectedClassSection != null) {
                getAttendance();
              }
            }
          }
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<ClassesCubit>().getClasses();
    context.read<TeacherMyTimetableCubit>().getTeacherMyTimetable();
  }

  void changeTimetableSlotSelection(int? newSelectedTimetableId) {
    print('Changing timetable selection to ID: $newSelectedTimetableId');

    setState(() {
      _selectedTimetableId = newSelectedTimetableId ?? 0;
    });

    // Add delay to ensure state is updated
    Future.microtask(() {
      if (_selectedTimetableId != 0) {
        print('Fetching attendance for timetable ID: $_selectedTimetableId');
        getAttendance();
      }
    });
  }

  String formatTime(String time) {
    // if (time == null) return '';
    return time.substring(0, 5).replaceAll(':', '.');
  }

  void getAttendance({StudentAttendanceStatus? selectedStatus}) {
    print("Getting attendance for:");
    print("Date: $_selectedDateTime");
    print(
        "Class: ${_selectedClassSection?.name} (${_selectedClassSection?.id})");
    print("Timetable ID: $_selectedTimetableId");

    if (_selectedClassSection == null) {
      final classState = context.read<ClassesCubit>().state;
      if (classState is ClassesFetchSuccess &&
          classState.primaryClasses.isNotEmpty) {
        _selectedClassSection = classState.primaryClasses.first;
        print("Using primary class: ${_selectedClassSection?.name}");
      } else {
        print("No class section selected!");
        return;
      }
    }

    // Get available slots for selected class and date
    final timetableState = context.read<TeacherMyTimetableCubit>().state;
    if (timetableState is TeacherMyTimetableFetchSuccess) {
      final slots = timetableState.timeTableSlots
          .where((slot) =>
              slot.day == weekDays[_selectedDateTime.weekday - 1] &&
              slot.classSectionId == _selectedClassSection?.id)
          .toList();

      print("Available slots for selected class and date: ${slots.length}");
      slots.forEach((slot) {
        print(
            "Slot: ${slot.id} - ${slot.subject?.name} - ${slot.startTime}-${slot.endTime}");
      });

      // Update selected timetable id if needed
      if (_selectedTimetableId == 0 && slots.isNotEmpty) {
        _selectedTimetableId = slots.first.id!;
        print("Updated timetable ID to: $_selectedTimetableId");
      }
    }

    if (_selectedClassSection != null) {
      print("Fetching attendance with params:");
      print("- Date: ${DateFormat('yyyy-MM-dd').format(_selectedDateTime)}");
      print("- Class Section ID: ${_selectedClassSection!.id}");
      print("- Timetable ID: $_selectedTimetableId");

      context.read<SubjectAttendanceCubit>().fetchSubjectAttendance(
            date: _selectedDateTime,
            classSectionId: _selectedClassSection!.id!,
            type: selectedStatus != null
                ? getStudentAttendanceStatusValue(selectedStatus)
                : isPresentStatusOnly == null
                    ? null
                    : isPresentStatusOnly!
                        ? 1
                        : 0,
            timetableId: _selectedTimetableId,
          );
    }
  }

  int getStudentAttendanceStatusValue(StudentAttendanceStatus status) {
    switch (status) {
      case StudentAttendanceStatus.absent:
        return 0;
      case StudentAttendanceStatus.present:
        return 1;
      case StudentAttendanceStatus.sick:
        return 2;
      case StudentAttendanceStatus.permission:
        return 3;
      case StudentAttendanceStatus.alpa:
        return 4;
      default:
        return 0;
    }
  }

  Widget _buildTotalTitleContainer(
      {required String value,
      required String title,
      required Color backgroundColor}) {
    return Container(
      height: Utils().getResponsiveHeight(context, 90),
      padding: EdgeInsets.symmetric(
          horizontal: appContentHorizontalPadding, vertical: 12.5),
      decoration: BoxDecoration(
          color: backgroundColor, borderRadius: BorderRadius.circular(5.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextContainer(
            textKey: value,
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
          ),
          CustomTextContainer(
            textKey: title,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsContainer() {
    return BlocBuilder<ClassesCubit, ClassesState>(
      builder: (context, classState) {
        if (classState is ClassesFetchSuccess) {
          // Allow viewing attendance for primary class (wali kelas)
          if (_selectedClassSection == null &&
              classState.primaryClasses.isNotEmpty) {
            _selectedClassSection = classState.primaryClasses.first;
            Future.microtask(() => getAttendance());
          }

          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  top:
                      Utils.appContentTopScrollPadding(context: context) + 330),
              child:
                  BlocBuilder<SubjectAttendanceCubit, SubjectAttendanceState>(
                builder: (context, state) {
                  if (state is SubjectAttendanceFetchSuccess) {
                    if (state.isHoliday) {
                      return HolidayAttendanceContainer(
                        holiday: state.holidayDetails,
                      );
                    }

                    if (state.attendance.isEmpty) {
                      String message = '';

                      if (selectedStatus == StudentAttendanceStatus.sick) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: Utils.appContentTopScrollPadding(
                                      context: context) +
                                  110,
                            ),
                            child: CustomTextContainer(
                              textKey: "Tidak ada siswa yang sakit",
                            ),
                          ),
                        );
                      } else if (selectedStatus ==
                          StudentAttendanceStatus.permission) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: Utils.appContentTopScrollPadding(
                                      context: context) +
                                  110,
                            ),
                            child: CustomTextContainer(
                              textKey: "Tidak ada siswa yang izin",
                            ),
                          ),
                        );
                      } else if (selectedStatus ==
                          StudentAttendanceStatus.alpa) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: Utils.appContentTopScrollPadding(
                                      context: context) +
                                  110,
                            ),
                            child: CustomTextContainer(
                              textKey: "Tidak ada siswa yang sakit",
                            ),
                          ),
                        );
                      } else {
                        // Jika hari biasa, tampilkan pesan "Belum ada Kehadiran"
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: Utils.appContentTopScrollPadding(
                                      context: context) +
                                  110,
                            ),
                            child: CustomTextContainer(
                              textKey:
                                  Utils.getTranslatedLabel(noAttendanceYetKey),
                            ),
                          ),
                        );
                      }
                    }
                    return Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final presentCount = state.attendance
                                      .where((element) => element.isPresent())
                                      .length
                                      .toString();
                                  print('Jumlah siswa hadir: $presentCount');
                                  return _buildTotalTitleContainer(
                                    backgroundColor: Theme.of(context)
                                        .extension<CustomColors>()!
                                        .totalStaffOverviewBackgroundColor!
                                        .withOpacity(0.3),
                                    title: presentKey,
                                    value: presentCount,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final absentCount = state.attendance
                                      .where((element) => !element.isPresent())
                                      .length
                                      .toString();
                                  print(
                                      'Jumlah siswa tidak hadir: $absentCount');
                                  return _buildTotalTitleContainer(
                                    backgroundColor: Theme.of(context)
                                        .extension<CustomColors>()!
                                        .totalStudentOverviewBackgroundColor!
                                        .withOpacity(0.3),
                                    title: absentKey,
                                    value: absentCount,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final sickCount = state.attendance
                                      .where((element) => element.isSick())
                                      .length
                                      .toString();
                                  print('Jumlah siswa sakit: $sickCount');
                                  return _buildTotalTitleContainer(
                                    backgroundColor: Theme.of(context)
                                        .extension<CustomColors>()!
                                        .sickBackgroundColor!
                                        .withOpacity(0.3),
                                    title: sickKey,
                                    value: sickCount,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final permissionCount = state.attendance
                                      .where(
                                          (element) => element.isPermission())
                                      .length
                                      .toString();
                                  print('Jumlah siswa izin: $permissionCount');
                                  return _buildTotalTitleContainer(
                                    backgroundColor: Theme.of(context)
                                        .extension<CustomColors>()!
                                        .permissionBackgroundColor!
                                        .withOpacity(0.3),
                                    title: permissionKey,
                                    value: permissionCount,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final alpaCount = state.attendance
                                      .where((element) => element.isAlpa())
                                      .length
                                      .toString();
                                  print('Jumlah siswa alpa: $alpaCount');
                                  return _buildTotalTitleContainer(
                                    backgroundColor: Theme.of(context)
                                        .extension<CustomColors>()!
                                        .totalStudentOverviewBackgroundColor!
                                        .withOpacity(0.3),
                                    title: alpaKey,
                                    value: alpaCount,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        StudentSubjectAttendanceContainer(
                          studentAttendances: state.attendance,
                          isForAddAttendance: false,
                        ),
                      ],
                    );
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
        return Center(
          child: CustomCircularProgressIndicator(
            indicatorColor: Theme.of(context).colorScheme.primary,
          ),
        );
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
              _selectedClassSection = state.primaryClasses.first;
              setState(() {});
              getAttendance();
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              const CustomAppbar(titleKey: viewAttendanceSubjectKey),
              AppbarFilterBackgroundContainer(
                height: _isLoading
                    ? Utils().getResponsiveHeight(
                        context, 290) // Tinggi ketika loading
                    : Utils()
                        .getResponsiveHeight(context, 290), // Tinggi normal
                child: LayoutBuilder(builder: (context, boxConstraints) {
                  return Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: ClampingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Filter Tanggal
                          SizedBox(
                            height: 40,
                            child: FilterButton(
                              onTap: () async {
                                final selectedDate = await Utils.openDatePicker(
                                  context: context,
                                  lastDate: DateTime.now(),
                                  firstDate: DateTime.now()
                                      .subtract(const Duration(days: 30)),
                                );

                                if (selectedDate != null) {
                                  _selectedDateTime = selectedDate;
                                  setState(() {});
                                  print("Selected Date: $_selectedDateTime");

                                  final timetableState = context
                                      .read<TeacherMyTimetableCubit>()
                                      .state;
                                  if (timetableState
                                      is TeacherMyTimetableFetchSuccess) {
                                    final classSections = timetableState
                                        .timeTableSlots
                                        .where((slot) =>
                                            slot.day ==
                                            weekDays[
                                                _selectedDateTime.weekday - 1])
                                        .map((slot) => slot.classSection)
                                        .whereType<ClassSection>()
                                        .toSet()
                                        .toList();

                                    if (classSections.isNotEmpty) {
                                      _selectedClassSection =
                                          classSections.first;
                                    } else {
                                      _selectedClassSection = null;
                                    }
                                  }

                                  getAttendance();
                                }
                              },
                              titleKey: Utils.formatDate(_selectedDateTime),
                              width: boxConstraints.maxWidth * (0.98),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Filter Kelas
                                FilterButton(
                                  onTap: () {
                                    var timetableState = context
                                        .read<TeacherMyTimetableCubit>()
                                        .state;
                                    if (timetableState
                                        is TeacherMyTimetableFetchSuccess) {
                                      var classSections = timetableState
                                          .timeTableSlots
                                          .where((slot) =>
                                              slot.day ==
                                              weekDays[
                                                  _selectedDateTime.weekday -
                                                      1])
                                          .map((slot) => slot.classSection)
                                          .whereType<ClassSection>()
                                          .toSet()
                                          .toList();

                                      if (classSections.isNotEmpty) {
                                        Utils.showBottomSheet(
                                          child: FilterSelectionBottomsheet<
                                              ClassSection>(
                                            onSelection: (value) {
                                              Get.back();
                                              if (_selectedClassSection !=
                                                  value) {
                                                _selectedClassSection = value;
                                                setState(() {
                                                  _selectedClassSection = value;
                                                });
                                                print(
                                                    "Selected Class Section: $_selectedClassSection");

                                                // Update timetable ID when class section changes
                                                final slots = timetableState
                                                    .timeTableSlots
                                                    .where((slot) =>
                                                        slot.day ==
                                                            weekDays[
                                                                _selectedDateTime
                                                                        .weekday -
                                                                    1] &&
                                                        slot.classSection?.id ==
                                                            _selectedClassSection
                                                                ?.id)
                                                    .toList();

                                                if (slots.isNotEmpty) {
                                                  _selectedTimetableId =
                                                      slots.first.id!;
                                                  print(
                                                      "Updated Timetable ID: $_selectedTimetableId");
                                                } else {
                                                  _selectedTimetableId = 0;
                                                  print(
                                                      "No Timetable Slot Found for Selected Class Section");
                                                }

                                                getAttendance();
                                              }
                                            },
                                            selectedValue:
                                                _selectedClassSection!,
                                            titleKey: classKey,
                                            values: classSections,
                                          ),
                                          context: context,
                                        );
                                      }
                                    }
                                  },
                                  titleKey: (() {
                                    final timetableState = context
                                        .read<TeacherMyTimetableCubit>()
                                        .state;
                                    if (timetableState
                                        is TeacherMyTimetableFetchSuccess) {
                                      final hasClassesToday = timetableState
                                          .timeTableSlots
                                          .where((slot) =>
                                              slot.day ==
                                              weekDays[
                                                  _selectedDateTime.weekday -
                                                      1])
                                          .isNotEmpty;

                                      // Jika tidak ada kelas yang diajar hari ini, kembalikan classKey
                                      if (!hasClassesToday) {
                                        return classKey;
                                      }
                                    }

                                    // Jika ada kelas yang dipilih, tampilkan nama kelasnya
                                    return _selectedClassSection?.id == null
                                        ? classKey
                                        : Utils().cleanClassName(
                                            _selectedClassSection?.fullName ??
                                                "");
                                  })(),
                                  width: boxConstraints.maxWidth * (0.48),
                                ),
                                // Filter Status
                                FilterButton(
                                    onTap: () {
                                      Utils.showBottomSheet(
                                          child: FilterSelectionBottomsheet<
                                              String>(
                                            onSelection: (value) {
                                              Get.back();
                                              bool refreshPage = false;
                                              if (value == allKey &&
                                                  isPresentStatusOnly != null) {
                                                // Handle case for "Semua"
                                                isPresentStatusOnly = null;
                                                selectedStatus =
                                                    null; // Reset status
                                                refreshPage = true;
                                                // } else if (value == presentKey &&
                                                //     isPresentStatusOnly != true) {
                                                //   // Handle case for "Hadir"
                                                //   isPresentStatusOnly = true;
                                                //   selectedStatus =
                                                //       null; // Reset status for present
                                                //   refreshPage = true;
                                              } else if (value == absentKey &&
                                                  isPresentStatusOnly !=
                                                      false) {
                                                // Handle case for "Tidak Hadir"
                                                isPresentStatusOnly = false;
                                                selectedStatus =
                                                    null; // Absence combines sick, permission, and alpa
                                                refreshPage = true;
                                              } else if (value == sickKey &&
                                                  selectedStatus !=
                                                      StudentAttendanceStatus
                                                          .sick) {
                                                // Handle case for "Sakit"
                                                isPresentStatusOnly = null;
                                                selectedStatus =
                                                    StudentAttendanceStatus
                                                        .sick;
                                                refreshPage = true;
                                              } else if (value ==
                                                      permissionKey &&
                                                  selectedStatus !=
                                                      StudentAttendanceStatus
                                                          .permission) {
                                                // Handle case for "Izin"
                                                isPresentStatusOnly = null;
                                                selectedStatus =
                                                    StudentAttendanceStatus
                                                        .permission;
                                                refreshPage = true;
                                              } else if (value == alpaKey &&
                                                  selectedStatus !=
                                                      StudentAttendanceStatus
                                                          .alpa) {
                                                // Handle case for "Alpa"
                                                isPresentStatusOnly = null;
                                                selectedStatus =
                                                    StudentAttendanceStatus
                                                        .alpa;
                                                refreshPage = true;
                                              }
                                              if (refreshPage) {
                                                setState(() {});
                                                print(
                                                    "Selected Status: $selectedStatus, isPresentStatusOnly: $isPresentStatusOnly");
                                                getAttendance(
                                                    selectedStatus:
                                                        selectedStatus);
                                              }
                                            },
                                            selectedValue: isPresentStatusOnly ==
                                                    null
                                                ? selectedStatus == null
                                                    ? allKey
                                                    : selectedStatus ==
                                                            StudentAttendanceStatus
                                                                .sick
                                                        ? sickKey
                                                        : selectedStatus ==
                                                                StudentAttendanceStatus
                                                                    .permission
                                                            ? permissionKey
                                                            : selectedStatus ==
                                                                    StudentAttendanceStatus
                                                                        .alpa
                                                                ? alpaKey
                                                                : absentKey
                                                : isPresentStatusOnly!
                                                    ? presentKey
                                                    : absentKey, // Default to "Tidak Hadir"
                                            titleKey: statusKey,
                                            values: const [
                                              allKey,
                                              // presentKey,
                                              absentKey,
                                              sickKey,
                                              permissionKey,
                                              alpaKey,
                                            ],
                                          ),
                                          context: context);
                                    },
                                    titleKey: isPresentStatusOnly == null
                                        ? selectedStatus == null
                                            ? allKey
                                            : selectedStatus ==
                                                    StudentAttendanceStatus.sick
                                                ? sickKey
                                                : selectedStatus ==
                                                        StudentAttendanceStatus
                                                            .permission
                                                    ? permissionKey
                                                    : selectedStatus ==
                                                            StudentAttendanceStatus
                                                                .alpa
                                                        ? alpaKey
                                                        : absentKey
                                        : isPresentStatusOnly!
                                            ? presentKey
                                            : absentKey,
                                    width: boxConstraints.maxWidth * (0.48)),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          // Filter Mapel
                          SizedBox(
                            height: 40,
                            child: Row(
                              children: [
                                // Update timetable filter builder
                                BlocBuilder<TeacherMyTimetableCubit,
                                    TeacherMyTimetableState>(
                                  builder: (context, timetableState) {
                                    if (timetableState
                                        is TeacherMyTimetableFetchSuccess) {
                                      // Get today's weekday name
                                      final currentDay =
                                          weekDays[DateTime.now().weekday - 1];
                                      print("Current day: $currentDay");

                                      final slots = timetableState
                                          .timeTableSlots
                                          .where((element) {
                                        print("Checking slot:");
                                        print("- ID: ${element.id}");
                                        print(
                                            "- Class: ${element.classSectionId}");
                                        print("- Day: ${element.day}");
                                        print(
                                            "- Selected class: ${_selectedClassSection?.id}");
                                        print("- Current day: $currentDay");

                                        return element.day == currentDay &&
                                            element.classSectionId ==
                                                _selectedClassSection?.id;
                                      }).toList();

                                      print(
                                          "Found slots for filter: ${slots.length}");
                                      slots.forEach((slot) => print(
                                          "Slot: ${slot.id} - ${slot.subject?.name} - ${slot.startTime}-${slot.endTime}"));

                                      return FilterButton(
                                        onTap: () {
                                          if (slots.isEmpty) return;

                                          Utils.showBottomSheet(
                                            child: FilterSelectionBottomsheet<
                                                TimeTableSlot>(
                                              onSelection: (value) {
                                                Get.back();
                                                changeTimetableSlotSelection(
                                                    value?.id);
                                              },
                                              selectedValue: slots.firstWhere(
                                                (slot) =>
                                                    slot.id ==
                                                    _selectedTimetableId,
                                                orElse: () => slots.first,
                                              ),
                                              titleKey: timeTableKey,
                                              values: slots,
                                              displayFunction: (slot) =>
                                                  "${slot.subject?.name ?? '-'} : ${formatTime(slot.startTime ?? '')} - ${formatTime(slot.endTime ?? '')}",
                                            ),
                                            context: context,
                                          );
                                        },
                                        titleKey: slots.isEmpty
                                            ? timeTableKey
                                            : "${slots.firstWhere((slot) => slot.id == _selectedTimetableId, orElse: () => slots.first).subject?.name ?? '-'}",
                                        width: boxConstraints.maxWidth * 0.98,
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          // Textfield Materi
                          SizedBox(
                            child: Row(
                              children: [
                                Expanded(
                                  child: BlocBuilder<SubjectAttendanceCubit,
                                      SubjectAttendanceState>(
                                    builder: (context, state) {
                                      if (state
                                          is SubjectAttendanceFetchSuccess) {
                                        _materiController.text =
                                            state.materi ?? "-";
                                      }
                                      return TextFormField(
                                        controller: _materiController,
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Isi Materi',
                                        ),
                                        maxLines: 2,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              CustomTextContainer(
                                textKey: "Lampiran : ",
                                style: TextStyle(
                                    fontSize: Utils()
                                        .getResponsiveHeight(context, 15),
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 10),
                              BlocBuilder<SubjectAttendanceCubit,
                                  SubjectAttendanceState>(
                                builder: (context, state) {
                                  if (_isLoading) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 10.0),
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else if (state
                                      is SubjectAttendanceFetchSuccess) {
                                    return Column(
                                      children: [
                                        if (state.lampiran != null &&
                                            state.lampiran!.isNotEmpty)
                                          GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Dialog(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Image.network(
                                                          state.lampiran!,
                                                          loadingBuilder: (context,
                                                              child,
                                                              loadingProgress) {
                                                            if (loadingProgress ==
                                                                null)
                                                              return child;
                                                            return Shimmer
                                                                .fromColors(
                                                              baseColor: Colors
                                                                  .grey[300]!,
                                                              highlightColor:
                                                                  Colors.grey[
                                                                      100]!,
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                height: 200,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          child: Text('Close'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 10.0),
                                              child: Image.network(
                                                state.lampiran ?? '-',
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        if (state.lampiran == null ||
                                            state.lampiran!.isEmpty)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 10.0),
                                            child: Text(
                                              '-',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),
                                      ],
                                    );
                                  } else if (state
                                      is SubjectAttendanceFetchFailure) {
                                    return Text('-');
                                  } else {
                                    return Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top:
                                                topPaddingOfErrorAndLoadingContainer),
                                        child: Text("-"),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
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
          BlocBuilder<ClassesCubit, ClassesState>(
            builder: (context, state) {
              if (state is ClassesFetchSuccess) {
                print("ClassesFetchSuccess: ${state.primaryClasses}");
                return _buildStudentsContainer();
              }
              if (state is ClassesFetchFailure) {
                print("ClassesFetchFailure: ${state.errorMessage}");
                // return Center(
                //     child: ErrorContainer(
                //   errorMessage: state.errorMessage,
                //   onTapRetry: () {
                //     context.read<ClassesCubit>().getClasses();
                //   },
                // ));
              }
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
