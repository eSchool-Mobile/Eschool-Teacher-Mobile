import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/teacher/teachersCubit.dart';
import 'package:eschool_saas_staff/ui/screens/leaves/leavesScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherProfileScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherTimeTableDetailsScreen.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customErrorWidget.dart';
import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/searchContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/no_search_results_widget.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';

enum TeacherNavigationType { leave, profile, timetable }

// Menambahkan enum untuk filter status guru
enum TeacherStatusFilter { all, active, inactive }

class TeachersScreen extends StatefulWidget {
  final TeacherNavigationType teacherNavigationType;
  const TeachersScreen({super.key, required this.teacherNavigationType});

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return BlocProvider(
      create: (context) => TeachersCubit(),
      child: TeachersScreen(
        teacherNavigationType: arguments['teacherNavigationType'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required TeacherNavigationType teacherNavigationType}) {
    return {"teacherNavigationType": teacherNavigationType};
  }

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen>
    with TickerProviderStateMixin {
  late String _selectedTabKey = allKey;
  late final TextEditingController _textEditingController =
      TextEditingController()..addListener(searchQueryTextControllerListener);

  // Variable untuk status filter guru
  TeacherStatusFilter _currentStatusFilter = TeacherStatusFilter.all;

  late int waitForNextRequestSearchQueryTimeInMilliSeconds =
      nextSearchRequestQueryTimeInMilliSeconds;

  Timer? waitForNextSearchRequestTimer;

  // Warna tema maroon yang digunakan dalam aplikasi
  final Color maroonPrimary = const Color(0xFF8B1F41);
  final Color maroonSecondary = const Color(0xFFA84B5C);
  final Color maroonLight = const Color(0xFFE7C8CD);
  final Color accentPink = const Color(0xFFF4D0D9);
  final Color warmBeige = const Color(0xFFF5E6E8);

  // Controllers untuk animasi
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  late AnimationController
      _fabAnimationController; // Added for CustomModernAppBar

  // Untuk efek hover pada item staff
  int _hoveredTeacherIndex = -1;

  // Untuk efek scroll header
  final ScrollController _scrollController = ScrollController();
  double _headerHeight = 200.0;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();

    // Inisialisasi animation controllers
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutQuint,
      ),
    );

