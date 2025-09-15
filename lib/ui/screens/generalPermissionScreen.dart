import 'package:eschool_saas_staff/cubits/leave/generalPermissionCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customErrorWidget.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/permissionDetailsContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';

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

class _GeneralPermissionScreenState extends State<GeneralPermissionScreen>
    with TickerProviderStateMixin {
  DateTime _selectedDateTime = DateTime.now();
  final Color _maroonPrimary = const Color(0xFF800020);
  final Color _maroonLight = const Color(0xFFAA6976);

  late AnimationController _fabAnimationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getLeaves();
    });

    _fabAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > 50) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void getLeaves() {
    LeaveDayType leaveDayType = LeaveDayType.today;
    print("Fetching leaves for date: $_selectedDateTime");
    print(
        "Formatted date: ${_selectedDateTime.toIso8601String().split('T')[0]}");

    context
        .read<GeneralPermissionCubit>()
        .getGeneralLeaves(leaveDayType: leaveDayType, date: _selectedDateTime);
  }

  Widget _buildAppBar() {
    return CustomModernAppBar(
      title: Utils.getTranslatedLabel(permissionStudentKey),
      icon: Icons.person_outline_rounded,
      fabAnimationController: _fabAnimationController,
      primaryColor: _maroonPrimary,
      lightColor: _maroonLight,
      height: 150,
      onBackPressed: () => Navigator.of(context).pop(),
      // showFilterButton: true,
      onFilterPressed: () async {
        final selectedDate = await Utils.openDatePicker(
          context: context,
          lastDate: DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        if (selectedDate != null) {
          _selectedDateTime = selectedDate;
          setState(() {});
          print("Tanggal Terpilih: $_selectedDateTime");
          print(
              "Tanggal ISO: ${_selectedDateTime.toIso8601String().split('T')[0]}");
          getLeaves();
        }
      },
      tabBuilder: (context) => Container(
        height: 48,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final selectedDate = await Utils.openDatePicker(
                context: context,
                lastDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
              );

              if (selectedDate != null) {
                _selectedDateTime = selectedDate;
                setState(() {});
                print("Tanggal Terpilih dari tab: $_selectedDateTime");
                print(
                    "Tanggal ISO dari tab: ${_selectedDateTime.toIso8601String().split('T')[0]}");
                getLeaves();
              }
            },
            borderRadius: BorderRadius.circular(12),
            highlightColor: Colors.white.withOpacity(0.1),
            splashColor: Colors.white.withOpacity(0.2),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 12),
                  Text(
                    Utils.formatDate(_selectedDateTime),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child:
                    BlocBuilder<GeneralPermissionCubit, GeneralPermissionState>(
                  builder: (context, state) {
                    if (state is GeneralPermissionFetchSuccess) {
                      print("Total leaves data: ${state.leaves.length}");
                      print("Selected date: $_selectedDateTime");

                      // Debug: Print all leaves data structure
                      for (int i = 0; i < state.leaves.length; i++) {
                        final permissionDetails = state.leaves[i];
                        print(
                            "Permission $i: User - ${permissionDetails.user?.fullName ?? 'Unknown'}");
                        print(
                            "Permission $i: Leaves count - ${permissionDetails.leaves.length}");

                        // Print raw object structure
                        print(
                            "Permission $i raw: ${permissionDetails.toString()}");

                        // Try to access properties directly (in case of wrong model mapping)
                        try {
                          // Check if permissionDetails has direct student info
                          if (permissionDetails is Map) {
                            print("Permission $i is Map: ${permissionDetails}");
                          }
                        } catch (e) {
                          print("Error checking raw object: $e");
                        }

                        for (int j = 0;
                            j < permissionDetails.leaves.length;
                            j++) {
                          final leave = permissionDetails.leaves[j];
                          print("  Leave $j: fromDate - ${leave.fromDate}");
                          print("  Leave $j: toDate - ${leave.toDate}");
                          print("  Leave $j: reason - ${leave.reason}");
                        }
                      }

                      final filteredLeaves =
                          state.leaves.where((permissionDetails) {
                        bool hasMatchingLeave =
                            permissionDetails.leaves.any((leave) {
                          try {
                            if (leave.fromDate == null ||
                                leave.fromDate!.isEmpty) {
                              print("Skipping leave with null/empty fromDate");
                              return false;
                            }

                            // Parse date with more flexible approach
                            DateTime leaveDate;
                            try {
                              leaveDate = DateTime.parse(leave.fromDate!);
                            } catch (e) {
                              print("Error parsing date ${leave.fromDate}: $e");
                              return false;
                            }

                            // Compare dates (ignoring time)
                            final leaveDay = DateTime(
                                leaveDate.year, leaveDate.month, leaveDate.day);
                            final selectedDay = DateTime(_selectedDateTime.year,
                                _selectedDateTime.month, _selectedDateTime.day);

                            final isSameDate =
                                leaveDay.isAtSameMomentAs(selectedDay);

                            if (isSameDate) {
                              print(
                                  "MATCH FOUND: Siswa izin: ${permissionDetails.user?.fullName ?? 'Unknown'} pada tanggal ${leave.fromDate}");
                            }

                            return isSameDate;
                          } catch (e) {
                            print("Error processing leave: $e");
                            return false;
                          }
                        });

                        return hasMatchingLeave;
                      }).toList();

                      print("Filtered leaves count: ${filteredLeaves.length}");

                      if (filteredLeaves.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_ind_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              CustomTextContainer(
                                textKey: Utils.getTranslatedLabel(
                                    noStudentPermissionKey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tanggal: ${Utils.formatDate(_selectedDateTime)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: getLeaves,
                                icon: Icon(Icons.refresh),
                                label: Text('Refresh Data'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _maroonPrimary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top + 160,
                            bottom: 25,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title section
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Utils.getTranslatedLabel(
                                          permissionStudentKey),
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: _maroonPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Izin siswa tanggal ${Utils.formatDate(_selectedDateTime)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(duration: 400.ms).slideY(
                                  begin: -0.1,
                                  end: 0,
                                  curve: Curves.easeOutQuad),

                              // Permission containers
                              Column(
                                children: filteredLeaves
                                    .map((permissionDetails) =>
                                        PermissionDetailsContainer(
                                            permissionDetails:
                                                permissionDetails,
                                            onPermissionUpdated: getLeaves))
                                    .toList(),
                              ).animate().fadeIn(duration: 500.ms).slideY(
                                  begin: 0.05,
                                  end: 0,
                                  curve: Curves.easeOutQuad,
                                  duration: 500.ms),
                            ],
                          ),
                        );
                      }
                    } else if (state is GeneralPermissionFetchFailure) {
                      return Center(
                        child: CustomErrorWidget(
                          message: ErrorMessageUtils.getReadableErrorMessage(
                              state.errorMessage),
                          onRetry: getLeaves,
                          primaryColor: _maroonPrimary,
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
          _buildAppBar(),
        ],
      ),
    );
  }
}
