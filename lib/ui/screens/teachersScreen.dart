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
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/searchContainer.dart';
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
    if (state.teachers.isEmpty) {
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

    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        itemCount: state.teachers.length,
        itemBuilder: (context, index) {
          final teacherDetails = state.teachers[index];
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
    return Scaffold(
      // Set warna status bar transparan agar app bar terlihat full sampai status bar
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background dengan gradien dan pattern
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  warmBeige.withOpacity(0.5),
                  Colors.white,
                ],
              ),
            ),
          ),

          // Animated background pattern
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: BackgroundPatternPainter(
                    animation: _rotationAnimation.value,
                    primaryColor: maroonPrimary.withOpacity(0.03),
                    accentColor: maroonSecondary.withOpacity(0.02),
                  ),
                );
              },
            ),
          ),

          // Content area - Tidak menggunakan SafeArea untuk header
          Column(
            children: [
              // Header section with animations - tanpa SafeArea
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOutQuint,
                // Tambahkan padding top untuk status bar
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                height: _headerHeight + MediaQuery.of(context).padding.top,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [maroonPrimary, maroonSecondary],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: maroonPrimary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Stack(
                      children: [
                        // Decorative elements
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                                stops: [0, 0.7],
                              ),
                            ),
                          ),
                        ),

                        // Header content
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Back button and title
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => Get.back(),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    "Guru",
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),

                              if (!_isScrolled) ...[
                                SizedBox(height: 16),
                                Text(
                                  "Kelola guru dan akses informasi guru secara lebih mudah",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),


              // Search Bar
              Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
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

              // Teacher List
              Expanded(
                child: BlocBuilder<TeachersCubit, TeachersState>(
                  builder: (context, state) {
                    if (state is TeachersFetchSuccess) {
                      return _buildTeacherList(state, context);
                    }

                    if (state is TeachersFetchFailure) {
                      return Center(
                        child: ErrorContainer(
                          errorMessage: state.errorMessage,
                          onTapRetry: () {
                            getTeachers();
                          },
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
        ],
      ),
    );
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
