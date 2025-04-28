import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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

class _AddQuestionScreenState extends State<AddQuestionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _questionController = TextEditingController();
  final _noteController = TextEditingController();
  final _minValueController = TextEditingController();
  final _maxValueController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];
  final List<TextEditingController> _feedbackControllers = [];
  final List<TextEditingController> _percentageControllers = [];
  final TextEditingController _defaultPointController =
      TextEditingController(text: '100');
  String selectedType = 'multiple_choice';
  String selectedOrderType = 'numeric';

  List<bool> _correctAnswers = [];
  Map<int, int> _answerPercentages = {};

  bool _isSubmitting = false;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Define the theme colors
  final Color _primaryColor = Color(0xFF7A1E23); // Softer deep maroon
  final Color _accentColor = Color(0xFF9D3C3C); // Softer medium maroon
  final Color _highlightColor = Color(0xFFB84D4D); // Softer bright maroon
  final Color _energyColor = Color(0xFFCE6D6D); // Softer light maroon
  final Color _glowColor = Color(0xFFAF4F4F); // Softer rich maroon

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      _optionControllers.add(TextEditingController());
      _feedbackControllers.add(TextEditingController());
      _percentageControllers.add(TextEditingController());
    }
    _correctAnswers =
        List.generate(_optionControllers.length, (index) => false);
    _answerPercentages = {};

    // Add these animation initializations
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Controller for pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
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
    _isSubmitting = false;
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String toRomanNumeral(int number) {
    if (number < 1) {
      return "Angka harus lebih besar dari 0";
    }
    List<int> values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    List<String> symbols = [
      "M",
      "CM",
      "D",
      "CD",
      "C",
      "XC",
      "L",
      "XL",
      "X",
      "IX",
      "V",
      "IV",
      "I"
    ];
    String result = "";
    int num = number;
    for (int i = 0; i < values.length; i++) {
      while (num >= values[i]) {
        result += symbols[i];
        num -= values[i];
      }
    }
    while (num > 0) {
      result += "M";
      num -= 1000;
    }
    return result;
  }

  String toBaseAZ(int number) {
    if (number < 1) {
      return "Angka harus lebih besar dari 0";
    }
    String result = "";
    int num = number;
    while (num > 0) {
      int remainder = (num - 1) % 26;
      result = String.fromCharCode(65 + remainder) + result;
      num = (num - 1) ~/ 26;
    }
    return result;
  }

  List<QuestionOption> _getOptionsData() {
    List<QuestionOption> options = [];
    if (selectedType == 'true_false') {
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
      for (int i = 0; i < _optionControllers.length; i++) {
        options.add(QuestionOption(
          text: _optionControllers[i].text,
          percentage: int.tryParse(_percentageControllers[i].text) ?? 0,
          feedback: _feedbackControllers[i].text,
        ));
      }
    }
    return options;
  }

  int _selectedCorrectAnswer = 0;

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Widget _buildImageSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gambar Pertanyaan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 12),
          if (_imageFile != null) ...[
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: FileImage(_imageFile!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () => setState(() => _imageFile = null),
                ),
              ],
            ),
          ] else
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Tambah Gambar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (_isSubmitting) return;

    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isSubmitting = true;
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: Center(
                child: Card(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Menyimpan soal...')
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );

        List<int> emptyFeedbackIndexes = [];
        for (int i = 0; i < _feedbackControllers.length; i++) {
          if (_feedbackControllers[i].text.trim().isEmpty) {
            emptyFeedbackIndexes.add(i + 1);
          }
        }

        if (emptyFeedbackIndexes.isNotEmpty) {
          Navigator.pop(context);
          setState(() {
            _isSubmitting = false;
          });

          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Peringatan'),
                content: Text(
                    'Umpan Balik untuk opsi ${emptyFeedbackIndexes.join(", ")} wajib diisi'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          return;
        }

        final options = _getOptionsData();

        await context.read<QuestionBankCubit>().createQuestion(
              banksoalId: widget.bankSoalId,
              subjectId: widget.subjectId,
              name: _nameController.text.trim(),
              type: selectedType,
              orderType: selectedOrderType,
              defaultPoint: int.parse(_defaultPointController.text),
              question: _questionController.text.trim(),
              note: _noteController.text.trim(),
              options: options,
              image: _imageFile,
            );

        Navigator.pop(context);
        Get.back(result: true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Soal berhasil ditambahkan!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.green.shade400,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 4,
          ),
        );
      } catch (e) {
        Navigator.pop(context);
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Gagal membuat soal, mohon periksa koneksi internet anda dan coba lagi"),
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
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              _primaryColor,
              Color(0xFF5A2223), // Softer deeper maroon
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAnimatedHeader(),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _glowColor.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: Offset(0, -5),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: Offset(0, -10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(20),
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            FadeInUp(
                              duration: Duration(milliseconds: 800),
                              child: _buildQuestionInfoCard(),
                            ),
                            SizedBox(height: 20),
                            _buildQuestionTypeSelector(),
                            SizedBox(height: 20),
                            if (selectedType == 'multiple_choice')
                              _buildMultipleChoiceOrder(),
                            if (selectedType == 'multiple_choice')
                              SizedBox(height: 20),
                            _buildAnswerOptionsCard(),
                            SizedBox(height: 30),
                            _buildImageSection(),
                            SizedBox(height: 30),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionInfoCard() {
    return Container(
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _glowColor.withOpacity(0.08),
            spreadRadius: 5,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor, _accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 12),
                Text(
                  'Informasi Soal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // Content area
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name field
                _buildAnimatedFormField(
                  controller: _nameController,
                  label: 'Nama Soal',
                  icon: Icons.title_rounded,
                  hint: 'Masukkan nama soal',
                ),
                SizedBox(height: 20),

                // Question field
                _buildAnimatedFormField(
                  controller: _questionController,
                  label: 'Pertanyaan',
                  icon: Icons.help_outline_rounded,
                  hint: 'Masukkan pertanyaan lengkap',
                  maxLines: null,
                  minLines: 3,
                ),
                SizedBox(height: 20),

                // Note field
                _buildAnimatedFormField(
                  controller: _noteController,
                  label: 'Catatan (Opsional)',
                  icon: Icons.notes_rounded,
                  hint: 'Tambahkan catatan jika diperlukan',
                  maxLines: 2,
                  isOptional: true,
                ),
                SizedBox(height: 20),

                // Points field
                _buildAnimatedFormField(
                  controller: _defaultPointController,
                  label: 'Poin Bawaan',
                  icon: Icons.stars_rounded,
                  hint: 'Masukkan poin',
                  keyboardType: TextInputType.number,
                  helperText: 'Nilai maksimal untuk soal ini',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Poin Bawaan harus diisi';
                    }
                    final point = int.tryParse(value);
                    if (point == null || point <= 0) {
                      return 'Masukkan nilai yang valid';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _updateAllPointsBasedOnPercentages();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptionsCard() {
    return FadeInUp(
      duration: Duration(milliseconds: 1000),
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _glowColor.withOpacity(0.08),
              spreadRadius: 5,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Styled header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_highlightColor, _energyColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.question_answer_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Pengaturan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  // Display type badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedType == 'multiple_choice'
                              ? Icons.check_circle_outline
                              : selectedType == 'essay'
                                  ? Icons.edit_note
                                  : selectedType == 'true_false'
                                      ? Icons.rule
                                      : selectedType == 'short_answer'
                                          ? Icons.short_text
                                          : Icons.numbers,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 5),
                        Text(
                          selectedType == 'multiple_choice'
                              ? 'Pilihan Ganda'
                              : selectedType == 'essay'
                                  ? 'Essay'
                                  : selectedType == 'true_false'
                                      ? 'Benar/Salah'
                                      : selectedType == 'short_answer'
                                          ? 'Jawaban Singkat'
                                          : 'Numerik',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Instructions section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selectedType == 'multiple_choice'
                          ? 'Tambahkan pilihan jawaban dan tandai jawaban yang benar'
                          : selectedType == 'true_false'
                              ? 'Pilih jawaban yang benar (Benar atau Salah)'
                              : 'Tambahkan jawaban yang diterima untuk soal ini',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Options area with appropriate padding
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedType == 'multiple_choice') ...[
                    ...List.generate(
                      _optionControllers.length,
                      (index) => _buildMultipleChoiceOptionEnhanced(index),
                    ),
                    _buildAddOptionButtonEnhanced(),
                  ] else if (selectedType == 'true_false') ...[
                    _buildTrueFalseOptionEnhanced(0, 'Benar'),
                    _buildTrueFalseOptionEnhanced(1, 'Salah'),
                  ] else ...[
                    _buildEssayOptionEnhanced(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleChoiceOptionEnhanced(int index) {
    // Get the appropriate prefix based on selected order type
    String prefix = selectedOrderType == 'roman_uppercase'
        ? toRomanNumeral(index + 1).toUpperCase()
        : selectedOrderType == 'roman_lowercase'
            ? toRomanNumeral(index + 1).toLowerCase()
            : selectedOrderType == 'alphabet_uppercase'
                ? toBaseAZ(index + 1).toUpperCase()
                : selectedOrderType == 'alphabet_lowercase'
                    ? toBaseAZ(index + 1).toLowerCase()
                    : (index + 1).toString();

    bool isCorrect = _correctAnswers[index];

    return FadeInLeft(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isCorrect ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isCorrect ? Colors.green.shade300 : Colors.grey.shade200,
            width: isCorrect ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.07),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Option header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green.shade100.withOpacity(0.5)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: isCorrect
                        ? Colors.green.shade200
                        : Colors.grey.shade200,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCorrect
                          ? Colors.green
                          : _primaryColor.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Text(
                        "$prefix",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isCorrect ? Colors.white : _primaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isCorrect ? 'Jawaban Benar' : 'Pilihan Jawaban',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isCorrect
                            ? Colors.green.shade700
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  if (_optionControllers.length > 2)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade400,
                      ),
                      onPressed: () => _removeOption(index),
                      tooltip: 'Hapus pilihan jawaban',
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                ],
              ),
            ),

            // Option content
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text input
                  TextFormField(
                    controller: _optionControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Teks Jawaban',
                      prefixIcon: Icon(
                        Icons.text_fields_rounded,
                        color: _primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
                  ),

                  SizedBox(height: 16),

                  // Correct answer selection
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _correctAnswers[index],
                          onChanged: (value) {
                            setState(() {
                              if (value!) {
                                // Reset all checkboxes first
                                for (int i = 0;
                                    i < _correctAnswers.length;
                                    i++) {
                                  _correctAnswers[i] = false;
                                  _percentageControllers[i].text = "0";
                                }
                                // Then set this one
                                _correctAnswers[index] = true;
                                _percentageControllers[index].text = "100";
                              } else {
                                _correctAnswers[index] = false;
                                _percentageControllers[index].text = "0";
                              }
                            });
                          },
                          activeColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Text(
                          'Tandai sebagai jawaban benar',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Feedback input
                  TextFormField(
                    controller: _feedbackControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Umpan Balik untuk jawaban ini',
                      prefixIcon: Icon(
                        Icons.comment_outlined,
                        color: _primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      helperText: '* Wajib diisi',
                      helperStyle: TextStyle(color: Colors.red),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Umpan Balik tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrueFalseOptionEnhanced(int index, String text) {
    bool isSelected = _selectedCorrectAnswer == index;

    return FadeInLeft(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.green.shade300 : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.07),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Option header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.green.shade100.withOpacity(0.5)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? Colors.green.shade200
                        : Colors.grey.shade200,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    text == 'Benar'
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: isSelected
                        ? Colors.green.shade700
                        : Colors.grey.shade700,
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected
                          ? Colors.green.shade700
                          : Colors.grey.shade700,
                    ),
                  ),
                  if (isSelected) ...[
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Jawaban Benar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Option content
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selection control
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: index,
                          groupValue: _selectedCorrectAnswer,
                          onChanged: (value) {
                            setState(() {
                              _selectedCorrectAnswer = value!;
                              // Update percentages for true/false options
                              _percentageControllers[0].text =
                                  value == 0 ? "100" : "0";
                              _percentageControllers[1].text =
                                  value == 1 ? "100" : "0";
                            });
                          },
                          activeColor: Colors.green,
                        ),
                        Text(
                          'Tandai sebagai jawaban benar',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Feedback input
                  TextFormField(
                    controller: _feedbackControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Umpan Balik',
                      prefixIcon: Icon(
                        Icons.comment_outlined,
                        color: _primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      helperText: '* Wajib diisi',
                      helperStyle: TextStyle(color: Colors.red),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Umpan Balik tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEssayOptionEnhanced() {
    return Column(
      children: [
        ...List.generate(
          _optionControllers.length,
          (index) => FadeInLeft(
            delay: Duration(milliseconds: 100 * index),
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.07),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Option header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                selectedType == 'essay'
                                    ? Icons.edit_note_rounded
                                    : selectedType == 'short_answer'
                                        ? Icons.short_text_rounded
                                        : Icons.numbers_rounded,
                                color: _primaryColor,
                                size: 18,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              selectedType == 'essay'
                                  ? 'Jawaban Essay'
                                  : selectedType == 'short_answer'
                                      ? 'Jawaban Singkat'
                                      : 'Jawaban Numerik',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: _primaryColor,
                              ),
                            ),
                          ],
                        ),
                        if (_optionControllers.length > 1)
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: Colors.red.shade400),
                            onPressed: () => _removeAnswerOption(index),
                            tooltip: 'Hapus jawaban ini',
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                      ],
                    ),
                  ),

                  // Option content
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Answer text field
                        TextFormField(
                          controller: _optionControllers[index],
                          style: TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            labelText: selectedType == 'short_answer'
                                ? 'Jawaban Singkat'
                                : selectedType == 'numeric'
                                    ? 'Jawaban Numerik'
                                    : 'Jawaban Essay',
                            prefixIcon: Icon(
                              selectedType == 'short_answer'
                                  ? Icons.short_text
                                  : selectedType == 'numeric'
                                      ? Icons.numbers
                                      : Icons.edit_note,
                              color: _primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          keyboardType: selectedType == 'numeric'
                              ? TextInputType.number
                              : TextInputType.multiline,
                          inputFormatters: selectedType == 'numeric'
                              ? [FilteringTextInputFormatter.digitsOnly]
                              : null,
                          maxLines: null,
                          minLines: selectedType == 'essay' ? 3 : 1,
                          textInputAction: selectedType == 'essay'
                              ? TextInputAction.newline
                              : TextInputAction.done,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Wajib diisi' : null,
                        ),

                        SizedBox(height: 16),

                        // Percentage field
                        TextFormField(
                          controller: _percentageControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Persentase Nilai',
                            prefixIcon:
                                Icon(Icons.percent, color: _primaryColor),
                            suffixText: '%',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Wajib diisi' : null,
                        ),

                        SizedBox(height: 16),

                        // Feedback field
                        TextFormField(
                          controller: _feedbackControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Umpan Balik',
                            prefixIcon: Icon(Icons.comment_outlined,
                                color: _primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            helperText: '*Wajib diisi',
                            helperStyle: TextStyle(color: Colors.red),
                          ),
                          maxLines: null,
                          minLines: 2,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Umpan Balik tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (selectedType != 'true_false') _buildAddAnswerButtonEnhanced(),
      ],
    );
  }

  Widget _buildAddOptionButtonEnhanced() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 8),
        child: InkWell(
          onTap: _addOption,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: _primaryColor.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: _primaryColor,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Tambah Pilihan Jawaban',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddAnswerButtonEnhanced() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 8),
        child: InkWell(
          onTap: _addAnswerOption,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: _primaryColor.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: _primaryColor,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Tambah Jawaban',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFormField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    String? hint,
    int? maxLines = 1,
    int? minLines,
    bool isOptional = false,
    String? helperText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with icon
        Padding(
          padding: EdgeInsets.only(left: 2, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: _primaryColor),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _primaryColor,
                ),
              ),
              if (isOptional)
                Text(
                  ' (Opsional)',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
        // Input field with animation
        FadeInLeft(
          duration: Duration(milliseconds: 300),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            minLines: minLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              helperText: helperText,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _primaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: validator ??
                (value) {
                  if (!isOptional && (value == null || value.isEmpty)) {
                    return '$label harus diisi';
                  }
                  return null;
                },
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: FadeInUp(
        duration: Duration(milliseconds: 600),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isSubmitting ? null : _submitForm,
              borderRadius: BorderRadius.circular(15),
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isSubmitting) ...[
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                    ],
                    Text(
                      _isSubmitting ? 'Memproses...' : 'Simpan Soal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (!_isSubmitting) ...[
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 22,
                      ).animate(onPlay: (controller) {
                        controller.repeat(reverse: true);
                      }).slideX(
                        begin: 0,
                        end: 0.3,
                        duration: Duration(milliseconds: 1000),
                        curve: Curves.easeInOut,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleChoiceOrder() {
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
              'Tipe Urutan',
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
                  value: selectedOrderType,
                  items: [
                    _buildDropdownItem(
                        'roman_uppercase', 'Romawi Kapital', null),
                    _buildDropdownItem('roman_lowercase', 'Romawi', null),
                    _buildDropdownItem('numeric', 'Angka', null),
                    _buildDropdownItem(
                        'alphabet_uppercase', 'Alfabet Kapital', null),
                    _buildDropdownItem('alphabet_lowercase', 'Alfabet', null),
                  ],
                  onChanged: (value) => _onOrderTypeChanged(value!),
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
      String value, String label, IconData? icon) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          if (icon != null)
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

  void _onOrderTypeChanged(String type) {
    setState(() {
      selectedOrderType = type;
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
          _optionControllers.add(TextEditingController());
          _feedbackControllers.add(TextEditingController());
          _percentageControllers.add(TextEditingController());
          _correctAnswers = List.generate(1, (index) => false);
          break;
      }
    });
  }

  void _addAnswerOption() {
    if (selectedType == 'essay' ||
        selectedType == 'short_answer' ||
        selectedType == 'numeric') {
      setState(() {
        _optionControllers.add(TextEditingController());
        _feedbackControllers.add(TextEditingController());
        _percentageControllers.add(TextEditingController());
        _correctAnswers.add(false);
      });
    }
  }

  void _removeAnswerOption(int index) {
    if (_optionControllers.length > 1) {
      setState(() {
        _optionControllers.removeAt(index);
        _feedbackControllers.removeAt(index);
        _percentageControllers.removeAt(index);
        _correctAnswers.removeAt(index);
      });
    }
  }

  void _updateAllPointsBasedOnPercentages() {
    final defaultPoint = int.tryParse(_defaultPointController.text) ?? 100;
    for (int i = 0; i < _percentageControllers.length; i++) {
      final percentage = int.tryParse(_percentageControllers[i].text) ?? 0;
      final point = (defaultPoint * percentage / 100).round();
    }
  }

  // Add these helper methods
  Widget _buildGlowingIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12),
              boxShadow: [
                BoxShadow(
                  color: _highlightColor
                      .withOpacity(0.1 + 0.1 * _pulseAnimation.value),
                  blurRadius: 12 * (1 + _pulseAnimation.value),
                  spreadRadius: 2 * _pulseAnimation.value,
                )
              ],
              border: Border.all(
                color: Colors.white
                    .withOpacity(0.1 + 0.05 * _pulseAnimation.value),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.15),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: CircleBorder(),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return SlideInDown(
      duration: Duration(milliseconds: 800),
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            // Back button with smaller padding
            _buildGlowingIconButton(
              Icons.arrow_back_rounded,
              () {
                HapticFeedback.mediumImpact();
                Get.back();
              },
            ),

            SizedBox(width: 16),

            // Title and subtitle in column
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tambah Soal',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: 0.5,
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
                    'Buat soal baru untuk bank soal',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDropdownEnhanced() {
    // Map of question types with their details
    final questionTypes = {
      'multiple_choice': {
        'icon': Icons.check_circle_outline_rounded,
        'label': 'Pilihan Ganda',
      },
      'essay': {
        'icon': Icons.edit_note_rounded,
        'label': 'Essay',
      },
      'true_false': {
        'icon': Icons.rule_rounded,
        'label': 'Benar/Salah',
      },
      'short_answer': {
        'icon': Icons.short_text_rounded,
        'label': 'Jawaban Singkat',
      },
      'numeric': {
        'icon': Icons.numbers_rounded,
        'label': 'Numerik',
      },
    };

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonFormField<String>(
        value: selectedType,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: _primaryColor),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: questionTypes.entries.map((type) {
          return DropdownMenuItem<String>(
            value: type.key,
            child: Row(
              children: [
                Icon(
                  type.value['icon'] as IconData,
                  color: _primaryColor,
                  size: 22,
                ),
                SizedBox(width: 12),
                Text(
                  type.value['label'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            _onTypeChanged(newValue);
          }
        },
      ),
    );
  }

  Widget _buildQuestionTypeSelector() {
    return FadeInUp(
      duration: Duration(milliseconds: 900),
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _glowColor.withOpacity(0.08),
              spreadRadius: 5,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Styled header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_accentColor, _highlightColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.category_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Tipe Soal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            // Type selection area
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih tipe soal yang sesuai:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 15),
                  _buildTypeDropdownEnhanced(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
