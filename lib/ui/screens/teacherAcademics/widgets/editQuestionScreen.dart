import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/assignment/questionBankCubit.dart';
import 'package:eschool_saas_staff/data/models/question.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Question'),
        actions: [
          TextButton(
            child: Text(
              'Version $version',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: null,
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
                    child: Text('Update Question'),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final question = Question(
                        id: widget.question.id,
                        subjectId: widget.question.subjectId,
                        name: nameController.text,
                        type: selectedType,
                        defaultPoint: defaultPoint.toString(),
                        question: questionController.text,
                        note: noteController.text,
                        options: options,
                        version: version.toString()
                      );
                      
                      context.read<QuestionBankCubit>()
                        .updateQuestion(int.parse(widget.question.id), question);
                      Navigator.pop(context);
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