    // Pulse animation untuk efek interaktif
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Rotation animation untuk elemen dekoratif
    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 10000),
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    // Initialize fabAnimationController for CustomModernAppBar
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    )..forward();

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    // Listener untuk efek scroll header
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && !_isScrolled) {
        setState(() {
          _headerHeight = 120.0;
          _isScrolled = true;
        });
      } else if (_scrollController.offset <= 50 && _isScrolled) {
        setState(() {
          _headerHeight = 200.0;
          _isScrolled = false;
        });
      }
    });

    Future.delayed(Duration.zero, () {
      getTeachers();
    });
  }

  @override
  void dispose() {
    waitForNextSearchRequestTimer?.cancel();
    _textEditingController.removeListener(searchQueryTextControllerListener);
    _textEditingController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _fabAnimationController
        .dispose(); // Add this line to dispose the new controller
    _scrollController.dispose();
    super.dispose();
  }

  void getTeachers() {
    context.read<TeachersCubit>().getTeachers(
        search: _textEditingController.text.trim().isEmpty
            ? null
            : _textEditingController.text.trim());
  }

  void searchQueryTextControllerListener() {
    if (_textEditingController.text.trim().isEmpty) {
      return;
    }
    waitForNextSearchRequestTimer?.cancel();
    setWaitForNextSearchRequestTimer();
  }

  void setWaitForNextSearchRequestTimer() {
    if (waitForNextRequestSearchQueryTimeInMilliSeconds !=
        (waitForNextRequestSearchQueryTimeInMilliSeconds -
            searchRequestPerodicMilliSeconds)) {
      //
      waitForNextRequestSearchQueryTimeInMilliSeconds =
          (nextSearchRequestQueryTimeInMilliSeconds -
              searchRequestPerodicMilliSeconds);
    }
    //
    waitForNextSearchRequestTimer = Timer.periodic(
        Duration(milliseconds: searchRequestPerodicMilliSeconds), (timer) {
      if (waitForNextRequestSearchQueryTimeInMilliSeconds == 0) {
        timer.cancel();
        getTeachers();
      } else {
        waitForNextRequestSearchQueryTimeInMilliSeconds =
            waitForNextRequestSearchQueryTimeInMilliSeconds -
                searchRequestPerodicMilliSeconds;
      }
    });
  }

  void changeTab(String value) {
    setState(() {
      _selectedTabKey = value;
    });
    getTeachers();
  }

  String getNavigationTitleKey() {
    if (widget.teacherNavigationType == TeacherNavigationType.leave) {
      return viewLeavesKey;
    }
    if (widget.teacherNavigationType == TeacherNavigationType.timetable) {
      return timetableKey;
    }
    return viewProfileKey;
  }

  Widget _buildTeacherList(TeachersFetchSuccess state, BuildContext context) {
    // Menerapkan filter berdasarkan status guru
    var filteredTeachers = state.teachers;

    if (_currentStatusFilter == TeacherStatusFilter.active) {
      filteredTeachers =
          state.teachers.where((teacher) => teacher.isActive()).toList();
    } else if (_currentStatusFilter == TeacherStatusFilter.inactive) {
      filteredTeachers =
          state.teachers.where((teacher) => !teacher.isActive()).toList();
    }

    if (filteredTeachers.isEmpty) {
      // Check if this is due to search or no data at all
      if (_textEditingController.text.trim().isNotEmpty) {
        return NoSearchResultsWidget(
          searchQuery: _textEditingController.text.trim(),
          onClearSearch: () {
            _textEditingController.clear();
            getTeachers();
          },
          primaryColor: maroonPrimary,
          accentColor: maroonSecondary,
          title: 'Guru Tidak Ditemukan',
          description:
              'Tidak ditemukan guru yang sesuai dengan pencarian Anda. Coba gunakan kata kunci yang berbeda.',
          icon: Icons.person_outline,
        );
      } else {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animasi ikon
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Icon(
                      Icons.people_outline,
                      size: 80,
                      color: maroonPrimary.withOpacity(0.6),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              Text(
                "Tidak ada data guru ditemukan",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );
      }
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        itemCount: filteredTeachers.length,
        itemBuilder: (context, index) {
          final teacherDetails = filteredTeachers[index];
          final bool isHovered = _hoveredTeacherIndex == index;

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: Duration(milliseconds: 450),
            child: SlideAnimation(
              horizontalOffset: 40,
              child: FadeInAnimation(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (widget.teacherNavigationType ==
                        TeacherNavigationType.leave) {
                      Get.toNamed(Routes.leavesScreen,
                          arguments: LeavesScreen.buildArguments(
                              showMyLeaves: false,
                              userDetails: teacherDetails));
                    } else if (widget.teacherNavigationType ==
                        TeacherNavigationType.timetable) {
                      Get.toNamed(Routes.teacherTimeTableDetailsScreen,
                          arguments:
                              TeacherTimeTableDetailsScreen.buildArguments(
                                  teacherDetails: teacherDetails));
                    } else {
                      Get.toNamed(Routes.teacherProfileScreen,
                          arguments: TeacherProfileScreen.buildArguments(
                              userDetails: teacherDetails));
                    }
                  },
                  onTapDown: (_) {
                    setState(() {
                      _hoveredTeacherIndex = index;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      _hoveredTeacherIndex = -1;
                    });
                  },
                  onTapUp: (_) {
                    Future.delayed(Duration(milliseconds: 300), () {
                      if (mounted) {
                        setState(() {
                          _hoveredTeacherIndex = -1;
                        });
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isHovered
                            ? [
                                maroonPrimary.withOpacity(0.02),
                                maroonSecondary.withOpacity(0.05),
                              ]
                            : [Colors.white, Colors.white],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isHovered
                            ? maroonPrimary.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isHovered
                              ? maroonPrimary.withOpacity(0.1)
                              : Colors.black.withOpacity(0.03),
                          blurRadius: isHovered ? 12 : 6,
                          offset: Offset(0, 4),
                          spreadRadius: isHovered ? 1 : 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar dengan efek hover
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isHovered
                                  ? maroonPrimary.withOpacity(0.4)
                                  : Colors.grey.shade200,
                              width: 2,
                            ),
                            boxShadow: isHovered
                                ? [
                                    BoxShadow(
                                      color: maroonPrimary.withOpacity(0.15),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : [],
                          ),
                          child: ProfileImageContainer(
                            imageUrl: teacherDetails.image ?? "",
                          ),
                        ),
                        SizedBox(width: 16),

                        // Teacher info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      teacherDetails.fullName ?? "-",
                                      style: GoogleFonts.poppins(
                                        fontWeight: isHovered
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        fontSize: 16,
                                        color: isHovered
                                            ? maroonPrimary
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),

                                  // Status indicator
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: teacherDetails.isActive()
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      teacherDetails.isActive()
                                          ? "Aktif"
                                          : "Non-aktif",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: teacherDetails.isActive()
                                            ? Colors.green
                                            : Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                teacherDetails.occupation ?? "Guru",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),

                              // Role tags
                              if (teacherDetails.getRoles().isNotEmpty) ...[
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: teacherDetails
                                      .getRoles()
                                      .split(',')
                                      .map((role) => role.trim())
                                      .where((role) => role.isNotEmpty)
                                      .map((role) => Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: maroonPrimary
                                                  .withOpacity(0.08),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              role,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: maroonPrimary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Icon animasi
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          transform: Matrix4.translationValues(
                              isHovered ? 8.0 : 0.0, 0.0, 0.0),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: isHovered
                                ? maroonPrimary
                                : maroonPrimary.withOpacity(0.5),
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Need to add a fabAnimationController for the CustomModernAppBar
    late final AnimationController fabAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    )..forward();

    String titleKey = "Daftar Guru";
    if (widget.teacherNavigationType == TeacherNavigationType.leave) {
      titleKey = "Guru - Cuti";
    } else if (widget.teacherNavigationType ==
        TeacherNavigationType.timetable) {
      titleKey = "Guru - Jadwal";
    } else {
      titleKey = "Daftar Guru";
    }

    return Scaffold(
      appBar: CustomModernAppBar(
        title: titleKey,
        icon: Icons.people_alt_rounded,
        fabAnimationController: fabAnimationController,
        primaryColor: maroonPrimary,
        lightColor: maroonSecondary,
        onBackPressed: () => Navigator.of(context).pop(),
        showFilterButton: true,
        onFilterPressed: () {
          // Optional: Implement filter functionality here
          HapticFeedback.lightImpact();
          // Show filter options
          showFilterOptions();
        },
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: "Cari guru...",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: maroonPrimary),
                  suffixIcon: _textEditingController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _textEditingController.clear();
                            getTeachers();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Filter Indicator
          if (_currentStatusFilter != TeacherStatusFilter.all)
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Row(
                children: [
                  Icon(
                    _currentStatusFilter == TeacherStatusFilter.active
                        ? Icons.check_circle_outline
                        : Icons.remove_circle_outline,
                    color: maroonPrimary,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _currentStatusFilter == TeacherStatusFilter.active
                        ? "Menampilkan Guru Aktif"
                        : "Menampilkan Guru Non-Aktif",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _currentStatusFilter = TeacherStatusFilter.all;
                      });
                    },
                    child: Text(
                      "Reset",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: maroonPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Filter Status Indicator
          if (_currentStatusFilter != TeacherStatusFilter.all)
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: maroonPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: maroonPrimary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _currentStatusFilter == TeacherStatusFilter.active
                          ? Icons.check_circle_outline
                          : Icons.remove_circle_outline,
                      color: maroonPrimary,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _currentStatusFilter == TeacherStatusFilter.active
                          ? "Filter: Guru Aktif"
                          : "Filter: Guru Non-Aktif",
                      style: GoogleFonts.poppins(
                        color: maroonPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _currentStatusFilter = TeacherStatusFilter.all;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          color: maroonPrimary,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Teacher List
          Expanded(
            child: BlocBuilder<TeachersCubit, TeachersState>(
              builder: (context, state) {
                if (state is TeachersFetchSuccess) {
                  return _buildTeacherList(state, context);
                }

                if (state is TeachersFetchFailure) {
                  return Center(
                    child: CustomErrorWidget(
                      message: state.errorMessage,
                      onRetry: () {
                        getTeachers();
                      },
                      primaryColor: maroonPrimary,
                    ),
                  );
                }

                return Center(
                  child: CustomCircularProgressIndicator(
                    indicatorColor: maroonPrimary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showFilterOptions() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Filter Status Guru",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      onTap: () {
                        setState(() {
                          _currentStatusFilter = TeacherStatusFilter.all;
                        });
                        Navigator.pop(context);
                      },
                      title: Text(
                        "Semua Guru",
                        style: GoogleFonts.poppins(
                          fontWeight:
                              _currentStatusFilter == TeacherStatusFilter.all
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                          color: _currentStatusFilter == TeacherStatusFilter.all
                              ? maroonPrimary
                              : Colors.black87,
                        ),
                      ),
                      leading: Icon(
                        Icons.people_alt_rounded,
                        color: _currentStatusFilter == TeacherStatusFilter.all
                            ? maroonPrimary
                            : Colors.grey.shade600,
                      ),
                      trailing: _currentStatusFilter == TeacherStatusFilter.all
                          ? Icon(Icons.check_circle, color: maroonPrimary)
                          : null,
                      tileColor: _currentStatusFilter == TeacherStatusFilter.all
                          ? maroonPrimary.withOpacity(0.05)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(height: 8),
                    ListTile(
                      onTap: () {
                        setState(() {
                          _currentStatusFilter = TeacherStatusFilter.active;
                        });
                        Navigator.pop(context);
                      },
                      title: Text(
                        "Guru Aktif",
                        style: GoogleFonts.poppins(
                          fontWeight:
                              _currentStatusFilter == TeacherStatusFilter.active
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                          color:
                              _currentStatusFilter == TeacherStatusFilter.active
                                  ? maroonPrimary
                                  : Colors.black87,
                        ),
                      ),
                      leading: Icon(
                        Icons.check_circle_outline,
                        color:
                            _currentStatusFilter == TeacherStatusFilter.active
                                ? maroonPrimary
                                : Colors.grey.shade600,
                      ),
                      trailing:
                          _currentStatusFilter == TeacherStatusFilter.active
                              ? Icon(Icons.check_circle, color: maroonPrimary)
                              : null,
                      tileColor:
                          _currentStatusFilter == TeacherStatusFilter.active
                              ? maroonPrimary.withOpacity(0.05)
                              : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(height: 8),
                    ListTile(
                      onTap: () {
                        setState(() {
                          _currentStatusFilter = TeacherStatusFilter.inactive;
                        });
                        Navigator.pop(context);
                      },
                      title: Text(
                        "Guru Non-Aktif",
                        style: GoogleFonts.poppins(
                          fontWeight: _currentStatusFilter ==
                                  TeacherStatusFilter.inactive
                              ? FontWeight.w500
                              : FontWeight.normal,
                          color: _currentStatusFilter ==
                                  TeacherStatusFilter.inactive
                              ? maroonPrimary
                              : Colors.black87,
                        ),
                      ),
                      leading: Icon(
                        Icons.remove_circle_outline,
                        color:
                            _currentStatusFilter == TeacherStatusFilter.inactive
                                ? maroonPrimary
                                : Colors.grey.shade600,
                      ),
                      trailing:
                          _currentStatusFilter == TeacherStatusFilter.inactive
                              ? Icon(Icons.check_circle, color: maroonPrimary)
                              : null,
                      tileColor:
                          _currentStatusFilter == TeacherStatusFilter.inactive
                              ? maroonPrimary.withOpacity(0.05)
                              : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      // Refresh list after filter is selected
      setState(() {});
    });
  }
}

class BackgroundPatternPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;

  BackgroundPatternPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Pola titik-titik
    final dotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    for (var x = 0; x < width; x += 30) {
      for (var y = 0; y < height; y += 30) {
        final offset = math.sin(x * 0.05 + y * 0.05 + animation) * 3;
        final radius = 1 + math.sin(x * 0.04 + y * 0.04 + animation) * 0.5;
        canvas.drawCircle(
          Offset(x + offset, y + offset),
          radius,
          dotPaint,
        );
      }
    }

    // Gelombang animasi
    final wavePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var startY = 0; startY < height; startY += 200) {
      final path = Path();
      var startX = 0.0;
      path.moveTo(startX, startY.toDouble());

      for (var x = 0; x < width; x += 10) {
        final y = startY + math.sin(x * 0.02 + animation) * 20;
        path.lineTo(x.toDouble(), y);
      }

      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) => true;
}
