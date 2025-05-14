import 'dart:math' as math;
import 'dart:ui';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../../../cubits/teacherAcademics/assignment/questionBankCubit.dart';
import '../../../data/models/question.dart';
import '../../../data/models/subjectQuestion.dart';
import '../../../ui/widgets/customModernAppBar.dart';

class QuestionSubjectController extends GetxController {
  final BuildContext context;
  final bool isStaffView;

  QuestionSubjectController(this.context, this.isStaffView);

  @override
  void onInit() {
    super.onInit();
    _reloadData();
  }

  @override
  void onReady() {
    super.onReady();
    _reloadData();
  }

  void _reloadData() {
    print("Reloading QuestionSubjectScreen");
    context
        .read<QuestionBankCubit>()
        .fetchTeacherSubjects(isStaffView: isStaffView);
  }
}

// Light rays painter
class LightRaysPainter extends CustomPainter {
  final Color color;

  LightRaysPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw multiple rays from center
    final center = Offset(size.width / 2, size.height / 2);
    final rays = 12; // Number of rays
    final maxLength = size.width > size.height ? size.width : size.height;

    for (int i = 0; i < rays; i++) {
      final angle = (i * 2 * math.pi / rays);
      final x = math.cos(angle) * maxLength;
      final y = math.sin(angle) * maxLength;

      // Draw triangular ray
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx + x * 0.2, center.dy + y * 0.2)
        ..lineTo(center.dx + x, center.dy + y)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class QuestionSubjectScreen extends StatefulWidget {
  final bool isStaffView;

  const QuestionSubjectScreen({
    Key? key,
    this.isStaffView = false,
  }) : super(key: key);

  @override
  State<QuestionSubjectScreen> createState() => _QuestionSubjectScreenState();
}

class _QuestionSubjectScreenState extends State<QuestionSubjectScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<SubjectQuestion> _filteredSubjects = [];
  bool _showSearch = false;
  late QuestionSubjectController _controller;

  // Animation controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _waveAnimationController;
  late AnimationController _floatingIconsController;
  late AnimationController _cardHoverController;
  late AnimationController _breathingController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _loadingController;
  late AnimationController _tabTransitionController;
  late AnimationController _searchExpandController;

  // Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _searchWidthAnimation;

  int _selectedTabIndex = 0;
  int _hoveredCardIndex = -1;
  double _dragPosition = 0;

  // // Particles
  // final List<ParticleModel> _particles = [];

  // Theme colors - Softer Maroon palette
  final Color _primaryColor =
      Color(0xFF7A1E23); // Softer deep maroon (was 0xFF4A0000)
  final Color _accentColor =
      Color(0xFF9D3C3C); // Softer medium maroon (was 0xFF800000)
  final Color _highlightColor =
      Color(0xFFB84D4D); // Softer bright maroon (was 0xFFA52A2A)
  final Color _energyColor =
      Color(0xFFCE6D6D); // Softer light maroon (was 0xFFC13E3E)
  final Color _glowColor =
      Color(0xFFAF4F4F); // Softer rich maroon (was 0xFF9E2A2A)

  final List<Color> _cardGradients = [
    Color(0xFF7A2828), // Softer dark maroon (was 0xFF5D0000)
    Color(0xFF9D3C3C), // Softer classic maroon (was 0xFF800000)
    Color(0xFFAF4F4F), // Softer rich maroon (was 0xFF9E2A2A)
    Color(0xFFB84D4D), // Softer brown-maroon (was 0xFFA52A2A)
    Color(0xFFC65454), // Softer firebrick (was 0xFFB22222)
    Color(0xFFAA3939), // Softer dark red (was 0xFF8B0000)
    Color(0xFF8F2D2D), // Softer deep maroon (was 0xFF700000)
    Color(0xFFB14040), // Softer bright maroon (was 0xFF940000)
  ];
  // Track if the screen is initially loaded for animations
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _controller =
        Get.put(QuestionSubjectController(context, widget.isStaffView));

