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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Soal berhasil ditambahkan')),
      );
    }
  }

  void _navigateToEditQuestion(
      q.Question question, q.QuestionVersion version) async {
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
        // Update the question in the local state
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
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bankSoal.name,
                      style: TextStyle(
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
                    SizedBox(height: 4),
                    Text(
                      'Bank Soal',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // Tambah Tombol di sini
              ElevatedButton.icon(
                onPressed: _navigateToAddQuestion,
                icon: Icon(Icons.edit_note, size: 20),
                label: Text('Tambah Soal'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (query) => _filterQuestions(query, questions),
              decoration: InputDecoration(
                hintText: 'Cari soal...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        Expanded(
          child: _filteredQuestions.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  physics: BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _filteredQuestions.length,
                  itemBuilder: (context, index) {
                    final question = _filteredQuestions[index];
                    final latestVersion = question.versions.last;
                    return FadeInUp(
                      duration: Duration(milliseconds: 600 + (index * 100)),
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
            // Gradient Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getTypeColor(latestVersion.type).withOpacity(0.8),
                    _getTypeColor(latestVersion.type).withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Type Icon Badge
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTypeIcon(latestVersion.type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),

                  // Type & Points
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTypeName(latestVersion.type),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                              SizedBox(width: 4),
                              Text(
                                '${latestVersion.defaultPoint} poin',
                                style: TextStyle(
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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Title with elegant ellipsis
                    Text(
                      latestVersion.name,
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

                    SizedBox(height: 10),

                    // Question Preview in contained box
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[100]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Question preview text
                            Expanded(
                              child: Text(
                                parseHtmlString(latestVersion.question),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                  letterSpacing: 0.1,
                                ),
                                maxLines: 4, // Show more preview lines
                                overflow:
                                    TextOverflow.fade, // Smoother fade effect
                              ),
                            ),

                            // Options count with divider
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
                                    Icon(Icons.check_circle_outline,
                                        size: 16, color: Colors.green[400]),
                                    SizedBox(width: 6),
                                    Text(
                                      '${latestVersion.options.length} Opsi',
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Point: ${latestVersion.defaultPoint}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.edit,
                        tooltip: 'Edit Soal',
                        onPressed: () =>
                            _navigateToEditQuestion(question, latestVersion),
                      ),
                      SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        tooltip: 'Hapus Soal',
                        onPressed: () =>
                            _showDeleteQuestionConfirmation(question),
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

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
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
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          margin: EdgeInsets.only(bottom: 16),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
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
          Icon(Icons.question_mark_rounded, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada soal',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
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

  Widget _buildModalActionButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              SizedBox(width: 4),
              Text(
                icon == Icons.edit ? 'Edit' : 'Hapus',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
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
                      content: Text("Tidak dapat menghapus soal, mohon periksa koneksi internet anda dan coba lagi"),
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
