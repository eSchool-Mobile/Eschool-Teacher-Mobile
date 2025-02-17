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
  @override
  void initState() {
    super.initState();
    // Load questions when screen opens
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
              // TODO: Implement add new question
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada soal untuk ujian ini',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement add question
                      },
                      icon: Icon(Icons.add),
                      label: Text('Tambah Soal'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: state.questions.length,
              itemBuilder: (context, index) {
                final question = state.questions[index];
                return _buildQuestionCard(question);
              },
            );
          }

          return SizedBox();
        },
      ),
    );
  }

  Widget _buildQuestionCard(QuestionOnlineExam question) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          'Soal ${question.id}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question.question),
                SizedBox(height: 8),
                _buildOption('A', question.optionA),
                _buildOption('B', question.optionB),
                _buildOption('C', question.optionC),
                _buildOption('D', question.optionD),
                Divider(),
                Text(
                  'Jawaban Benar: ${question.correctAnswer}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Nilai: ${question.marks}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String label, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label. ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
