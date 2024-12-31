import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/attendence/attendanceCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/holidayAttendanceContainer.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/studentAttendanceContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TeacherViewAttendanceScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AttendanceCubit(),
        ),
        BlocProvider(
          create: (context) => ClassesCubit(),
        ),
      ],
      child: const TeacherViewAttendanceScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const TeacherViewAttendanceScreen({super.key});

  @override
  State<TeacherViewAttendanceScreen> createState() =>
      _TeacherViewAttendanceScreenState();
}

class _TeacherViewAttendanceScreenState
    extends State<TeacherViewAttendanceScreen> {
  bool? isPresentStatusOnly;
  DateTime _selectedDateTime = DateTime.now();
  ClassSection? _selectedClassSection;
  StudentAttendanceStatus? selectedStatus;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<ClassesCubit>().getClasses();
      }
    });
    super.initState();
  }

  String _getSelectedStatusKey() {
    if (isPresentStatusOnly == null && selectedStatus == null) {
      return allKey;
    } else if (isPresentStatusOnly == true) {
      return presentKey;
    } else if (selectedStatus == StudentAttendanceStatus.sick) {
      return sickKey;
    } else if (selectedStatus == StudentAttendanceStatus.permission) {
      return permissionKey;
    } else if (selectedStatus == StudentAttendanceStatus.alpa) {
      return alpaKey;
    } else {
      return absentKey;
    }
  }

  void getAttendance({StudentAttendanceStatus? selectedStatus}) {
    print('Getting attendance with:');
    debugPrint('Date: $_selectedDateTime');
    debugPrint('ClassSectionId: ${_selectedClassSection?.id}');
    debugPrint('Selected Status: $selectedStatus');

    // Tentukan type berdasarkan status
    int? attendanceType;

    if (selectedStatus != null) {
      // Mapping sesuai dengan enum yang sudah ada
      switch (selectedStatus) {
        case StudentAttendanceStatus.absent:
          attendanceType = 0;
          break;
        case StudentAttendanceStatus.present:
          attendanceType = 1;
          break;
        case StudentAttendanceStatus.sick:
          attendanceType = 2;
          break;
        case StudentAttendanceStatus.permission:
          attendanceType = 3;
          break;
        case StudentAttendanceStatus.alpa:
          attendanceType = 4;
          break;
      }
      debugPrint('Mapped attendanceType: $attendanceType');
    } else if (isPresentStatusOnly != null) {
      // Jika menggunakan isPresentStatusOnly
      attendanceType = isPresentStatusOnly! ? 1 : 0;
    }

    if (_selectedClassSection?.id == null) {
      debugPrint('Error: ClassSectionId is null');
      return;
    }

    context.read<AttendanceCubit>().fetchAttendance(
          date: _selectedDateTime,
          classSectionId: _selectedClassSection?.id ?? 0,
          type: attendanceType,
        );
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
            style: TextStyle(
                fontSize: Utils.getScaledValue(context, 23),
                fontWeight: FontWeight.w600),
          ),
          CustomTextContainer(
            textKey: title,
            style: TextStyle(fontSize: Utils.getScaledValue(context, 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsContainer() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
            top: Utils.appContentTopScrollPadding(context: context) + 145),
        child: BlocBuilder<AttendanceCubit, AttendanceState>(
          builder: (context, state) {
            if (state is AttendanceFetchSuccess) {
              if (state.isHoliday) {
                return HolidayAttendanceContainer(
                  holiday: state.holidayDetails,
                );
              }
              final isWeekend = _selectedDateTime.weekday == DateTime.sunday;

              if (state.attendance.isEmpty) {
                // Jika hari Minggu, tampilkan pesan "Tidak ada Kehadiran hari ini"
                if (isWeekend) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top:
                            Utils.appContentTopScrollPadding(context: context) +
                                110,
                      ),
                      child: CustomTextContainer(
                        textKey:
                            Utils.getTranslatedLabel('Tidak Ada Kehadiran'),
                      ),
                    ),
                  );
                }

                // Jika hari biasa, tampilkan pesan "Belum ada Kehadiran"
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: Utils.appContentTopScrollPadding(context: context) +
                          110,
                    ),
                    child: CustomTextContainer(
                      textKey: Utils.getTranslatedLabel('Belum Ada Kehadiran'),
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: _buildTotalTitleContainer(
                          backgroundColor: Theme.of(context)
                              .extension<CustomColors>()!
                              .totalStaffOverviewBackgroundColor!
                              .withOpacity(0.3),
                          title: presentKey,
                          value: state.attendance
                              .where((element) => element.isPresent())
                              .length
                              .toString(),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: _buildTotalTitleContainer(
                          backgroundColor: Theme.of(context)
                              .extension<CustomColors>()!
                              .totalStudentOverviewBackgroundColor!
                              .withOpacity(0.3),
                          title: absentKey,
                          value: state.attendance
                              .where((element) => !element.isPresent())
                              .length
                              .toString(),
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
                        child: _buildTotalTitleContainer(
                          backgroundColor: Theme.of(context)
                              .extension<CustomColors>()!
                              .sickBackgroundColor!
                              .withOpacity(0.3),
                          title: sickKey,
                          value: state.attendance
                              .where((element) => element.isSick())
                              .length
                              .toString(),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: _buildTotalTitleContainer(
                          backgroundColor: Theme.of(context)
                              .extension<CustomColors>()!
                              .permissionBackgroundColor!
                              .withOpacity(0.3),
                          title: permissionKey,
                          value: state.attendance
                              .where((element) => element.isPermission())
                              .length
                              .toString(),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: _buildTotalTitleContainer(
                          backgroundColor: Theme.of(context)
                              .extension<CustomColors>()!
                              .totalStudentOverviewBackgroundColor!
                              .withOpacity(0.3),
                          title: alpaKey,
                          value: state.attendance
                              .where((element) => element.isAlpa())
                              .length
                              .toString(),
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
                  StudentAttendanceContainer(
                    studentAttendances: state.attendance,
                    isForAddAttendance: false,
                  ),
                ],
              );
            } else if (state is AttendanceFetchFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Terjadi kesalahan: ${state.errorMessage}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Retry fetch
                        getAttendance(selectedStatus: selectedStatus);
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
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
              const CustomAppbar(titleKey: viewAttendanceKey),
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
                                      state.primaryClasses.isNotEmpty) {
                                    Utils.showBottomSheet(
                                        child: FilterSelectionBottomsheet<
                                            ClassSection>(
                                          onSelection: (value) {
                                            Get.back();
                                            if (_selectedClassSection !=
                                                value) {
                                              setState(() {
                                                _selectedClassSection = value;
                                              });
                                              getAttendance();
                                            }
                                          },
                                          selectedValue: _selectedClassSection!,
                                          titleKey: classKey,
                                          values: state.primaryClasses,
                                        ),
                                        context: context);
                                  }
                                },
                                titleKey: _selectedClassSection?.id == null
                                    ? classKey
                                    : Utils().cleanClassName(
                                        _selectedClassSection?.fullName ?? ""),
                                width: boxConstraints.maxWidth * (0.48)),
                            FilterButton(
                              onTap: () {
                                Utils.showBottomSheet(
                                  child: FilterSelectionBottomsheet<String>(
                                    onSelection: (value) {
                                      Get.back();

                                      StudentAttendanceStatus? newStatus;
                                      bool? newIsPresentStatusOnly;

                                      if (value == sickKey) {
                                        newStatus =
                                            StudentAttendanceStatus.sick;
                                        newIsPresentStatusOnly = null;
                                      } else if (value == permissionKey) {
                                        newStatus =
                                            StudentAttendanceStatus.permission;
                                        newIsPresentStatusOnly = null;
                                      } else if (value == alpaKey) {
                                        newStatus =
                                            StudentAttendanceStatus.alpa;
                                        newIsPresentStatusOnly = null;
                                      } else if (value == presentKey) {
                                        newStatus = null;
                                        newIsPresentStatusOnly = true;
                                      } else if (value == absentKey) {
                                        newStatus = null;
                                        newIsPresentStatusOnly = false;
                                      } else {
                                        // allKey
                                        newStatus = null;
                                        newIsPresentStatusOnly = null;
                                      }

                                      setState(() {
                                        selectedStatus = newStatus;
                                        isPresentStatusOnly =
                                            newIsPresentStatusOnly;
                                      });

                                      print('After setState:');
                                      print('selectedStatus: $selectedStatus');
                                      print(
                                          'isPresentStatusOnly: $isPresentStatusOnly');

                                      // Ubah pemanggilan getAttendance dengan mengirim selectedStatus
                                      getAttendance(selectedStatus: newStatus);
                                    },
                                    selectedValue: _getSelectedStatusKey(),
                                    titleKey: statusKey,
                                    values: const [
                                      allKey,
                                      presentKey,
                                      absentKey,
                                      sickKey,
                                      permissionKey,
                                      alpaKey,
                                    ],
                                  ),
                                  context: context,
                                );
                              },
                              titleKey: _getSelectedStatusKey(),
                              width: boxConstraints.maxWidth * (0.48),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 40,
                        child: FilterButton(
                          onTap: () async {
                            final selectedDate = await showDatePicker(
                                context: context,
                                currentDate: _selectedDateTime,
                                firstDate: DateTime.now()
                                    .subtract(const Duration(days: 30)),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 30)));

                            if (selectedDate != null) {
                              setState(() {
                                _selectedDateTime = selectedDate;
                              });
                              getAttendance();
                            }
                          },
                          titleKey: Utils.formatDate(_selectedDateTime),
                          width: boxConstraints.maxWidth,
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
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<ClassesCubit, ClassesState>(
            builder: (context, state) {
              if (state is ClassesFetchSuccess) {
                return _buildStudentsContainer();
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
