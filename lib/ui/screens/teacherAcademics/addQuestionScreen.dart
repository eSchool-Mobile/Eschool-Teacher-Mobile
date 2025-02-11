import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../../cubits/teacherAcademics/assignment/questionBankCubit.dart';
import 'package:eschool_saas_staff/data/models/question.dart';
import '../../../data/models/subjectQuestion.dart';

class AddQuestionScreen extends StatefulWidget {
  final int bankSoalId;
  final int subjectId;

  const AddQuestionScreen({
    Key? key,
    required this.bankSoalId,
    required this.subjectId,
  }) : super(key: key);

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _questionController = TextEditingController();
  final _noteController = TextEditingController();
  final _minValueController = TextEditingController();
  final _maxValueController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];
  final List<TextEditingController> _feedbackControllers = [];
  final List<TextEditingController> _percentageControllers = [];
  String selectedType = 'multiple_choice';

  // Update state variables
  List<bool> _correctAnswers = [];
  Map<int, int> _answerPercentages = {};

  @override
  void initState() {
    super.initState();
    // Initialize 3 options
    for (int i = 0; i < 3; i++) {
      _optionControllers.add(TextEditingController());
      _feedbackControllers.add(TextEditingController());
      _percentageControllers.add(TextEditingController());
    }
    // Initialize correct answers array sesuai jumlah opsi awal
    _correctAnswers =
        List.generate(_optionControllers.length, (index) => false);
    // Initialize default percentages
    _answerPercentages = {};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _questionController.dispose();
    _noteController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    for (var controller in _feedbackControllers) {
      controller.dispose();
    }
    for (var controller in _percentageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<QuestionOption> _getOptionsData() {
    List<QuestionOption> options = [];

    if (selectedType == 'true_false') {
      // True/False specific logic
      options = [
        QuestionOption(
          text: 'Benar',
          percentage: _selectedCorrectAnswer == 0 ? 100 : 0,
          feedback: _feedbackControllers[0].text,
        ),
        QuestionOption(
          text: 'Salah',
          percentage: _selectedCorrectAnswer == 1 ? 100 : 0,
          feedback: _feedbackControllers[1].text,
        ),
      ];
    } else {
      // Other question types
      for (int i = 0; i < _optionControllers.length; i++) {
        options.add(QuestionOption(
          text: _optionControllers[i].text,
          percentage: _correctAnswers[i] ? 100 : 0,
          feedback: _feedbackControllers[i].text,
        ));
      }
    }

    return options;
  }

  int _selectedCorrectAnswer = 0;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final options = _getOptionsData();

        print("Submitting question type: $selectedType"); // Debug
        print("Options data: $options"); // Debug

        // Validate based on question type
        switch (selectedType) {
          case 'true_false':
            // Check if exactly one option is selected as correct
            final correctAnswers =
                options.where((opt) => opt.percentage == 100).length;
            if (correctAnswers != 1) {
              throw Exception('Pilih satu jawaban yang benar (Benar/Salah)');
            }
            break;

          case 'multiple_choice':
            if (!options.any((opt) => opt.percentage == 100)) {
              throw Exception('Pilih salah satu jawaban yang benar');
            }
            break;

          case 'essay':
            if (options.isEmpty || options[0].text.isEmpty) {
              throw Exception('Masukkan jawaban essay');
            }
            break;

          case 'short_answer':
            if (options.isEmpty || options[0].text.isEmpty) {
              throw Exception('Masukkan jawaban singkat');
            }
            break;

          case 'numeric':
            if (options.isEmpty || options[0].text.isEmpty) {
              throw Exception('Masukkan jawaban numerik');
            }
            break;
        }

        await context.read<QuestionBankCubit>().createQuestion(
              banksoalId: widget.bankSoalId,
              subjectId: widget.subjectId,
              name: _nameController.text.trim(),
              type: selectedType,
              defaultPoint: 10,
              question: _questionController.text.trim(),
              note: _noteController.text.trim(),
              options: options,
            );

        Get.back(result: true);
      } catch (e) {
        print("Error submitting form: $e"); // Debug
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                        'Tambah Soal',
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
                        children: [
                          // Question Info Card
                          FadeInUp(
                            duration: Duration(milliseconds: 800),
                            child: _buildQuestionInfoCard(),
                          ),

                          SizedBox(height: 20),

                          // Question Type Selector
                          _buildQuestionTypeSelector(),

                          SizedBox(height: 20),

                          // Answer Options Card
                          _buildAnswerOptionsCard(),

                          SizedBox(height: 30),

                          // Submit Button
                          FadeInUp(
                            duration: Duration(milliseconds: 1200),
                            child: _buildSubmitButton(),
                          ),
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

  Widget _buildQuestionInfoCard() {
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
            'Informasi Soal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 20),
          _buildAnimatedTextField(
            controller: _nameController,
            label: 'Nama Soal',
            icon: Icons.title,
          ),
          SizedBox(height: 15),
          _buildAnimatedTextField(
            controller: _questionController,
            label: 'Pertanyaan',
            icon: Icons.help_outline,
            maxLines: 3,
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Catatan (Opsional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptionsCard() {
    return FadeInUp(
      duration: Duration(milliseconds: 1000),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengaturan Jawaban',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(height: 20),

            // Different layouts based on question type
            if (selectedType == 'multiple_choice') ...[
              ...List.generate(_optionControllers.length,
                  (index) => _buildMultipleChoiceOption(index)),
              Center(
                child: TextButton.icon(
                  icon: Icon(Icons.add_circle),
                  label: Text('Tambah Pilihan Jawaban'),
                  onPressed: _addOption,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ] else if (selectedType == 'true_false') ...[
              _buildTrueFalseOption(0, "Benar"),
              _buildTrueFalseOption(1, "Salah"),
            ] else if (selectedType == 'essay') ...[
              _buildEssayOption(),
            ] else if (selectedType == 'short_answer') ...[
              _buildShortAnswerOption(),
            ] else if (selectedType == 'numeric') ...[
              _buildNumericOption(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEssayOption() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: _getOptionDecoration(false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _optionControllers[0], // Add this
            decoration: InputDecoration(
              labelText: 'Jawaban',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            maxLines: 3,
            validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _percentageControllers[0],
            decoration: InputDecoration(
              labelText: 'Persentase Nilai',
              suffixText: '%',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _feedbackControllers[0],
            decoration: InputDecoration(
              labelText: 'Feedback',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  BoxDecoration _getOptionDecoration(bool isSelected) {
    return BoxDecoration(
      color: isSelected ? Colors.green.withOpacity(0.1) : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: isSelected ? Colors.green : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildShortAnswerOption() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: _getOptionDecoration(false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _optionControllers[0], // Add this
            decoration: InputDecoration(
              labelText: 'Jawaban',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _percentageControllers[0],
            decoration: InputDecoration(
              labelText: 'Persentase Nilai',
              suffixText: '%',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _feedbackControllers[0],
            decoration: InputDecoration(
              labelText: 'Feedback',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildNumericOption() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: _getOptionDecoration(false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _optionControllers[0], // Add this
            decoration: InputDecoration(
              labelText: 'Jawaban',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _percentageControllers[0],
            decoration: InputDecoration(
              labelText: 'Persentase Nilai',
              suffixText: '%',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _feedbackControllers[0],
            decoration: InputDecoration(
              labelText: 'Feedback',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerTypeCard() {
    if (!['multiple_choice', 'true_false'].contains(selectedType)) {
      return SizedBox.shrink();
    }

    return FadeInUp(
      duration: Duration(milliseconds: 1000),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selectedType == 'multiple_choice'
                      ? Icons.check_circle
                      : Icons.rule,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(width: 10),
                Text(
                  selectedType == 'multiple_choice'
                      ? 'Pilihan Ganda'
                      : 'Benar/Salah',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              selectedType == 'multiple_choice'
                  ? 'Tambahkan pilihan jawaban dan pilih satu jawaban yang benar'
                  : 'Pilih jawaban yang benar antara Benar atau Salah',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),
            ...List.generate(
              _optionControllers.length,
              (index) => _buildOptionFieldByType(index),
            ),
            if (selectedType == 'multiple_choice') ...[
              SizedBox(height: 15),
              Center(
                child: TextButton.icon(
                  icon: Icon(Icons.add_circle),
                  label: Text('Tambah Pilihan Jawaban'),
                  onPressed: _addOption,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionFieldByType(int index) {
    if (selectedType == 'true_false') {
      return _buildTrueFalseOption(index, index == 0 ? "Benar" : "Salah");
    }
    return _buildMultipleChoiceOption(index);
  }

  Widget _buildTrueFalseOption(int index, String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _selectedCorrectAnswer == index
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _selectedCorrectAnswer == index
              ? Colors.green
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Radio<int>(
                value: index,
                groupValue: _selectedCorrectAnswer,
                onChanged: (value) {
                  setState(() {
                    _selectedCorrectAnswer = value!;
                  });
                },
              ),
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _selectedCorrectAnswer == index
                      ? Colors.green
                      : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _percentageControllers[index],
            decoration: InputDecoration(
              labelText: 'Persentase Nilai',
              suffixText: '%',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _feedbackControllers[index],
            decoration: InputDecoration(
              labelText: 'Feedback',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceOption(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _correctAnswers[index]
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _correctAnswers[index] ? Colors.green : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                String.fromCharCode(65 + index), // A, B, C, D...
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildAnimatedTextField(
                  controller: _optionControllers[index],
                  label: 'Pilihan Jawaban',
                  icon: Icons.radio_button_unchecked,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: _correctAnswers[index],
                onChanged: (value) {
                  setState(() {
                    _correctAnswers[index] = value!;
                    if (value) {
                      // Set default percentage for correct answer
                      _answerPercentages[index] = 100;
                    } else {
                      _answerPercentages.remove(index);
                    }
                  });
                },
              ),
              Text('Jawaban Benar'),
              if (_correctAnswers[index]) ...[
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    initialValue:
                        _answerPercentages[index]?.toString() ?? '100',
                    decoration: InputDecoration(
                      labelText: 'Persentase',
                      suffixText: '%',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      int? percentage = int.tryParse(value);
                      if (percentage == null ||
                          percentage < 0 ||
                          percentage > 100) {
                        return 'Invalid percentage';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _answerPercentages[index] = int.tryParse(value) ?? 100;
                      });
                    },
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 10),
          _buildAnimatedTextField(
            controller: _feedbackControllers[index],
            label: 'Feedback untuk jawaban ini',
            icon: Icons.comment_outlined,
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
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      validator: (value) =>
          value?.isEmpty ?? true ? 'Bidang ini wajib diisi' : null,
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: Text(
          'Simpan Soal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionTypeSelector() {
    return FadeInUp(
      duration: Duration(milliseconds: 800),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipe Soal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  value: selectedType,
                  items: [
                    _buildDropdownItem(
                        'multiple_choice', 'Pilihan Ganda', Icons.check_circle),
                    _buildDropdownItem('essay', 'Essay', Icons.edit_note),
                    _buildDropdownItem('true_false', 'Benar/Salah', Icons.rule),
                    _buildDropdownItem(
                        'short_answer', 'Jawaban Singkat', Icons.short_text),
                    _buildDropdownItem('numeric', 'Numerik', Icons.numbers),
                  ],
                  onChanged: (value) => _onTypeChanged(value!),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(
      String value, String label, IconData icon) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary),
          SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
      _feedbackControllers.add(TextEditingController());
      _percentageControllers.add(TextEditingController());
      // Tambahkan elemen false baru ke _correctAnswers
      _correctAnswers.add(false);
    });
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers.removeAt(index);
      _feedbackControllers.removeAt(index);
      _percentageControllers.removeAt(index);
      _correctAnswers.removeAt(index);
      _answerPercentages.remove(index);

      // Update answer percentages indexes
      Map<int, int> newPercentages = {};
      _answerPercentages.forEach((key, value) {
        if (key > index) {
          newPercentages[key - 1] = value;
        } else if (key < index) {
          newPercentages[key] = value;
        }
      });
      _answerPercentages = newPercentages;
    });
  }

  void _onTypeChanged(String type) {
    setState(() {
      selectedType = type;
      _optionControllers.clear();
      _feedbackControllers.clear();
      _percentageControllers.clear();

      switch (type) {
        case 'true_false':
          _optionControllers.addAll([
            TextEditingController(text: 'Benar'),
            TextEditingController(text: 'Salah'),
          ]);
          _feedbackControllers.addAll([
            TextEditingController(),
            TextEditingController(),
          ]);
          _percentageControllers.addAll([
            TextEditingController(),
            TextEditingController(),
          ]);
          _correctAnswers = List.generate(2, (index) => false);
          break;
        case 'multiple_choice':
          for (int i = 0; i < 4; i++) {
            _optionControllers.add(TextEditingController());
            _feedbackControllers.add(TextEditingController());
            _percentageControllers.add(TextEditingController());
          }
          _correctAnswers = List.generate(4, (index) => false);
          break;
        default:
          // For essay, short_answer, and numeric types
          _optionControllers.add(TextEditingController());
          _feedbackControllers.add(TextEditingController());
          _percentageControllers.add(TextEditingController());
          _correctAnswers = List.generate(1, (index) => false);
          break;
      }
    });
  }

  Widget _buildOptionField(int index) {
    return FadeInLeft(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opsi ${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _optionControllers[index],
              decoration: InputDecoration(
                labelText: 'Teks Jawaban',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _percentageControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Persentase Nilai',
                      suffixText: '%',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      helperText: 'Total persentase harus 100%',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Wajib diisi';
                      int? value = int.tryParse(v!);
                      if (value == null || value < 0 || value > 100) {
                        return 'Nilai harus 0-100';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 12),
                if (selectedType == 'multiple_choice' && index > 1)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeOption(index),
                  ),
              ],
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _feedbackControllers[index],
              decoration: InputDecoration(
                labelText: 'Feedback',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                helperText: 'Feedback akan ditampilkan setelah menjawab',
              ),
              maxLines: 2,
              validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
            ),
          ],
        ),
      ),
    );
  }

  // Add validation method
  bool _validatePercentages() {
    int total = 0;
    for (var controller in _percentageControllers) {
      total += int.tryParse(controller.text) ?? 0;
    }
    return total == 100;
  }

  Widget _buildAnswerSection() {
    switch (selectedType) {
      case 'essay':
        return _buildEssayAnswer();
      case 'true_false':
        return _buildTrueFalseAnswers();
      case 'short_answer':
        return _buildShortAnswer();
      case 'numeric':
        return _buildNumericAnswer();
      case 'multiple_choice':
        return _buildMultipleChoiceAnswers();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildEssayAnswer() {
    return FadeInUp(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kriteria Penilaian Essay', style: _headerStyle()),
            SizedBox(height: 16),
            TextFormField(
              controller: _percentageControllers[0],
              decoration: InputDecoration(
                labelText: 'Nilai Maksimum',
                suffixText: '%',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _feedbackControllers[0],
              decoration: InputDecoration(
                labelText: 'Feedback',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortAnswer() {
    return FadeInUp(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jawaban yang Benar', style: _headerStyle()),
            SizedBox(height: 16),
            TextFormField(
              controller: _optionControllers[0],
              decoration: InputDecoration(
                labelText: 'Jawaban',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _percentageControllers[0],
              decoration: InputDecoration(
                labelText: 'Persentase Nilai',
                suffixText: '%',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _feedbackControllers[0],
              decoration: InputDecoration(
                labelText: 'Feedback',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumericAnswer() {
    return FadeInUp(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rentang Jawaban yang Benar', style: _headerStyle()),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minValueController,
                    decoration: InputDecoration(
                      labelText: 'Nilai Minimum',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxValueController,
                    decoration: InputDecoration(
                      labelText: 'Nilai Maksimum',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _percentageControllers[0],
              decoration: InputDecoration(
                labelText: 'Persentase Nilai',
                suffixText: '%',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _feedbackControllers[0],
              decoration: InputDecoration(
                labelText: 'Feedback',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrueFalseAnswers() {
    return FadeInUp(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Jawaban yang Benar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Benar'),
              leading: Radio<bool>(
                value: true,
                groupValue: _selectedCorrectAnswer == 0,
                onChanged: (bool? value) {
                  setState(() {
                    _selectedCorrectAnswer = value! ? 0 : 1;
                  });
                },
              ),
            ),
            ListTile(
              title: Text('Salah'),
              leading: Radio<bool>(
                value: true,
                groupValue: _selectedCorrectAnswer == 1,
                onChanged: (bool? value) {
                  setState(() {
                    _selectedCorrectAnswer = value! ? 1 : 0;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleChoiceAnswers() {
    return FadeInUp(
      duration: Duration(milliseconds: 1000),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selectedType == 'multiple_choice'
                      ? Icons.check_circle
                      : Icons.rule,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(width: 10),
                Text(
                  selectedType == 'multiple_choice'
                      ? 'Pilihan Ganda'
                      : 'Benar/Salah',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              selectedType == 'multiple_choice'
                  ? 'Tambahkan pilihan jawaban dan pilih satu jawaban yang benar'
                  : 'Pilih jawaban yang benar antara Benar atau Salah',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),
            ...List.generate(
              _optionControllers.length,
              (index) => _buildOptionFieldByType(index),
            ),
            if (selectedType == 'multiple_choice') ...[
              SizedBox(height: 15),
              Center(
                child: TextButton.icon(
                  icon: Icon(Icons.add_circle),
                  label: Text('Tambah Pilihan Jawaban'),
                  onPressed: _addOption,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 5,
          blurRadius: 10,
        ),
      ],
    );
  }

  TextStyle _headerStyle() {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.secondary,
    );
  }
}
