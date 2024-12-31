import 'package:eschool_saas_staff/cubits/leave/generalPermissionCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/permissionDetailsContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralPermissionScreen extends StatefulWidget {
  const GeneralPermissionScreen({super.key});

  static Widget getRouteInstance() => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => GeneralPermissionCubit(),
          ),
        ],
        child: const GeneralPermissionScreen(),
      );

  @override
  State<GeneralPermissionScreen> createState() =>
      _GeneralPermissionScreenState();
}

class _GeneralPermissionScreenState extends State<GeneralPermissionScreen> {
  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getLeaves();
    });
  }

  void getLeaves() {
    LeaveDayType leaveDayType = LeaveDayType.today;
    context
        .read<GeneralPermissionCubit>()
        .getGeneralLeaves(leaveDayType: leaveDayType, date: _selectedDateTime);
  }

  Widget _buildAppbarAndFilters() {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          const CustomAppbar(titleKey: permissionStudentKey),
          AppbarFilterBackgroundContainer(
            height: Utils().getResponsiveHeight(context, 70),
            child: LayoutBuilder(builder: (context, boxConstraints) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 40,
                      child: FilterButton(
                        titleKey: Utils.formatDate(_selectedDateTime),
                        width: boxConstraints.maxWidth * (0.98),
                        onTap: () async {
                          final selectedDate = await Utils.openDatePicker(
                              context: context,
                              lastDate: DateTime.now(),
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 30)));

                          if (selectedDate != null) {
                            _selectedDateTime = selectedDate;
                            setState(() {});
                            print("Selected Date: $_selectedDateTime");
                            getLeaves(); // Panggil getLeaves dengan tanggal yang dipilih
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                _buildAppbarAndFilters(),
                Expanded(
                  child: BlocBuilder<GeneralPermissionCubit,
                      GeneralPermissionState>(
                    builder: (context, state) {
                      if (state is GeneralPermissionFetchSuccess) {
                        final filteredLeaves =
                            state.leaves.where((permissionDetails) {
                          return permissionDetails.leaves.any((leave) {
                            final leaveDate = DateTime.parse(leave.fromDate!);
                            final isSameDate = leaveDate.year ==
                                    _selectedDateTime.year &&
                                leaveDate.month == _selectedDateTime.month &&
                                leaveDate.day == _selectedDateTime.day;
                            if (isSameDate) {
                              print(
                                  "Siswa izin: ${permissionDetails.user?.fullName ?? 'Unknown'}");
                            }
                            return isSameDate;
                          });
                        }).toList();

                        if (filteredLeaves.isEmpty) {
                          return Center(
                            child: CustomTextContainer(
                              textKey: Utils.getTranslatedLabel(
                                  noStudentPermissionKey),
                            ),
                          );
                        } else {
                          return SingleChildScrollView(
                            padding: EdgeInsets.only(top: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(
                                  vertical: appContentHorizontalPadding),
                              color: Theme.of(context).colorScheme.surface,
                              child: Column(
                                children: filteredLeaves
                                    .map((permissionDetails) =>
                                        PermissionDetailsContainer(
                                            permissionDetails:
                                                permissionDetails))
                                    .toList(),
                              ),
                            ),
                          );
                        }
                      } else if (state is GeneralPermissionFetchFailure) {
                        return Center(
                          child: ErrorContainer(
                            errorMessage: state.errorMessage,
                            onTapRetry: getLeaves,
                          ),
                        );
                      } else {
                        return CustomCircularProgressIndicator();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
