import 'package:eschool_saas_staff/cubits/teacherAcademics/attendence/attendanceRankingCubit.dart';
import 'package:eschool_saas_staff/data/models/attendanceRanking.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/attendanceRankingContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class RankingAttendanceScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    return BlocProvider(
        create: (context) => AttendanceRankingCubit()..getAttendanceRanking(),
        child: const RankingAttendanceScreen());
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const RankingAttendanceScreen({super.key});

  @override
  State<RankingAttendanceScreen> createState() =>
      _RankingAttendanceScreenState();
}

class _RankingAttendanceScreenState extends State<RankingAttendanceScreen> {
  String? selectedClassLevel;

  List<String> getClassLevels(AttendanceRanking data) {
    return (data.groupedByClassLevel ?? [])
        .map((e) => e.classLevel ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Widget _buildRecapTable(AttendanceRanking attendanceRankings) {
    AttendanceRanking filteredData;

    // Check if selectedClassLevel is null (Show all students)
    if (selectedClassLevel == null) {
      filteredData = attendanceRankings; // Pass complete data
    } else {
      // Filter by class level
      filteredData = AttendanceRanking(
        groupedByClassLevel: attendanceRankings.groupedByClassLevel
            ?.where((classLevel) => classLevel.classLevel == selectedClassLevel)
            .toList(),
        allStudents: attendanceRankings.allStudents,
      );
    }

    // Check if data is empty
    if ((filteredData.groupedByClassLevel?.isEmpty ?? true) &&
        (filteredData.allStudents?.isEmpty ?? true)) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(
            top: Utils.appContentTopScrollPadding(context: context) + 150,
          ),
          child: const CustomTextContainer(
            textKey: noAttendanceRankingKey,
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
            top: Utils.appContentTopScrollPadding(context: context) + 100,
            bottom: 25),
        child: AttendanceRankingContainer(
          attendanceRankings: filteredData,
          showAllStudents: selectedClassLevel == null,
        ),
      ),
    );
  }

  Widget _buildAppbarAndFilters() {
    return Align(
      alignment: Alignment.topCenter,
      child: BlocConsumer<AttendanceRankingCubit, AttendanceRankingState>(
        listener: (context, state) {},
        builder: (context, state) {
          List<String> classLevels = [];
          if (state is AttendanceRankingFetchSuccess) {
            classLevels = getClassLevels(state.attendanceRanking);
          }

          return Column(
            children: [
              const CustomAppbar(titleKey: 'Peringkat Absensi'),
              AppbarFilterBackgroundContainer(
                height: Utils().getResponsiveHeight(context, 85),
                child: LayoutBuilder(builder: (context, boxConstraints) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: FilterButton(
                          onTap: () {
                            Utils.showBottomSheet(
                              child: FilterSelectionBottomsheet(
                                onSelection: (value) {
                                  Get.back();
                                  setState(() {
                                    selectedClassLevel =
                                        value == allKey ? null : value;
                                  });
                                },
                                selectedValue: selectedClassLevel ?? allKey,
                                titleKey: 'Semua',
                                values: [allKey, ...classLevels],
                              ),
                              context: context,
                            );
                          },
                          titleKey: selectedClassLevel ?? 'Semua',
                          width: boxConstraints.maxWidth * (0.98),
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
          BlocBuilder<AttendanceRankingCubit, AttendanceRankingState>(
            builder: (context, state) {
              if (state is AttendanceRankingFetchSuccess) {
                return _buildRecapTable(state.attendanceRanking);
              }
              if (state is AttendanceRankingFetchFailure) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer,
                    ),
                    child: Text('Failed to fetch attendance ranking data'),
                  ),
                );
              }
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: topPaddingOfErrorAndLoadingContainer,
                  ),
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
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