    // Setup animation controllers
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 30000),
    )..repeat();

    _waveAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 7000),
    )..repeat();

    _floatingIconsController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _cardHoverController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _breathingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 10000),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _loadingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();

    _tabTransitionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _searchExpandController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    // Setup animations
    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.linear,
    );

    _waveAnimation = CurvedAnimation(
      parent: _waveAnimationController,
      curve: Curves.easeInOut,
    );

    _breathingAnimation = CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    );

    _rotationAnimation = CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    );

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _searchWidthAnimation = Tween<double>(
      begin: 0.7,
      end: 0.9,
    ).animate(
      CurvedAnimation(
        parent: _searchExpandController,
        curve: Curves.easeOutCubic,
      ),
    );

    // // Initialize particles with enhanced properties
    // _initializeParticles();

    _reloadData();

    // Add device orientation listener for responsive design
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Set system UI style for immersive experience
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: _primaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    // Delay to ensure animations look good on first load
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isFirstLoad = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _backgroundAnimationController.dispose();
    _waveAnimationController.dispose();
    _floatingIconsController.dispose();
    _cardHoverController.dispose();
    _breathingController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _loadingController.dispose();
    _tabTransitionController.dispose();
    _searchExpandController.dispose();
    Get.delete<QuestionSubjectController>();
    super.dispose();
  }

  void _reloadData() {
    _searchController.clear();
    _filteredSubjects = [];
    _showSearch = false;
    context
        .read<QuestionBankCubit>()
        .fetchTeacherSubjects(isStaffView: widget.isStaffView);
  }

  void _filterSubjects(String query, List<SubjectQuestion> subjects) {
    setState(() {
      if (query.isEmpty) {
        _filteredSubjects = subjects;
      } else {
        _filteredSubjects = subjects
            .where((subject) => subject.subjectWithName
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();

        // Extra haptic feedback on results found
        if (_filteredSubjects.isNotEmpty) {
          HapticFeedback.selectionClick();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: CustomModernAppBar(
          title: 'Bank Soal',
          icon: Icons.book,
          fabAnimationController: _breathingController,
          primaryColor: _primaryColor,
          lightColor: _energyColor,
          onBackPressed: () => Navigator.pop(context),
        ),
        body: BlocBuilder<QuestionBankCubit, QuestionBankState>(
          builder: (context, state) {
            return Container(
              color: Colors.white,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    setState(() {
                      _dragPosition = notification.metrics.pixels / 10;
                    });
                  }
                  return false;
                },
                child: Column(
                  children: [
                    // Leave space for the app bar
                    SizedBox(height: 90),

                    // Animated search bar
                    if (state is SubjectsFetchSuccess &&
                        state.subjects.length > 5)
                      _buildSearchBar(state.subjects),

                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.95),
                              Color(0xFFFFF0F0),
                            ],
                          ),
                          borderRadius: BorderRadius.zero,
                          boxShadow: [
                            BoxShadow(
                              color: _glowColor.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                              offset: Offset(0, -5),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 30,
                              offset: Offset(0, -10),
                            ),
                          ],
                        ),
                        child: _buildContentArea(state),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Base gradient with softer maroon colors
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                _primaryColor,
                Color(0xFF5A2223), // Softer deeper maroon (was 0xFF230000)
              ],
            ),
          ),
        ),

        // Glowing orbs and decorative elements
        Positioned(
          top: -60,
          right: -40,
          child: AnimatedBuilder(
            animation: _breathingAnimation,
            builder: (context, child) {
              final scale = 1.0 + 0.1 * _breathingAnimation.value;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _glowColor.withOpacity(0.4),
                        _glowColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: Get.height * 0.35,
          left: -50,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final opacity = 0.15 + 0.1 * _pulseAnimation.value;
              return Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _energyColor.withOpacity(opacity),
                      _energyColor.withOpacity(0.0),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Dynamic light rays effect
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * math.pi * 2,
                child: CustomPaint(
                  painter: LightRaysPainter(_highlightColor.withOpacity(0.03)),
                  size: Size(Get.width, Get.height),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGlowingIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12),
              boxShadow: [
                BoxShadow(
                  color: _highlightColor
                      .withOpacity(0.1 + 0.1 * _pulseAnimation.value),
                  blurRadius: 12 * (1 + _pulseAnimation.value),
                  spreadRadius: 2 * _pulseAnimation.value,
                )
              ],
              border: Border.all(
                color: Colors.white
                    .withOpacity(0.1 + 0.05 * _pulseAnimation.value),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(List<SubjectQuestion> subjects) {
    return FadeInDown(
      delay: Duration(milliseconds: 300),
      duration: Duration(milliseconds: 800),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _highlightColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _accentColor.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (query) => _filterSubjects(query, subjects),
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Cari mata pelajaran...',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.search, color: Colors.white70),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentArea(QuestionBankState state) {
    if (state is QuestionBankLoading) {
      return _buildLoadingView();
    }

    if (state is SubjectsFetchSuccess) {
      _showSearch = state.subjects.length > 5;
      if (_filteredSubjects.isEmpty) {
        _filteredSubjects = state.subjects;
      }
      return _buildSubjectsList(_filteredSubjects);
    }

    if (state is QuestionBankError) {
      return _buildErrorView(state.message);
    }

    return SizedBox();
  }

  Widget _buildLoadingView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFFFF0F0), // Very light maroon tint instead of light blue
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use shimmer loading animation instead of Lottie for a more modern look
            Shimmer.fromColors(
              baseColor: _accentColor.withOpacity(0.4),
              highlightColor: _highlightColor.withOpacity(0.7),
              period: Duration(milliseconds: 1500),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 25),
            Text(
              'Memuat Mata Pelajaran',
              style: TextStyle(
                color: _primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            // Animated loading indicator
            Container(
              width: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  backgroundColor: _accentColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                  minHeight: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFFFF0F0), // Very light maroon tint
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error image animation
              SlideInDown(
                duration: Duration(milliseconds: 800),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFF0F0), // Very light maroon tint
                    boxShadow: [
                      BoxShadow(
                        color: _highlightColor
                            .withOpacity(0.3), // Using maroon instead of red
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 70,
                      color: _energyColor, // Using maroon instead of red accent
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Oops! Terjadi Kesalahan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _accentColor, // Using maroon instead of purple
                ),
              ),
              SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF5D0000), // Dark maroon instead of grey
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return FadeIn(
      duration: Duration(milliseconds: 800),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.network(
                'https://assets9.lottiefiles.com/packages/lf20_yuiimsha.json',
                width: 180,
                height: 180,
              ),
              SizedBox(height: 20),
              Text(
                'Belum ada mata pelajaran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _accentColor, // Using maroon instead of purple
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectsList(List<SubjectQuestion> subjects) {
    if (subjects.isEmpty) {
      return _buildEmptyView();
    }

    return Stack(
      children: [
        // Holographic background effect
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _backgroundAnimation.value * 0.05,
                child: ShaderMask(
                  blendMode: BlendMode.srcATop,
                  shaderCallback: (bounds) => RadialGradient(
                    center: Alignment(
                      math.sin(_backgroundAnimation.value * math.pi * 2) * 0.5,
                      math.cos(_backgroundAnimation.value * math.pi * 2) * 0.5,
                    ),
                    colors: [
                      Colors.transparent,
                      _highlightColor.withOpacity(0.01),
                      _accentColor.withOpacity(0.02),
                      Colors.transparent,
                    ],
                    radius: 1.0,
                  ).createShader(bounds),
                  child: Container(
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),

        // Interactive card list with 3D effects
        ListView.builder(
          padding: EdgeInsets.fromLTRB(20, 25, 20, 100),
          physics: BouncingScrollPhysics(),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];
            final Color cardBaseColor =
                _cardGradients[index % _cardGradients.length];
            // Generate subject-specific neon colors for glow effects
            final neonGlowColor = HSLColor.fromColor(cardBaseColor)
                .withLightness(0.7)
                .withSaturation(0.9)
                .toColor();

            final bool isHovered = _hoveredCardIndex == index;

            return GestureDetector(
              onTap: () async {
                if (subject.subject.id != 0) {
                  // Add spectacular tap effect
                  setState(() {
                    _hoveredCardIndex = index;
                  });

                  // Elaborate haptic pattern
                  HapticFeedback.mediumImpact();
                  await Future.delayed(Duration(milliseconds: 50));
                  HapticFeedback.lightImpact();

                  // Exaggerated scale animation on tap
                  _cardHoverController.forward().then((_) {
                    _cardHoverController.reverse();
                  });

                  await Get.toNamed(Routes.questionBankScreen,
                      arguments: subject);
                  _reloadData();
                }
              },
              onTapDown: (_) {
                setState(() {
                  _hoveredCardIndex = index;
                });
                HapticFeedback.selectionClick();
              },
              onTapCancel: () {
                setState(() {
                  _hoveredCardIndex = -1;
                });
              },
              onTapUp: (_) {
                Future.delayed(Duration(milliseconds: 300), () {
                  if (mounted) {
                    setState(() {
                      _hoveredCardIndex = -1;
                    });
                  }
                });
              },
              child: Transform.translate(
                offset: Offset(0, index == _hoveredCardIndex ? -5 : 0),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  margin: EdgeInsets.only(bottom: 24),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 3D Card Background with "holographic" effect
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // Perspective
                          ..rotateX(isHovered ? 0.05 : 0.0)
                          ..rotateY(isHovered ? -0.05 : 0.0),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                cardBaseColor
                                    .withOpacity(isHovered ? 1.0 : 0.85),
                                HSLColor.fromColor(cardBaseColor)
                                    .withLightness(
                                      HSLColor.fromColor(cardBaseColor)
                                              .lightness *
                                          0.7,
                                    )
                                    .toColor()
                                    .withOpacity(isHovered ? 0.95 : 0.8),
                              ],
                              stops: [0.3, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              // Outer glow shadow
                              BoxShadow(
                                color: neonGlowColor
                                    .withOpacity(isHovered ? 0.35 : 0.15),
                                blurRadius: isHovered ? 25 : 15,
                                spreadRadius: isHovered ? 2 : 0,
                              ),
                              // Inner depth shadow
                              BoxShadow(
                                color: cardBaseColor.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: -3,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Holographic overlay

                              // Content layout
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Subject text & details with advanced effects
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Elaborated subject title with glow
                                            ShaderMask(
                                              blendMode: BlendMode.srcIn,
                                              shaderCallback: (bounds) =>
                                                  LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.white.withOpacity(1.0),
                                                  Colors.white.withOpacity(0.9),
                                                  Colors.white.withOpacity(1.0),
                                                ],
                                              ).createShader(bounds),
                                              child: Text(
                                                subject.subjectWithName,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  height: 1.2,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black26,
                                                      blurRadius: 3,
                                                      offset: Offset(1, 1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            SizedBox(height: 4),

                                            // Divider with animation
                                            AnimatedContainer(
                                              duration:
                                                  Duration(milliseconds: 400),
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 8),
                                              height: 2,
                                              width: isHovered ? 180 : 80,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    Colors.white
                                                        .withOpacity(0.8),
                                                    Colors.white
                                                        .withOpacity(0.2),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),

                                            SizedBox(height: 4),

                                            // Question count chip with advanced styling
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 7),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      width: 1,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black12,
                                                        blurRadius: 8,
                                                        spreadRadius: 0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        '${subject.bankSoalCount} Bank Soal',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Arrow button with animations and effects
                                      AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        width: isHovered ? 50 : 45,
                                        height: isHovered ? 50 : 45,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: isHovered
                                                ? [
                                                    Colors.white
                                                        .withOpacity(0.3),
                                                    Colors.white
                                                        .withOpacity(0.1)
                                                  ]
                                                : [
                                                    Colors.white
                                                        .withOpacity(0.2),
                                                    Colors.white
                                                        .withOpacity(0.05)
                                                  ],
                                          ),
                                          boxShadow: isHovered
                                              ? [
                                                  BoxShadow(
                                                    color: neonGlowColor
                                                        .withOpacity(0.4),
                                                    blurRadius: 15,
                                                    spreadRadius: 1,
                                                  ),
                                                ]
                                              : [],
                                          border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: AnimatedBuilder(
                                          animation: _pulseAnimation,
                                          builder: (context, child) {
                                            return Transform.rotate(
                                              angle: isHovered ? 0.1 : 0,
                                              child: Transform.scale(
                                                scale: isHovered
                                                    ? 1.0 +
                                                        0.15 *
                                                            _pulseAnimation
                                                                .value
                                                    : 1.0,
                                                child: Icon(
                                                  Icons.arrow_forward_rounded,
                                                  color: Colors.white,
                                                  size: isHovered ? 25 : 22,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Decorative elements
                      Positioned(
                        right: 20,
                        top: -10,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: neonGlowColor.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
