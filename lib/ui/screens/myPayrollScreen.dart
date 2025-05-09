import 'dart:math';
import 'dart:ui';

import 'package:eschool_saas_staff/cubits/academics/sessionYearsCubit.dart';
import 'package:eschool_saas_staff/cubits/payRoll/downloadPayRollSlipCubit.dart';
import 'package:eschool_saas_staff/cubits/payRoll/myPayRollCubit.dart';
import 'package:eschool_saas_staff/data/models/payRoll.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/downloadPayRollSlipDialog.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/textWithFadedBackgroundContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class MyPayrollScreen extends StatefulWidget {
  const MyPayrollScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SessionYearsCubit(),
        ),
        BlocProvider(create: (context) => MyPayRollCubit())
      ],
      child: const MyPayrollScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<MyPayrollScreen> createState() => _MyPayrollScreenState();
}

class _MyPayrollScreenState extends State<MyPayrollScreen>
    with TickerProviderStateMixin {
  SessionYear? _selectedSessionYear;

  // Color scheme for maroon theme
  final Color _maroonPrimary = const Color(0xFF800020);
  final Color _maroonLight = const Color(0xFFAA6976);
  final Color _maroonDark = const Color(0xFF5A0018);

  // Animation controller for various animated elements
  late AnimationController _fabAnimationController;
  late final ScrollController _scrollController = ScrollController()
    ..addListener(scrollListener);

  // State variables for UI interactions
  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<SessionYearsCubit>().getSessionYears();
      }
    });
  }

  void scrollListener() {
    // Animate elements based on scroll
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
    super.dispose();
  }

  void changeSelectedSessionYear(SessionYear value) {
    _selectedSessionYear = value;
    setState(() {});
    getPayRoll();
  }

  void getPayRoll() {
    context
        .read<MyPayRollCubit>()
        .getMyPayRoll(sessionYearId: _selectedSessionYear?.id ?? 0);
  }

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: MediaQuery.of(context).padding.top + 150,
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
                                              Icons.payments_rounded,
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
                                        'Gaji Saya',
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

                        // Filter button with interactive animation
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
                                  _isFilterVisible = !_isFilterVisible;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: _isFilterVisible
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
                                  child: _isFilterVisible
                                      ? Icon(
                                          Icons.close_rounded,
                                          key: ValueKey<bool>(true),
                                          color: Colors.white,
                                          size: 22,
                                        )
                                      : Icon(
                                          Icons.filter_list_rounded,
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

            // Filter options - Session Year Selector
            BlocBuilder<SessionYearsCubit, SessionYearsState>(
              builder: (context, state) {
                return AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  bottom: 10,
                  left: 16,
                  right: 16,
                  height: _isFilterVisible ? 56 : 0,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 300),
                    opacity: _isFilterVisible ? 1.0 : 0.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (state is SessionYearsFetchSuccess &&
                                    state.sessionYears.isNotEmpty) {
                                  Utils.showBottomSheet(
                                    child:
                                        FilterSelectionBottomsheet<SessionYear>(
                                      onSelection: (value) {
                                        changeSelectedSessionYear(value!);
                                        Get.back();
                                      },
                                      selectedValue: _selectedSessionYear!,
                                      titleKey: sessionYearKey,
                                      values: state.sessionYears,
                                    ),
                                    context: context,
                                  );
                                }
                              },
                              highlightColor: Colors.white.withOpacity(0.1),
                              splashColor: Colors.white.withOpacity(0.2),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _selectedSessionYear?.name ??
                                            "Tahun Ajaran",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
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
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayRolls() {
    return BlocBuilder<MyPayRollCubit, MyPayRollState>(
      builder: (context, state) {
        if (state is MyPayRollFetchSuccess) {
          if (state.payrolls.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _maroonPrimary.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 70,
                      color: _maroonPrimary.withOpacity(0.7),
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  SizedBox(height: 24),
                  Text(
                    'Gaji Belum Tersedia',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _maroonPrimary,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  SizedBox(height: 12),
                  Text(
                    'Gaji Anda untuk periode ini belum tersedia',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            );
          }
          return Align(
            alignment: Alignment.topCenter,
            child: RefreshIndicator(
              onRefresh: () async {
                getPayRoll();
              },
              color: _maroonPrimary,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(
                  bottom: 100,
                  // Increasing top padding to ensure content appears below app bar
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
                            'Riwayat Gaji',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _maroonPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lihat riwayat lengkap gaji Anda',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: -0.1, end: 0, curve: Curves.easeOutQuad),

                    // Payroll list with container styling
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
                                    Icons.account_balance_wallet,
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
                                        'Gaji Periode',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        '${state.payrolls.length} pembayaran tersedia',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Counter badge with animation
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                    ),
                                  ],
                                  ),
                                  child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                 
                                  child: Row(
                                    children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: Color(0xFF28A745),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Dibayar",
                                      style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF28A745),
                                      ),
                                    ),
                                    ],
                                  ),
                                  ),
                                ),
                                ],
                              ),
                              ),

                          // Payroll items list
                          Column(
                            children: List.generate(
                              state.payrolls.length,
                              (index) => MyPayrollDetailsContainer(
                                payRoll: state.payrolls[index],
                                index: index,
                                maroonPrimary: _maroonPrimary,
                                maroonLight: _maroonLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad),
                  ],
                ),
              ),
            ),
          );
            
        }

        if (state is MyPayRollFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: () {
                getPayRoll();
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
              'Memuat data gaji...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          BlocBuilder<SessionYearsCubit, SessionYearsState>(
            builder: (context, state) {
              if (state is SessionYearsFetchSuccess) {
                if (state.sessionYears.isNotEmpty) {
                  return _buildPayRolls();
                }
                return const SizedBox();
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
                child: CustomCircularProgressIndicator(
                  indicatorColor: _maroonPrimary,
                ),
              );
            },
          ),

          // Modern AppBar with frosted glass effect
          _buildAppBar(),

          // Code for SessionYearsCubit listener
          BlocListener<SessionYearsCubit, SessionYearsState>(
            listener: (context, state) {
              if (state is SessionYearsFetchSuccess &&
                  state.sessionYears.isNotEmpty) {
                changeSelectedSessionYear(state.sessionYears
                    .where((element) => element.isThisDefault())
                    .toList()
                    .first);
              }
            },
            child: const SizedBox(),
          ),
        ],
      ),
    );
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

