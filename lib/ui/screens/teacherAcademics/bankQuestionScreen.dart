import 'dart:convert';
import 'dart:io';
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
import 'package:flutter/services.dart' show Uint8List;
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:image_picker/image_picker.dart';

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

class UltraModernPatternPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  UltraModernPatternPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintPrimary = Paint()
      ..color = primaryColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final paintSecondary = Paint()
      ..color = secondaryColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Draw diagonal lines
    final double spacing = 25;
    for (double i = -size.width; i < size.width * 2; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paintPrimary,
      );
    }

    // Draw crossing pattern
    for (double i = -size.height; i < size.height * 2; i += spacing * 2) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i + size.width * 0.5),
        paintSecondary,
      );
    }

    // Draw dots at intersections
    final dotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing * 2) {
      for (double y = 0; y < size.height; y += spacing * 2) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
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

  // Tambahkan variabel untuk menyimpan data gambar
  Map<int, dynamic> _questionImages = {};

  // Add this map to track active version for each question
  Map<int, int> _activeVersionIndices = {};

  // Add this controller map to access PageView controllers
  Map<int, PageController> _pageControllers = {};

  // Create controller for a question
  PageController _getPageController(int questionId) {
    if (!_pageControllers.containsKey(questionId)) {
      _pageControllers[questionId] = PageController(
        viewportFraction: 0.99, // Slightly less than 1.0 for peeking effect
        initialPage: 0,
      );
    }
    return _pageControllers[questionId]!;
  }

  // Update the active version index
  void _setActiveVersionIndex(int questionId, int versionIndex) {
    setState(() {
      _activeVersionIndices[questionId] = versionIndex;
    });
  }

  // Get the active version index, default to 0 (latest version)
  int _getActiveVersionIndex(int questionId) {
    return _activeVersionIndices[questionId] ?? 0;
  }

  // Tambahkan properti ini di class _BankQuestionScreenState
  bool _hasShownSwipeGuide = false;

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

    // Tambahkan ini di initState()
    _pageControllers.forEach((questionId, controller) {
      controller.addListener(() {
        // Trigger rebuild for animation based on page scroll position
        if (mounted) setState(() {});
      });
    });

    // Add in initState() after other PageController initialization
    _pageControllers.forEach((questionId, controller) {
      controller.addListener(() {
        if (controller.hasClients &&
            controller.page != null &&
            controller.page!.round() != controller.page) {
          // This will rebuild during animation for smoother transitions
          if (mounted) setState(() {});
        }
      });
    });
  }

  @override
  void dispose() {
    // Dispose all page controllers
    _pageControllers.forEach((_, controller) => controller.dispose());

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
          subjectId: widget.subject.subject.id,
          bankId: widget.bankSoal.id,
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
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                      ),
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
                                            subjectId:
                                                widget.subject.subject.id,
                                            bankId: widget.bankSoal.id,
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

  // Modifikasi _buildContent untuk menampilkan panduan swipe saat pertama kali
  Widget _buildContent(List<q.Question> questions) {
    if (questions.isEmpty) {
      return _buildEmptyState();
    }

    _showSearch = questions.length > 5;

    // Update filtered questions only if it's empty or search is not active
    if (_filteredQuestions.isEmpty || _searchController.text.isEmpty) {
      _filteredQuestions = List.from(questions);
    }

    // Show swipe guide tooltip if multiple versions and not shown before
    bool hasMultipleVersions = questions.any((q) => q.versions.length > 1);

    return Column(
      children: [
        // Search bar if needed
        if (_showSearch)
          AnimatedBuilder(
            animation: _searchExpandController,
            builder: (context, child) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      (_searchWidthAnimation.value),
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.1),
                        blurRadius: 8.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _filterQuestions(value, questions),
                    decoration: InputDecoration(
                      hintText: 'Cari soal...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: _primaryColor,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

        // Questions list
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.only(top: 8.0, bottom: 100.0),
                itemCount: _filteredQuestions.length,
                itemBuilder: (context, index) {
                  final question = _filteredQuestions[index];
                  final latestVersionIndex = question.versions.length - 1;
                  final latestVersion = question.versions[latestVersionIndex];

                  return _buildQuestionCard(question, latestVersion);
                },
              ),

              // Swipe guide tooltip
              if (hasMultipleVersions && !_hasShownSwipeGuide)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: FadeIn(
                    duration: Duration(seconds: 1),
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 32.0),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8.0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.swipe, color: _primaryColor),
                            SizedBox(width: 12.0),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Geser Untuk Melihat Versi",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _primaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    "Geser kartu ke kiri/kanan untuk melihat versi soal sebelumnya",
                                    style: TextStyle(fontSize: 12.0),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, size: 16.0),
                              onPressed: () {
                                setState(() {
                                  _hasShownSwipeGuide = true;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
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
    final int questionVersionsCount = question.versions.length;
    final PageController pageController = _getPageController(question.id);
    final int activeVersionIndex = _getActiveVersionIndex(question.id);

    return FadeInUp(
      duration: Duration(milliseconds: 500),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _getTypeColor(latestVersion.type).withOpacity(0.12),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: PageView.builder(
              controller: pageController,
              // Add smooth page physics
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              // Reduce viewportFraction slightly to show peek of adjacent cards
              pageSnapping: true,
              allowImplicitScrolling: true,
              padEnds: false,
              itemCount: questionVersionsCount,
              onPageChanged: (index) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    HapticFeedback.lightImpact();
                    _setActiveVersionIndex(question.id, index);
                  }
                });
              },
              itemBuilder: (context, index) {
                final displayIndex = questionVersionsCount - 1 - index;
                final version = question.versions[displayIndex];

                // Add animation transformation wrapper
                return AnimatedBuilder(
                  animation: pageController,
                  builder: (context, child) {
                    double value = 1.0;

                    // Calculate animation value only when controller is attached to scroll view
                    if (pageController.position.hasContentDimensions) {
                      value = pageController.page! - index;
                      // Add smooth curve and constrain the value
                      value = (1 - (value.abs() * 0.3)).clamp(0.85, 1.0);
                    }

                    return Transform(
                      // Apply 3D effect on horizontal swipe
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // Perspective
                        ..rotateY(value - 1 != 0.0
                            ? (value - 1) * 0.5
                            : 0.0), // Y-axis rotation
                      alignment: value < 0
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      // Scale the card slightly during animation
                      child: Transform.scale(
                        scale: value,
                        child: child,
                      ),
                    );
                  },
                  child: _buildVersionCardWithActionsImproved(
                      version, question, index, questionVersionsCount),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVersionCardWithActionsImproved(q.QuestionVersion version,
      q.Question question, int versionIndex, int totalVersions) {
    // Calculate the header height based on aspect ratio
    final double headerHeight = MediaQuery.of(context).size.width / 2;

    return Stack(
      children: [
        // Header section
        _buildVersionCardHeader(version, question, versionIndex, totalVersions),

        // Content section with scrollable area if needed
        Positioned(
          top: headerHeight,
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            children: [
              // Main content area - Now uses Expanded + SingleChildScrollView to handle overflow
              Expanded(
                child: Container(
                  padding: EdgeInsets.fromLTRB(24, 26, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question content
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  _getTypeColor(version.type),
                                  _getTypeColor(version.type).withOpacity(0.6),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getTypeColor(version.type)
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
                      Expanded(
                        child: Container(
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
                            parseHtmlString(version.question),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[800],
                              height: 1.5,
                              letterSpacing: 0.2,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 8,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Pilihan Jawaban section
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
                            color: _getTypeColor(version.type).withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Animated pulse container
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(version.type)
                                        .withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(version.type)
                                        .withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(version.type)
                                        .withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _getTypeColor(version.type),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: _getTypeColor(version.type),
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
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${version.options.length} Opsi',
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            // Arrow indicator
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _getTypeColor(version.type)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: _getTypeColor(version.type),
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Add space for pagination indicators
                      SizedBox(height: totalVersions > 1 ? 40 : 0),
                    ],
                  ),
                ),
              ),
              // Action buttons - now in a fixed position at bottom
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
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Show edit, delete, and detail buttons for latest version
                    if (versionIndex == 0)
                      Row(
                        children: [
                          // View Detail Button (tambahan baru)
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () =>
                                  _showDetailQuestionSheet(question, version),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      _getTypeColor(version.type).withOpacity(0.8),
                                      Color.lerp(_getTypeColor(version.type),
                                              Colors.black, 0.2)!
                                          .withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getTypeColor(version.type)
                                          .withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: Offset(0, 5),
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.visibility_outlined,
                                        size: 18, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Lihat Detail',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          // Edit Button
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () =>
                                  _navigateToEditQuestion(question, version),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      _getTypeColor(version.type),
                                      Color.lerp(_getTypeColor(version.type),
                                          Colors.black, 0.15)!,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getTypeColor(version.type)
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
                                    Icon(Icons.edit_rounded,
                                        size: 18, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Edit',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          // Delete Button
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () =>
                                  _showDeleteQuestionConfirmation(question),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
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
                                    color: Colors.grey.shade300,
                                    width: 1.0,
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
                                    Icon(Icons.delete_outline_rounded,
                                        size: 18, color: Colors.red.shade700),
                                    SizedBox(width: 8),
                                    // Text(
                                    //   'Hapus',
                                    //   style: TextStyle(
                                    //     color: Colors.red.shade700,
                                    //     fontWeight: FontWeight.w600,
                                    //     fontSize: 14,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      // Detail Button for older versions
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () =>
                              _showDetailQuestionSheet(question, version),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  _getTypeColor(version.type).withOpacity(0.8),
                                  Color.lerp(_getTypeColor(version.type),
                                          Colors.black, 0.2)!
                                      .withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getTypeColor(version.type)
                                      .withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: Offset(0, 5),
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.visibility_outlined,
                                    size: 18, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Lihat Detail',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Version indicators
        if (totalVersions > 1)
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalVersions, (index) {
                  final isActive = index == versionIndex;
                  return GestureDetector(
                    onTap: () {
                      _getPageController(question.id).animateToPage(
                        index,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: isActive ? 24 : 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isActive
                            ? _getTypeColor(version.type)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVersionCardHeader(q.QuestionVersion version, q.Question question,
      int versionIndex, int totalVersions) {
    return AspectRatio(
      aspectRatio: 2,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getTypeColor(version.type),
                Color.lerp(_getTypeColor(version.type), Colors.black, 0.2)!,
                _getTypeColor(version.type).withOpacity(0.85),
              ],
              stops: [0.2, 0.6, 0.9],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Pattern background
              CustomPaint(
                painter: UltraModernPatternPainter(
                  primaryColor: Colors.white.withOpacity(0.12),
                  secondaryColor: Colors.white.withOpacity(0.06),
                ),
                size: Size.infinite,
              ),

              // Light effect
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
                        Colors.white.withOpacity(0)
                      ],
                      stops: [0.1, 1.0],
                    ),
                  ),
                ),
              ),

              // Badge tipe soal
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.5), width: 1),
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
                        Colors.white.withOpacity(0.1)
                      ],
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
              ),

              // Badge poin
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              ),

              // Badge versi
              Positioned(
                top: 70,
                right: 20,
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(20 * (1 - value), 0),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Versi ${totalVersions - versionIndex}/${totalVersions}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Judul soal
              Positioned(
                bottom: 22,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 3,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      version.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        letterSpacing: 0.3,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                          ),
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
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
      ),
    );
  }

  void _navigateToEditQuestion(
      q.Question question, q.QuestionVersion version) async {
    // Create a map with all the data needed by EditQuestionScreen
    Map<String, dynamic> questionData = {
      'idBankSoal': widget.bankSoal.id,
      'name': version.name,
      'typeOrder': 'numeric', // Default value since property doesn't exist
      'question': version.question,
      'default_point': version.defaultPoint,
      'note': version.note,
      'type': version.type,
      'image': version.image,
      'options': version.options
          .map((opt) => {
                'text': opt.text,
                'percentage': opt.percentage,
                'feedback': opt.feedback,
              })
          .toList(),
    };

    final result = await Get.toNamed(
      Routes.editQuestionScreen,
      arguments: {
        'questionData': questionData, // Pass data with the key 'questionData'
      },
    );

    if (result == true) {
      _loadQuestions();
    }
  }

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

                  // Show auto-dismissing success notification
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Text(
                              'Soal berhasil dihapus!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      backgroundColor: Colors.green.shade400,
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
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

  // Add helper method to display image preview
  Widget _buildImagePreview(dynamic imageData) {
    if (imageData is Uint8List) {
      return Image.memory(
        imageData,
        fit: BoxFit.contain,
      );
    } else if (imageData is String) {
      if (imageData.startsWith('http')) {
        return Image.network(
          imageData,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                "Gagal memuat gambar",
                style: TextStyle(color: Colors.grey),
              ),
            );
          },
        );
      } else {
        // Assume it's a base64 image
        try {
          final decodedImage = base64Decode(imageData);
          return Image.memory(
            decodedImage,
            fit: BoxFit.contain,
          );
        } catch (e) {
          return Center(
            child: Text(
              "Format gambar tidak valid",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
      }
    } else {
      return Center(
        child: Text(
          "Format gambar tidak didukung",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
  }

  Widget _buildDetailQuestionContent(
      q.Question question, q.QuestionVersion version) {
    return Stack(
      children: [
        // Base white background container yang menutupi seluruh area (kecuali gradient header)
        Positioned(
          top: 160, // Mulai setelah header gradient
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
          ),
        ),

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

              // Main content area - Ubah dengan container tunggal dengan padding internal
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
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
                              color:
                                  _getTypeColor(version.type).withOpacity(0.1),
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
                          border:
                              Border.all(color: Colors.grey.shade200, width: 1),
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
                      color: Colors.white, // Pastikan background tetap putih
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
                                                  : _getTypeColor(version.type)
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
                                              margin: EdgeInsets.only(left: 10),
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
                                              margin: EdgeInsets.only(left: 10),
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
                        color: Colors.white, // Pastikan background tetap putih
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
                        color: Colors.white, // Pastikan background tetap putih
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
                                    color: _getTypeColor(version.type)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: _getTypeColor(version.type),
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

                            // Image content with improved display
                            Container(
                              width: double.infinity,
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
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: _questionImages.containsKey(question.id)
                                    ? _buildImagePreview(
                                        _questionImages[question.id])
                                    : version.image != null
                                        ? Container(
                                            height: 200,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        _getTypeColor(
                                                            version.type)),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            height: 100,
                                            child: Center(
                                              child: Text(
                                                "Tidak ada gambar",
                                                style: TextStyle(
                                                    color: Colors.grey),
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
                                  side: BorderSide(color: Colors.grey.shade300),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () =>
                                  _navigateToEditQuestion(question, version),
                              child: Text(
                                "Edit",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
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
      ],
    );
  }
}
