import 'dart:math' as math;
import 'dart:ui';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/BankOnlineQuestion.dart';
import 'package:eschool_saas_staff/cubits/questionOnlineExam/questionOnlineExamCubit.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:get/get.dart' as getx;
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';

// Animated particle system
// class ParticleModel {
//   Offset position;
//   Color color;
//   double radius;
//   double speed;
//   double theta;
//   double opacity;
//   double rotationSpeed;

//   ParticleModel({
//     required this.position,
//     required this.color,
//     required this.radius,
//     required this.speed,
//     required this.theta,
//     required this.opacity,
//     required this.rotationSpeed,
//   });

//   void move() {
//     position += Offset(speed * math.cos(theta), speed * math.sin(theta));
//     theta += rotationSpeed;
//     opacity += (math.Random().nextDouble() - 0.5) * 0.03;
//     opacity = opacity.clamp(0.1, 0.9);
//   }
// }

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

// class ParticlesPainter extends CustomPainter {
//   final List<ParticleModel> particles;
//   final double time;

//   ParticlesPainter(this.particles, this.time);

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (var i = 0; i < particles.length; i++) {
//       final particle = particles[i];
//       final paint = Paint()
//         ..color = particle.color.withOpacity(particle.opacity)
//         ..style = PaintingStyle.fill;

//       // Draw glow effect around particles
//       if (i % 3 == 0) {
//         final glowPaint = Paint()
//           ..color = particle.color.withOpacity(particle.opacity * 0.3)
//           ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0);
//         canvas.drawCircle(particle.position, particle.radius * 2, glowPaint);
//       }

//       canvas.drawCircle(particle.position, particle.radius, paint);

//       // Add connecting lines between nearby particles
//       if (i < particles.length - 1) {
//         final nextParticle = particles[i + 1];
//         final distance = (particle.position - nextParticle.position).distance;
//         if (distance < 80) {
//           final linePaint = Paint()
//             ..color = particle.color
//                 .withOpacity(particle.opacity * 0.2 * (1 - distance / 80))
//             ..strokeWidth = 1.0;
//           canvas.drawLine(particle.position, nextParticle.position, linePaint);
//         }
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }

class BankSoalSelectionScreen extends StatefulWidget {
  final int examId;

  const BankSoalSelectionScreen({
    Key? key,
    required this.examId,
  }) : super(key: key);

  @override
  State<BankSoalSelectionScreen> createState() =>
      _BankSoalSelectionScreenState();
}

