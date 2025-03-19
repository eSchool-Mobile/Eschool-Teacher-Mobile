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

class LightRaysPainter extends CustomPainter {
  final Color color;

  LightRaysPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final rays = 12;
    final maxLength = size.width > size.height ? size.width : size.height;

    for (int i = 0; i < rays; i++) {
      final angle = (i * 2 * math.pi / rays);
      final x = math.cos(angle) * maxLength;
      final y = math.sin(angle) * maxLength;

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

class BankSoalSelectionScreen extends StatefulWidget {
  final int examId;

  const BankSoalSelectionScreen({
    Key? key,
    required this.examId,
  }) : super(key: key);

  @override
  State<BankSoalSelectionScreen> createState() => _BankSoalSelectionScreenState();
}

class _BankSoalSelectionScreenState extends State<BankSoalSelectionScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<BankSoalQuestion> _filteredBanks = [];
  bool _showSearch = false;
  int _hoveredCardIndex = -1;
  double _dragPosition = 0;

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

  late Animation<double> _backgroundAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _searchWidthAnimation;

  final Color _primaryColor = Color(0xFF7A1E23);
  final Color _accentColor = Color(0xFF9D3C3C);
  final Color _highlightColor = Color(0xFFB84D4D);
  final Color _energyColor = Color(0xFFCE6D6D);
  final Color _glowColor = Color(0xFFAF4F4F);

  final List<Color> _cardGradients = [
    Color(0xFF7A2828),
    Color(0xFF9D3C3C),
    Color(0xFFAF4F4F),
    Color(0xFFB84D4D),
    Color(0xFFC65454),
    Color(0xFFAA3939),
    Color(0xFF8F2D2D),
    Color(0xFFB14040),
  ];

  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    context.read<QuestionOnlineExamCubit>().getBankSoal(widget.examId);

    _backgroundAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 30000))..repeat();
    _waveAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 7000))..repeat();
    _floatingIconsController = AnimationController(vsync: this, duration: Duration(milliseconds: 2000))..repeat(reverse: true);
    _cardHoverController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _breathingController = AnimationController(vsync: this, duration: Duration(milliseconds: 3000))..repeat(reverse: true);
    _rotationController = AnimationController(vsync: this, duration: Duration(milliseconds: 10000))..repeat();
    _pulseController = AnimationController(vsync: this, duration: Duration(milliseconds: 1200))..repeat(reverse: true);
    _loadingController = AnimationController(vsync: this, duration: Duration(milliseconds: 1500))..repeat();
    _tabTransitionController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _searchExpandController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _backgroundAnimation = CurvedAnimation(parent: _backgroundAnimationController, curve: Curves.linear);
    _waveAnimation = CurvedAnimation(parent: _waveAnimationController, curve: Curves.easeInOut);
    _breathingAnimation = CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut);
    _rotationAnimation = CurvedAnimation(parent: _rotationController, curve: Curves.linear);
    _pulseAnimation = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);
    _searchWidthAnimation = Tween<double>(begin: 0.7, end: 0.9).animate(CurvedAnimation(parent: _searchExpandController, curve: Curves.easeOutCubic));

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: _primaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isFirstLoad = false);
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

  void _filterBanks(String query, List<BankSoalQuestion> banks) {
    setState(() {
      if (query.isEmpty) {
        _filteredBanks = banks;
      } else {
        _filteredBanks = banks.where((bank) => bank.name.toLowerCase().contains(query.toLowerCase())).toList();
        if (_filteredBanks.isNotEmpty) HapticFeedback.selectionClick();
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
                _buildAnimatedBackground(),
                SafeArea(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification) {
                        setState(() => _dragPosition = notification.metrics.pixels / 10);
                      }
                      return false;
                    },
                    child: Column(
                      children: [
                        _buildCustomAppBar(),
                        if (state is QuestionBanksLoaded && state.banks.length > 5) _buildSearchBar(state.banks),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(top: 15),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.white.withOpacity(0.95), Color(0xFFFFF0F0)],
                              ),
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                              boxShadow: [
                                BoxShadow(color: _glowColor.withOpacity(0.2), blurRadius: 20, spreadRadius: 5, offset: Offset(0, -5)),
                                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: Offset(0, -10)),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
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
                _buildGlowingIconButton(Icons.arrow_back_rounded, () {
                  HapticFeedback.mediumImpact();
                  getx.Get.back();
                }),
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    'Pilih Bank Soal',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Colors.white, height: 1.2),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                'Pilih Bank Soal untuk Ujian',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500, letterSpacing: 0.5),
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
                  color: _highlightColor.withOpacity(0.1 + 0.1 * _pulseAnimation.value),
                  blurRadius: 12 * (1 + _pulseAnimation.value),
                  spreadRadius: 2 * _pulseAnimation.value,
                )
              ],
              border: Border.all(color: Colors.white.withOpacity(0.1 + 0.05 * _pulseAnimation.value), width: 1.5),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [_primaryColor, Color(0xFF5A2223)],
            ),
          ),
        ),
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
                    gradient: RadialGradient(colors: [_glowColor.withOpacity(0.4), _glowColor.withOpacity(0.0)]),
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
                  gradient: RadialGradient(colors: [_energyColor.withOpacity(opacity), _energyColor.withOpacity(0.0)]),
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * math.pi * 2,
                child: CustomPaint(painter: LightRaysPainter(_highlightColor.withOpacity(0.03)), size: Size(getx.Get.width, getx.Get.height)),
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
            border: Border.all(color: _highlightColor.withOpacity(0.3), width: 1.5),
            boxShadow: [BoxShadow(color: _accentColor.withOpacity(0.2), blurRadius: 15, spreadRadius: 0, offset: Offset(0, 5))],
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
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentArea(QuestionOnlineExamState state) {
    if (state is QuestionBanksLoading) return _buildLoadingView();
    if (state is QuestionBanksLoaded) {
      _showSearch = state.banks.length > 5;
      if (_searchController.text.isEmpty) {
        _filteredBanks = state.banks;
      } else {
        _filteredBanks = state.banks.where((bank) => bank.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
      }
      if (state.banks.isEmpty) return _buildEmptyView("Tidak ada bank soal yang tersedia", "Silakan tambahkan bank soal baru.");
      return Column(children: [Expanded(child: _buildBankList(_filteredBanks))]);
    }
    if (state is QuestionOnlineExamFailure) {
      return Center(
        child: ErrorContainer(
          errorMessage: "Tidak dapat memuat bank soal. Silakan coba lagi.",
          onTapRetry: () => context.read<QuestionOnlineExamCubit>().getBankSoal(widget.examId),
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
          colors: [Colors.white, Color(0xFFFFF0F0)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Shimmer.fromColors(
              baseColor: _accentColor.withOpacity(0.4),
              highlightColor: _highlightColor.withOpacity(0.7),
              period: Duration(milliseconds: 1500),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: Icon(Icons.auto_stories_rounded, size: 80, color: Colors.white),
              ),
            ),
            SizedBox(height: 25),
            Text('Memuat Bank Soal', style: TextStyle(color: _primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              width: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(backgroundColor: _accentColor.withOpacity(0.2), valueColor: AlwaysStoppedAnimation<Color>(_accentColor), minHeight: 6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(String title, String subtitle) {
    return FadeIn(
      duration: Duration(milliseconds: 800),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankList(List<BankSoalQuestion> banks) {
    if (banks.isEmpty && _searchController.text.isNotEmpty) {
      return _buildEmptyView(
        "Tidak ada bank soal yang cocok",
        "Coba gunakan kata kunci lain untuk pencarian.",
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _backgroundAnimation.value * 0.05,
                child: ShaderMask(
                  blendMode: BlendMode.srcATop,
                  shaderCallback: (bounds) => RadialGradient(
                    center: Alignment(math.sin(_backgroundAnimation.value * math.pi * 2) * 0.5, math.cos(_backgroundAnimation.value * math.pi * 2) * 0.5),
                    colors: [Colors.transparent, _highlightColor.withOpacity(0.01), _accentColor.withOpacity(0.02), Colors.transparent],
                    radius: 1.0,
                  ).createShader(bounds),
                  child: Container(color: Colors.white),
                ),
              );
            },
          ),
        ),
        ListView.builder(
          padding: EdgeInsets.fromLTRB(20, 25, 20, 100),
          physics: BouncingScrollPhysics(),
          itemCount: banks.length,
          itemBuilder: (context, index) {
            final bank = banks[index];
            final Color cardBaseColor = _cardGradients[index % _cardGradients.length];
            final neonGlowColor = HSLColor.fromColor(cardBaseColor).withLightness(0.7).withSaturation(0.9).toColor();
            final bool isHovered = _hoveredCardIndex == index;

            return GestureDetector(
              onTap: () => navigateToPreview(bank),
              onTapDown: (_) {
                setState(() => _hoveredCardIndex = index);
                HapticFeedback.selectionClick();
              },
              onTapCancel: () => setState(() => _hoveredCardIndex = -1),
              onTapUp: (_) => Future.delayed(Duration(milliseconds: 300), () => mounted ? setState(() => _hoveredCardIndex = -1) : null),
              child: Transform.translate(
                offset: Offset(0, isHovered ? -5 : 0),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  margin: EdgeInsets.only(bottom: 24),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(isHovered ? 0.05 : 0.0)
                          ..rotateY(isHovered ? -0.05 : 0.0),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                cardBaseColor.withOpacity(isHovered ? 1.0 : 0.85),
                                HSLColor.fromColor(cardBaseColor).withLightness(HSLColor.fromColor(cardBaseColor).lightness * 0.7).toColor().withOpacity(isHovered ? 0.95 : 0.8),
                              ],
                              stops: [0.3, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(color: neonGlowColor.withOpacity(isHovered ? 0.35 : 0.15), blurRadius: isHovered ? 25 : 15, spreadRadius: isHovered ? 2 : 0),
                              BoxShadow(color: cardBaseColor.withOpacity(0.5), blurRadius: 15, spreadRadius: -3, offset: Offset(0, 8)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ShaderMask(
                                          blendMode: BlendMode.srcIn,
                                          shaderCallback: (bounds) => LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [Colors.white.withOpacity(1.0), Colors.white.withOpacity(0.9), Colors.white.withOpacity(1.0)],
                                          ).createShader(bounds),
                                          child: Text(
                                            bank.name,
                                            style: TextStyle(
                                              fontSize: 20,
                                              height: 1.2,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                              shadows: [Shadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 1))],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        AnimatedContainer(
                                          duration: Duration(milliseconds: 400),
                                          margin: EdgeInsets.symmetric(vertical: 8),
                                          height: 2,
                                          width: isHovered ? 180 : 80,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.2)],
                                            ),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(30),
                                            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 0)],
                                          ),
                                          child: Text(
                                            '${bank.soal.length} Soal',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                            ? [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)]
                                            : [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
                                      ),
                                      boxShadow: isHovered ? [BoxShadow(color: neonGlowColor.withOpacity(0.4), blurRadius: 15, spreadRadius: 1)] : [],
                                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                                    ),
                                    child: AnimatedBuilder(
                                      animation: _pulseAnimation,
                                      builder: (context, child) {
                                        return Transform.rotate(
                                          angle: isHovered ? 0.1 : 0,
                                          child: Transform.scale(
                                            scale: isHovered ? 1.0 + 0.15 * _pulseAnimation.value : 1.0,
                                            child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: isHovered ? 25 : 22),
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
                      Positioned(
                        right: 20,
                        top: -10,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: neonGlowColor.withOpacity(0.1)),
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

    if (bank.classSectionId == 0 || bank.classSubjectId == 0) {
      getx.Get.snackbar('Error', 'Data kelas atau mata pelajaran tidak valid', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: getx.SnackPosition.BOTTOM);
      return;
    }

    getx.Get.toNamed(Routes.previewQuestionBank, arguments: {'bank': bank, 'examId': widget.examId, 'classSectionId': bank.classSectionId, 'classSubjectId': bank.classSubjectId});
  }
}