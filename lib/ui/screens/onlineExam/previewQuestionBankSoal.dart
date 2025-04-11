import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:eschool_saas_staff/data/models/BankOnlineQuestion.dart';
import 'package:eschool_saas_staff/data/repositories/onlineExamRepository.dart';
import 'package:get/get.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:animate_do/animate_do.dart';
import 'package:html/parser.dart' show parse;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubits/teacherAcademics/assignment/questionBankCubit.dart';
import 'package:flutter/services.dart';

class PreviewQuestionBankSoal extends StatefulWidget {
  final BankSoalQuestion bank;
  final int examId;
  final int classSectionId;
  final int classSubjectId;

  const PreviewQuestionBankSoal({
    required this.bank,
    required this.examId,
    required this.classSectionId,
    required this.classSubjectId,
    Key? key,
  }) : super(key: key);

  @override
  State<PreviewQuestionBankSoal> createState() =>
      _PreviewQuestionBankSoalState();
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

class _PreviewQuestionBankSoalState extends State<PreviewQuestionBankSoal>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allQuestions = [];
  List<dynamic> _filteredQuestions = [];
  bool _showSearch = false;
  Set<int> _selectedQuestions = {};
  late AnimationController _selectionController;
  bool _hasShownTooltip = false;

  // New properties for swipeable cards
  Map<int, PageController> _pageControllers = {};
  Map<int, int> _activeVersionIndices = {};
  bool _hasShownSwipeGuide = false;
  // Define the border radius for cards
  final BorderRadius cardBorderRadius = BorderRadius.circular(28);

  @override
  void initState() {
    super.initState();
    _selectionController =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);
    _fetchQuestions();
    _searchController.addListener(_filterQuestionsLocally);
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _searchController.removeListener(_filterQuestionsLocally);
    _searchController.dispose();

    // Dispose all page controllers
    _pageControllers.forEach((_, controller) => controller.dispose());

