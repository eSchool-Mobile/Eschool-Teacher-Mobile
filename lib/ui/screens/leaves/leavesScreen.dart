import 'package:eschool_saas_staff/cubits/academics/sessionYearsCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/leave/userLeavesCubit.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/customFilterModernAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

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

  // Define theme colors
  final Color maroonPrimary = Color(0xFF8B1F41);
  final Color maroonLight = Color(0xFFAC3B5C);
  final Color maroonDark = Color(0xFF6A0F2A);
  final Color accentColor = Color(0xFFF5EBE0);
  final Color bgColor = Color(0xFFFAF6F2);
  final Color cardColor = Colors.white;
  final Color textDarkColor = Color(0xFF2D2D2D);
  final Color textMediumColor = Color(0xFF717171);
  final Color borderColor = Color(0xFFE8E8E8);

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

    // Start animations
    _animationController.forward();

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
    return months.indexOf(_selectedMonthKey) + 1;
  }

  void getLeaves() {
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
      height: Utils().getResponsiveHeight(context, 100),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
            spreadRadius: 0,
          )
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: maroonPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  title == allowedLeavesKey
                      ? Icons.event_available
                      : Icons.event_busy,
                  size: 18,
                  color: maroonPrimary,
                ),
              ),
              SizedBox(width: 12),
              Text(
                title.tr,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: textMediumColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: maroonPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveTableHeader() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: maroonPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
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
        // If we have a session year but no leaves data yet, fetch it
        if (state is UserLeavesInitial && _selectedSessionYear != null) {
          getLeaves();
        }
      },
      builder: (context, state) {
        if (state is UserLeavesFetchSuccess) {
          if (state.leaves.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 100,
                ),
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

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.only(top: 20, bottom: 30),
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ringkasan Cuti",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textDarkColor,
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
                        SizedBox(height: 16),

                        // Leave count summary
                        LayoutBuilder(builder: (context, boxConstraints) {
                          return Row(
                            children: [
                              _buildLeaveCountContainer(
                                width: boxConstraints.maxWidth * 0.48,
                                title: allowedLeavesKey,
                                value: state.monthlyAllowedLeaves
                                    .toStringAsFixed(0),
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

                  SizedBox(height: 24),

                  // Leave applications section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: maroonPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.list_alt_rounded,
                                color: maroonPrimary,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Riwayat Pengajuan",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textDarkColor,
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
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: maroonPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: maroonPrimary.withOpacity(0.3),
                                  width: 1,
                                ),
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
                        SizedBox(height: 16),

                        // Leave applications list
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildLeaveTableHeader(),
                              Container(
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                child: ListView.separated(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: state.leaves.length,
                                  separatorBuilder: (context, index) => Divider(
                                    color: borderColor,
                                    height: 1,
                                  ),
                                  itemBuilder: (context, index) {
                                    final leave = state.leaves[index];
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 40,
                                            child: Text(
                                              "${index + 1}",
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: textDarkColor,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
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
                                                if (leave.fromDate !=
                                                    leave.toDate)
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
                                          SizedBox(
                                            width: 100,
                                            child: _buildStatusBadge(
                                                leave.status?.toString() ?? ''),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is UserLeavesFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: () {
                getLeaves();
              },
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

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'approved':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = "Disetujui";
        break;
      case 'pending':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        label = "Menunggu";
        break;
      case 'rejected':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        label = "Ditolak";
        break;
      default:
        bgColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          fontFamily: 'Poppins',
        ),
        textAlign: TextAlign.center,
      ),
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
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context.read<SessionYearsCubit>().getSessionYears();
                  },
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