class MyPayrollDetailsContainer extends StatefulWidget {
  final int index;
  final PayRoll payRoll;
  final Color maroonPrimary;
  final Color maroonLight;

  const MyPayrollDetailsContainer({
    super.key,
    required this.index,
    required this.payRoll,
    required this.maroonPrimary,
    required this.maroonLight,
  });

  @override
  State<MyPayrollDetailsContainer> createState() =>
      _MyPayrollDetailsContainerState();
}

class _MyPayrollDetailsContainerState extends State<MyPayrollDetailsContainer>
    with TickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));

  late final AnimationController _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500))
    ..repeat(reverse: true);

  // Remove fixed height animation
  bool get _isExpanded => _animationController.value > 0.5;

  late final Animation<double> _opacityAnimation =
      Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOut)));

  late final Animation<double> _iconAngleAnimation =
      Tween<double>(begin: 0, end: 0.5).animate(CurvedAnimation(
          parent: _animationController, curve: Curves.easeInOut));

  late final Animation<double> _pulseAnimation =
      Tween<double>(begin: 1.0, end: 1.08).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

  bool _isHovered = false;

  String _formatToRupiah(double? value) {
    if (value == null) return "Rp -";
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  String getIndonesianMonth(int monthNumber) {
    const List<String> indonesianMonths = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    if (monthNumber >= 1 && monthNumber <= 12) {
      return indonesianMonths[monthNumber - 1];
    }
    return 'Bulan tidak valid';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Modern styled info row for payroll details
  Widget _buildInfoRow({
    required String label,
    required String value,
    IconData? icon,
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side - label with icon
          Expanded(
            flex: 2,
            child: Row(
              children: [
                if (icon != null)
                  Container(
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: widget.maroonPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: widget.maroonPrimary,
                    ),
                  ),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              ":",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ),

          // Right side - value
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? widget.maroonPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_animationController, _pulseAnimation]),
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? widget.maroonPrimary.withOpacity(0.15)
                      : Colors.black.withOpacity(0.03),
                  blurRadius: _isHovered ? 10 : 4,
                  offset: Offset(0, 2),
                  spreadRadius: _isHovered ? 1 : 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_animationController.isAnimating) {
                      return;
                    }

                    if (_animationController.isCompleted) {
                      _animationController.reverse();
                    } else {
                      _animationController.forward();
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  splashColor: widget.maroonPrimary.withOpacity(0.05),
                  highlightColor: widget.maroonPrimary.withOpacity(0.05),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isHovered
                            ? widget.maroonPrimary.withOpacity(0.2)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with month and year
                        Row(
                          children: [
                            // Left side with month and year
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          widget.maroonPrimary.withOpacity(0.8),
                                          widget.maroonLight,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: widget.maroonPrimary
                                              .withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      "${widget.index + 1}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${getIndonesianMonth(widget.payRoll.month ?? 1)}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[800],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "${widget.payRoll.year ?? ''}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Right side with status and expand button
                            Row(
                              children: [
                              
                                const SizedBox(width: 8),
                                Transform.rotate(
                                  angle:
                                      _iconAngleAnimation.value * 2 * 3.14159,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _animationController.isCompleted
                                          ? widget.maroonPrimary
                                              .withOpacity(0.1)
                                          : Colors.grey[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: _animationController.isCompleted
                                          ? widget.maroonPrimary
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Salary information section
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Basic salary
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet_outlined,
                                          size: 16,
                                          color: Colors.grey[700],
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Gaji Pokok",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatToRupiah(
                                          widget.payRoll.basicSalary),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.grey[300],
                                margin: EdgeInsets.symmetric(horizontal: 12),
                              ),

                              // Net salary
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.payments_rounded,
                                          size: 16,
                                          color: widget.maroonPrimary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Gaji Bersih",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: widget.maroonPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatToRupiah(widget.payRoll.amount),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: widget.maroonPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Expanded details section with AnimatedSize
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: _isExpanded
                              ? AnimatedOpacity(
                                  opacity: _opacityAnimation.value,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Section title
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              size: 16,
                                              color: widget.maroonPrimary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Detail Gaji',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: widget.maroonPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),

                                        // Leave details
                                        _buildInfoRow(
                                          label: "Cuti Bulanan",
                                          value: widget.payRoll.paidLeaves
                                                  ?.toStringAsFixed(0) ??
                                              "-",
                                          icon: Icons.event_available,
                                        ),

                                        _buildInfoRow(
                                          label: "Cuti Diambil",
                                          value: widget.payRoll.takenLeaves
                                                  ?.toStringAsFixed(0) ??
                                              "-",
                                          icon: Icons.calendar_month,
                                        ),

                                        // Download button
                                        Container(
                                          width: double.infinity,
                                          margin:
                                              const EdgeInsets.only(top: 12),
                                          child: Material(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              onTap: () {
                                                Get.dialog(BlocProvider(
                                                  create: (context) =>
                                                      DownloadPayRollSlipCubit(),
                                                  child:
                                                      DownloadPayRollSlipDialog(
                                                    payRoll: widget.payRoll,
                                                  ),
                                                ));
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      widget.maroonPrimary,
                                                      Color(0xFF9A1E3C),
                                                    ],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: widget
                                                          .maroonPrimary
                                                          .withOpacity(0.3),
                                                      offset:
                                                          const Offset(0, 3),
                                                      blurRadius: 6,
                                                      spreadRadius: 0,
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.download_rounded,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        Utils.getTranslatedLabel(
                                                            downloadSalarySlipKey),
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