    super.dispose();
  }

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

  Future<void> _fetchQuestions() async {
    await context.read<QuestionBankCubit>().fetchBankQuestions(
          examId: widget.examId,
          bankId: widget.bank.id,
          subjectId: widget.bank.subjectId,
        );
    _filterQuestionsLocally();
  }

  void _filterQuestionsLocally() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredQuestions = List.from(_allQuestions);
      } else {
        _filteredQuestions = _allQuestions.where((question) {
          final questionText = parseHtmlString(
                  question.versions[question.versions.length - 1].question)
              .toLowerCase();
          return questionText.contains(query);
        }).toList();
      }
    });
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

  void _toggleQuestionSelection(int index) {
    final question = _filteredQuestions[index];
    if (question.selected) return;

    setState(() {
      if (_selectedQuestions.contains(index)) {
        _selectedQuestions.remove(index);
      } else {
        _selectedQuestions.add(index);
      }
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon:
                      Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                  onPressed: () => Get.back(),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bank.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        shadows: [
                          Shadow(
                              color: Colors.black38,
                              offset: Offset(0, 2),
                              blurRadius: 4),
                        ],
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
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8B0000).withOpacity(0.9),
              Color(0xFF6B0000),
              Color(0xFF4B0000),
              Theme.of(context).colorScheme.secondary,
            ],
            stops: [0.2, 0.4, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              FadeInDown(
                  duration: Duration(milliseconds: 600), child: _buildHeader()),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    child: BlocConsumer<QuestionBankCubit, QuestionBankState>(
                      listener: (context, state) {
                        if (state is BankQuestionsFetchSuccess) {
                          setState(() {
                            _allQuestions = List.from(state.questions);
                            _filterQuestionsLocally();
                          });
                        }
                      },
                      builder: (context, state) {
                        if (state is QuestionBankLoading &&
                            _allQuestions.isEmpty) {
                          return Center(child: CircularProgressIndicator());
                        } else if (state is QuestionBankError &&
                            _allQuestions.isEmpty) {
                          return Center(
                              child: Text('Gagal memuat soal: ${state.message}',
                                  style: TextStyle(color: Colors.red)));
                        }
                        return RefreshIndicator(
                            onRefresh: _fetchQuestions, child: _buildContent());
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedQuestions.isNotEmpty
          ? Container(
              margin: EdgeInsets.only(bottom: 16.0, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SlideInLeft(
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      margin: EdgeInsets.only(right: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10)
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () =>
                              setState(() => _selectedQuestions.clear()),
                          borderRadius: BorderRadius.circular(30),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Icon(Icons.clear, color: Colors.grey[700]),
                                SizedBox(width: 8),
                                Text('Batal',
                                    style: TextStyle(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SlideInRight(
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.blue[600]!, Colors.blue[800]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.blue[600]!.withOpacity(0.3),
                              blurRadius: 10)
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _saveSelectedQuestions,
                          borderRadius: BorderRadius.circular(30),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            child: Row(
                              children: [
                                Icon(Icons.save, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Simpan ${_selectedQuestions.length} Soal',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildContent() {
    // Check if any questions have multiple versions
    bool hasMultipleVersions =
        _filteredQuestions.any((q) => q.versions.length > 1);

    return Column(
      children: [
        if (!_hasShownTooltip)
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                    child: Text('Ketuk kartu soal untuk memilih',
                        style: TextStyle(
                            color: Colors.blue.shade900, fontSize: 14))),
                IconButton(
                    icon: Icon(Icons.close, color: Colors.blue),
                    onPressed: () => setState(() => _hasShownTooltip = true)),
              ],
            ),
          ),

        // Show swipe guide tooltip if we have multiple versions and it hasn't been shown
        if (hasMultipleVersions && !_hasShownSwipeGuide)
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.swipe, color: Colors.amber.shade700),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Geser kanan atau kiri untuk melihat versi soal lain',
                        style: TextStyle(
                          color: Colors.amber.shade900,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Beberapa soal memiliki beberapa versi yang dapat dilihat',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.amber.shade700),
                  onPressed: () => setState(() => _hasShownSwipeGuide = true),
                ),
              ],
            ),
          ),

        if (_allQuestions.length > 5)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: Offset(0, 5))
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari soal...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        Expanded(
          child: _filteredQuestions.isEmpty
              ? _buildNoDataWidget()
              : ListView.builder(
                  padding: EdgeInsets.only(top: 8, bottom: 24),
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: _filteredQuestions.length,
                  itemBuilder: (context, index) {
                    final question = _filteredQuestions[index];
                    return FadeInUp(
                      duration: Duration(milliseconds: 400 + (index * 50)),
                      child: _buildSwipeableQuestionCard(question, index),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNoDataWidget() {
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
              _searchController.text.isNotEmpty
                  ? 'Tidak ada soal yang cocok'
                  : 'Belum ada soal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Coba gunakan kata kunci lain'
                  : 'Bank soal ini belum memiliki soal',
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

  // New method to build swipeable question card
  Widget _buildSwipeableQuestionCard(dynamic question, int index) {
    bool isSelected = _selectedQuestions.contains(index);
    bool isDisabled = question.selected;
    final int questionVersionsCount = question.versions.length;
    final PageController pageController = _getPageController(question.id);
    final int activeVersionIndex = _getActiveVersionIndex(question.id);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Stack(
        children: [
          // Main Card dengan enhanced shadow dan animasi
          GestureDetector(
            onTap: isDisabled
                ? () {
                    Get.snackbar(
                      'Soal Sudah Ditambahkan',
                      'Soal ini sudah ada dalam ujian',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                      margin: EdgeInsets.all(16),
                      borderRadius: 8,
                      duration: Duration(seconds: 2),
                    );
                  }
                : () => _toggleQuestionSelection(index),
            // Deteksi horizontal drag khusus untuk swipe
            behavior: HitTestBehavior.deferToChild,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.transparent,
                    width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.3)
                        : _getTypeColor(
                                question.versions[activeVersionIndex].type)
                            .withOpacity(0.12),
                    blurRadius: isSelected ? 15 : 40,
                    offset: Offset(0, 15),
                    spreadRadius: isSelected ? 2 : 0,
                  ),
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: Offset(0, 8)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: PageView.builder(
                    controller: pageController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
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

                      // Modified AnimatedBuilder to match bankQuestionScreen.dart
                      return AnimatedBuilder(
                        animation: pageController,
                        builder: (context, child) {
                          double value = 1.0;

                          if (pageController.position.hasContentDimensions) {
                            value = pageController.page! - index;
                            value = (1 - (value.abs() * 0.3)).clamp(0.85, 1.0);
                          }

                          // The key change is here - removing the ClipRRect from around the Transform
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(
                                  value - 1 != 0.0 ? (value - 1) * 0.5 : 0.0),
                            alignment: value < 0
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Transform.scale(
                              scale: value,
                              child: child,
                            ),
                          );
                        },
                        child: _buildQuestionVersionContent(
                            version, question, index, questionVersionsCount),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Overlay untuk kartu yang dinonaktifkan (soal sudah dipilih)
          if (isDisabled)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: cardBorderRadius, // Apply same border radius
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, color: Colors.white, size: 32),
                        SizedBox(height: 8),
                        Text(
                          'Soal sudah ditambahkan',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Indikator seleksi dengan animasi
          if (isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 350),
                curve: Curves.elasticOut,
                tween: Tween<double>(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(Icons.check, color: Colors.white, size: 16),
                    ),
                  );
                },
              ),
            ),

          // Version indicators if there are multiple versions
          if (questionVersionsCount > 1)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(questionVersionsCount, (index) {
                    final isActive = index == activeVersionIndex;
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
                              ? _getTypeColor(question
                                  .versions[questionVersionsCount -
                                      1 -
                                      activeVersionIndex]
                                  .type)
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
      ),
    );
  }

  // Content for a specific version of the question
  Widget _buildQuestionVersionContent(
      dynamic version, dynamic question, int versionIndex, int totalVersions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with gradient background - fixed height to match the other screen
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: Container(
            height: 160, // Fixed height to match the other screen
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
                // Advanced geometric pattern effect
                CustomPaint(
                  painter: UltraModernPatternPainter(
                    primaryColor: Colors.white.withOpacity(0.12),
                    secondaryColor: Colors.white.withOpacity(0.06),
                  ),
                  size: Size.infinite,
                ),

                // Radial glow effect
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

                // Type Badge - positioned consistently
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
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            Icon(_getTypeIcon(version.type),
                                color: Colors.white, size: 18),
                          ],
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

                // Points Badge - positioned consistently
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                          color: _getTypeColor(version.type).withOpacity(0.3),
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
                            Icon(Icons.star_rounded,
                                color: Colors.amber.shade100, size: 26),
                            Icon(Icons.star_rounded,
                                color: Colors.amber.shade300, size: 22),
                            Icon(Icons.star_rounded,
                                color: Colors.amber, size: 18),
                          ],
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${question.defaultPoint} poin',
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

                // Version badge - specific to previewQuestionBankSoal
                Positioned(
                  top: 70,
                  right: 20,
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

                // Title section at bottom
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
                      // Show a preview of the question content
                      Text(
                        parseHtmlString(version.question).split('\n').first,
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
                              color:
                                  _getTypeColor(version.type).withOpacity(0.6),
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
        ),

        // Content section - matching structure and padding
        Container(
          padding: EdgeInsets.fromLTRB(24, 26, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section title with accent
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
                          color: _getTypeColor(version.type).withOpacity(0.4),
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

              // Question content with consistent styling
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
                // Use a consistent height for this section to match both cards
                height: 120, // Fixed height for content area
                child: SingleChildScrollView(
                  child: Text(
                    parseHtmlString(version.question),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                      height: 1.5,
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Options Information section - consistent with other screen
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
                            color:
                                _getTypeColor(version.type).withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color:
                                _getTypeColor(version.type).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color:
                                _getTypeColor(version.type).withOpacity(0.15),
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
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '${version.options.length} Opsi',
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
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getTypeColor(version.type).withOpacity(0.1),
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

              // Space for the pagination indicators
              SizedBox(height: totalVersions > 1 ? 40 : 20),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveSelectedQuestions() async {
    try {
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 10))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.blue[50], shape: BoxShape.circle),
                  child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                          strokeWidth: 3)),
                ),
                SizedBox(height: 24),
                Text('Menyimpan Soal',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800])),
                SizedBox(height: 8),
                Text('Mohon tunggu sebentar...',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                SizedBox(height: 16),
                LinearProgressIndicator(
                    backgroundColor: Colors.blue[50],
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blue[400]!)),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
      );

      final repository = OnlineExamRepository();
      final existingQuestions =
          await repository.getOnlineExamQuestions(widget.examId);

      Map<String, Map<String, dynamic>> assignQuestions = {};
      for (var question in existingQuestions) {
        assignQuestions[question.id.toString()] = {
          'question_id': question.question_id,
          'marks': question.marks,
          'from_bank': false
        };
      }

      for (int index in _selectedQuestions) {
        final question = _filteredQuestions[index];
        // Use the active version index instead of always using the last version
        final activeVersionIndex = _getActiveVersionIndex(question.id);
        final displayIndex = question.versions.length - 1 - activeVersionIndex;
        final version = question.versions[displayIndex];

        assignQuestions[version.id.toString()] = {
          'question_id': version.id,
          'marks': question.defaultPoint,
          'from_bank': true
        };
      }

      await repository.storeOnlineExamQuestions(
        examId: widget.examId,
        classSectionId: widget.classSectionId,
        classSubjectId: widget.classSubjectId,
        assignQuestions: assignQuestions,
      );

      Get.back();

      await Get.dialog(
        Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
                SizedBox(height: 20),
                Text('Berhasil!',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Soal berhasil ditambahkan ke ujian',
                    textAlign: TextAlign.center),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.toNamed(Routes.questionOnlineExam
                        .replaceAll(':id', widget.examId.toString()));
                  },
                  child: Text('Lihat Daftar Soal',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Gagal menyimpan soal: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5));
    }
  }
}
