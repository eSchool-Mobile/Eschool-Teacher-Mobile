import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
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

  void _addOption() {
    setState(() {
      options.add(QuestionOption(
        text: '',
        percentage: '0',
        feedback: ''
      ));
    });
  }

  void _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      try {
        if (options.isEmpty) {
          throw Exception('Please add at least one option');
        }
        // Validation logic remains same...
        
        final question = Question(
          id: '0',
          subjectId: Get.arguments?.toString() ?? '41',
          name: nameController.text.trim(),
          type: selectedType,
          defaultPoint: defaultPoint.toString(),
          question: questionController.text.trim(),
          note: noteController.text.trim(),
          options: options,
          version: '1'
        );

        context.read<QuestionBankCubit>().createQuestion(question);
        
        Get.back();
        Get.snackbar(
          'Success',
          'Question created successfully',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          borderRadius: 10,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
        );

      } catch (e) {
        Get.snackbar(
          'Error',
          e.toString(),
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          borderRadius: 10,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  Widget _buildOptionFields(int index, QuestionOption option) {
    return FadeInLeft(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Option ${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              initialValue: option.text,
              decoration: InputDecoration(
                labelText: 'Answer Text',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              onChanged: (value) => setState(() {
                options[index] = QuestionOption(
                  text: value,
                  percentage: option.percentage,
                  feedback: option.feedback
                );
              }),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: option.percentage,
                    decoration: InputDecoration(
                      labelText: 'Percentage',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    onChanged: (value) => setState(() {
                      options[index] = QuestionOption(
                        text: option.text,
                        percentage: value,
                        feedback: option.feedback
                      );
                    }),
                  ),
                ),
                if (selectedType != 'true_false')
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => options.removeAt(index)),
                  ),
              ],
            ),
            SizedBox(height: 12),
            TextFormField(
              initialValue: option.feedback,
              decoration: InputDecoration(
                labelText: 'Feedback',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              onChanged: (value) => setState(() {
                options[index] = QuestionOption(
                  text: option.text,
                  percentage: option.percentage,
                  feedback: value
                );
              }),
            ),
          ],
        ),
      ),
    );
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
              Theme.of(context).primaryColor.withOpacity(0.8),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              FadeInDown(
                duration: Duration(milliseconds: 600),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      Text(
                        'Create Question',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Form Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question Basic Info
                          FadeInUp(
                            duration: Duration(milliseconds: 800),
                            child: _buildQuestionBasicInfo(),
                          ),
                          
                          SizedBox(height: 25),
                          
                          // Question Content
                          FadeInUp(
                            duration: Duration(milliseconds: 1000),
                            child: _buildQuestionContent(),
                          ),

                          // Options Section
                          if (selectedType == 'multiple_choice' || selectedType == 'true_false') ...[
                            SizedBox(height: 25),
                            _buildOptionsSection(),
                          ],

                          SizedBox(height: 30),
                          
                          // Submit Button
                          FadeInUp(
                            duration: Duration(milliseconds: 1200),
                            child: _buildSubmitButton(),
                          ),
                          
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionBasicInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 20),
          _buildAnimatedTextField(
            controller: nameController,
            label: 'Question Name',
            icon: Icons.title,
          ),
          SizedBox(height: 15),
          _buildTypeDropdown(),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedType,
      decoration: InputDecoration(
        labelText: 'Question Type',
        prefixIcon: Icon(Icons.category, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: [
        DropdownMenuItem(value: 'multiple_choice', child: Text('Multiple Choice')),
        DropdownMenuItem(value: 'true_false', child: Text('True/False')),
      ],
      onChanged: (value) {
        setState(() {
          selectedType = value!;
          options.clear();
          if (value == 'true_false') {
            options.add(QuestionOption(text: 'True', percentage: '100', feedback: ''));
            options.add(QuestionOption(text: 'False', percentage: '0', feedback: ''));
          }
        });
      },
    );
  }

  Widget _buildQuestionContent() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question Content',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 20),
          _buildAnimatedTextField(
            controller: questionController,
            label: 'Question Text',
            icon: Icons.help_outline,
            maxLines: 3,
          ),
          SizedBox(height: 15),
          _buildAnimatedTextField(
            controller: noteController,
            label: 'Note (Optional)',
            icon: Icons.note,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            if (selectedType == 'multiple_choice')
              TextButton.icon(
                onPressed: _addOption,
                icon: Icon(Icons.add),
                label: Text('Add Option'),
              ),
          ],
        ),
        SizedBox(height: 15),
        ...options.asMap().entries.map((entry) =>
          _buildOptionFields(entry.key, entry.value)
        ).toList(),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _validateAndSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          'Create Question',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}