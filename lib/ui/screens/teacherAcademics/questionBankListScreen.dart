import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../cubits/teacherAcademics/assignment/questionBankCubit.dart';
import '../../../data/models/question.dart';

class QuestionBankListScreen extends StatefulWidget {
  @override
  _QuestionBankListScreenState createState() => _QuestionBankListScreenState();
}

class QuestionCard extends StatelessWidget {
  final Question question;
  
  const QuestionCard({Key? key, required this.question}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(question.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${question.type}'),
            Text('Version: ${question.version}'),
            Text('Points: ${question.defaultPoint}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => Get.toNamed(
                '/edit-question',
                arguments: question
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Add delete functionality
              },
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
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
      appBar: AppBar(title: Text('Question Bank')),
      body: BlocBuilder<QuestionBankCubit, QuestionBankState>(
        builder: (context, state) {
          print("Screen: Building with state - isLoading: ${state.isLoading}, questions: ${state.questions.length}"); // Debug print
          
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text('Error: ${state.error}'));
          }

          if (state.questions.isEmpty) {
            return Center(child: Text('No questions found'));
          }

          return ListView.builder(
            itemCount: state.questions.length,
            itemBuilder: (context, index) {
              final subject = state.questions[index];
              return ExpansionTile(
                title: Text(subject.subjectName),
                children: subject.questions.map((question) => 
                  QuestionCard(question: question)
                ).toList(),
              );
            },
          );
        },
      ),
    );
  }
}