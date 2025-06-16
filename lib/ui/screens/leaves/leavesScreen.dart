import 'package:eschool_saas_staff/cubits/academics/sessionYearsCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/leave/userLeavesCubit.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/customFilterModernAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customErrorWidget.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';

class LeavesScreen extends StatefulWidget {
  final bool showMyLeaves;
  final UserDetails? userDetails;
  const LeavesScreen({super.key, required this.showMyLeaves, this.userDetails});

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SessionYearsCubit(),
        ),
        BlocProvider(
          create: (context) => UserLeavesCubit(),
        ),
      ],
      child: LeavesScreen(
        userDetails: arguments['userDetails'],
        showMyLeaves: arguments['showMyLeaves'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required bool showMyLeaves, UserDetails? userDetails}) {
    return {"showMyLeaves": showMyLeaves, "userDetails": userDetails};
  }

  @override
  State<LeavesScreen> createState() => _LeavesScreenState();
}

class _LeavesScreenState extends State<LeavesScreen>
    with TickerProviderStateMixin {
  SessionYear? _selectedSessionYear;
  late String _selectedMonthKey =
      Utils.getMonthFullName(DateTime.now().month).toLowerCase();
  double _headerHeight = 200.0;
  final ScrollController _scrollController = ScrollController();

  // Animation controllers
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  // Additional animations for enhanced visuals
  late final AnimationController _cardAnimationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _slideAnimation;
  late final Animation<Offset> _offsetAnimation;

  // Define theme colors - modern palette
  final Color maroonPrimary = Color(0xFF8B1F41);
  final Color maroonLight = Color(0xFFAC3B5C);
  final Color maroonDark = Color(0xFF6A0F2A);
  final Color accentColor = Color(0xFFFFE9EC);
  final Color bgColor = Color(0xFFFCF6F7);
  final Color cardColor = Colors.white;
  final Color textDarkColor = Color(0xFF2D2D2D);
  final Color textMediumColor = Color(0xFF717171);
  final Color borderColor = Color(0xFFEFE2E5);

  // Additional modern UI colors
  final Color gradientStart = Color(0xFF8B1F41);
  final Color gradientEnd = Color(0xFFAC3B5C);
  final Color highlightColor = Color(0xFFFFF0F2);
  final Color shadowColor = Color(0x29000000);
  final Color cardShadowColor = Color(0x0F000000);
  final Color surfaceColor = Color(0xFFFFFAFB);

  @override
  void initState() {
    super.initState();

    // Primary animation controller for fade effects
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Card animations controller for more dynamic UI elements
    _cardAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _animationController.forward();
    _cardAnimationController.forward();

    // Scroll listener for collapsing header effect
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && _headerHeight == 200.0) {
        setState(() {
          _headerHeight = 120.0;
        });
      } else if (_scrollController.offset <= 50 && _headerHeight == 120.0) {
        setState(() {
          _headerHeight = 200.0;
        });
      }
    });

    // Set default month to current month
    _selectedMonthKey =
        Utils.getMonthFullName(DateTime.now().month).toLowerCase();

    // Initialize data loading pipeline
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Get session years first
        context.read<SessionYearsCubit>().getSessionYears();
        // The BlocConsumer in build method will handle selecting the default session year
        // and triggering the leaves data fetch after session years are available
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void changeSelectedSessionYear(SessionYear sessionYear) {
    HapticFeedback.lightImpact();
    _selectedSessionYear = sessionYear;
    setState(() {});
    getLeaves();
  }

  void changeSelectedMonth(String month) {
    HapticFeedback.lightImpact();
    _selectedMonthKey = month;
    setState(() {});
    getLeaves();
  }

  int getSelectedMonthNumber() {
    // Map lowercase Indonesian month names to their numeric values
    final Map<String, int> monthMap = {
      'januari': 1,
      'februari': 2,
      'maret': 3,
      'april': 4,
      'mei': 5,
      'juni': 6,
      'juli': 7,
      'agustus': 8,
      'september': 9,
      'oktober': 10,
      'november': 11,
      'desember': 12,
    };

    return monthMap[_selectedMonthKey] ??
        DateTime.now().month; // Return current month as fallback
  }

  void getLeaves() {
    print("=== Fetching leaves data ===");
    print("Month: ${_selectedMonthKey} (${getSelectedMonthNumber()})");
    print(
        "Session Year: ${_selectedSessionYear?.name ?? 'Not selected'} (ID: ${_selectedSessionYear?.id ?? 0})");
    print(
        "User ID: ${widget.showMyLeaves ? (context.read<AuthCubit>().getUserDetails().id ?? 0) : (widget.userDetails?.id ?? 0)}");
    print("===============================");

    context.read<UserLeavesCubit>().getUserLeaves(
        monthNumber: getSelectedMonthNumber(),
        userId: widget.showMyLeaves
            ? (context.read<AuthCubit>().getUserDetails().id ?? 0)
            : (widget.userDetails?.id ?? 0),
        sessionYearId: (_selectedSessionYear?.id ?? 0));
  }

  Widget _buildLeaveCountContainer(
      {required double width, required String title, required String value}) {
    return Container(
      width: width,
      height: Utils().getResponsiveHeight(context, 120),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: title == allowedLeavesKey
              ? maroonPrimary.withOpacity(0.1)
              : maroonLight.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: title == allowedLeavesKey
                  ? maroonPrimary.withOpacity(0.08)
                  : maroonLight.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // No icon neede
                SizedBox(width: 6),
                Text(
                  title.tr,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color:
                        title == allowedLeavesKey ? maroonPrimary : maroonLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: title == allowedLeavesKey
                          ? maroonPrimary
                          : maroonLight,
                    ),
                  ),
                  SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      "hari",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: textMediumColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: 0.7,
                  backgroundColor:
                      (title == allowedLeavesKey ? maroonPrimary : maroonLight)
                          .withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(
                    title == allowedLeavesKey ? maroonPrimary : maroonLight,
                  ),
                  minHeight: 3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveTableHeader() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            maroonPrimary.withOpacity(0.12),
            maroonPrimary.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              "No",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: maroonPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              leaveDateKey.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: maroonPrimary,
                letterSpacing: 0.2,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              statusKey.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: maroonPrimary,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveListContainer() {
    return BlocConsumer<UserLeavesCubit, UserLeavesState>(
      listener: (context, state) {
        if (state is UserLeavesInitial && _selectedSessionYear != null) {
          getLeaves();
        }
      },
      builder: (context, state) {
        if (state is UserLeavesFetchSuccess) {
          if (state.leaves.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.only(top: 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 64,
                      color: maroonPrimary.withOpacity(0.5),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Tidak ada pengajuan cuti",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textMediumColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          double remainingLeaves = (state.monthlyAllowedLeaves -
              context
                  .read<UserLeavesCubit>()
                  .getTakenLeavesCount(monthNumber: getSelectedMonthNumber()));
          remainingLeaves = remainingLeaves < 0 ? 0 : remainingLeaves;

          return SingleChildScrollView(
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(24),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor.withOpacity(0.05),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: maroonPrimary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.event_note_rounded,
                              color: maroonPrimary,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ringkasan Cuti",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: textDarkColor,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                Text(
                                  "Informasi jatah cuti bulan ini",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: textMediumColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      LayoutBuilder(builder: (context, boxConstraints) {
                        return Row(
                          children: [
                            _buildLeaveCountContainer(
                              width: boxConstraints.maxWidth * 0.48,
                              title: allowedLeavesKey,
                              value:
                                  state.monthlyAllowedLeaves.toStringAsFixed(0),
                            ),
                            SizedBox(width: boxConstraints.maxWidth * 0.04),
                            _buildLeaveCountContainer(
                              width: boxConstraints.maxWidth * 0.48,
                              title: remainingLeavesKey,
                              value: remainingLeaves.toStringAsFixed(0),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),

                // Leave History Section
                Container(
                  margin: EdgeInsets.fromLTRB(24, 0, 24, 24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor.withOpacity(0.05),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                        spreadRadius: 0,
                      )
                    ],
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: maroonPrimary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.list_alt_rounded,
                                color: maroonPrimary,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Riwayat Pengajuan",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: textDarkColor,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                  Text(
                                    "${state.leaves.length} pengajuan",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      color: textMediumColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: maroonPrimary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${state.leaves.length} Cuti",
                                style: TextStyle(
                                  color: maroonPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: borderColor),
                      ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.leaves.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: borderColor,
                        ),
                        itemBuilder: (context, index) {
                          final leave = state.leaves[index];
                          return Container(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: maroonPrimary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: maroonPrimary,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${leave.fromDate != null ? Utils.formatDate(DateTime.parse(leave.fromDate!)) : ''}",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: textDarkColor,
                                        ),
                                      ),
                                      if (leave.fromDate != leave.toDate)
                                        Text(
                                          "s/d ${leave.toDate != null ? Utils.formatDate(DateTime.parse(leave.toDate!)) : ''}",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                            color: textMediumColor,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        if (state is UserLeavesFetchFailure) {
          return Center(
            child: CustomErrorWidget(
              message:
                  ErrorMessageUtils.getReadableErrorMessage(state.errorMessage),
              onRetry: () {
                getLeaves();
              },
              primaryColor: maroonPrimary,
            ),
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: maroonPrimary,
                  strokeWidth: 4,
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Memuat data...",
                style: TextStyle(
                  fontSize: 16,
                  color: textMediumColor,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildHeaderSection() {
    return CustomFilterModernAppBar(
      title: widget.showMyLeaves
          ? myLeaveKey.tr
          : (widget.userDetails?.fullName ?? ""),
      titleIcon: Icons.event_available_rounded,
      primaryColor: maroonPrimary,
      secondaryColor: maroonLight,
      onBackPressed: () {
        Navigator.pop(context);
      },
      animationController: _animationController,
      enableAnimations: true,
      height: _headerHeight,
      firstFilterItem: FilterItemConfig(
        title: _selectedSessionYear?.name ?? "Tahun Ajaran",
        icon: Icons.calendar_today_rounded,
        onTap: () {
          if (context.read<SessionYearsCubit>().state
              is SessionYearsFetchSuccess) {
            final state = context.read<SessionYearsCubit>().state
                as SessionYearsFetchSuccess;
            if (state.sessionYears.isNotEmpty) {
              _showSessionYearFilter(context, state.sessionYears);
            }
          }
        },
      ),
      secondFilterItem: FilterItemConfig(
        title: _selectedMonthKey.tr,
        icon: Icons.date_range_rounded,
        onTap: () {
          _showMonthFilter(context);
        },
      ),
    );
  }

  void _showSessionYearFilter(
      BuildContext context, List<SessionYear> sessionYears) {
    // Prevent overflow errors with proper sheet sizing
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6, // Start at 60% of screen height
        minChildSize: 0.3, // Can be dragged to minimum 30%
        maxChildSize: 0.9, // Maximum 90% of screen height
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  "Pilih Tahun Ajaran",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: sessionYears.length,
                  itemBuilder: (context, index) {
                    final year = sessionYears[index];
                    return ListTile(
                      title: Text(year.name ?? ""),
                      trailing: _selectedSessionYear?.id == year.id
                          ? Icon(Icons.check_circle, color: maroonPrimary)
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        changeSelectedSessionYear(year);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMonthFilter(BuildContext context) {
    // Prevent overflow errors with proper sheet sizing
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6, // Start at 60% of screen height
        minChildSize: 0.3, // Can be dragged to minimum 30%
        maxChildSize: 0.9, // Maximum 90% of screen height
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  "Pilih Bulan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final month = months[index];
                    return ListTile(
                      title: Text(month.tr),
                      trailing: _selectedMonthKey == month
                          ? Icon(Icons.check_circle, color: maroonPrimary)
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        changeSelectedMonth(month);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveSummarySection(
      BuildContext context, UserLeavesFetchSuccess state) {
    double remainingLeaves = (state.monthlyAllowedLeaves -
        context
            .read<UserLeavesCubit>()
            .getTakenLeavesCount(monthNumber: getSelectedMonthNumber()));
    remainingLeaves = remainingLeaves < 0 ? 0 : remainingLeaves;

    return Container(
      margin: EdgeInsets.all(24),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 10),
            spreadRadius: 0,
          )
        ],
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: maroonPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.event_note_rounded,
                  color: maroonPrimary,
                  size: 20,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ringkasan Cuti",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textDarkColor,
                        letterSpacing: 0.1,
                      ),
                    ),
                    Text(
                      "Informasi jatah cuti bulan ini",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: textMediumColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildLeaveCountCard(
                  title: allowedLeavesKey,
                  value: state.monthlyAllowedLeaves.toStringAsFixed(0),
                  icon: Icons.event_available,
                  color: maroonPrimary,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildLeaveCountCard(
                  title: remainingLeavesKey,
                  value: remainingLeaves.toStringAsFixed(0),
                  icon: Icons.event_busy,
                  color: maroonLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveCountCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.tr,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: textMediumColor,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1,
                ),
              ),
              SizedBox(width: 4),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  "hari",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: textMediumColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: 0.7,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      primaryColor: maroonPrimary,
      scaffoldBackgroundColor: bgColor,
      textTheme: GoogleFonts.poppinsTextTheme(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: maroonPrimary,
        primary: maroonPrimary,
        secondary: maroonLight,
      ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: _buildHeaderSection(),
        body: BlocConsumer<SessionYearsCubit, SessionYearsState>(
          listener: (context, state) {
            if (state is SessionYearsFetchSuccess) {
              if (state.sessionYears.isNotEmpty &&
                  _selectedSessionYear == null) {
                // Automatically select default session year when data is first loaded
                final defaultYear = state.sessionYears.firstWhere(
                    (element) => element.isThisDefault(),
                    orElse: () => state.sessionYears.first);
                _selectedSessionYear = defaultYear;
                // Fetch leaves data once we have the session year
                getLeaves();
              }
            }
          },
          builder: (context, state) {
            if (state is SessionYearsFetchSuccess) {
              return _buildLeaveListContainer();
            }

            if (state is SessionYearsFetchFailure) {
              return Center(
                child: CustomErrorWidget(
                  message: ErrorMessageUtils.getReadableErrorMessage(
                      state.errorMessage),
                  onRetry: () {
                    context.read<SessionYearsCubit>().getSessionYears();
                  },
                  primaryColor: maroonPrimary,
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: maroonPrimary,
                      strokeWidth: 4,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Memuat data...",
                    style: TextStyle(
                      fontSize: 16,
                      color: textMediumColor,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
