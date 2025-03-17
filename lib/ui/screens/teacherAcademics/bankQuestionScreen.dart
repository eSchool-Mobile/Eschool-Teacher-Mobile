import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';
import '../../../cubits/teacherAcademics/assignment/questionBankCubit.dart';
import 'package:eschool_saas_staff/data/models/question.dart' as q;
import 'package:eschool_saas_staff/data/models/questionBank.dart';
import 'package:eschool_saas_staff/data/models/QuestionVersion.dart';
import '../../../data/models/subjectQuestion.dart';
import 'package:html/parser.dart' show parse;
import '../../../app/routes.dart';

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

class BankQuestionScreen extends StatefulWidget {
  final BankSoal bankSoal;
  final int subjectId;
  final SubjectQuestion subject;

  const BankQuestionScreen({
    Key? key,
    required this.bankSoal,
    required this.subjectId,
    required this.subject,
  }) : super(key: key);

  @override
  State<BankQuestionScreen> createState() => _BankQuestionScreenState();
}

class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double spacing = 15;

    // Draw diagonal lines for premium pattern effect
    for (double i = -size.width; i < size.width * 2; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _BankQuestionScreenState extends State<BankQuestionScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<q.Question> _filteredQuestions = [];
  bool _showSearch = false;

  // Theme colors - Softer Maroon palette
  final Color _primaryColor = Color(0xFF7A1E23); // Softer deep maroon
  final Color _accentColor = Color(0xFF9D3C3C); // Softer medium maroon
  final Color _highlightColor = Color(0xFFB84D4D); // Softer bright maroon
  final Color _energyColor = Color(0xFFCE6D6D); // Softer light maroon
  final Color _glowColor = Color(0xFFAF4F4F); // Softer rich maroon

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

  // Particles
  // final List<ParticleModel> _particles = [];

  // Track hover and drag states
  int _hoveredCardIndex = -1;
  double _dragPosition = 0;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();

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
    super.dispose();
  }

  String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    return document.body?.text ?? htmlString;
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'multiple_choice':
        return const Color.fromARGB(255, 5, 120, 214);
      case 'essay':
        return const Color.fromARGB(255, 19, 122, 22);
      case 'true_false':
        return const Color.fromARGB(255, 227, 136, 0);
      case 'short_answer':
        return Colors.purple;
      case 'numeric':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'multiple_choice':
        return Icons.radio_button_checked;
      case 'essay':
        return Icons.edit_note;
      case 'true_false':
        return Icons.check_circle;
      case 'short_answer':
        return Icons.short_text;
      case 'numeric':
        return Icons.numbers;
      default:
        return Icons.help;
    }
  }

  String _getTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'multiple_choice':
        return 'Pilihan Ganda';
      case 'essay':
        return 'Essay';
      case 'true_false':
        return 'Benar/Salah';
      case 'short_answer':
        return 'Jawaban Singkat';
      case 'numeric':
        return 'Numerik';
      default:
        return 'Lainnya';
    }
  }

  void _loadQuestions() {
    context.read<QuestionBankCubit>().fetchBankQuestions(
          widget.subject.subject.id,
          widget.bankSoal.id,
        );
  }

  void _navigateToAddQuestion() async {
    final result = await Get.toNamed(
      Routes.addQuestionScreen,
      arguments: {
        'bankSoalId': widget.bankSoal.id,
        'subjectId': widget.subject.subject.id,
      },
    );

    if (result == true) {
      _loadQuestions();
    }
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

  Widget _buildHeader() {
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
                    Get.back();
                  },
                ),
                SizedBox(width: 15),

                // Title with modern styling
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.bankSoal.name,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Bank Soal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Add Question circular button with animation
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final scale = 1.0 + 0.05 * _pulseAnimation.value;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _navigateToAddQuestion();
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          boxShadow: [
                            BoxShadow(
                              color: _highlightColor.withOpacity(
                                  0.1 + 0.1 * _pulseAnimation.value),
                              blurRadius: 12 * (1 + _pulseAnimation.value),
                              spreadRadius: 2 * _pulseAnimation.value,
                            )
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(
                                0.1 + 0.05 * _pulseAnimation.value),
                            width: 1.5,
                          ),
                        ),
                        child: Transform.scale(
                          scale: scale,
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
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

  // Ubah method build() untuk menghapus FloatingActionButton
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _primaryColor,
        extendBodyBehindAppBar: true,
        body: Stack(
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
                    _buildHeader(),

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
                          child:
                              BlocBuilder<QuestionBankCubit, QuestionBankState>(
                            builder: (context, state) {
                              if (state is QuestionBankLoading) {
                                return _buildShimmerLoading();
                              }
                              if (state is BankQuestionsFetchSuccess) {
                                return state.questions.isEmpty
                                    ? _buildEmptyState()
                                    : _buildContent(state.questions);
                              }
                              if (state is QuestionBankError) {
                                return Center(
                                  child: ErrorContainer(
                                    errorMessage:
                                        "Tidak dapat terhubung ke server, mohon periksa koneksi internet anda dan coba lagi",
                                    onTapRetry: () {
                                      context
                                          .read<QuestionBankCubit>()
                                          .fetchBankQuestions(
                                            widget.subject.subject.id,
                                            widget.bankSoal.id,
                                          );
                                    },
                                  ),
                                );
                              }
                              return SizedBox();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // The rest of your methods remain unchanged...

  void _filterQuestions(String query, List<q.Question> questions) {
    setState(() {
      if (query.isEmpty) {
        _filteredQuestions = questions;
      } else {
        _filteredQuestions = questions
            .where((question) =>
                question.versions.last.name
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                question.versions.last.question
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Widget _buildContent(List<q.Question> questions) {
    if (questions.isEmpty) {
      return _buildEmptyState();
    }

    _showSearch = questions.length > 5;

    // Update filtered questions only if it's empty or search is not active
    if (_filteredQuestions.isEmpty || _searchController.text.isEmpty) {
      _filteredQuestions = questions;
    }

    return Column(
      children: [
        if (_showSearch)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (query) => _filterQuestions(query, questions),
              decoration: InputDecoration(
                hintText: 'Cari soal...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        Expanded(
          child: _filteredQuestions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.only(top: 8, bottom: 24),
                  physics: BouncingScrollPhysics(),
                  itemCount: _filteredQuestions.length,
                  itemBuilder: (context, index) {
                    final question = _filteredQuestions[index];
                    final latestVersion = question.versions.last;
                    return FadeInUp(
                      duration: Duration(milliseconds: 400 + (index * 50)),
                      child: _buildQuestionCard(question, latestVersion),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
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
              'Memuat Soal',
              style: TextStyle(
                color: _primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.question_mark_rounded,
                size: 70, color: Colors.grey.shade400),
          ),
          SizedBox(height: 24),
          Text(
            'Belum ada soal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Tambahkan soal baru untuk memulai',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(q.Question question, dynamic latestVersion) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Stack(
        children: [
          // Main Card with enhanced shadow and animation
          GestureDetector(
            onTap: () => _showDetailQuestionSheet(question, latestVersion),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _getTypeColor(latestVersion.type).withOpacity(0.12),
                    blurRadius: 40,
                    offset: Offset(0, 15),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stunning 3D Header with Parallax Effect
                    Container(
                      height: 160, // Increased for more impact
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getTypeColor(latestVersion.type),
                            Color.lerp(_getTypeColor(latestVersion.type),
                                Colors.black, 0.2)!,
                            _getTypeColor(latestVersion.type).withOpacity(0.85),
                          ],
                          stops: [0.2, 0.6, 0.9],
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Advanced geometric pattern effect
                          CustomPaint(
                            painter: UltraModernPatternPainter(
                              primaryColor: Colors.white.withOpacity(0.12),
                              secondaryColor: Colors.white.withOpacity(0.06),
                            ),
                          ),

                          // Radial glow effect (adds depth)
                          Positioned(
                            top: -40,
                            right: -40,
                            child: Container(
                              height: 180,
                              width: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.3),
                                    Colors.white.withOpacity(0),
                                  ],
                                  stops: [0.1, 1.0],
                                ),
                              ),
                            ),
                          ),

                          // Glass-effect Type Badge with ultra-modern styling
                          Positioned(
                            top: 20,
                            left: 20,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 15,
                                    spreadRadius: -5,
                                  ),
                                ],
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.4),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Outer glow
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                      ),
                                      // Icon with glow effect
                                      Icon(
                                        _getTypeIcon(latestVersion.type),
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    _getTypeName(latestVersion.type),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Premium Points Badge with floating effect
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: Offset(0, 5),
                                  ),
                                  BoxShadow(
                                    color: _getTypeColor(latestVersion.type)
                                        .withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: Offset(0, 2),
                                    spreadRadius: -5,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 3D star effect
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber.shade100,
                                        size: 26,
                                      ),
                                      Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber.shade300,
                                        size: 22,
                                      ),
                                      Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '${latestVersion.defaultPoint} poin',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Question Title with cinematic styling
                          Positioned(
                            bottom: 22,
                            left: 20,
                            right: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Decorative element
                                Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.3),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  latestVersion.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                    letterSpacing: 0.3,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.4),
                                        offset: Offset(0, 2),
                                        blurRadius: 5,
                                      ),
                                      Shadow(
                                        color: _getTypeColor(latestVersion.type)
                                            .withOpacity(0.6),
                                        offset: Offset(0, 1),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Question Content with premium styling
                    Container(
                      padding: EdgeInsets.fromLTRB(24, 26, 24, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section title with modern accent
                          Row(
                            children: [
                              // Modern vertical line with gradient and glow
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      _getTypeColor(latestVersion.type),
                                      _getTypeColor(latestVersion.type)
                                          .withOpacity(0.6),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getTypeColor(latestVersion.type)
                                          .withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Konten Pertanyaan",
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 18),

                          // Question content with enhanced styling
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.grey.shade100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              parseHtmlString(latestVersion.question),
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[800],
                                height: 1.5,
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          SizedBox(height: 24),

                          // Options Information with stunning styling
                          Container(
                            padding: EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Colors.grey.shade50,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: _getTypeColor(latestVersion.type)
                                    .withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Animated pulse container (simulated with Stack)
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(latestVersion.type)
                                            .withOpacity(0.08),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(latestVersion.type)
                                            .withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(latestVersion.type)
                                            .withOpacity(0.15),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              _getTypeColor(latestVersion.type)
                                                  .withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.check_circle_outline_rounded,
                                        color:
                                            _getTypeColor(latestVersion.type),
                                        size: 22,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 18),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pilihan Jawaban',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      '${latestVersion.options.length} opsi tersedia',
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                // Stunning arrow indicator
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(latestVersion.type)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: _getTypeColor(latestVersion.type),
                                    size: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Ultra-modern Action Footer
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.grey.shade50,
                            Colors.grey.shade100,
                          ],
                        ),
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .end, // Changed from spaceBetween to end
                        children: [
                          // Question ID section has been removed

                          // Action Buttons with premium styling
                          Row(
                            children: [
                              // Edit Button - Ultra-premium styling
                              Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _navigateToEditQuestion(
                                      question, latestVersion),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 13),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        colors: [
                                          _getTypeColor(latestVersion.type),
                                          Color.lerp(
                                              _getTypeColor(latestVersion.type),
                                              Colors.black,
                                              0.15)!,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              _getTypeColor(latestVersion.type)
                                                  .withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: Offset(0, 5),
                                          spreadRadius: -2,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Layered icon effect
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(
                                              Icons.edit_rounded,
                                              size: 20,
                                              color:
                                                  Colors.white.withOpacity(0.6),
                                            ),
                                            Icon(
                                              Icons.edit_rounded,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14.5,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: 14),

                              // Delete Button - Ultra-premium styling
                              Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () =>
                                      _showDeleteQuestionConfirmation(question),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 13),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Colors.grey.shade50,
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      border: Border.all(
                                        color: Colors.red.shade300,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 12,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Layered icon effect for delete
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(
                                              Icons.delete_outline_rounded,
                                              size: 20,
                                              color: Colors.red.shade300,
                                            ),
                                            Icon(
                                              Icons.delete_outline_rounded,
                                              size: 18,
                                              color: Colors.red.shade700,
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Hapus',
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14.5,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditQuestion(
      q.Question question, q.QuestionVersion version) async {
    String jsonString = JsonEncoder.withIndent("  ").convert(question);

    print("ASELINYA MOMENT");
    print(version.orderType);

    final result = await Get.toNamed(
      Routes.editQuestionScreen,
      arguments: {
        'questionData': {
          'banksoal_soal_id': question.id,
          'subject_id': widget.subject.subject.id,
          'idBankSoal': widget.bankSoal.id,
          'name': version.name,
          'type': version.type,
          'question': version.question,
          'default_point': version.defaultPoint,
          'typeOrder': version.orderType,
          'note': version.note,
          'image': version.image,
          'options': version.options
              .map((opt) => {
                    'text': opt.text,
                    'percentage': opt.percentage,
                    'feedback': opt.feedback,
                  })
              .toList(),
        },
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      if (result['success'] == true) {
        _loadQuestions();
        setState(() {
          final updatedData = result['updatedData'];
          final questionIndex = _filteredQuestions.indexWhere(
            (q) => q.id == updatedData['id'],
          );

          if (questionIndex != -1) {
            // Update the defaultPoint in the latest version
            final updatedQuestion = _filteredQuestions[questionIndex];
            final updatedVersions = List<q.QuestionVersion>.from(
              updatedQuestion.versions,
            );

            // Update the last version with new default point
            final lastVersion = updatedVersions.last;
            updatedVersions[updatedVersions.length - 1] = q.QuestionVersion(
              id: lastVersion.id,
              version: lastVersion.version,
              question: lastVersion.question,
              name: lastVersion.name,
              note: lastVersion.note,
              orderType: lastVersion.orderType,
              defaultPoint: updatedData['defaultPoint'],
              type: lastVersion.type,
              options: lastVersion.options,
            );

            // Create updated question with new versions
            _filteredQuestions[questionIndex] = q.Question(
              id: updatedQuestion.id,
              bankSoalId: updatedQuestion.bankSoalId,
              subjectId: updatedQuestion.subjectId,
              createdAt: updatedQuestion.createdAt,
              updatedAt: updatedQuestion.updatedAt,
              defaultPoint: updatedData['defaultPoint'],
              bankSoal: updatedQuestion.bankSoal,
              versions: updatedVersions,
            );
          }
        });
      }
    }
  }

  Widget _buildQuestionTypeHeader(q.QuestionVersion latestVersion) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getTypeColor(latestVersion.type).withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTypeColor(latestVersion.type),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTypeIcon(latestVersion.type),
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _getTypeName(latestVersion.type),
              style: TextStyle(
                color: _getTypeColor(latestVersion.type),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionFooter(
      q.QuestionVersion latestVersion, q.Question question) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: Colors.amber,
              ),
              SizedBox(width: 4),
              Text(
                '${latestVersion.defaultPoint}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, size: 20),
                onPressed: () =>
                    _navigateToEditQuestion(question, latestVersion),
                color: Theme.of(context).colorScheme.secondary,
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, size: 20),
                onPressed: () => _showDeleteQuestionConfirmation(question),
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionDetails(q.QuestionVersion version) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.help_outline, 'Pertanyaan',
              parseHtmlString(version.question)),
          SizedBox(height: 16),
          _buildOptionsSection(version.options),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsSection(List<q.QuestionOption> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilihan Jawaban',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        ...options.map((option) => _buildOptionItem(option)).toList(),
      ],
    );
  }

  Widget _buildOptionItem(q.QuestionOption option) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Text(
                '${option.percentage}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: option.percentage == 100
                      ? Colors.green
                      : Colors.grey[600],
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(parseHtmlString(option.text)),
                Text(
                  option.feedback,
                  style: TextStyle(
                    fontSize: 14, // Increased from 12
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return FadeIn(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 16, // Increased
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadQuestions(),
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // Add this method inside the _BankQuestionScreenState class
  void _showDeleteQuestionConfirmation(q.Question question) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 16),
              Text('Hapus Soal'),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus soal ini? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext); // Close dialog first

                try {
                  await context.read<QuestionBankCubit>().deleteQuestion(
                        subjectId: widget.subject.subject.id,
                        banksoalId: widget.bankSoal.id,
                        banksoalSoalId: question.id,
                      );

                  // Remove question from local state
                  setState(() {
                    _filteredQuestions.removeWhere((q) => q.id == question.id);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Soal berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Tidak dapat menghapus soal, mohon periksa koneksi internet anda dan coba lagi"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // Add this new method to show the question detail sheet
  void _showDetailQuestionSheet(
      q.Question question, q.QuestionVersion version) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.92,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: Container(
            color: Colors.white,
            child: _buildDetailQuestionContent(question, version),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailQuestionContent(
      q.Question question, q.QuestionVersion version) {
    return Stack(
      children: [
        // Gradient background top decoration - increased height
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 580, // Keep this height for the background
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getTypeColor(version.type),
                  Color.lerp(_getTypeColor(version.type), Colors.black, 0.3)!,
                ],
                stops: [0.4, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Pattern and decorative elements remain the same
                CustomPaint(
                  painter: UltraModernPatternPainter(
                    primaryColor: Colors.white.withOpacity(0.12),
                    secondaryColor: Colors.white.withOpacity(0.06),
                  ),
                  size: Size.infinite,
                ),

                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0),
                        ],
                        stops: [0.1, 1.0],
                      ),
                    ),
                  ),
                ),

                // Subtle accent line
                Positioned(
                  bottom: 0,
                  left: 40,
                  right: 40,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(0.5),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Main content
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header container with improved title display - Complete title without scrolling
              Container(
                padding: EdgeInsets.fromLTRB(24, 60, 24, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question type badge
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTypeIcon(version.type),
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Text(
                            _getTypeName(version.type),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // IMPROVED TITLE CONTAINER - Showing full text without scrolling
                    Text(
                      version.name,
                      style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      letterSpacing: 0.3,
                      ),
                    ),

                    SizedBox(height: 16),

                    // Points badge
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '${version.defaultPoint} poin',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Rest of the content remains unchanged
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question title bar
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Colors.grey.shade50],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade100),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: _getTypeColor(version.type)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.help_outline_rounded,
                                color: _getTypeColor(version.type),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              "Pertanyaan",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Question content
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.grey.shade200, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Text(
                            parseHtmlString(version.question),
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ),

                      // Options section
                      Container(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Options header
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(version.type)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.check_circle_outline,
                                    color: _getTypeColor(version.type),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  "Opsi Jawaban",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 24),

                            // Options list
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: version.options.length,
                              itemBuilder: (context, index) {
                                final option = version.options[index];
                                final isCorrect = option.percentage == 100;

                                return Container(
                                  margin: EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isCorrect
                                          ? Colors.green.shade200
                                          : Colors.grey.shade200,
                                      width: 1.5,
                                    ),
                                    color: isCorrect
                                        ? Colors.green.shade50
                                        : Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: isCorrect
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.black.withOpacity(0.03),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Option content
                                      Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Option indicator (letter or number)
                                            Container(
                                              width: 36,
                                              height: 36,
                                              margin: EdgeInsets.only(
                                                  top: 2, right: 16),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isCorrect
                                                    ? Colors.green
                                                        .withOpacity(0.2)
                                                    : _getTypeColor(
                                                            version.type)
                                                        .withOpacity(0.1),
                                                border: Border.all(
                                                  color: isCorrect
                                                      ? Colors.green
                                                      : _getTypeColor(
                                                          version.type),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  String.fromCharCode(65 +
                                                      index), // A, B, C, etc.
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: isCorrect
                                                        ? Colors.green
                                                        : _getTypeColor(
                                                            version.type),
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Option text
                                            Expanded(
                                              child: Text(
                                                parseHtmlString(option.text),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey.shade800,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),

                                            // Correct indicator
                                            if (isCorrect)
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 6,
                                                ),
                                                margin:
                                                    EdgeInsets.only(left: 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  "BENAR",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),

                                            // Percentage badge (if not 100% or 0%)
                                            if (!isCorrect &&
                                                option.percentage > 0)
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 6,
                                                ),
                                                margin:
                                                    EdgeInsets.only(left: 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  "${option.percentage}%",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      // Feedback section (if any)
                                      if (option.feedback.isNotEmpty)
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            ),
                                            border: Border(
                                              top: BorderSide(
                                                  color: Colors.grey.shade200),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Feedback:",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                option.feedback,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                  height: 1.4,
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

                      // Note section (if available)
                      if (version.note != null && version.note.isNotEmpty)
                        Container(
                          padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Note header
                              Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.notes,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    "Catatan Soal",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16),

                              // Note content
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.blue.shade100,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  version.note,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Image section (if available)
                      if (version.image != null &&
                          version.image?.isNotEmpty == true)
                        Container(
                          padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image header
                              Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.purple,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    "Gambar Soal",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16),

                              // Image content
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 15,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: version.image != null
                                      ? Image.network(
                                          version.image!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              height: 120,
                                              color: Colors.grey.shade200,
                                              child: Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey,
                                                  size: 40,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          height: 120,
                                          color: Colors.grey.shade200,
                                          child: Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Action buttons
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, -5),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Close button
                            Expanded(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "Tutup",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 16),

                            // Edit button
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: _getTypeColor(version.type),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _navigateToEditQuestion(question, version);
                                },
                                child: Text(
                                  "Edit Soal",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom padding
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Close button at top
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }
}

// Enhanced luxury pattern painter
class LuxuryPatternPainter extends CustomPainter {
  final Color color;

  LuxuryPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw diagonal lines for premium pattern effect
    final double spacing = 20;
    for (double i = -size.width; i < size.width * 2; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    // Add curved lines for more luxurious effect
    final path = Path();
    for (double i = 0; i < size.width; i += spacing * 2) {
      path.moveTo(i, 0);
      path.quadraticBezierTo(i + spacing, size.height / 2, i, size.height);
    }
    canvas.drawPath(path, paint);

    // Add circles for decorative elements
    for (int i = 0; i < 3; i++) {
      final circlePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;

      canvas.drawCircle(
          Offset(size.width - 40, 40), 15 + (i * 10), circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Add this advanced pattern painter class for a stunning effect
class UltraModernPatternPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  UltraModernPatternPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Diagonal lines for a premium pattern effect
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double spacing = 30;
    for (double i = -size.width; i < size.width * 2; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    // Add some perpendicular lines for a grid effect
    final secondPaint = Paint()
      ..color = secondaryColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (double i = spacing; i < size.width; i += spacing * 2) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        secondPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
