import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/assignment/questionBankCubit.dart';
import 'package:eschool_saas_staff/data/models/question.dart';
import 'package:get/get.dart';

class EditQuestionScreen extends StatefulWidget {
  final Question question;

  EditQuestionScreen({required this.question});

  @override
  _EditQuestionScreenState createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController questionController;
  late TextEditingController noteController;
  late String selectedType;
  late int defaultPoint;
  late List<QuestionOption> options;
  late int version;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.question.name);
    questionController = TextEditingController(text: widget.question.question);
    noteController = TextEditingController(text: widget.question.note);
    selectedType = widget.question.type;
    defaultPoint = int.parse(widget.question.defaultPoint);
    options = List.from(widget.question.options);
    version = int.parse(widget.question.version) + 1;
  }

  void _updateQuestion() async {
    if (_formKey.currentState!.validate()) {
      try {
        final question = Question(
          id: widget.question.id,
          // Get subject_id from original question
          subjectId: "41", // Hardcode for now since we know the subject_id
          name: nameController.text.trim(),
          type: selectedType,
          defaultPoint: defaultPoint.toString(),
          question: questionController.text.trim(),
          note: noteController.text.trim(),
          version: version.toString(),
          options: options.map((opt) => QuestionOption(
            text: opt.text.trim(),
            percentage: opt.percentage,
            feedback: opt.feedback.trim()
          )).toList(),
        );

        print('Update payload: ${question.toJson()}');
        
        await context.read<QuestionBankCubit>().updateQuestion(question);
        
        Get.back();
        Get.snackbar(
          'Berhasil', 
          'Soal berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Question'),
        actions: [
          TextButton(
            onPressed: _updateQuestion,
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
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
              if (selectedType == 'multiple_choice' ||
                  selectedType == 'true_false') ...[
                SizedBox(height: 16),
                Text('Options', style: Theme.of(context).textTheme.titleLarge),
                ...options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: option.text,
                          decoration: InputDecoration(
                            labelText: 'Option ${index + 1}',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Required' : null,
                          onChanged: (value) {
                            setState(() {
                              options[index] = QuestionOption(
                                  text: value,
                                  percentage: option.percentage,
                                  feedback: option.feedback);
                            });
                          },
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          initialValue: option.percentage,
                          decoration: InputDecoration(
                            labelText: 'Percentage',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Required' : null,
                          onChanged: (value) {
                            setState(() {
                              options[index] = QuestionOption(
                                  text: option.text,
                                  percentage: value,
                                  feedback: option.feedback);
                            });
                          },
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          initialValue: option.feedback,
                          decoration: InputDecoration(
                            labelText: 'Feedback',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Required' : null,
                          onChanged: (value) {
                            setState(() {
                              options[index] = QuestionOption(
                                  text: option.text,
                                  percentage: option.percentage,
                                  feedback: value);
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
                            text: '', percentage: '0', feedback: ''));
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
                    child: Text('Update Question'),
                  ),
                  onPressed: _updateQuestion,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
