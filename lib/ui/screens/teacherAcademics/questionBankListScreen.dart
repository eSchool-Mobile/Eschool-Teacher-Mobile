import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import '../../../cubits/teacherAcademics/assignment/questionBankCubit.dart';
import '../../../data/models/question.dart';

class QuestionBankListScreen extends StatefulWidget {
  @override
  _QuestionBankListScreenState createState() => _QuestionBankListScreenState();
}

class QuestionCard extends StatelessWidget {
  final Question question;
  final int index;
  
  const QuestionCard({
    Key? key, 
    required this.question,
    required this.index,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getTypeColor(question.type),
              child: Text(
                question.type[0].toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              question.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Version ${question.version}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.help_outline, 'Question', question.question),
                    SizedBox(height: 8),
                    _buildInfoRow(Icons.star_outline, 'Points', question.defaultPoint),
                    SizedBox(height: 8),
                    _buildInfoRow(Icons.note_outlined, 'Note', question.note),
                    SizedBox(height: 16),
                    _buildOptionsSection(question.options),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildActionButton(
                          Icons.edit,
                          Colors.blue,
                          () => Get.toNamed(
                            Routes.editQuestionScreen, 
                            arguments: question
                          ),
                        ),
                        SizedBox(width: 8),
                        _buildActionButton(
                          Icons.delete,
                          Colors.red,
                          () {/* Delete action */},
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

  Widget _buildOptionsSection(List<QuestionOption> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Options',
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

  Widget _buildOptionItem(QuestionOption option) {
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
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(option.text),
                Text(
                  option.feedback,
                  style: TextStyle(
                    fontSize: 12,
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

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed) {
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
                icon == Icons.edit ? 'Edit' : 'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'multiple_choice':
        return Colors.blue;
      case 'essay':
        return Colors.green;
      case 'true_false':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }
}

class _QuestionBankListScreenState extends State<QuestionBankListScreen> {
  @override
  void initState() {
    super.initState();
    print("Screen: Initializing"); // Debug print
    
    // Delay to ensure context is available
    Future.microtask(() {
      context.read<QuestionBankCubit>().getQuestions(41);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: Text('Question Bank'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blue.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      floatingActionButton: BounceInUp(
        child: FloatingActionButton.extended(
          onPressed: () {
            // Pass subject_id when navigating
            final currentSubjectId = '41zzz'; // Get this from your state/context
            Get.toNamed(
              Routes.addQuestionScreen,
              arguments: currentSubjectId,
            );
          },
          label: Text('Add Question'),
          icon: Icon(Icons.add),
        ),
      ),
      body: BlocBuilder<QuestionBankCubit, QuestionBankState>(
        builder: (context, state) {
          print("Screen: Building with state - isLoading: ${state.isLoading}, questions: ${state.questions.length}"); // Debug print
          
          if (state.isLoading) {
            return _buildShimmerLoading();
          }

          if (state.error != null) {
            return _buildErrorWidget(state.error!);
          }

          if (state.questions.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: state.questions.length,
            itemBuilder: (context, index) {
              final subject = state.questions[index];
              return FadeInUp(
                delay: Duration(milliseconds: 200 * index),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(
                        subject.subjectName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      children: subject.questions.asMap().entries.map((entry) => 
                        QuestionCard(
                          question: entry.value,
                          index: entry.key,
                        )
                      ).toList(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.all(16),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
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
            Text(error),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<QuestionBankCubit>().getQuestions(41);
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeIn(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.question_answer_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Questions Yet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Start by adding your first question'),
          ],
        ),
      ),
    );
  }
}