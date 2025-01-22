import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../cubits/teacherAcademics/assignment/questionBankCubit.dart';
import 'package:eschool_saas_staff/data/models/question.dart';

class AddQuestionScreen extends StatefulWidget {
  @override
  _AddQuestionScreenState createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final questionController = TextEditingController();
  final noteController = TextEditingController();
  String selectedType = 'multiple_choice';
  int defaultPoint = 10;
  List<QuestionOption> options = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Question')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Question Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: 'Question Type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'multiple_choice',
                  'essay',
                  'true_false',
                  'short_answer',
                  'numeric'
                ].map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.replaceAll('_', ' ').toUpperCase()),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                    if (value == 'true_false') {
                      options = [
                        QuestionOption(
                          text: 'True',
                          percentage: '100',
                          feedback: 'Correct'
                        ),
                        QuestionOption(
                          text: 'False',
                          percentage: '0',
                          feedback: 'Incorrect'
                        ),
                      ];
                    }
                  });
                },
              ),
              
              SizedBox(height: 16),
              TextFormField(
                controller: questionController,
                decoration: InputDecoration(
                  labelText: 'Question Text',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              
              SizedBox(height: 16),
              TextFormField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),

              if (selectedType == 'multiple_choice' || selectedType == 'true_false') ...[
                SizedBox(height: 16),
                Text('Options', style: Theme.of(context).textTheme.titleLarge),
                ...options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: option.text,
                            decoration: InputDecoration(
                              labelText: 'Option ${index + 1}',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                options[index] = QuestionOption(
                                  text: value,
                                  percentage: option.percentage,
                                  feedback: option.feedback
                                );
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        if (selectedType != 'true_false')
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                options.removeAt(index);
                              });
                            },
                          ),
                      ],
                    ),
                  );
                }).toList(),
                
                if (selectedType == 'multiple_choice')
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Add Option'),
                    onPressed: () {
                      setState(() {
                        options.add(QuestionOption(
                          text: '',
                          percentage: '0',
                          feedback: ''
                        ));
                      });
                    },
                  ),
              ],
              
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Save Question'),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final question = Question(
                        id: '0', // Set initial ID for new question
                        version: '1', // Set initial version for new question
                        subjectId: Get.arguments,
                        name: nameController.text,
                        type: selectedType,
                        defaultPoint: defaultPoint.toString(),
                        question: questionController.text,
                        note: noteController.text,
                        options: options,
                      );
                      
                      context.read<QuestionBankCubit>()
                        .createQuestion(question);
                      Get.back();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}