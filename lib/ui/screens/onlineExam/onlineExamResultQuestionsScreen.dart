import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:html/parser.dart' show parse;
import 'package:eschool_saas_staff/cubits/questionOnlineExam/questionOnlineExamCubit.dart';
import 'package:eschool_saas_staff/data/models/questionOnlineExam.dart';
import 'package:shimmer/shimmer.dart';

class OnlineExamResultQuestionsScreen extends StatefulWidget {
  final int examId;
  final String examName;

  const OnlineExamResultQuestionsScreen(
      {Key? key, required this.examId, required this.examName})
      : super(key: key);

  @override
  State<OnlineExamResultQuestionsScreen> createState() =>
      _OnlineExamResultQuestionsScreenState();
}

class _OnlineExamResultQuestionsScreenState
    extends State<OnlineExamResultQuestionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<QuestionOnlineExam> _filteredQuestions = [];
  bool _showSearch = false;

  String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    return document.body?.text ?? htmlString;
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'multiple_choice':
        return Colors.blue;
      case 'essay':
        return Colors.green;
      case 'true_false':
        return Colors.orange;
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lihat Jawaban Siswa',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.examName}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<QuestionOnlineExam> questions) {
    _showSearch = questions.length > 5;
    if (_filteredQuestions.isEmpty) {
      _filteredQuestions = questions;
    }

    return Column(
      children: [
        if (_showSearch)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (query) => _filterQuestions(query, questions),
              decoration: const InputDecoration(
                hintText: 'Cari soal...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
            ),
            itemCount: _filteredQuestions.length,
            itemBuilder: (context, index) {
              final question = _filteredQuestions[index];
              return FadeInUp(
                duration: Duration(milliseconds: 600 + (index * 100)),
                child: _buildQuestionCard(question),
              );
            },
          ),
        ),
      ],
    );
  }

  void _filterQuestions(String query, List<QuestionOnlineExam> questions) {
    setState(() {
      _filteredQuestions = questions.where((question) {
        final titleMatch =
            question.title?.toLowerCase().contains(query.toLowerCase()) ??
                false;
        final questionMatch =
            question.question.toLowerCase().contains(query.toLowerCase());
        return titleMatch || questionMatch;
      }).toList();
    });
  }

  Widget _buildQuestionCard(QuestionOnlineExam question) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getTypeColor(question.type).withOpacity(0.8),
                    _getTypeColor(question.type).withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTypeIcon(question.type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTypeName(question.type),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber[100],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${question.marks} poin',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
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

            // Question Content
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.title ?? 'Untitled',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        height: 1.3,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[100]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                parseHtmlString(question.question),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                  letterSpacing: 0.1,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            Column(
                              children: [
                                Divider(
                                  height: 16,
                                  thickness: 1,
                                  color: Colors.grey[200],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 16,
                                      color: Colors.green[400],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${question.options.length} Opsi', // You might want to make this dynamic
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
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
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[100]!),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                    Icon(
                    Icons.remove_red_eye,
                    size: 18,
                    color: const Color(0xFF800000),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Lihat',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF800000),
                          letterSpacing: 0.3,
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
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<QuestionOnlineExamCubit>().getQuestions(widget.examId);
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
              const Color(0xFF8B0000).withOpacity(0.9),
              const Color(0xFF6B0000),
              const Color(0xFF4B0000),
              Theme.of(context).colorScheme.secondary,
            ],
            stops: const [0.2, 0.4, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<QuestionOnlineExamCubit, QuestionOnlineExamState>(
            builder: (context, state) {
              if (state is QuestionOnlineExamLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is QuestionOnlineExamSuccess) {
                return Column(
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: _buildHeader(),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: _buildContent(state.questions),
                      ),
                    ),
                  ],
                );
              }
              if (state is QuestionOnlineExamFailure) {
                return Center(child: Text(state.message));
              }
              return const Center(child: Text('No questions available'));
            },
          ),
        ),
      ),
    );
  }
}
