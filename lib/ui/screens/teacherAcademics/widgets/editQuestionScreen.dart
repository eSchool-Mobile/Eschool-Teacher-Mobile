import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/assignment/questionBankCubit.dart';
import 'package:eschool_saas_staff/data/models/question.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';

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
      try {
        // Check for empty feedback fields
        List<int> emptyFeedbackIndexes = [];

        for (int i = 0; i < options.length; i++) {
          if (options[i]['feedback'].toString().trim().isEmpty) {
            emptyFeedbackIndexes.add(i + 1);
          }
        }

        if (emptyFeedbackIndexes.isNotEmpty) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Feedback Wajib Diisi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feedback belum diisi pada opsi:',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    ...emptyFeedbackIndexes
                        .map((index) => Padding(
                              padding: EdgeInsets.only(left: 16, bottom: 4),
                              child: Text(
                                '• Opsi $index',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                    SizedBox(height: 16),
                    Text(
                      'Silakan isi feedback untuk setiap opsi jawaban sebelum menyimpan.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Mengerti',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
          return; // Stop form submission
        }

        // Continue with existing update logic
        await context.read<QuestionBankCubit>().updateQuestion(
              banksoalSoalId: widget.questionData!['banksoal_soal_id'],
              subjectId: widget.questionData!['subject_id'],
              bankSoalId: idBankSoal,
              name: nameController.text.trim(),
              type: selectedType,
              defaultPoint: int.parse(pointController.text),
              question: questionController.text.trim(),
              note: noteController.text.trim(),
              options: options
                  .map((opt) => QuestionOption(
                        text: opt['text'].toString(),
                        percentage: int.parse(opt['percentage'].toString()),
                        feedback: opt['feedback'].toString(),
                      ))
                  .toList(),
            );

        Get.back(result: true);
        Get.snackbar(
          'Berhasil',
          'Soal berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        // Only show error if it's not validation.exists with successful update
        if (!e.toString().contains('validation.exists') ||
            !e.toString().toLowerCase().contains('updated')) {
          Get.snackbar(
            'Error',
            e.toString(),
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
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
                labelText: 'Feedback',
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
                  return 'Feedback tidak boleh kosong';
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
                labelText: 'Feedback untuk jawaban ini',
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
                  return 'Feedback tidak boleh kosong';
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
    return FadeInUp(
      duration: Duration(milliseconds: 1200),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        child: ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.secondary,
                  Color(0xFF8B0000),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF8B0000).withOpacity(0.3),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.update_rounded,
                    color: Colors.white,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Update Question',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
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
            TextFormField(
              initialValue: options[index]['percentage'].toString(),
              decoration: InputDecoration(
                labelText: 'Persentase Nilai',
                suffixText: '%',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
              onChanged: (value) => setState(() {
                options[index]['percentage'] = int.tryParse(value) ?? 0;
              }),
            ),
            SizedBox(height: 12),
            TextFormField(
              initialValue: options[index]['feedback'],
              decoration: InputDecoration(
                labelText: 'Feedback',
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
                  return 'Feedback tidak boleh kosong';
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
              padding: EdgeInsets.all(16),
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
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Jawaban ${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      if (options.length > 1)
                        IconButton(
                          icon: Icon(Icons.delete_outline),
                          color: Colors.red.shade400,
                          onPressed: () => _removeAnswerOption(index),
                          tooltip: 'Hapus jawaban ini',
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: options[index]['text'],
                    decoration: InputDecoration(
                      labelText: 'Jawaban',
                      prefixIcon: Icon(Icons.edit_note,
                          color: Theme.of(context).colorScheme.secondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    maxLines: 3,
                    validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
                    onChanged: (value) => setState(() {
                      options[index]['text'] = value;
                    }),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: options[index]['percentage'].toString(),
                    decoration: InputDecoration(
                      labelText: 'Persentase Nilai',
                      prefixIcon: Icon(Icons.percent,
                          color: Theme.of(context).colorScheme.secondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
                    onChanged: (value) => setState(() {
                      options[index]['percentage'] = int.tryParse(value) ?? 0;
                    }),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: options[index]['feedback'],
                    decoration: InputDecoration(
                      labelText: 'Feedback',
                      prefixIcon: Icon(Icons.comment_outlined,
                          color: Theme.of(context).colorScheme.secondary),
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
                        return 'Feedback tidak boleh kosong';
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
          ),
        ),
        SizedBox(height: 16),
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
        icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor),
        label: Text('Add Option',
            style: TextStyle(color: Theme.of(context).primaryColor)),
      ),
    );
  }

  Widget _buildNumericOption() {
    return Column(
      children: [
        ...List.generate(
          options.length,
          (index) => FadeInLeft(
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
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Jawaban ${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      if (options.length > 1)
                        IconButton(
                          icon: Icon(Icons.delete_outline),
                          color: Colors.red.shade400,
                          onPressed: () => _removeAnswerOption(index),
                          tooltip: 'Hapus jawaban ini',
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: options[index]['text'],
                    decoration: InputDecoration(
                      labelText: 'Jawaban (Numerik)',
                      prefixIcon: Icon(Icons.numbers,
                          color: Theme.of(context).colorScheme.secondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      helperText: 'Masukkan angka saja',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Wajib diisi';
                      if (int.tryParse(v!) == null) return 'Harus berupa angka';
                      return null;
                    },
                    onChanged: (value) => setState(() {
                      options[index]['text'] = value;
                    }),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: options[index]['percentage'].toString(),
                    decoration: InputDecoration(
                      labelText: 'Persentase Nilai',
                      prefixIcon: Icon(Icons.percent,
                          color: Theme.of(context).colorScheme.secondary),
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
                    validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
                    onChanged: (value) => setState(() {
                      options[index]['percentage'] = int.tryParse(value) ?? 0;
                    }),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: options[index]['feedback'],
                    decoration: InputDecoration(
                      labelText: 'Feedback',
                      prefixIcon: Icon(Icons.comment_outlined,
                          color: Theme.of(context).colorScheme.secondary),
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
                        return 'Feedback tidak boleh kosong';
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
          ),
        ),
      ],
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
