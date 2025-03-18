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
  final TextEditingController _defaultPointController =
      TextEditingController(text: '100');
  String selectedType = 'multiple_choice';
  String selectedOrderType = 'numeric';

  // Update state variables
  List<bool> _correctAnswers = [];
  Map<int, int> _answerPercentages = {};

  // Tambahkan variabel untuk mengontrol status pengiriman
  bool _isSubmitting = false;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

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
    // Reset flag saat widget di-dispose
    _isSubmitting = false;
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

  // Modifikasi _submitForm
  void _submitForm() async {
    // Cek apakah sedang dalam proses pengiriman
    if (_isSubmitting) {
      return; // Jika sedang mengirim, abaikan klik berikutnya
    }

    if (_formKey.currentState!.validate()) {
      try {
        // Set flag pengiriman menjadi true
        setState(() {
          _isSubmitting = true;
        });

        // Tampilkan loading indicator
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

        // Check for empty feedback fields
        List<int> emptyFeedbackIndexes = [];
        for (int i = 0; i < _feedbackControllers.length; i++) {
          if (_feedbackControllers[i].text.trim().isEmpty) {
            emptyFeedbackIndexes.add(i + 1);
          }
        }

        if (emptyFeedbackIndexes.isNotEmpty) {
          // Tutup dialog loading
          Navigator.pop(context);
          // Reset flag pengiriman
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
              image: _imageFile, // Add image file
            );

        // Tutup dialog loading
        Navigator.pop(context);

        // Kembali ke halaman sebelumnya dengan status berhasil
        Get.back(result: true);

        // Tampilkan snackbar sukses
        // Show auto-dismissing success snackbar
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
        // Tutup dialog loading jika terjadi error
        Navigator.pop(context);

        // Reset flag pengiriman
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

                          if (selectedType == 'multiple_choice')
                            _buildMultipleChoiceOrder(),
                          if (selectedType == 'multiple_choice')
                            SizedBox(height: 20),

                          // Answer Options Card
                          _buildAnswerOptionsCard(),

                          SizedBox(height: 30),

                          // Image Section
                          _buildImageSection(),

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
          // Tambahkan field untuk Poin Bawaan
          TextFormField(
            controller: _defaultPointController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Poin Bawaan',
              prefixIcon: Icon(Icons.stars),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              helperText: 'Nilai maksimal untuk soal ini',
            ),
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
              // Update semua nilai persentase ketika poin bawaan berubah
              setState(() {
                _updateAllPointsBasedOnPercentages();
              });
            },
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
            ] else if (selectedType == 'true_false') ...[
              _buildTrueFalseOption(0, 'Benar'),
              _buildTrueFalseOption(1, 'Salah'),
            ] else if (selectedType == 'numeric') ...[
              // Gunakan _buildNumericOption() untuk tipe soal numerik
              _buildNumericOption(),
            ] else ...[
              // Untuk essay dan short_answer
              _buildEssayOption(),
            ],
          ],
        ),
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

  Widget _buildEssayOption() {
    return Column(
      children: [
        ...List.generate(
          _optionControllers.length,
          (index) => FadeInLeft(
            delay: Duration(milliseconds: 100 * index),
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jawaban ${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 16,
                            ),
                          ),
                          if (_optionControllers.length > 1)
                            IconButton(
                              icon: Icon(Icons.delete_outline),
                              color: Colors.red.shade400,
                              onPressed: () => _removeAnswerOption(index),
                              tooltip: 'Hapus jawaban ini',
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
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
                          // Input Jawaban
                          AnimatedSize(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: TextFormField(
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
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
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
                              validator: (v) =>
                                  v?.isEmpty ?? true ? 'Wajib diisi' : null,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Persentase Nilai
                          TextFormField(
                            controller: _percentageControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Persentase Nilai',
                              prefixIcon: Icon(Icons.percent),
                              suffixText: '%',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (v) =>
                                v?.isEmpty ?? true ? 'Wajib diisi' : null,
                          ),
                          SizedBox(height: 16),

                          // Feedback
                          TextFormField(
                            controller: _feedbackControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Umpan Balik',
                              prefixIcon: Icon(Icons.comment_outlined),
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
        ),
        // Tombol Tambah Jawaban
        if (selectedType != 'true_false')
          Center(
            child: TextButton.icon(
              icon: Icon(Icons.add_circle),
              label: Text('Tambah Jawaban'),
              onPressed: _addAnswerOption,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildShortAnswerOption() {
    // Gunakan tampilan yang sama dengan essay
    return _buildEssayOption();
  }

  // Modifikasi _buildNumericOption()
  Widget _buildNumericOption() {
    return Column(
      children: [
        ...List.generate(
          _optionControllers.length,
          (index) => FadeInLeft(
            delay: Duration(milliseconds: 100 * index),
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jawaban ${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 16,
                            ),
                          ),
                          if (_optionControllers.length > 1)
                            IconButton(
                              icon: Icon(Icons.delete_outline),
                              color: Colors.red.shade400,
                              onPressed: () => _removeAnswerOption(index),
                              tooltip: 'Hapus jawaban ini',
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
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
                          // Input Jawaban Numerik
                          TextFormField(
                            controller: _optionControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Jawaban Numerik',
                              prefixIcon: Icon(
                                Icons.numbers,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (v) =>
                                v?.isEmpty ?? true ? 'Wajib diisi' : null,
                          ),
                          SizedBox(height: 16),

                          // Persentase Nilai
                          TextFormField(
                            controller: _percentageControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Persentase Nilai',
                              prefixIcon: Icon(Icons.percent),
                              suffixText: '%',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (v) =>
                                v?.isEmpty ?? true ? 'Wajib diisi' : null,
                          ),
                          SizedBox(height: 16),

                          // Feedback
                          TextFormField(
                            controller: _feedbackControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Umpan Balik',
                              prefixIcon: Icon(Icons.comment_outlined),
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
        ),

        // Tombol Tambah Jawaban
        Center(
          child: TextButton.icon(
            icon: Icon(Icons.add_circle),
            label: Text('Tambah Jawaban'),
            onPressed: _addAnswerOption,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // Method removed as it was a duplicate of the one below

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
          // TextFormField(
          //   controller: _percentageControllers[index],
          //   decoration: InputDecoration(
          //     labelText: 'Persentase Nilai',
          //     suffixText: '%',
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //   ),
          //   keyboardType: TextInputType.number,
          // ),
          // SizedBox(height: 12),
          TextFormField(
            controller: _feedbackControllers[index],
            decoration: InputDecoration(
              labelText: 'Umpan Balik',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
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
              // Add delete button here
              if (_optionControllers.length > 2) // Minimum 2 options required
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  onPressed: () => _removeOption(index),
                  tooltip: 'Hapus pilihan jawaban',
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
                    controller: _percentageControllers[index],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Persentase Nilai',
                      suffixText: '%',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Wajib diisi';
                      final percentage = int.tryParse(value);
                      if (percentage == null ||
                          percentage < 0 ||
                          percentage > 100) {
                        return 'Persentase harus 0-100';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        final percentage = int.tryParse(value) ?? 0;
                        final defaultPoint =
                            int.tryParse(_defaultPointController.text) ?? 100;
                        final point = (defaultPoint * percentage / 100).round();
                        // Update nilai aktual
                        _answerPercentages[index] = percentage;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                // Tampilkan nilai aktual
                Text(
                  '${((int.tryParse(_defaultPointController.text) ?? 100) * (int.tryParse(_percentageControllers[index].text) ?? 0) / 100).round()} poin',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _feedbackControllers[index],
            decoration: InputDecoration(
              labelText: 'Umpan Balik untuk jawaban ini',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              helperText: '*Umpan Balik Wab diisi',
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
                      _isSubmitting ? 'Memproses...' : 'Simpan',
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


  DropdownMenuItem<String> _buildDropdownItem(String value, String label, IconData? icon) {
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
                labelText: 'Umpan Balik',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
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
                labelText: 'Umpan Balik',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 3,
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
                labelText: 'Umpan Balik',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                    // Tambahkan konfigurasi keyboard numerik
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
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
                    // Tambahkan konfigurasi keyboard numerik
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
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
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _feedbackControllers[0],
              decoration: InputDecoration(
                labelText: 'Umpan Balik',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
      // Keep at least one answer option
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
      // Update nilai di controller atau state yang menyimpan nilai aktual
    }
  }

  void _showOverlayMessage(
      {required BuildContext context, required String message}) {
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
