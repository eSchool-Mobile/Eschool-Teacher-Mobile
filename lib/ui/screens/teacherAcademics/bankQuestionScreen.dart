import 'dart:convert';

import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:flutter/material.dart';
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

class _BankQuestionScreenState extends State<BankQuestionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<q.Question> _filteredQuestions = [];
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
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
      case 'short_answer': // Add this
        return Icons.short_text;
      case 'numeric': // Add this
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

  @override
  void initState() {
    super.initState();
    _loadQuestions();
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
      _loadQuestions(); // Refresh questions list
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Soal berhasil ditambahkan')),
      // );
    }
  }

  void _navigateToEditQuestion(
      q.Question question, q.QuestionVersion version) async {
    String jsonString = JsonEncoder.withIndent("  ").convert(question);

    final result = await Get.toNamed(
      Routes.editQuestionScreen,
      arguments: {
        'questionData': {
          'banksoal_soal_id': question.id,
          'subject_id': widget.subject.subject.id,
          'idBankSoal': widget.bankSoal.id,
          'name': version.name,
          'type': version.type, // Add this
          'question': version.question,
          'default_point': version.defaultPoint,
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

  // Ubah method _buildHeader()
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              // Back button with enhanced styling
              Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                onPressed: () => Get.back(),
              ),
              ),
              SizedBox(width: 16),
              // Title section with improved typography
              Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  widget.bankSoal.name,
                  style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  shadows: [
                    Shadow(
                    color: Colors.black38,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    ),
                  ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              // Add Question button with premium styling
              Container(
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                colors: [Colors.white, Colors.white.withOpacity(0.9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _navigateToAddQuestion,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                  children: [
                    Icon(
                    Icons.add_circle_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                    'Soal',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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
        ],
      ),
    );
  }

  // Ubah method build() untuk menghapus FloatingActionButton
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
                duration: Duration(milliseconds: 600),
                child: _buildHeader(),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: BlocBuilder<QuestionBankCubit, QuestionBankState>(
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
      // Hapus floatingActionButton di sini
    );
  }

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

  Widget _buildQuestionCard(q.Question question, dynamic latestVersion) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Stack(
        children: [
          // Main Card with enhanced shadow
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _getTypeColor(latestVersion.type).withOpacity(0.07),
                  blurRadius: 30,
                  offset: Offset(0, 10),
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Premium Header with Dynamic Glass Effect
                  Container(
                    height: 140, // Increased height
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getTypeColor(latestVersion.type),
                          _getTypeColor(latestVersion.type).withOpacity(0.85),
                          _getTypeColor(latestVersion.type).withOpacity(0.7),
                        ],
                        stops: [0.2, 0.6, 1.0],
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Enhanced Premium Pattern
                        CustomPaint(
                          painter: LuxuryPatternPainter(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),

                        // Light beam effect (top right)
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.4),
                                  Colors.white.withOpacity(0),
                                ],
                                stops: [0.1, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Type Badge with enhanced styling
                        Positioned(
                          top: 18,
                          left: 20,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getTypeColor(latestVersion.type)
                                      .withOpacity(0.2),
                                  blurRadius: 12,
                                  spreadRadius: -2,
                                ),
                              ],
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getTypeIcon(latestVersion.type),
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  _getTypeName(latestVersion.type),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Points Badge with premium styling
                        Positioned(
                          top: 18,
                          right: 20,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber.shade200,
                                      size: 22,
                                    ),
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                  ],
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '${latestVersion.defaultPoint} poin',
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Question Title with elegant styling
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                latestVersion.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                  letterSpacing: 0.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
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

                  // Question Content with enhanced styling
                  Container(
                    padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section title with premium styling
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
                                    _getTypeColor(latestVersion.type),
                                    _getTypeColor(latestVersion.type)
                                        .withOpacity(0.7),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getTypeColor(latestVersion.type)
                                        .withOpacity(0.3),
                                    blurRadius: 6,
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
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Question content with enhanced styling
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Text(
                            parseHtmlString(latestVersion.question),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[800],
                              height: 1.5,
                              letterSpacing: 0.2,
                              fontFamily: 'Roboto',
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        SizedBox(height: 22),

                        // Options Information with enhanced styling
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Colors.grey.shade50,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: _getTypeColor(latestVersion.type)
                                  .withOpacity(0.15),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(latestVersion.type)
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _getTypeColor(latestVersion.type)
                                        .withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: _getTypeColor(latestVersion.type),
                                  size: 22,
                                ),
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pilihan Jawaban',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${latestVersion.options.length} opsi tersedia',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: _getTypeColor(latestVersion.type)
                                    .withOpacity(0.7),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Enhanced Action Footer
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.shade100,
                          width: 1.5,
                        ),
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Question ID with premium styling
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.tag_rounded,
                                size: 16,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 6),
                              Text(
                                'ID: ${question.id}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action Buttons with enhanced styling
                        Row(
                          children: [
                            // Edit Button - Enhanced with premium styling
                            Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => _navigateToEditQuestion(question, latestVersion),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: LinearGradient(
                                      colors: [
                                        _getTypeColor(latestVersion.type).withOpacity(0.9),
                                        _getTypeColor(latestVersion.type).withOpacity(0.7),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getTypeColor(latestVersion.type).withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Edit',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 12),

                            // Delete Button - Enhanced with premium styling
                            Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => _showDeleteQuestionConfirmation(question),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
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
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.delete_outline_rounded,
                                        size: 18,
                                        color: Colors.red.shade700,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Hapus',
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          letterSpacing: 0.3,
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

          // Premium Badge (optional)
          // Positioned(
          //   top: 0,
          //   right: 30,
          //   child: Container(
          //     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          //     decoration: BoxDecoration(
          //       color: Colors.amber.shade700,
          //       borderRadius: BorderRadius.only(
          //         bottomLeft: Radius.circular(10),
          //         bottomRight: Radius.circular(10),
          //       ),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.amber.withOpacity(0.3),
          //           blurRadius: 8,
          //           offset: Offset(0, 2),
          //         ),
          //       ],
          //     ),
          //     child: Row(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         Icon(
          //           Icons.school_rounded,
          //           color: Colors.white,
          //           size: 14,
          //         ),
          //         SizedBox(width: 4),
          //         Text(
          //           'PREMIUM',
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 10,
          //             fontWeight: FontWeight.bold,
          //             letterSpacing: 0.5,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
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

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          margin: EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
              ),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildActionButtons(q.Question question, q.QuestionVersion version) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildActionButton(
            icon: Icons.edit_note,
            tooltip: 'Edit',
            onPressed: () => _navigateToEditQuestion(question, version),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
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

  void _showQuestionDetails(
      BuildContext context, q.Question question, q.QuestionVersion version) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              _buildQuestionDetails(version),
              _buildActionButtons(question, version),
            ],
          ),
        ),
      ),
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
