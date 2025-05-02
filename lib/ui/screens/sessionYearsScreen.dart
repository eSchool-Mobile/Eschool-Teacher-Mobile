import 'package:eschool_saas_staff/cubits/academics/sessionYearsCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';

class SessionYearsScreen extends StatefulWidget {
  const SessionYearsScreen({super.key});

  static Widget getRouteInstance() {
    return BlocProvider(
      create: (context) => SessionYearsCubit(),
      child: const SessionYearsScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<SessionYearsScreen> createState() => _SessionYearsScreenState();
}

class _SessionYearsScreenState extends State<SessionYearsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  int _selectedIndex = -1;
  final ScrollController _scrollController = ScrollController();

  // Enhanced soft maroon color palette
  final List<Color> _gradientColors = [
    const Color(0xFF9E2A2B), // Deep soft maroon
    const Color(0xFFE09F7D), // Soft peach
  ];

  // Updated shadow colors for more elegant look
  final List<BoxShadow> _cardShadows = [
    const BoxShadow(
      color: Color(0x20800000),
      blurRadius: 15,
      offset: Offset(0, 5),
      spreadRadius: 1,
    ),
    const BoxShadow(
      color: Color(0x10800000),
      blurRadius: 25,
      offset: Offset(0, 8),
      spreadRadius: -2,
    ),
  ];

  // Pattern opacity
  final double _patternOpacity = 0.03;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<SessionYearsCubit>().getSessionYears();
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  void _selectYear(int index) {
    setState(() {
      if (_selectedIndex == index) {
        _selectedIndex = -1;
      } else {
        _selectedIndex = index;
      }
    });
  }

  Color _getRandomPastelColor(int index) {
    // Enhanced color palette with soft maroon tones
    final List<Color> pastelColors = [
      const Color(0xFF8C1C13), // Deep burgundy
      const Color(0xFFBF4342), // Rusty rose
      const Color(0xFFA75D5D), // Dusted clay
      const Color(0xFFC16E70), // Rose taupe
      const Color(0xFFD19C97), // Rosy brown
      const Color(0xFF9D5C63), // Rose dust
      const Color(0xFFBA6E6E), // Copper rose
      const Color(0xFF7C383B), // Wine
      const Color(0xFFAF4035), // Russet
      const Color(0xFFCB5D61), // Light carmine
    ];

    return pastelColors[index % pastelColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Update system UI overlay style for immersive experience
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: theme.scaffoldBackgroundColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      ),
      body: BlocBuilder<SessionYearsCubit, SessionYearsState>(
        builder: (context, state) {
          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom App Bar with gradient
              SliverAppBar(
                expandedHeight: size.height * 0.28,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Gradient background
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),

                      // Decorative patterns
                      Positioned(
                        right: -30,
                        top: -30,
                        child: SlideTransition(
                          position: _slideController.drive(Tween(
                            begin: const Offset(0.2, -0.2),
                            end: Offset.zero,
                          )),
                          child: Opacity(
                            opacity: 0.1,
                            child: Icon(
                              Icons.calendar_today_rounded,
                              size: size.width * 0.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Lower decorative element
                      Positioned(
                        left: -40,
                        bottom: -10,
                        child: SlideTransition(
                          position: _slideController.drive(Tween(
                            begin: const Offset(-0.2, 0.2),
                            end: Offset.zero,
                          )),
                          child: Opacity(
                            opacity: 0.15,
                            child: Icon(
                              Icons.school_rounded,
                              size: size.width * 0.3,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Content
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).padding.top + 16),

                              // Title row (back button removed)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Adding space at the beginning to move text to the right
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.10),

                                  // Title and subtitle
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Main title
                                        ShaderMask(
                                          shaderCallback: (Rect bounds) {
                                            return LinearGradient(
                                              colors: [
                                                Colors.white,
                                                Colors.white.withOpacity(0.8)
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ).createShader(bounds);
                                          },
                                          child: Text(
                                            'Tahun Akademik',
                                            style: GoogleFonts.poppins(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        )
                                            .animate()
                                            .fadeIn(
                                                duration: 600.ms, delay: 200.ms)
                                            .slideY(
                                                begin: 0.2,
                                                end: 0,
                                                duration: 500.ms,
                                                curve: Curves.easeOutQuad),

                                        const SizedBox(height: 4),

                                        // Subtitle
                                        Text(
                                          'Kelola periode tahun akademik sekolah',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                Colors.white.withOpacity(0.8),
                                          ),
                                        )
                                            .animate()
                                            .fadeIn(
                                                duration: 600.ms, delay: 300.ms)
                                            .slideY(
                                                begin: 0.2,
                                                end: 0,
                                                duration: 500.ms,
                                                curve: Curves.easeOutQuad),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const Spacer(),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(0),
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              if (state is SessionYearsFetchSuccess) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _gradientColors[0].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_view_month_rounded,
                                size: 16,
                                color: _gradientColors[0],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${state.sessionYears.length} Tahun Akademik',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _gradientColors[0],
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 400.ms)
                            .slideX(begin: -0.2, end: 0, duration: 500.ms),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  sliver: SliverList.builder(
                    itemCount: state.sessionYears.length,
                    itemBuilder: (context, index) {
                      final sessionYear = state.sessionYears[index];
                      final bool isDefault = sessionYear.isThisDefault();
                      final bool isSelected = _selectedIndex == index;
                      final Color cardColor = _getRandomPastelColor(index);
                      final int yearNumber = DateTime.now().year - index;

                      // Calculate the darkness of the card color for contrast
                      final isDark = cardColor.computeLuminance() < 0.5;

                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: GestureDetector(
                                onTap: () => _selectYear(index),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Main card with glassmorphism effect
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: _cardShadows,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 0, sigmaY: 0),
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  cardColor,
                                                  Color.lerp(cardColor,
                                                      Colors.white, 0.2)!,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                // Background patterns
                                                Positioned(
                                                  right: -30,
                                                  top: -30,
                                                  child: Icon(
                                                    Icons
                                                        .calendar_today_rounded,
                                                    size: 120,
                                                    color: Colors.white
                                                        .withOpacity(
                                                            _patternOpacity),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: -20,
                                                  bottom: -15,
                                                  child: Icon(
                                                    Icons.school_rounded,
                                                    size: 80,
                                                    color: Colors.white
                                                        .withOpacity(
                                                            _patternOpacity),
                                                  ),
                                                ),

                                                // Card content
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Year icon with glass effect
                                                          Container(
                                                            width: 60,
                                                            height: 60,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.2),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18),
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.4),
                                                                width: 1.5,
                                                              ),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: cardColor
                                                                      .withOpacity(
                                                                          0.5),
                                                                  blurRadius: 8,
                                                                  offset:
                                                                      const Offset(
                                                                          0, 3),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Center(
                                                              child: Icon(
                                                                isDefault
                                                                    ? Icons
                                                                        .school_rounded
                                                                    : Icons
                                                                        .calendar_today_rounded,
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.95),
                                                                size: 28,
                                                              ),
                                                            ),
                                                          ),

                                                          const SizedBox(
                                                              width: 20),

                                                          // Year details
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        sessionYear.name ??
                                                                            "",
                                                                        style: GoogleFonts
                                                                            .poppins(
                                                                          fontSize:
                                                                              22,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          color: Colors
                                                                              .white
                                                                              .withOpacity(0.95),
                                                                          letterSpacing:
                                                                              0.2,
                                                                          shadows: [
                                                                            Shadow(
                                                                              color: Colors.black.withOpacity(0.2),
                                                                              blurRadius: 2,
                                                                              offset: const Offset(0, 1),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    if (isSelected)
                                                                      Container(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            5),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: Colors
                                                                              .white
                                                                              .withOpacity(0.95),
                                                                          shape:
                                                                              BoxShape.circle,
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: cardColor.withOpacity(0.5),
                                                                              blurRadius: 8,
                                                                              offset: const Offset(0, 2),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .check_rounded,
                                                                          color:
                                                                              cardColor,
                                                                          size:
                                                                              18,
                                                                        ),
                                                                      ).animate().fadeIn(duration: 300.ms).scale(
                                                                          begin: const Offset(
                                                                              0.8,
                                                                              0.8),
                                                                          end: const Offset(
                                                                              1.0,
                                                                              1.0),
                                                                          duration:
                                                                              300.ms),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      // Details section if selected
                                                      if (isSelected) ...[
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 20,
                                                                  bottom: 4),
                                                          height: 1,
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Colors.white
                                                                    .withOpacity(
                                                                        0.1),
                                                                Colors.white
                                                                    .withOpacity(
                                                                        0.4),
                                                                Colors.white
                                                                    .withOpacity(
                                                                        0.1),
                                                              ],
                                                            ),
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                            height: 20),

                                                        // Actions
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            _actionButtonEnhanced(
                                                              icon: Icons
                                                                  .edit_rounded,
                                                              label: 'Edit',
                                                              cardColor:
                                                                  cardColor,
                                                              bgColor: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.9),
                                                              onTap: () {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    content:
                                                                        Text(
                                                                      'Edit: ${sessionYear.name}',
                                                                      style: GoogleFonts
                                                                          .poppins(),
                                                                    ),
                                                                    behavior:
                                                                        SnackBarBehavior
                                                                            .floating,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.9,
                                                                    duration: const Duration(
                                                                        milliseconds:
                                                                            1500),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            if (!isDefault)
                                                              _actionButtonEnhanced(
                                                                icon: Icons
                                                                    .delete_outline_rounded,
                                                                label: 'Hapus',
                                                                cardColor:
                                                                    cardColor,
                                                                bgColor: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.9),
                                                                textColor: Colors
                                                                    .red
                                                                    .shade700,
                                                                iconColor: Colors
                                                                    .red
                                                                    .shade700,
                                                                onTap: () {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          Text(
                                                                        'Hapus: ${sessionYear.name}',
                                                                        style: GoogleFonts
                                                                            .poppins(),
                                                                      ),
                                                                      behavior:
                                                                          SnackBarBehavior
                                                                              .floating,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.9,
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              1500),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            if (!isDefault)
                                                              const SizedBox(
                                                                  width: 10),
                                                            _actionButtonEnhanced(
                                                              icon: isDefault
                                                                  ? Icons
                                                                      .check_circle_rounded
                                                                  : Icons
                                                                      .check_circle_outline_rounded,
                                                              label: isDefault
                                                                  ? 'Default'
                                                                  : 'Set Default',
                                                              cardColor:
                                                                  cardColor,
                                                              bgColor: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.9),
                                                              textColor: isDefault
                                                                  ? Colors.green
                                                                      .shade700
                                                                  : cardColor,
                                                              iconColor: isDefault
                                                                  ? Colors.green
                                                                      .shade700
                                                                  : cardColor,
                                                              onTap: () {
                                                                if (!isDefault) {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          Text(
                                                                        'Set as Default: ${sessionYear.name}',
                                                                        style: GoogleFonts
                                                                            .poppins(),
                                                                      ),
                                                                      behavior:
                                                                          SnackBarBehavior
                                                                              .floating,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.9,
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              1500),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                        ).animate().fadeIn(
                                                            duration: 400.ms),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Default badge

                                    // Current Year Indicator
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom space
                SliverToBoxAdapter(
                  child: SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 80),
                ),
              ] else if (state is SessionYearsFetchFailure) ...[
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: FadeTransition(
                        opacity: _fadeController,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Error animation
                            Lottie.network(
                              'https://assets1.lottiefiles.com/packages/lf20_snmohqxj.json',
                              width: 120,
                              height: 120,
                              repeat: true,
                              frameRate: FrameRate(60),
                            ),
                            const SizedBox(height: 24),

                            // Error message
                            Text(
                              'Gagal Memuat Data',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _gradientColors[0],
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              state.errorMessage,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: theme.colorScheme.onBackground
                                    .withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Retry button
                            GlassmorphicContainer(
                              width: 160,
                              height: 50,
                              borderRadius: 25,
                              blur: 10,
                              alignment: Alignment.center,
                              border: 1,
                              linearGradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderGradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25),
                                  onTap: () {
                                    context
                                        .read<SessionYearsCubit>()
                                        .getSessionYears();
                                  },
                                  child: Center(
                                    child: Text(
                                      'Coba Lagi',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
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
              ] else ...[
                // Loading state
                SliverFillRemaining(
                  child: Center(
                    child: FadeTransition(
                      opacity: _fadeController,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Loading animation
                          Lottie.network(
                            'https://assets6.lottiefiles.com/packages/lf20_usmfx6bp.json',
                            width: 150,
                            height: 150,
                            frameRate: FrameRate(60),
                          ),
                          const SizedBox(height: 16),

                          // Loading text
                          Text(
                            'Memuat Data Tahun Akademik...',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _gradientColors[0],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _actionButtonEnhanced({
    required IconData icon,
    required String label,
    required Color cardColor,
    required Color bgColor,
    Color? textColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    final effectiveTextColor = textColor ?? cardColor;
    final effectiveIconColor = iconColor ?? cardColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        splashColor: cardColor.withOpacity(0.1),
        highlightColor: cardColor.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: cardColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: effectiveIconColor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: effectiveTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
