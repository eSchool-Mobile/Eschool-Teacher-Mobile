import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/questionOnlineExam/questionOnlineExamCubit.dart';
import 'package:eschool_saas_staff/data/models/questionOnlineExam.dart';
import 'package:get/get.dart';

class QuestionOnlineExamScreen extends StatefulWidget {
  final int examId;

  const QuestionOnlineExamScreen({
    Key? key,
    required this.examId,
  }) : super(key: key);

  @override
  State<QuestionOnlineExamScreen> createState() =>
      _QuestionOnlineExamScreenState();
}

class _QuestionOnlineExamScreenState extends State<QuestionOnlineExamScreen> {
  int? selectedBankId;

  @override
  void initState() {
    super.initState();
    context.read<QuestionOnlineExamCubit>().getQuestions(widget.examId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soal Ujian Online'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showBankSoalDialog();
            },
          ),
        ],
      ),
      body: BlocBuilder<QuestionOnlineExamCubit, QuestionOnlineExamState>(
        builder: (context, state) {
          if (state is QuestionOnlineExamLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is QuestionOnlineExamFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () => context
                        .read<QuestionOnlineExamCubit>()
                        .getQuestions(widget.examId),
                    child: Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state is QuestionOnlineExamSuccess) {
            if (state.questions.isEmpty) {
              return _buildEmptyState();
            }

            return _buildQuestionsList(state.questions);
          }

          return SizedBox();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada soal untuk ujian ini',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showBankSoalDialog(),
            icon: Icon(Icons.add),
            label: Text('Pilih Bank Soal'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList(List<QuestionOnlineExam> questions) {
    return Column(
      children: [
        _buildBankSoalSelector(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return _buildQuestionCard(question, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBankSoalSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Bank Soal Terpilih: ${selectedBankId ?? "Belum dipilih"}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: _showBankSoalDialog,
            child: Text('Ganti Bank Soal'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionOnlineExam question, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Soal $index',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (question.version != null)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.purple[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'v${question.version}',
                          style: TextStyle(color: Colors.purple[900]),
                        ),
                      ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Nilai: ${question.marks}',
                        style: TextStyle(color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pertanyaan
                Text(
                  question.question,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16),

                // Pilihan Jawaban
                _buildOption('A', question.optionA),
                _buildOption('B', question.optionB),
                _buildOption('C', question.optionC),
                _buildOption('D', question.optionD),

                Divider(height: 32),

                // Jawaban Benar
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Jawaban Benar: ${question.correctAnswer}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editQuestion(question),
                      tooltip: 'Edit Soal',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteQuestion(question),
                      tooltip: 'Hapus Soal',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String label, String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBankSoalDialog() async {
    // Load bank soal data first
    await context.read<QuestionOnlineExamCubit>().getQuestionBanks();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<QuestionOnlineExamCubit, QuestionOnlineExamState>(
          builder: (context, state) {
            if (state is QuestionBanksLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (state is QuestionBanksLoaded) {
              final banks = state.banks;

              return AlertDialog(
                title: Text('Pilih Bank Soal'),
                content: Container(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: banks.length,
                    itemBuilder: (context, index) {
                      final bank = banks[index];
                      return ListTile(
                        title: Text(bank['name'] ?? ''),
                        subtitle: Text(
                            '${(bank['soal'] as List?)?.length ?? 0} soal'),
                        onTap: () async {
                          setState(() {
                            selectedBankId = bank['id'];
                          });
                          // Load questions from selected bank
                          await context
                              .read<QuestionOnlineExamCubit>()
                              .loadQuestionsFromBank(widget.examId, bank['id']);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Batal'),
                  ),
                ],
              );
            }

            return AlertDialog(
              title: Text('Error'),
              content: Text('Gagal memuat bank soal'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Tutup'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editQuestion(QuestionOnlineExam question) {
    // TODO: Implement question editing
  }

  void _deleteQuestion(QuestionOnlineExam question) {
    // TODO: Implement question deletion
  }
}
