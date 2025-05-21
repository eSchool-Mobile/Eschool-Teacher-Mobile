import 'package:eschool_saas_staff/cubits/payRoll/payRollYearsCubit.dart';
import 'package:eschool_saas_staff/cubits/payRoll/staffsPayrollCubit.dart';
import 'package:eschool_saas_staff/cubits/payRoll/submitStaffsPayRollCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/data/models/staffPayRoll.dart';
import 'package:eschool_saas_staff/ui/screens/managePayrolls/widgets/staffPayrollDetailsContainer.dart'
    hide TextEditingController;
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

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
  late String _selectedMonthKey =
      Utils.getMonthFullName(DateTime.now().month).toLowerCase();

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
    return months.indexOf(_selectedMonthKey) + 1;
  }

  void getStaffsPayRoll() {
    if (_selectedStaffs.isNotEmpty) {
      _selectedStaffs.clear();
      setState(() {});
    }
    context.read<StaffsPayrollCubit>().getStaffsPayroll(
        year: _selectedYear ?? 0, month: getSelectedMonthNumber());
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

                          context
                              .read<SubmitStaffsPayRollCubit>()
                              .submitStaffsPayRoll(
                                  month: getSelectedMonthNumber(),
                                  year: _selectedYear ?? 0,
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
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Staff tidak ditemukan',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Coba dengan kata kunci lain',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
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
                    // Increasing top padding to ensure title appears below app bar
                    top: MediaQuery.of(context).padding.top + 160,
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
            child: ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: () {
                getStaffsPayRoll();
              },
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

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: MediaQuery.of(context).padding.top +
            150, // Increased height to accommodate filters
        child: Stack(
          children: [
            // Fancy gradient background with animated particles
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _fabAnimationController,
                builder: (context, _) {
                  return ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF690013),
                          _maroonPrimary,
                          Color(0xFFA12948),
                          _maroonLight,
                        ],
                        stops: [0.0, 0.3, 0.6, 1.0],
                        transform: GradientRotation(
                            _fabAnimationController.value * 0.02),
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF800020),
                            Color(0xFF9A1E3C),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Decorative design elements
            Positioned.fill(
              child: CustomPaint(
                painter: AppBarDecorationPainter(
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),

            // Animated glowing effect
            AnimatedBuilder(
              animation: _fabAnimationController,
              builder: (context, _) {
                return Positioned(
                  top: -100 + (_fabAnimationController.value * 20),
                  right: -60 + (_fabAnimationController.value * 10),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.0),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Main app bar content with frosted glass effect - TOP ROW
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Back button with ripple effect
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              highlightColor: Colors.white.withOpacity(0.1),
                              splashColor: Colors.white.withOpacity(0.2),
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Animated divider
                        Container(
                          height: 24,
                          width: 1.5,
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

                        // Title with animated badge
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Main title
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Animated icon
                                    AnimatedBuilder(
                                      animation: _fabAnimationController,
                                      builder: (context, child) {
                                        return Transform.rotate(
                                          angle: _fabAnimationController.value *
                                              0.05,
                                          child: Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.white.withOpacity(0.9),
                                                  Colors.white.withOpacity(0.4),
                                                ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.account_balance_wallet,
                                              color: _maroonPrimary,
                                              size: 20,
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    SizedBox(width: 12),

                                    // Title text with glowing effect
                                    ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white,
                                            Colors.white.withOpacity(0.9),
                                          ],
                                        ).createShader(bounds);
                                      },
                                      blendMode: BlendMode.srcIn,
                                      child: Text(
                                        'Kelola Gaji',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 1),
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Animated divider
                        Container(
                          height: 24,
                          width: 1.5,
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

                        // Search button with interactive animation
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              highlightColor: Colors.white.withOpacity(0.1),
                              splashColor: Colors.white.withOpacity(0.2),
                              onTap: () {
                                setState(() {
                                  _isSearchActive = !_isSearchActive;
                                  if (!_isSearchActive) {
                                    _searchController.clear();
                                    _searchQuery = "";
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: _isSearchActive
                                      ? Border.all(
                                          color: Colors.white.withOpacity(0.4),
                                          width: 1.5,
                                        )
                                      : null,
                                ),
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 400),
                                  transitionBuilder: (Widget child,
                                      Animation<double> animation) {
                                    return RotationTransition(
                                      turns: Tween<double>(begin: 0.5, end: 1.0)
                                          .animate(animation),
                                      child: ScaleTransition(
                                        scale: animation,
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      ),
                                    );
                                  },
                                  child: _isSearchActive
                                      ? Icon(
                                          Icons.close_rounded,
                                          key: ValueKey<bool>(true),
                                          color: Colors.white,
                                          size: 22,
                                        )
                                      : Icon(
                                          Icons.search_rounded,
                                          key: ValueKey<bool>(false),
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // BOTTOM ROW - Filter Year and Month
            Positioned(
              bottom: 10,
              left: 16,
              right: 16,
              child: BlocBuilder<PayRollYearsCubit, PayRollYearsState>(
                builder: (context, state) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            (_selectedYear?.toString()) ??
                                                'Tahun',
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
                                        child:
                                            FilterSelectionBottomsheet<String>(
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.event_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            Utils.getTranslatedLabel(
                                                _selectedMonthKey),
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
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 200.ms)
                      .slideY(begin: -0.2, end: 0, curve: Curves.easeOutQuad);
                },
              ),
            ),
          ],
        ),
      ),
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
        body: Stack(
      children: [
        // Main content area with staff list
        BlocConsumer<PayRollYearsCubit, PayRollYearsState>(
          listener: (context, state) {
            if (state is PayRollYearsFetchSuccess) {
              context.read<StaffsPayrollCubit>().getStaffsPayroll(
                  year: _selectedYear ?? 0, month: getSelectedMonthNumber());
            }
          },
          builder: (context, state) {
            if (state is PayRollYearsFetchSuccess) {
              return _buildStaffs();
            }

            if (state is PayRollYearsFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context.read<PayRollYearsCubit>().getPayRollYears();
                  },
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

        // App bar with modern design
        _buildAppBar(),
      ],
    ));
  }
}

// Custom painter for decorative elements
class AppBarDecorationPainter extends CustomPainter {
  final Color color;

  AppBarDecorationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.2), 30, paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), 20, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.15), 15, paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), 10, paint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.4), 8, paint);

    // Draw arc
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final arcRect = Rect.fromLTRB(size.width * 0.1, size.height * 0.2,
        size.width * 0.6, size.height * 0.6);
    canvas.drawArc(arcRect, 0.2, 1.5, false, arcPaint);

    // Draw another arc
    final arcRect2 = Rect.fromLTRB(size.width * 0.5, size.height * 0.4,
        size.width * 0.9, size.height * 0.8);
    canvas.drawArc(arcRect2, 3, 1.5, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
