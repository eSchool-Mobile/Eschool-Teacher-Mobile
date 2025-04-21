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
import 'dart:ui'; // Untuk BackdropFilter

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
  Map<int, Set<int>> _selectedQuestions = {};
  late AnimationController _selectionController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _hasShownTooltip = false;

  // New properties for swipeable cards
  Map<int, PageController> _pageControllers = {};
  Map<int, int> _activeVersionIndices = {};
  bool _hasShownSwipeGuide = false;
  // Define the border radius for cards
  final BorderRadius cardBorderRadius = BorderRadius.circular(28);

  // New color variables
  final Color _primaryColor = Color(0xFF7A1E23); // Softer deep maroon
  final Color _accentColor = Color(0xFF9D3C3C); // Softer medium maroon
  final Color _highlightColor = Color(0xFFB84D4D); // Softer bright maroon
  final Color _energyColor = Color(0xFFCE6D6D); // Softer light maroon
  final Color _glowColor = Color(0xFFAF4F4F); // Softer rich maroon

  @override
  void initState() {
    super.initState();
    _selectionController =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _fetchQuestions();
    _searchController.addListener(_filterQuestionsLocally);
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _pulseController.dispose();
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
    final questionId = question.id;
    final activeVersionIndex = _getActiveVersionIndex(questionId);
    final versionId =
        question.versions[question.versions.length - 1 - activeVersionIndex].id;

    // Check if this specific version is already selected
    bool isVersionSelected = false;
    if (_selectedQuestions.containsKey(index)) {
      isVersionSelected =
          _selectedQuestions[index]!.contains(activeVersionIndex);
    }

    if (isVersionSelected) {
      // Unselect this version
      setState(() {
        _selectedQuestions[index]!.remove(activeVersionIndex);
        if (_selectedQuestions[index]!.isEmpty) {
          _selectedQuestions.remove(index);
        }
      });
    } else {
      // Select this version
      setState(() {
        if (!_selectedQuestions.containsKey(index)) {
          _selectedQuestions[index] = {};
        }
        _selectedQuestions[index]!.add(activeVersionIndex);
      });
    }
  }

  bool _isVersionSelected(int questionIndex, int versionIndex) {
    if (!_selectedQuestions.containsKey(questionIndex)) {
      return false;
    }
    return _selectedQuestions[questionIndex]!.contains(versionIndex);
  }

  bool _isVersionDisabled(dynamic question, int versionIndex) {
    // If the question doesn't have a versions array or the index is out of bounds, return false
    if (question.versions == null || versionIndex >= question.versions.length) {
      return false;
    }

    // Calculate the actual version index in the versions array (since it's reversed in the UI)
    final displayIndex = question.versions.length - 1 - versionIndex;
    final version = question.versions[displayIndex];

    // Check if this specific version is already added to the exam
    return version.selected == true;
  }

  Widget _buildHeader() {
    return SlideInDown(
      duration: Duration(milliseconds: 800),
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            // Back button with smaller padding
            _buildGlowingIconButton(
              Icons.arrow_back_rounded,
              () {
                HapticFeedback.mediumImpact();
                Get.back();
              },
              _highlightColor,
            ),

            SizedBox(width: 16),

            // Title and subtitle in column
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.bank.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Bank Soal',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons in a row - optional based on functionality needed
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Help button with icon only
                _buildCircleButton(
                  icon: Icons.help_outline,
                  onTap: () {
                    Get.snackbar(
                      'Bantuan',
                      'Ketuk kartu soal untuk memilih dan tambahkan ke ujian',
                      snackPosition: SnackPosition.BOTTOM,
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

  Widget _buildGlowingIconButton(
      IconData icon, VoidCallback onTap, Color highlightColor) {
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
                  color:
                      _glowColor.withOpacity(0.1 + 0.1 * _pulseAnimation.value),
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

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.15),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: CircleBorder(),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              _primaryColor,
              Color(
                  0xFF5A2223), // Softer deeper maroon, same as in onlineExamScreen
            ],
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
              : Stack(
                  children: [
                    ListView.builder(
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
                                  Icon(Icons.swipe, color: Color(0xFF8B0000)),
                                  SizedBox(width: 12.0),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Geser kanan atau kiri untuk melihat versi soal lain',
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          'Beberapa soal memiliki beberapa versi yang dapat dilihat',
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12.0),
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

  Widget _buildSwipeableQuestionCard(dynamic question, int index) {
    final int questionVersionsCount = question.versions.length;
    final PageController pageController = _getPageController(question.id);
    final int activeVersionIndex = _getActiveVersionIndex(question.id);

    // Check if this specific version is selected
    bool isSelected = _selectedQuestions.containsKey(index) &&
        _selectedQuestions[index]!.contains(activeVersionIndex);

    // Check if this specific version is disabled
    bool isVersionDisabled = _isVersionDisabled(question, activeVersionIndex);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Stack(
        children: [
          // Main card dan PageView
          AnimatedContainer(
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
                      ? Theme.of(context).colorScheme.secondary.withOpacity(0.3)
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
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.4,
                  maxHeight: MediaQuery.of(context).size.height * 0.63,
                ),
                child: PageView.builder(
                  controller: pageController,
                  physics: const BouncingScrollPhysics(),
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
                  itemBuilder: (context, vIndex) {
                    final displayIndex = questionVersionsCount - 1 - vIndex;
                    final version = question.versions[displayIndex];

                    // Cek apakah versi ini terkunci
                    final bool thisVersionDisabled =
                        _isVersionDisabled(question, vIndex);

                    return AnimatedBuilder(
                      animation: pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (pageController.position.hasContentDimensions) {
                          value = pageController.page! - vIndex;
                          value = (1 - (value.abs() * 0.3)).clamp(0.85, 1.0);
                        }

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
                            child: Stack(
                              children: [
                                // Konten soal
                                _buildQuestionVersionContent(version, question,
                                    vIndex, questionVersionsCount),

                                // Overlay langsung dalam PageView item dengan border radius
                                if (thisVersionDisabled)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.5),
                                        // Gradient overlay untuk efek visual yang lebih menarik
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.grey.withOpacity(0.6),
                                            Colors.grey.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 1.5, sigmaY: 1.5),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white
                                                      .withOpacity(0.15),
                                                ),
                                                child: Icon(Icons.lock,
                                                    color: Colors.white,
                                                    size: 32),
                                              ),
                                              SizedBox(height: 16),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  'Versi soal ini sudah ditambahkan',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
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
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // Layer untuk menangkap tap (tidak mengganggu swipe)
          Positioned.fill(
            child: Stack(
              children: [
                // Layer transparan untuk mengambil gestur tap
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      print(
                          'Tap detected on question $index, version $activeVersionIndex');
                      // Tambahkan umpan balik haptic untuk memastikan tap terdeteksi
                      HapticFeedback.mediumImpact();

                      if (isVersionDisabled) {
                        Get.snackbar(
                          'Versi Soal Sudah Ditambahkan',
                          'Versi soal ini sudah ada dalam ujian',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                          margin: EdgeInsets.all(16),
                          borderRadius: 8,
                          duration: Duration(seconds: 2),
                        );
                      } else {
                        setState(() {
                          _toggleQuestionSelection(index);
                        });
                      }
                    },
                    // Gunakan translucent untuk memastikan tap ditangkap dengan baik
                    behavior: HitTestBehavior.translucent,
                  ),
                ),
              ],
            ),
          ),

          // Indicator for selected version
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
        ],
      ),
    );
  }

  Widget _buildQuestionVersionContent(
      dynamic version, dynamic question, int versionIndex, int totalVersions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section - using AspectRatio for consistent sizing
        AspectRatio(
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                            '${question.defaultPoint} poin',
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
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        ),

        // Content section with improved layout
        Container(
          padding: EdgeInsets.fromLTRB(24, 26, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question content header
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

              // Question content
              SizedBox(height: 18),
              Container(
                width: double.infinity,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Options section
              SizedBox(height: 24),
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
                    // Stacked circles with icon
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

                    // Options text
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

              // Version indicators - moved from Positioned widget to here
              if (totalVersions > 1)
                Container(
                  margin: EdgeInsets.only(top: 24),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalVersions, (index) {
                      // Change the active detection logic
                      final isActive = index == versionIndex;
                      return GestureDetector(
                        onTap: () {
                          _getPageController(question.id).animateToPage(
                            index, // Directly use index instead of inverting it
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

              // Small spacer at the end
              SizedBox(height: 20),
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

      // Process all selected questions with their specific versions
      _selectedQuestions.forEach((questionIndex, selectedVersions) {
        final question = _filteredQuestions[questionIndex];

        // For each selected version of this question
        for (int versionIndex in selectedVersions) {
          // Convert from UI index to actual version index
          final displayIndex = question.versions.length - 1 - versionIndex;
          final version = question.versions[displayIndex];

          assignQuestions[version.id.toString()] = {
            'question_id': version.id,
            'marks': question.defaultPoint,
            'from_bank': true
          };
        }
      });

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
