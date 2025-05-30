// This is a temporary file to recreate the staffsScreen.dart file
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/staff/staffsCubit.dart';
import 'package:eschool_saas_staff/ui/screens/leaves/leavesScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffDetailsScreen.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBarWithTabs.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/searchContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/tabBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTabContainer.dart';
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

class StaffsScreen extends StatefulWidget {
  final bool forStaffLeave;
  const StaffsScreen({super.key, required this.forStaffLeave});

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return BlocProvider(
      create: (context) => StaffsCubit(),
      child: StaffsScreen(
        forStaffLeave: arguments['forStaffLeave'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments({required bool forStaffLeave}) {
    return {"forStaffLeave": forStaffLeave};
  }

  @override
  State<StaffsScreen> createState() => _StaffsScreenState();
}

class _StaffsScreenState extends State<StaffsScreen>
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
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  // Animation controller for CustomModernAppBar
  late AnimationController _fabAnimationController;

  // Untuk efek hover pada item staff
  int _hoveredStaffIndex = -1;

  // Untuk efek scroll
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

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
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    Future.delayed(Duration.zero, () {
      getStaffs();
    });
  }

  @override
  void dispose() {
    waitForNextSearchRequestTimer?.cancel();
    _textEditingController.removeListener(searchQueryTextControllerListener);
    _textEditingController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _fabAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
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
        getStaffs();
      } else {
        waitForNextRequestSearchQueryTimeInMilliSeconds =
            waitForNextRequestSearchQueryTimeInMilliSeconds -
                searchRequestPerodicMilliSeconds;
      }
    });
  }

  void getStaffs() {
    context.read<StaffsCubit>().getStaffs(
        search: _textEditingController.text.trim().isEmpty
            ? null
            : _textEditingController.text.trim(),
        status: getSatusValueFromKey(value: _selectedTabKey));
  }

  void changeTab(String value) {
    setState(() {
      _selectedTabKey = value;
    });
    getStaffs();
  }

  Widget _buildEnhancedTabButton(String key, bool isSelected) {
    // Konversi teks ke bahasa Indonesia
    String displayText = key;
    if (key == allKey) {
      displayText = "Semua";
    } else if (key == activeKey) {
      displayText = "Aktif";
    } else if (key == inactiveKey) {
      displayText = "Non-aktif";
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => changeTab(key),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? maroonPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              displayText,
              style: TextStyle(
                color: isSelected ? Colors.white : maroonPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffList(StaffsFetchSuccess state, BuildContext context) {
    if (state.saffs.isEmpty) {
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
              "Tidak ada data staff ditemukan",
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
        itemCount: state.saffs.length,
        itemBuilder: (context, index) {
          final staffDetails = state.saffs[index];
          final bool isHovered = _hoveredStaffIndex == index;

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: Duration(milliseconds: 450),
            child: SlideAnimation(
              horizontalOffset: 40,
              child: FadeInAnimation(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (widget.forStaffLeave) {
                      Get.toNamed(Routes.leavesScreen,
                          arguments: LeavesScreen.buildArguments(
                              userDetails: staffDetails, showMyLeaves: false));
                    } else {
                      Get.toNamed(Routes.staffDetailsScreen,
                          arguments: StaffDetailsScreen.buildArguments(
                              staffDetails: staffDetails));
                    }
                  },
                  onTapDown: (_) {
                    setState(() {
                      _hoveredStaffIndex = index;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      _hoveredStaffIndex = -1;
                    });
                  },
                  onTapUp: (_) {
                    Future.delayed(Duration(milliseconds: 300), () {
                      if (mounted) {
                        setState(() {
                          _hoveredStaffIndex = -1;
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
                            imageUrl: staffDetails.image ?? "",
                          ),
                        ),
                        SizedBox(width: 16),

                        // Staff info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      staffDetails.fullName ?? "-",
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
                                      color: staffDetails.status == 1
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      staffDetails.status == 1
                                          ? "Aktif"
                                          : "Non-aktif",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: staffDetails.status == 1
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
                                staffDetails.getRoles(),
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),

                              // Role tags
                              if (staffDetails.getRoles().isNotEmpty) ...[
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: staffDetails
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
      appBar: CustomModernAppBar(
        title: "Staff",
        icon: Icons.people,
        height: 120, // Memperbesar tinggi AppBar untuk mengakomodasi filter
        fabAnimationController: _fabAnimationController,
        primaryColor: maroonPrimary,
        lightColor: maroonSecondary,
        onBackPressed: () => Get.back(),
        tabBuilder: (context) => Row(
          children: [
            _buildEnhancedTabButton(allKey, _selectedTabKey == allKey),
            _buildEnhancedTabButton(activeKey, _selectedTabKey == activeKey),
            _buildEnhancedTabButton(
                inactiveKey, _selectedTabKey == inactiveKey),
          ],
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

          // Content area with proper padding for the AppBar
          Padding(
            padding:
                EdgeInsets.only(top: 120 + MediaQuery.of(context).padding.top),
            child: Column(
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
                        hintText: "Cari staff...",
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: maroonPrimary),
                        suffixIcon: _textEditingController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _textEditingController.clear();
                                  getStaffs();
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

                // Staff List
                Expanded(
                  child: BlocBuilder<StaffsCubit, StaffsState>(
                    builder: (context, state) {
                      if (state is StaffsFetchSuccess) {
                        return _buildStaffList(state, context);
                      }

                      if (state is StaffsFetchFailure) {
                        return Center(
                          child: ErrorContainer(
                            errorMessage: state.errorMessage,
                            onTapRetry: () {
                              getStaffs();
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
