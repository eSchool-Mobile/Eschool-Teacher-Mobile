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
      showFilterButton: true,
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
                print("Tanggal Terpilih: $_selectedDateTime");
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
                      final filteredLeaves =
                          state.leaves.where((permissionDetails) {
                        return permissionDetails.leaves.any((leave) {
                          final leaveDate = DateTime.parse(leave.fromDate!);
                          final isSameDate =
                              leaveDate.year == _selectedDateTime.year &&
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
                                                permissionDetails))
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
