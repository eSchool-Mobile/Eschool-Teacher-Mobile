import 'package:eschool_saas_staff/cubits/leave/generalLeavesCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customErrorWidget.dart';
import 'package:eschool_saas_staff/ui/widgets/leaveDetailsContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class GeneralLeavesScreen extends StatefulWidget {
  const GeneralLeavesScreen({super.key});

  static Widget getRouteInstance() => BlocProvider(
        create: (context) => GeneralLeavesCubit(),
        child: const GeneralLeavesScreen(),
      );

  @override
  State<GeneralLeavesScreen> createState() => _GeneralLeavesScreenState();
}

class _GeneralLeavesScreenState extends State<GeneralLeavesScreen>
    with TickerProviderStateMixin {
  late String _selectedTabTitleKey = todayKey;
  late AnimationController _fabAnimationController;
  final ScrollController _scrollController = ScrollController();
  final Color _maroonPrimary = const Color(0xFF800020);

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
    print('\n=== DEBUG: GeneralLeavesScreen.getLeaves() ===');
    LeaveDayType leaveDayType = LeaveDayType.today;

    if (_selectedTabTitleKey == tomorrowKey) {
      leaveDayType = LeaveDayType.tomorrow;
    } else if (_selectedTabTitleKey == upcomingKey) {
      leaveDayType = LeaveDayType.upcoming;
    }

    print('Selected tab: $_selectedTabTitleKey');
    print('Leave day type: $leaveDayType');

    context
        .read<GeneralLeavesCubit>()
        .getGeneralLeaves(leaveDayType: leaveDayType);
  }

  void changeTab(String value) {
    setState(() {
      _selectedTabTitleKey = value;
    });
    getLeaves();
  }

  Widget _buildFilterTabs(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFilterTab(todayKey),
        _buildVerticalDivider(),
        _buildFilterTab(tomorrowKey),
        _buildVerticalDivider(),
        _buildFilterTab(upcomingKey),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 24,
      width: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.0),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String tabKey) {
    final bool isSelected = tabKey == _selectedTabTitleKey;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => changeTab(tabKey),
          highlightColor: Colors.white.withOpacity(0.1),
          splashColor: Colors.white.withOpacity(0.2),
          child: Container(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: Colors.white.withOpacity(0.5), width: 1)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Text(
                Utils.getTranslatedLabel(tabKey),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: Colors.white.withOpacity(isSelected ? 1 : 0.7),
                ),
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
      backgroundColor: Colors.grey[50],
      appBar: CustomModernAppBar(
        title: Utils.getTranslatedLabel(leavesKey),
        icon: Icons.event_note_rounded,
        fabAnimationController: _fabAnimationController,
        primaryColor: _maroonPrimary,
        lightColor: const Color(0xFFAA6976),
        onBackPressed: () => Navigator.of(context).pop(),
        height: 140, // Increased height to accommodate filters
        tabBuilder: (context) => _buildFilterTabs(context),
      ),
      body: BlocBuilder<GeneralLeavesCubit, GeneralLeavesState>(
        builder: (context, state) {
          print('\n=== DEBUG: GeneralLeavesScreen BlocBuilder ===');
          print('Current state: ${state.runtimeType}');

          if (state is GeneralLeavesFetchSuccess) {
            print('State: GeneralLeavesFetchSuccess');
            print('Number of leaves: ${state.leaves.length}');

            if (state.leaves.isEmpty) {
              print('No leaves found - showing empty message');
              // If empty, show "No teacher on leave" text
              return Center(
                child: CustomTextContainer(
                  textKey: Utils.getTranslatedLabel('Tidak ada guru yang cuti'),
                ),
              );
            } else {
              print('Displaying ${state.leaves.length} leaves');
              return SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  top: 20, // Reduced padding since appBar handles spacing
                  bottom: 100,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(
                      vertical: appContentHorizontalPadding),
                  child: Column(
                    children: state.leaves
                        .map((leaveDetails) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: LeaveDetailsContainer(
                                  leaveDetails: leaveDetails),
                            ))
                        .toList(),
                  ).animate().fadeIn(duration: 500.ms).slideY(
                        begin: 0.05,
                        end: 0,
                        curve: Curves.easeOutQuad,
                        duration: 500.ms,
                      ),
                ),
              );
            }
          }
          if (state is GeneralLeavesFetchFailure) {
            return Center(
              child: CustomErrorWidget(
                message: state.errorMessage,
                onRetry: getLeaves,
                primaryColor: _maroonPrimary,
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomCircularProgressIndicator(
                  indicatorColor: _maroonPrimary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Memuat data cuti guru...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms);
        },
      ),
    );
  }
}
