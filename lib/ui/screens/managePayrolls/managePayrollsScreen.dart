import 'package:eschool_saas_staff/cubits/payRoll/payRollYearsCubit.dart';
import 'package:eschool_saas_staff/cubits/payRoll/staffsPayrollCubit.dart';
import 'package:eschool_saas_staff/cubits/payRoll/submitStaffsPayRollCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/data/models/staffPayRoll.dart';
import 'package:eschool_saas_staff/ui/screens/managePayrolls/widgets/staffPayrollDetailsContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customErrorWidget.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/no_search_results_widget.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class ManagePayrollsScreen extends StatefulWidget {
  const ManagePayrollsScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PayRollYearsCubit(),
        ),
        BlocProvider(
          create: (context) => StaffsPayrollCubit(),
        ),
        BlocProvider(
          create: (context) => SubmitStaffsPayRollCubit(),
        ),
      ],
      child: const ManagePayrollsScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<ManagePayrollsScreen> createState() => _ManagePayrollsScreenState();
}

class _ManagePayrollsScreenState extends State<ManagePayrollsScreen>
    with TickerProviderStateMixin {
  int? _selectedYear;

  // Get the month key from month number (1-12)
  String _getMonthKey(int month) {
    switch (month) {
      case 1:
        return januaryKey;
      case 2:
        return februaryKey;
      case 3:
        return marchKey;
      case 4:
        return aprilKey;
      case 5:
        return mayKey;
      case 6:
        return juneKey;
      case 7:
        return julyKey;
      case 8:
        return augustKey;
      case 9:
        return septemberKey;
      case 10:
        return octoberKey;
      case 11:
        return novemberKey;
      case 12:
        return decemberKey;
      default:
        return januaryKey;
    }
  }

  late String _selectedMonthKey = _getMonthKey(DateTime.now().month);

  // Color scheme for maroon theme
  final Color _maroonPrimary = const Color(0xFF800020);
  final Color _maroonLight = const Color(0xFFAA6976);

  // Search functionality
  bool _isSearchActive = false;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Animation controller for FAB and other animated elements
  late AnimationController _fabAnimationController;
  late final ScrollController _scrollController = ScrollController()
    ..addListener(scrollListener);

  final List<StaffPayRoll> _selectedStaffs = [];

  final List<GlobalKey<StaffPayrollDetailsContainerState>>
      _staffsPayRollDetailsContainerKeys = [];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<PayRollYearsCubit>().getPayRollYears();
      }
    });
  }

  void scrollListener() {
    // Animate FAB based on scroll
    if (_scrollController.offset > 50) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void changeSelectedYear(int year) {
    _selectedYear = year;
    setState(() {});
    getStaffsPayRoll();
  }

  void changeSelectedMonth(String month) {
    _selectedMonthKey = month;
    setState(() {});
    getStaffsPayRoll();
  }

  int getSelectedMonthNumber() {
    // Get month number based on selected month key
    for (int i = 0; i < months.length; i++) {
      if (months[i].toLowerCase() == _selectedMonthKey.toLowerCase()) {
        return i + 1; // Month numbers are 1-based (January = 1)
      }
    }

    // If month key not found in the months list, try direct mapping
    final Map<String, int> monthMap = {
      // Direct mapping for common month keys
      januaryKey: 1,
      februaryKey: 2,
      marchKey: 3,
      aprilKey: 4,
      mayKey: 5,
      juneKey: 6,
      julyKey: 7,
      augustKey: 8,
      septemberKey: 9,
      octoberKey: 10,
      novemberKey: 11,
      decemberKey: 12,
    };

    // Try to get from map, otherwise default to current month
    return monthMap[_selectedMonthKey.toLowerCase()] ?? DateTime.now().month;
  }

  void getStaffsPayRoll() {
    if (_selectedStaffs.isNotEmpty) {
      _selectedStaffs.clear();
      setState(() {});
    }

    final monthNumber = getSelectedMonthNumber();
    print(
        "Getting staff payroll for: Year: ${_selectedYear ?? 0}, Month: $monthNumber (${_selectedMonthKey})");

    context
        .read<StaffsPayrollCubit>()
        .getStaffsPayroll(year: _selectedYear ?? 0, month: monthNumber);
  }

  Widget _buildSubmitButton() {
    return context
                .read<StaffAllowedPermissionsAndModulesCubit>()
                .isPermissionGiven(permission: createPayRollPermissionKey) ||
            context
                .read<StaffAllowedPermissionsAndModulesCubit>()
                .isPermissionGiven(permission: editPayrollEditPermissionKey)
        ? BlocConsumer<SubmitStaffsPayRollCubit, SubmitStaffsPayRollState>(
            listener: (context, submitStaffsPayRollState) {
              if (submitStaffsPayRollState is SubmitStaffsPayRollSuccess) {
                getStaffsPayRoll();
                _selectedStaffs.clear();
                setState(() {});
              }
            },
            builder: (context, submitStaffsPayRollState) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.8),
                        Colors.white,
                        Colors.white,
                      ],
                      stops: [0.0, 0.2, 0.5, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _selectedStaffs.isEmpty
                            ? [
                                _maroonPrimary.withOpacity(0.5),
                                _maroonLight.withOpacity(0.5),
                              ]
                            : [
                                _maroonPrimary,
                                Color(0xFF9A1E3C),
                                _maroonLight,
                              ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: _selectedStaffs.isEmpty
                          ? []
                          : [
                              BoxShadow(
                                color: _maroonPrimary.withOpacity(0.3),
                                offset: const Offset(0, 4),
                                blurRadius: 12,
                                spreadRadius: 0,
                              ),
                            ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        highlightColor: Colors.white.withOpacity(0.1),
                        splashColor: Colors.white.withOpacity(0.2),
                        onTap: () {
                          if (_selectedStaffs.isEmpty) {
                            return;
                          }

                          if (submitStaffsPayRollState
                              is SubmitStaffsPayRollInProgress) {
                            return;
                          }

                          List<Map<String, dynamic>> staffPayRolls = [];

                          for (var staffPayRoll in _selectedStaffs) {
                            final index = context
                                .read<StaffsPayrollCubit>()
                                .staffsPayRoll()
                                .indexWhere(
                                    (element) => element.id == staffPayRoll.id);

                            final netSalary = (index != -1)
                                ? (_staffsPayRollDetailsContainerKeys[index]
                                        .currentState
                                        ?.getNetSalary() ??
                                    0.0)
                                : 0.0;

                            final basicSalary = (index != -1)
                                ? (_staffsPayRollDetailsContainerKeys[index]
                                        .currentState
                                        ?.getBasicSalary() ??
                                    0.0)
                                : (staffPayRoll.salary ?? 0.0);

                            staffPayRolls.add({
                              "staff_id": staffPayRoll.id,
                              "basic_salary": basicSalary,
                              "amount": netSalary
                            });
                          }

                          final monthNumber = getSelectedMonthNumber();
                          final year = _selectedYear ?? 0;

                          print(
                              "Submitting payrolls: Year: $year, Month: $monthNumber (${_selectedMonthKey})");

                          context
                              .read<SubmitStaffsPayRollCubit>()
                              .submitStaffsPayRoll(
                                  month: monthNumber,
                                  year: year,
                                  allowedLeaves: context
                                      .read<StaffsPayrollCubit>()
                                      .allowedLeaves(),
                                  staffPayRolls: staffPayRolls);
                        },
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: submitStaffsPayRollState
                                    is SubmitStaffsPayRollInProgress
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    key: ValueKey<String>("loading"),
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : Row(
                                    key: ValueKey<String>("button"),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        Utils.getTranslatedLabel(submitKey),
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      if (_selectedStaffs.isNotEmpty)
                                        Container(
                                          margin: EdgeInsets.only(left: 12),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            "${_selectedStaffs.length}",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms);
            },
          )
        : const SizedBox();
  }

  Widget _buildStaffs() {
    return BlocConsumer<StaffsPayrollCubit, StaffsPayrollState>(
      listener: (context, state) {
        if (state is StaffsPayrollFetchSuccess) {
          _staffsPayRollDetailsContainerKeys.clear();
          for (var _ in state.staffsPayRoll) {
            _staffsPayRollDetailsContainerKeys
                .add(GlobalKey<StaffPayrollDetailsContainerState>());
          }
          setState(() {});
        }
      },
      builder: (context, state) {
        if (state is StaffsPayrollFetchSuccess) {
          // Filter staff by search query when search is active
          final staffList = _searchQuery.isEmpty
              ? state.staffsPayRoll
              : state.staffsPayRoll
                  .where((staff) =>
                      ((staff.userDetails?.firstName ?? "")
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase())) ||
                      ((staff.userDetails?.lastName ?? "")
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase())))
                  .toList();

          if (staffList.isEmpty && _searchQuery.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20, // Reduced padding since AppBar handles the top spacing
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: NoSearchResultsWidget(
                searchQuery: _searchQuery,
                onClearSearch: () {
                  setState(() {
                    _searchQuery = "";
                    _searchController.clear();
                    _isSearchActive = false;
                  });
                },
                primaryColor: _maroonPrimary,
                accentColor: _maroonLight,
                title: 'Staff Tidak Ditemukan',
                description:
                    'Tidak ditemukan staff yang sesuai dengan pencarian Anda. Coba gunakan kata kunci yang berbeda.',
                icon: Icons.people_outline,
              ).animate().fadeIn(delay: 300.ms),
            );
          }

          return BlocBuilder<PayRollYearsCubit, PayRollYearsState>(
              builder: (context, yearState) {
            return Align(
              alignment: Alignment.topCenter,
              child: RefreshIndicator(
                onRefresh: () async {
                  getStaffsPayRoll();
                },
                color: _maroonPrimary,
                displacement: 100,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    bottom: 100,
                    // Reduced top padding since AppBar handles spacing
                    top: 20,
                  ),
                  child: Column(
                    children: [
                      // Title and subtitle section
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kelola Gaji',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _maroonPrimary,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(
                          begin: -0.1, end: 0, curve: Curves.easeOutQuad),

                      // Search bar
                      _buildSearchBar(),

                      // Filter buttons - now placed under title

                      // Staff list with container styling
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Elegant header with animated gradient
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _maroonPrimary.withOpacity(0.9),
                                    _maroonPrimary,
                                    _maroonLight,
                                  ],
                                ),
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                boxShadow: [
                                  BoxShadow(
                                    color: _maroonPrimary.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Animated icon
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.payments_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(duration: 300.ms)
                                      .slideX(begin: -0.2, end: 0),

                                  const SizedBox(width: 16),

                                  // Title text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Daftar Gaji Staff',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          '${staffList.length} staff tersedia',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color:
                                                Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Counter badge with animation
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        staffList.length.toString(),
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ).animate().fadeIn(duration: 400.ms).scale(
                                      begin: Offset(0.8, 0.8),
                                      end: Offset(1.0, 1.0),
                                      duration: 400.ms),
                                ],
                              ),
                            ),

                            // Table header with modern design
                            Container(
                              margin: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      "No",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: _maroonPrimary,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      Utils.getTranslatedLabel(nameKey),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: _maroonPrimary,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      Utils.getTranslatedLabel(statusKey),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: _maroonPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

                            // Staff list items
                            Container(
                              margin: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Column(
                                  children: List.generate(
                                          staffList.length, (index) => index)
                                      .map((index) {
                                    final staffPayRoll = staffList[index];
                                    final isSelected =
                                        _selectedStaffs.indexWhere((element) =>
                                                element.id ==
                                                staffPayRoll.id) !=
                                            -1;

                                    // Find the original index to use the correct key
                                    final originalIndex = state.staffsPayRoll
                                        .indexWhere((element) =>
                                            element.id == staffPayRoll.id);

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 2),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? _maroonPrimary.withOpacity(0.05)
                                            : Colors.white,
                                        border: index != staffList.length - 1
                                            ? Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[100]!),
                                              )
                                            : null,
                                      ),
                                      child: StaffPayrollDetailsContainer(
                                        key: _staffsPayRollDetailsContainerKeys[
                                            originalIndex],
                                        allowedMonthlyLeaves:
                                            state.allowedLeaves,
                                        isSelected: isSelected,
                                        staffPayRoll: staffPayRoll,
                                        onTapCheckBox: () {
                                          if (isSelected) {
                                            _selectedStaffs.removeWhere(
                                                (element) =>
                                                    element.id ==
                                                    staffPayRoll.id);
                                          } else {
                                            _selectedStaffs.add(staffPayRoll);
                                          }
                                          setState(() {});
                                        },
                                      ),
                                    )
                                        .animate()
                                        .fadeIn(
                                            duration: 400.ms,
                                            delay: (50 * index).ms)
                                        .slideY(
                                          begin: 0.1,
                                          end: 0,
                                          curve: Curves.easeOutQuad,
                                          duration: 500.ms,
                                          delay: (50 * index).ms,
                                        );
                                  }).toList(),
                                ),
                              ),
                            ),

                            // Empty state if no staff
                            if (staffList.isEmpty && _searchQuery.isEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.people_alt_outlined,
                                      size: 60,
                                      color: Colors.grey[300],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Belum ada data staff',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Data staff akan ditampilkan di sini',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(duration: 400.ms),
                          ],
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideY(
                          begin: 0.05, end: 0, curve: Curves.easeOutQuad),
                    ],
                  ),
                ),
              ),
            );
          });
        }

        if (state is StaffsPayrollFetchFailure) {
          return Center(
            child: CustomErrorWidget(
              message: state.errorMessage,
              onRetry: () {
                getStaffsPayRoll();
              },
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
                'Memuat data gaji staff...',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms);
      },
    );
  }

  Widget _buildFilterTabs() {
    return BlocBuilder<PayRollYearsCubit, PayRollYearsState>(
      builder: (context, state) {
        return Row(
          children: [
            // Year filter
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (state is PayRollYearsFetchSuccess &&
                        state.years.isNotEmpty) {
                      Utils.showBottomSheet(
                        child: FilterSelectionBottomsheet<int>(
                          onSelection: (value) {
                            changeSelectedYear(value!);
                            Get.back();
                          },
                          selectedValue: _selectedYear ?? 0,
                          titleKey: titleKey,
                          values: state.years,
                        ),
                        context: context,
                      );
                    }
                  },
                  highlightColor: Colors.white.withOpacity(0.1),
                  splashColor: Colors.white.withOpacity(0.2),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            (_selectedYear?.toString()) ?? 'Tahun',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Vertical divider
            Container(
              height: 24,
              width: 1.5,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),

            // Month filter
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (state is PayRollYearsFetchSuccess) {
                      Utils.showBottomSheet(
                        child: FilterSelectionBottomsheet<String>(
                          selectedValue: _selectedMonthKey,
                          titleKey: monthKey,
                          values: months,
                          displayFunction: (value) =>
                              Utils.getTranslatedLabel(value),
                          onSelection: (value) {
                            changeSelectedMonth(value!);
                            Get.back();
                          },
                        ),
                        context: context,
                      );
                    }
                  },
                  highlightColor: Colors.white.withOpacity(0.1),
                  splashColor: Colors.white.withOpacity(0.2),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            Utils.getTranslatedLabel(_selectedMonthKey),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isSearchActive ? 56 : 0,
      curve: Curves.easeInOut,
      child: _isSearchActive
          ? Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari staff...',
                  prefixIcon: Icon(Icons.search, color: _maroonLight),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close, color: _maroonLight),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = "";
                        _isSearchActive = false;
                      });
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            )
          : SizedBox.shrink(),
    );
  }

  Widget _buildFilterChip({
    required VoidCallback onTap,
    required String label,
    required IconData icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _maroonPrimary.withOpacity(0.9),
                _maroonLight.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _maroonPrimary.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withOpacity(0.7),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomModernAppBar(
          title: 'Kelola Gaji',
          icon: Icons.account_balance_wallet,
          fabAnimationController: _fabAnimationController,
          primaryColor: _maroonPrimary,
          onBackPressed: () => Get.back(),
          lightColor: _maroonLight,
          height: 160, // Increased height to accommodate all content properly
          showSearchButton: true,
          onSearchPressed: () {
            setState(() {
              _isSearchActive = !_isSearchActive;
              if (!_isSearchActive) {
                _searchController.clear();
                _searchQuery = "";
              }
            });
          },
          tabBuilder: (context) => _buildFilterTabs(),
        ),
        body: Stack(
          children: [
            // Main content area with staff list
            BlocConsumer<PayRollYearsCubit, PayRollYearsState>(
              listener: (context, state) {
                if (state is PayRollYearsFetchSuccess) {
                  context.read<StaffsPayrollCubit>().getStaffsPayroll(
                      year: _selectedYear ?? 0,
                      month: getSelectedMonthNumber());
                }
              },
              builder: (context, state) {
                if (state is PayRollYearsFetchSuccess) {
                  return _buildStaffs();
                }

                if (state is PayRollYearsFetchFailure) {
                  return Center(
                    child: CustomErrorWidget(
                      message: state.errorMessage,
                      onRetry: () {
                        context.read<PayRollYearsCubit>().getPayRollYears();
                      },
                      primaryColor: _maroonPrimary,
                    ),
                  );
                }

                return Center(
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),

            // Bottom submit button
            _buildSubmitButton(),
          ],
        ));
  }
}
