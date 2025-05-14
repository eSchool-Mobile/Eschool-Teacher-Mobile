import 'dart:math' as math;
import 'dart:ui';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import '../../../cubits/teacherAcademics/assignment/questionBankCubit.dart';
import '../../../data/models/question.dart';
import '../../../data/models/questionBank.dart';
import '../../../data/models/subjectQuestion.dart';
import 'package:eschool_saas_staff/data/repositories/questionBankRepository.dart';
import '../../widgets/customModernAppBar.dart';

// Controller GetX untuk lifecycle
class QuestionBankListController extends GetxController {
  final BuildContext context;
  final int subjectId;

  QuestionBankListController(this.context, this.subjectId);

  @override
  void onInit() {
    super.onInit();
    _reloadData();
  }

  @override
  void onReady() {
    super.onReady();
    _reloadData(); // Reload saat halaman siap
  }

  void _reloadData() {
    print("Reloading QuestionBankListScreen for subject ID: $subjectId");
    context.read<QuestionBankCubit>().fetchBankSoal(subjectId);
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

class QuestionBankListScreen extends StatefulWidget {
  final SubjectQuestion subject;

  static Widget getRouteInstance(SubjectQuestion subject) {
    return BlocProvider(
      create: (context) => QuestionBankCubit(
        repository: QuestionBankRepository(),
      )..fetchBankSoal(subject.subject.id),
      child: QuestionBankListScreen(subject: subject),
    );
  }

  const QuestionBankListScreen({super.key, required this.subject});

  @override
  State<QuestionBankListScreen> createState() => _QuestionBankListScreenState();
}

class _QuestionBankListScreenState extends State<QuestionBankListScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController(text: 'multiple_choice');
  final _defaultPointController = TextEditingController(text: '10');
  final TextEditingController _searchController = TextEditingController();
  List<BankSoal> _filteredBanks = [];
  bool _showSearch = false;
  late QuestionBankListController _controller;

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

  // Particles
  // final List<ParticleModel> _particles = [];

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

  @override
  void initState() {
    super.initState();
    _controller =
        Get.put(QuestionBankListController(context, widget.subject.subject.id));

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
    _nameController.dispose();
    _typeController.dispose();
    _defaultPointController.dispose();
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
    Get.delete<QuestionBankListController>();
    super.dispose();
  }

  void _reloadData() {
    print("Manual reload triggered for QuestionBankListScreen");
    _searchController.clear();
    _filteredBanks = [];
    _showSearch = false;
    context.read<QuestionBankCubit>().fetchBankSoal(widget.subject.subject.id);
  }

  void _filterBanks(String query, List<BankSoal> banks) {
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
       
        extendBodyBehindAppBar: true,
        appBar: CustomModernAppBar(
          title: widget.subject.subject.name,
          icon: Icons.school_rounded,
          fabAnimationController: _breathingController,
          primaryColor: _primaryColor,
          lightColor: _accentColor,
          showAddButton: true,
          onAddPressed: () {
            HapticFeedback.mediumImpact();
            _showAddBankDialog();
          },
          onBackPressed: () => Navigator.of(context).pop(),
        ),
        body: BlocBuilder<QuestionBankCubit, QuestionBankState>(
          builder: (context, state) {
            return Stack(
              children: [
                // Animated background with advanced effects
             // Content with parallax scroll effect
                SafeArea(
                  top:
                      false, // Don't add padding at the top to allow white background to extend to status bar
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
                        // Main content with container positioned below AppBar
                        Expanded(
                          child: Container(
                            // Add top margin to start content below the AppBar
                            margin: EdgeInsets.only(top: kToolbarHeight + 30),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.95),
                                  Color(0xFFFFF0F0),
                                ],
                              ),
                              // Add top border radius for a nice curve
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
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
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                              child: Column(
                                children: [
                                  // No need for additional padding since we have an AppBar now

                                  // Animated search bar moved inside the white container
                                  if (state is BankSoalFetchSuccess &&
                                      state.bankSoal.length > 5)
                                    _buildSearchBar(state.bankSoal),
                                  // Content area takes remaining space
                                  Expanded(
                                    child: _buildContentArea(state),
                                  ),
                                ],
                              ),
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

  // Tombol tambah bank soal untuk app bar
  Widget _buildAddButtonForAppBar() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = 1.0 + 0.05 * _pulseAnimation.value;
        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            _showAddBankDialog();
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
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

  Widget _buildSearchBar(List<BankSoal> banks) {
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

  Widget _buildContentArea(QuestionBankState state) {
    if (state is QuestionBankLoading) {
      return _buildLoadingView();
    }

    if (state is BankSoalFetchSuccess) {
      // Tetap set _showSearch berdasarkan jumlah bank soal untuk menampilkan search bar
      _showSearch = state.bankSoal.length > 5;

      // Pastikan _filteredBanks selalu diisi dengan bank soal yang ada
      if (_searchController.text.isEmpty) {
        _filteredBanks = state.bankSoal;
      } else {
        _filteredBanks = state.bankSoal
            .where((bank) => bank.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      }

      // Tampilkan pesan kosong hanya jika benar-benar tidak ada bank soal
      if (state.bankSoal.isEmpty) {
        return _buildEmptyView();
      }

      // Selalu tampilkan bank soal yang ada, terlepas dari jumlahnya
      return Column(
        children: [
          // Bagian ini selalu ditampilkan selama ada bank soal
          Expanded(
            child: _buildBankList(_filteredBanks),
          ),
        ],
      );
    }

    if (state is QuestionBankError) {
      return Center(
        child: ErrorContainer(
          errorMessage:
              "Tidak dapat terhubung ke server, mohon periksa koneksi internet anda dan coba lagi",
          onTapRetry: _reloadData,
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
              'Belum ada bank soal',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddBankDialog,
              icon: Icon(Icons.add),
              label: Text('Tambah Bank Soal'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankList(List<BankSoal> banks) {
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
          padding: EdgeInsets.fromLTRB(20, 50, 20, 100),
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
              onTap: () async {
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

                await Get.toNamed(
                  Routes.bankQuestionScreen,
                  arguments: {
                    'bankSoal': bank,
                    'subjectId': widget.subject.subject.id,
                    'subject': widget.subject,
                  },
                );
                _reloadData();
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

                                            // Question count badge
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
                                                    '${bank.soalCount} Soal',
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

                                      // Three-dots menu button
                                      _buildMoreOptionsButton(
                                        bank: bank,
                                        banks: banks,
                                        index: index,
                                        isHovered: isHovered,
                                        neonGlowColor: neonGlowColor,
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 0),

                                  // Arrow button repositioned at bottom right for better layout
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: AnimatedBuilder(
                                      animation: _pulseAnimation,
                                      builder: (context, child) {
                                        return Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withOpacity(
                                                isHovered ? 0.2 : 0.15),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                  isHovered ? 0.3 : 0.2),
                                              width: 1.5,
                                            ),
                                            boxShadow: isHovered
                                                ? [
                                                    BoxShadow(
                                                      color: neonGlowColor
                                                          .withOpacity(0.2 +
                                                              0.1 *
                                                                  _pulseAnimation
                                                                      .value),
                                                      blurRadius: 10,
                                                      spreadRadius: 1 *
                                                          _pulseAnimation.value,
                                                    )
                                                  ]
                                                : [],
                                          ),
                                          child: Center(
                                            child: Transform.scale(
                                              scale: isHovered
                                                  ? 1.0 +
                                                      0.15 *
                                                          _pulseAnimation.value
                                                  : 1.0,
                                              child: Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Colors.white,
                                                size: 22,
                                              ),
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

  Widget _buildMoreOptionsButton({
    required BankSoal bank,
    required List<BankSoal> banks,
    required int index,
    required bool isHovered,
    required Color neonGlowColor,
  }) {
    return PopupMenuButton<String>(
      offset: Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      position: PopupMenuPosition.under,
      elevation: 8,
      tooltip: "Opsi",
      color: Colors.white.withOpacity(0.95),
      splashRadius: 24,
      onSelected: (value) {
        if (value == 'edit') {
          _showEditBankDialog(banks, index);
        } else if (value == 'delete') {
          _showDeleteConfirmation(context, bank);
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'edit',
          height: 50,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit_outlined,
                  color: _accentColor,
                  size: 18,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Edit Bank Soal',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          height: 50,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 18,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Hapus Bank Soal',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(isHovered ? 0.2 : 0.15),
              border: Border.all(
                color: Colors.white.withOpacity(isHovered ? 0.3 : 0.2),
                width: 1.5,
              ),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: neonGlowColor
                            .withOpacity(0.2 + 0.1 * _pulseAnimation.value),
                        blurRadius: 10,
                        spreadRadius: 1 * _pulseAnimation.value,
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Transform.scale(
                scale: isHovered ? 1.0 + 0.15 * _pulseAnimation.value : 1.0,
                child: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddBankDialog() {
    final questionBankCubit = context.read<QuestionBankCubit>();
    bool isSubmitting = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ScaleTransition(
              scale: CurvedAnimation(
                parent: anim1,
                curve: Curves.elasticOut,
                reverseCurve: Curves.easeOutCubic,
              ),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_box_rounded,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Tambah Bank',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        enabled: !isSubmitting,
                        decoration: InputDecoration(
                          labelText: 'Nama Bank Soal',
                          prefixIcon: Icon(Icons.folder_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Nama bank soal tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            _nameController.clear();
                            Navigator.pop(context);
                          },
                    child: Text(
                      'Batal',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: MaterialButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  setState(() {
                                    isSubmitting = true;
                                  });

                                  await questionBankCubit.createQuestionBank(
                                    subjectId: widget.subject.subject.id,
                                    name: _nameController.text.trim(),
                                  );

                                  // Fetch updated bank list
                                  await questionBankCubit.fetchBankSoal(
                                    widget.subject.subject.id,
                                  );

                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  _nameController.clear();

                                  // Show custom success notification
                                  if (mounted) {
                                    // Auto-dismissing success banner
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Container(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.check_circle,
                                                  color: Colors.white),
                                              SizedBox(width: 12),
                                              Text(
                                                'Bank soal berhasil dibuat!',
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
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        elevation: 4,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content:
                                        Text('Gagal membuat bank soal: $e'),
                                    backgroundColor: Colors.red,
                                  ));
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      isSubmitting = false;
                                    });
                                  }
                                }
                              }
                            },
                      child: isSubmitting
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Simpan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditBankDialog(List<BankSoal> banks, int index) {
    final bank = banks[index];
    final _editController = TextEditingController(text: bank.name);
    final _editFormKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    // Simpan cubit di luar showDialog untuk menghindari masalah provider
    final questionBankCubit = context.read<QuestionBankCubit>();
    final BuildContext currentContext = context;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return ScaleTransition(
              scale: CurvedAnimation(
                parent: anim1,
                curve: Curves.elasticOut,
                reverseCurve: Curves.easeOutCubic,
              ),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(dialogContext)
                            .colorScheme
                            .secondary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        color: Theme.of(dialogContext).colorScheme.secondary,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Edit Bank Soal',
                      style: TextStyle(
                        color: Theme.of(dialogContext).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Form(
                  key: _editFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _editController,
                        enabled: !isSubmitting,
                        decoration: InputDecoration(
                          labelText: 'Nama Bank Soal',
                          prefixIcon: Icon(Icons.folder_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color:
                                  Theme.of(dialogContext).colorScheme.secondary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Nama bank soal tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: Text(
                      'Batal',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(dialogContext).colorScheme.primary,
                          Theme.of(dialogContext).colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: MaterialButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (_editFormKey.currentState?.validate() ??
                                  false) {
                                try {
                                  setState(() {
                                    isSubmitting = true;
                                  });

                                  // Gunakan questionBankCubit yang sudah disimpan
                                  await questionBankCubit.updateQuestionBank(
                                    subjectId: widget.subject.subject.id,
                                    banksoalId: bank.id,
                                    name: _editController.text.trim(),
                                  );

                                  Navigator.pop(dialogContext);

                                  // Refresh bank soal list
                                  _reloadData();

                                  // Gunakan currentContext yang disimpan
                                  if (currentContext.mounted) {
                                    ScaffoldMessenger.of(currentContext)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Container(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.check_circle,
                                                  color: Colors.white),
                                              SizedBox(width: 12),
                                              Text(
                                                'Bank soal berhasil diperbarui',
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
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        elevation: 4,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (currentContext.mounted) {
                                    ScaffoldMessenger.of(currentContext)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Gagal memperbarui: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      isSubmitting = false;
                                    });
                                  }
                                }
                              }
                            },
                      child: isSubmitting
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Simpan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext dialogContext, BankSoal bank) {
    // Simpan context di luar fungsi asynchronous
    final BuildContext currentContext = context;
    final cubit = context.read<QuestionBankCubit>();

    showDialog(
      context: dialogContext,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.delete_outline, color: Colors.red),
              ),
              SizedBox(width: 16),
              Text(
                'Hapus Bank Soal',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus bank soal "${bank.name}"? Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[400]!, Colors.red[700]!],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: MaterialButton(
                onPressed: () async {
                  try {
                    // Tutup dialog terlebih dahulu
                    Navigator.pop(context); // Lakukan proses delete
                    await cubit.deleteBankSoal(
                      subjectId: widget.subject.subject.id,
                      banksoalId: bank.id,
                    );

                    // Refresh data
                    _reloadData();

                    // Gunakan currentContext yang disimpan di awal function
                    // dan periksa apakah context masih mounted sebelum menampilkan SnackBar
                    if (currentContext.mounted) {
                      ScaffoldMessenger.of(currentContext).showSnackBar(
                        SnackBar(
                          content: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 12),
                                Text(
                                  'Bank soal berhasil dihapus!',
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
                          margin: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                      );
                    }
                  } catch (e) {
                    // Gunakan currentContext yang disimpan di awal function
                    // dan periksa apakah context masih mounted
                    if (currentContext.mounted) {
                      ScaffoldMessenger.of(currentContext).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Gagal menghapus bank soal: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  'Hapus',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ],
        );
      },
    );
  }

  // Tambahkan metode baru untuk tombol aksi yang lebih baik
  Widget _buildActionButtonImproved({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isHovered,
    required Color neonGlowColor,
    bool isPrimary = false,
    bool isDanger = false,
  }) {
    Color buttonColor;
    Color textColor = Colors.white;
    Color borderColor;

    if (isDanger) {
      buttonColor = Colors.red.withOpacity(0.2);
      borderColor = Colors.red.withOpacity(0.3);
    } else if (isPrimary) {
      buttonColor = Colors.white.withOpacity(0.2);
      borderColor = Colors.white.withOpacity(0.3);
    } else {
      buttonColor = Colors.white.withOpacity(0.15);
      borderColor = Colors.white.withOpacity(0.25);
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: isDanger
                        ? Colors.red.withOpacity(0.3)
                        : neonGlowColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : [],
          border: Border.all(
            color: borderColor,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: textColor,
              size: 18,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
