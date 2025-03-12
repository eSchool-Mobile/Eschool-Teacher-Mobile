import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/assignment/questionBankCubit.dart';
import 'package:eschool_saas_staff/data/models/question.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EditQuestionScreen extends StatefulWidget {
  final Map<String, dynamic>? questionData;

  const EditQuestionScreen({Key? key, this.questionData}) : super(key: key);

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController questionController;
  late TextEditingController pointController;
  late TextEditingController noteController;
  late String selectedType;
  late int idBankSoal;
  List<Map<String, dynamic>> options = [];
  late int version;

  dynamic? _imageFile;
  final ImagePicker _picker = ImagePicker();

  void _loadImage() async {
    _imageFile = await Api.fetchImg(widget.questionData?["image"]);
    setState(() {}); // Perbarui UI setelah gambar dimuat
  }

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.questionData?['name'] ?? '');
    questionController =
        TextEditingController(text: widget.questionData?['question'] ?? '');
    pointController = TextEditingController(
        text: widget.questionData?['default_point']?.toString() ?? '100');
    noteController =
        TextEditingController(text: widget.questionData?['note'] ?? '');
    idBankSoal = widget.questionData?['idBankSoal'];
    selectedType = widget.questionData?['type'] ?? 'multiple_choice';
    version = 1;

    print("RIEL");

    String jsonString =
        JsonEncoder.withIndent("  ").convert(widget.questionData);

    for (var line in jsonString.split("\n")) {
      print(line);
    }

    if (widget.questionData?["image"] != null) {
      _loadImage();
    }

    if (widget.questionData?['options'] != null) {
      options =
          List<Map<String, dynamic>>.from(widget.questionData!['options']);
    } else {
      // Inisialisasi dengan 2 opsi untuk multiple choice
      if (selectedType == 'multiple_choice') {
        options = List.generate(
            2,
            (index) => {
                  'text': '',
                  'percentage': 0,
                  'feedback': '',
                });
      } else {
        options = _getDefaultOptionsForType(selectedType);
      }
    }
  }

  List<Map<String, dynamic>> _getDefaultOptionsForType(String type) {
    switch (type) {
      case 'true_false':
        return [
          {'text': 'Benar', 'percentage': 0, 'feedback': ''},
          {'text': 'Salah', 'percentage': 0, 'feedback': ''},
        ];
      case 'essay':
      case 'short_answer':
      case 'numeric':
        return [
          {'text': '', 'percentage': 100, 'feedback': ''},
        ];
      case 'multiple_choice':
      default:
        return [
          {'text': '', 'percentage': 0, 'feedback': ''},
          {'text': '', 'percentage': 0, 'feedback': ''},
        ];
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    questionController.dispose();
    pointController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _onTypeChanged(String? value) {
    if (value != null) {
      setState(() {
        selectedType = value;
      });
    }
  }

  void _addOption() {
    setState(() {
      options.add({
        'text': '',
        'percentage': 0,
        'feedback': '',
      });
    });
  }

  void _addAnswerOption() {
    setState(() {
      // Sesuaikan logika penambahan opsi berdasarkan tipe soal
      switch (selectedType) {
        case 'essay':
        case 'short_answer':
        case 'numeric':
          options.add({
            'text': '',
            'percentage': 0,
            'feedback': '',
          });
          break;
        case 'multiple_choice':
          // Logika untuk pilihan ganda tetap sama
          options.add({
            'text': '',
            'percentage': 0,
            'feedback': '',
          });
          break;
        case 'true_false':
          // Tidak perlu menambah opsi untuk true/false
          break;
      }
    });
  }

  void _removeAnswerOption(int index) {
    if (options.length > 2) {
      setState(() {
        // Simpan nilai persentase sebelum menghapus opsi
        bool wasCorrectAnswer = options[index]['percentage'] == 100;

        // Hapus opsi
        options.removeAt(index);

        // Jika opsi yang dihapus adalah jawaban benar
        if (wasCorrectAnswer && options.isNotEmpty) {
          // Reset persentase ke opsi pertama
          options[0]['percentage'] = 100;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Minimal harus ada 2 pilihan jawaban'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_isSubmitting) return;

      setState(() {
        _isSubmitting = true;
      });

      try {
        await Future.delayed(Duration(seconds: 2));

        try {
          await context.read<QuestionBankCubit>().updateQuestion(
                banksoalSoalId: widget.questionData!['banksoal_soal_id'],
                subjectId: widget.questionData!['subject_id'],
                bankSoalId: idBankSoal,
                name: nameController.text.trim(),
                type: selectedType,
                defaultPoint: int.parse(pointController.text),
                question: questionController.text.trim(),
                note: noteController.text.trim(),
                image: _imageFile,
                options: options
                    .map((opt) => QuestionOption(
                          text: opt['text'].toString(),
                          percentage: int.parse(opt['percentage'].toString()),
                          feedback: opt['feedback'].toString(),
                        ))
                    .toList(),
              );

          Get.back(result: {
            'success': true,
            'updatedData': {
              'id': widget.questionData!['banksoal_soal_id'],
              'defaultPoint': int.parse(pointController.text),
            }
          });

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
                      'Soal berhasil diperbarui!',
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

          // Add slight delay before popping
          Future.delayed(Duration(milliseconds: 2200), () {
            if (context.mounted) {
              Get.back(result: true); 
            }
          });
        } catch (e) {
          if (!e.toString().contains('validation.exists') ||
              !e.toString().toLowerCase().contains('updated')) {
            Get.snackbar(
              'Error',
              "Gagal mengedit pertanyaan, periksa koneksi anda dan coba lagi",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

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
                        'Edit Soal',
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

                          Container(
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
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
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: _imageFile != null
                                              ? (_imageFile is File
                                                  ? Image.file(
                                                      _imageFile as File,
                                                      fit: BoxFit.cover)
                                                  : FutureBuilder<Uint8List>(
                                                      future:
                                                          (_imageFile as XFile)
                                                              .readAsBytes(),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return Center(
                                                              child:
                                                                  CircularProgressIndicator());
                                                        }
                                                        if (snapshot.hasError ||
                                                            !snapshot.hasData) {
                                                          return Center(
                                                              child: Icon(
                                                                  Icons.error));
                                                        }
                                                        return Image.memory(
                                                            snapshot.data!,
                                                            fit: BoxFit.cover);
                                                      },
                                                    ))
                                              : null,
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.close,
                                              color: Colors.red),
                                          onPressed: () =>
                                              setState(() => _imageFile = null),
                                        ),
                                      ],
                                    ),
                                  ] else
                                    InkWell(
                                      onTap: _pickImage,
                                      child: Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                  Icons
                                                      .add_photo_alternate_outlined,
                                                  size: 40,
                                                  color: Colors.grey),
                                              SizedBox(height: 8),
                                              Text(
                                                'Tambah Gambar',
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              )),

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
            controller: nameController,
            label: 'Nama Soal',
            icon: Icons.title,
          ),
          SizedBox(height: 15),
          _buildAnimatedTextField(
            controller: questionController,
            label: 'Pertanyaan',
            icon: Icons.help_outline,
            maxLines: 3,
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: noteController,
            decoration: InputDecoration(
              labelText: 'Catatan (Opsional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            maxLines: 2,
            // Remove validator here
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: pointController,
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
              setState(() {
                _updateOptionsPoints();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionTypeSelector() {
    return FadeInUp(
      duration: Duration(milliseconds: 900),
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
            _buildTypeDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
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
        // Ubah null menjadi _onTypeChanged untuk mengaktifkan perubahan tipe soal
        onChanged: (String? newValue) {
          if (newValue != null && newValue != selectedType) {
            // Tampilkan dialog konfirmasi
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Konfirmasi Perubahan'),
                  content: Text(
                      'Mengubah tipe soal akan mereset semua pilihan jawaban yang sudah ada. Anda yakin ingin melanjutkan?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          selectedType = newValue;
                          // Reset opsi sesuai tipe soal baru
                          options = _getDefaultOptionsForType(newValue);
                        });
                      },
                      child: Text('Ya'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
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
              ...options
                  .asMap()
                  .entries
                  .map((entry) => _buildMultipleChoiceOption(entry.key))
                  .toList(),
              _buildAddOptionButton(),
            ] else if (selectedType == 'true_false') ...[
              _buildTrueFalseOption(0, 'Benar'),
              _buildTrueFalseOption(1, 'Salah'),
            ] else ...[
              // Untuk essay, short_answer, dan numeric menggunakan tampilan yang sama
              _buildEssayOption(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionField(int index) {
    if (selectedType == 'true_false') {
      String label = index == 0 ? 'Benar' : 'Salah';
      return _buildTrueFalseOption(index, label);
    }
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
            if (selectedType == 'multiple_choice')
              TextFormField(
                initialValue: options[index]['text'],
                decoration: InputDecoration(
                  labelText: 'Teks Jawaban',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
                onChanged: (value) {
                  setState(() {
                    options[index]['text'] = value;
                  });
                },
              ),
            SizedBox(height: 12),
            TextFormField(
              initialValue: options[index]['percentage'].toString(),
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
              onChanged: (value) {
                setState(() {
                  options[index]['percentage'] = int.tryParse(value) ?? 0;
                });
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              initialValue: options[index]['feedback'],
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
              onChanged: (value) => setState(() {
                options[index]['feedback'] = value;
              }),
            ),
            if (selectedType == 'multiple_choice' && index > 1)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: Icon(Icons.delete, color: Colors.red),
                  label: Text('Hapus', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    setState(() {
                      options.removeAt(index);
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleChoiceOption(int index) {
    return FadeInLeft(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: options[index]['percentage'] == 100
              ? Colors.green.withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: options[index]['percentage'] == 100
                ? Colors.green
                : Colors.grey.shade300,
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
                  child: TextFormField(
                    initialValue: options[index]['text'],
                    decoration: InputDecoration(
                      labelText: 'Pilihan Jawaban',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
                    onChanged: (value) {
                      setState(() {
                        options[index]['text'] = value;
                      });
                    },
                  ),
                ),
                // Ubah kondisi menjadi > 2
                if (options.length > 2) // Minimal 2 opsi jawaban
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeAnswerOption(index),
                    tooltip: 'Hapus pilihan jawaban',
                  ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: options[index]['percentage'] == 100,
                  onChanged: (value) {
                    setState(() {
                      options[index]['percentage'] = value! ? 100 : 0;
                    });
                  },
                ),
                Text('Jawaban Benar'),
                if (options[index]['percentage'] == 100) ...[
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: options[index]['percentage'].toString(),
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
                          options[index]['percentage'] =
                              int.tryParse(value) ?? 100;
                        });
                      },
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: options[index]['feedback'],
              decoration: InputDecoration(
                labelText: 'Umpan Balik untuk jawaban ini',
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
              onChanged: (value) => setState(() {
                options[index]['feedback'] = value;
              }),
            ),
            if (index > 1) SizedBox.shrink(),
          ],
        ),
      ),
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
                      _isSubmitting ? 'Memproses...' : 'Update Soal',
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

  DropdownMenuItem<String> _buildDropdownItem(
      String value, String label, IconData icon) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey),
          SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildTrueFalseOption(int index, String text) {
    return FadeInLeft(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Radio<int>(
                  value: index,
                  groupValue:
                      options.indexWhere((opt) => opt['percentage'] == 100),
                  onChanged: (value) {
                    setState(() {
                      for (var i = 0; i < options.length; i++) {
                        options[i]['percentage'] = i == value ? 100 : 0;
                      }
                    });
                  },
                ),
                Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            // TextFormField(
            //   initialValue: options[index]['percentage'].toString(),
            //   decoration: InputDecoration(
            //     labelText: 'Persentase Nilai',
            //     suffixText: '%',
            //     border:
            //         OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            //     filled: true,
            //     fillColor: Colors.grey.shade50,
            //   ),
            //   keyboardType: TextInputType.number,
            //   validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
            //   onChanged: (value) => setState(() {
            //     options[index]['percentage'] = int.tryParse(value) ?? 0;
            //   }),
            // ),
            // SizedBox(height: 12),
            TextFormField(
              initialValue: options[index]['feedback'],
              decoration: InputDecoration(
                labelText: 'Umpan Balik',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
              onChanged: (value) => setState(() {
                options[index]['feedback'] = value;
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEssayOption() {
    return Column(
      children: [
        ...List.generate(
          options.length,
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
                          if (options.length > 1)
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
                          // Input Jawaban dengan AnimatedSize
                          AnimatedSize(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: TextFormField(
                              initialValue: options[index]['text'],
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
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
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
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              keyboardType: selectedType == 'numeric'
                                  ? TextInputType.number
                                  : TextInputType.multiline,
                              inputFormatters: selectedType == 'numeric'
                                  ? [FilteringTextInputFormatter.digitsOnly]
                                  : null,
                              maxLines: null, // Allow unlimited lines
                              minLines: selectedType == 'essay' ? 3 : 1,
                              textInputAction: selectedType == 'essay'
                                  ? TextInputAction.newline
                                  : TextInputAction.done,
                              validator: (v) =>
                                  v?.isEmpty ?? true ? 'Wajib diisi' : null,
                              onChanged: (value) {
                                setState(() {
                                  options[index]['text'] = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 16),

                          // Persentase Nilai
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue:
                                      options[index]['percentage'].toString(),
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
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (v) =>
                                      v?.isEmpty ?? true ? 'Wajib diisi' : null,
                                  onChanged: (value) {
                                    setState(() {
                                      options[index]['percentage'] =
                                          int.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),

                          // Feedback
                          AnimatedSize(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: TextFormField(
                              initialValue: options[index]['feedback'],
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
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              maxLines: null,
                              minLines: 2,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Umpan Balik tidak boleh kosong';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  options[index]['feedback'] = value;
                                });
                              },
                            ),
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

  Widget _buildAddOptionButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _addOption,
        icon: Icon(
          Icons.add_circle,
          color: Theme.of(context).colorScheme.secondary,
        ),
        label: Text('Tambah Jawaban',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            )),
      ),
    );
  }

  Widget _buildNumericOption() {
    // Gunakan tampilan yang sama dengan essay
    return _buildEssayOption();
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
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  void _updateOptionsPoints() {
    final defaultPoint = int.tryParse(pointController.text) ?? 100;
    setState(() {
      for (var option in options) {
        final percentage = option['percentage'] as int;
        final point = (defaultPoint * percentage / 100).round();
        // Update point value in option
        option['point'] = point;
      }
    });
  }
}