class _BankSoalSelectionScreenState extends State<BankSoalSelectionScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<BankSoalQuestion> _filteredBanks = [];
  bool _showSearch = false;
  int _hoveredCardIndex = -1;
  double _dragPosition = 0;

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

  // Theme colors - Softer Maroon palette
  final Color _primaryColor = Color(0xFF7A1E23); // Softer deep maroon
  final Color _accentColor = Color(0xFF9D3C3C); // Softer medium maroon
  final Color _highlightColor = Color(0xFFB84D4D); // Softer bright maroon
  final Color _energyColor = Color(0xFFCE6D6D); // Softer light maroon
  final Color _glowColor = Color(0xFFAF4F4F); // Softer rich maroon

  final List<Color> _cardGradients = [
    Color(0xFF7A2828), // Softer dark maroon
    Color(0xFF9D3C3C), // Softer classic maroon
    Color(0xFFAF4F4F), // Softer rich maroon
    Color(0xFFB84D4D), // Softer brown-maroon
    Color(0xFFC65454), // Softer firebrick
    Color(0xFFAA3939), // Softer dark red
    Color(0xFF8F2D2D), // Softer deep maroon
    Color(0xFFB14040), // Softer bright maroon
  ];

  // Track if the screen is initially loaded for animations
  bool _isFirstLoad = true;

  // Particles
  // final List<ParticleModel> _particles = [];

  @override
  void initState() {
    super.initState();
    context.read<QuestionOnlineExamCubit>().getBankSoal(widget.examId);

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

    // Initialize particles with enhanced properties
    // _initializeParticles();

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

  // void _initializeParticles() {
  //   final random = math.Random();
  //   for (int i = 0; i < 40; i++) {
  //     // More particles for denser effect
  //     _particles.add(
  //       ParticleModel(
  //         position: Offset(
  //           random.nextDouble() * getx.Get.width,
  //           random.nextDouble() * getx.Get.height / 1.5,
  //         ),
  //         color: [_highlightColor, _accentColor, _glowColor][random.nextInt(3)],
  //         radius: random.nextDouble() * 3.5 + 0.5,
  //         speed: random.nextDouble() * 0.5 + 0.1,
  //         theta: random.nextDouble() * math.pi * 2,
  //         opacity: random.nextDouble() * 0.5 + 0.3,
  //         rotationSpeed:
  //             (random.nextDouble() * 0.04) * (random.nextBool() ? 1 : -1),
  //       ),
  //     );
  //   }
  // }

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
    super.dispose();
  }

  void _filterBanks(String query, List<BankSoalQuestion> banks) {
    setState(() {
      if (query.isEmpty) {
        _filteredBanks = banks;
      } else {
        _filteredBanks = banks
            .where(
                (bank) => bank.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        // Extra haptic feedback on results found
        if (_filteredBanks.isNotEmpty) {
          HapticFeedback.selectionClick();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _primaryColor,
        extendBodyBehindAppBar: true,
        body: BlocBuilder<QuestionOnlineExamCubit, QuestionOnlineExamState>(
          builder: (context, state) {
            return Stack(
              children: [
                // Animated background with advanced effects
                _buildAnimatedBackground(),

                // Content with parallax scroll effect
                SafeArea(
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
                        // Custom app bar with advanced animated elements
                        _buildCustomAppBar(),

                        // Animated search bar
                        if (state is QuestionBanksLoaded &&
                            state.banks.length > 5)
                          _buildSearchBar(state.banks),

                        // Main content with curved container and 3D effect
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(top: 15),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.95),
                                  Color(0xFFFFF0F0),
                                ],
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                              child: _buildContentArea(state),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return SlideInDown(
      duration: Duration(milliseconds: 800),
      child: Padding(
        padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Back button with advanced ripple and glow effects
                _buildGlowingIconButton(
                  Icons.arrow_back_rounded,
                  () {
                    HapticFeedback.mediumImpact();
                    getx.Get.back();
                  },
                ),
                SizedBox(width: 15),

                // Title with animated gradients and text effects
                Expanded(
                  child: Text(
                    'Pilih Bank Soal',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Subtitle with animated elements
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  Text(
                    'Pilih Bank Soal untuk Ujian',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
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
                Color(0xFF5A2223), // Softer deeper maroon
              ],
            ),
          ),
        ),

        // Advanced particles system
        // AnimatedBuilder(
        //   animation: _backgroundAnimationController,
        //   builder: (context, child) {
        //     for (var particle in _particles) {
        //       particle.move();
        //       // Keep particles within bounds
        //       if (particle.position.dx < 0 ||
        //           particle.position.dx > getx.Get.width ||
        //           particle.position.dy < 0 ||
        //           particle.position.dy > getx.Get.height / 1.5) {
        //         particle.theta = math.Random().nextDouble() * math.pi * 2;
        //       }
        //     }

        //     return CustomPaint(
        //       painter: ParticlesPainter(_particles, _backgroundAnimation.value),
        //       size: Size(getx.Get.width, getx.Get.height),
        //     );
        //   },
        // ),

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
          bottom: getx.Get.height * 0.35,
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
                  size: Size(getx.Get.width, getx.Get.height),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(List<BankSoalQuestion> banks) {
    return FadeInDown(
      delay: Duration(milliseconds: 300),
      duration: Duration(milliseconds: 800),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            onChanged: (query) => _filterBanks(query, banks),
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Cari bank soal...',
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

  Widget _buildContentArea(QuestionOnlineExamState state) {
    if (state is QuestionBanksLoading) {
      return _buildLoadingView();
    }

    if (state is QuestionBanksLoaded) {
      // Set _showSearch based on bank count
      _showSearch = state.banks.length > 5;

      // Update _filteredBanks based on search query
      if (_searchController.text.isEmpty) {
        _filteredBanks = state.banks;
      } else {
        _filteredBanks = state.banks
            .where((bank) => bank.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      }

      if (state.banks.isEmpty) {
        return _buildEmptyView();
      }

      return Column(
        children: [
          Expanded(
            child: _buildBankList(_filteredBanks),
          ),
        ],
      );
    }

    if (state is QuestionOnlineExamFailure) {
      return Center(
        child: ErrorContainer(
          errorMessage: "Tidak dapat memuat bank soal. Silakan coba lagi.",
          onTapRetry: () => context
              .read<QuestionOnlineExamCubit>()
              .getBankSoal(widget.examId),
        ),
      );
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
            Color(0xFFFFF0F0), // Very light maroon tint
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use shimmer loading animation
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
              'Memuat Bank Soal',
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

  Widget _buildEmptyView() {
    return FadeInUp(
      duration: Duration(milliseconds: 800),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.source_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Tidak ada bank soal yang tersedia',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankList(List<BankSoalQuestion> banks) {
    if (banks.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Text(
          'Tidak ada bank soal yang cocok dengan pencarian',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
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
          itemCount: banks.length,
          itemBuilder: (context, index) {
            final bank = banks[index];
            final Color cardBaseColor =
                _cardGradients[index % _cardGradients.length];
            // Generate bank-specific neon colors for glow effects
            final neonGlowColor = HSLColor.fromColor(cardBaseColor)
                .withLightness(0.7)
                .withSaturation(0.9)
                .toColor();

            final bool isHovered = _hoveredCardIndex == index;

            return GestureDetector(
              onTap: () => navigateToPreview(bank),
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
                              // Content layout
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Bank text & details with advanced effects
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Elaborated bank title with glow
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
                                                bank.name,
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
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 7),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(30),
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
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '${bank.soal.length} Soal',
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

  void navigateToPreview(BankSoalQuestion bank) {
    print('Navigating to preview with:');
    print('Bank ID: ${bank.id}');
    print('Exam ID: ${widget.examId}');
    print('Class Section ID: ${bank.classSectionId}');
    print('Class Subject ID: ${bank.classSubjectId}');

    // Validasi data sebelum navigasi
    if (bank.classSectionId == 0 || bank.classSubjectId == 0) {
      getx.Get.snackbar(
        'Error',
        'Data kelas atau mata pelajaran tidak valid',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: getx.SnackPosition.BOTTOM,
      );
      return;
    }

    getx.Get.toNamed(
      Routes.previewQuestionBank,
      arguments: {
        'bank': bank,
        'examId': widget.examId,
        'classSectionId': bank.classSectionId,
        'classSubjectId': bank.classSubjectId,
      },
    );
  }
}
