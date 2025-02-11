import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/assignment/questionBankCubit.dart';
import 'package:eschool_saas_staff/data/models/question.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';

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
        text: widget.questionData?['default_point']?.toString() ?? '10');
    noteController =
        TextEditingController(text: widget.questionData?['note'] ?? '');
    idBankSoal = widget.questionData?['idBankSoal'];
    selectedType = widget.questionData?['type'] ?? 'multiple_choice';
    version = 1;

    if (widget.questionData?['options'] != null) {
      options =
          List<Map<String, dynamic>>.from(widget.questionData!['options']);
    } else {
      options = _getDefaultOptionsForType(selectedType);
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
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
        onChanged: null, // Disable changing question type when editing
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
                helperText: 'Feedback akan ditampilkan setelah menjawab',
              ),
              maxLines: 2,
              validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
              onChanged: (value) {
                setState(() {
                  options[index]['feedback'] = value;
                });
              },
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
              ],
            ),
            SizedBox(height: 10),
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
              ),
              maxLines: 2,
              validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
              onChanged: (value) {
                setState(() {
                  options[index]['feedback'] = value;
                });
              },
            ),
            if (index > 1)
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

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        'Update Question',
        style: TextStyle(fontSize: 16),
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
              ),
              maxLines: 2,
              validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
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
    return Container(
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
          TextFormField(
            initialValue: options[0]['text'],
            decoration: InputDecoration(
              labelText: 'Jawaban',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            maxLines: 3,
            validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
            onChanged: (value) => setState(() {
              options[0]['text'] = value;
            }),
          ),
          SizedBox(height: 12),
          TextFormField(
            initialValue: options[0]['percentage'].toString(),
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
              options[0]['percentage'] = int.tryParse(value) ?? 0;
            }),
          ),
          SizedBox(height: 12),
          TextFormField(
            initialValue: options[0]['feedback'],
            decoration: InputDecoration(
              labelText: 'Feedback',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            maxLines: 2,
            validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
            onChanged: (value) => setState(() {
              options[0]['feedback'] = value;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildShortAnswerOption() {
    return Container(
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
          TextFormField(
            initialValue: options[0]['text'],
            decoration: InputDecoration(
              labelText: 'Jawaban',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
            onChanged: (value) => setState(() {
              options[0]['text'] = value;
            }),
          ),
          SizedBox(height: 12),
          TextFormField(
            initialValue: options[0]['percentage'].toString(),
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
              options[0]['percentage'] = int.tryParse(value) ?? 0;
            }),
          ),
          SizedBox(height: 12),
          TextFormField(
            initialValue: options[0]['feedback'],
            decoration: InputDecoration(
              labelText: 'Feedback',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            maxLines: 2,
            validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
            onChanged: (value) => setState(() {
              options[0]['feedback'] = value;
            }),
          ),
        ],
      ),
    );
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
    return Container(
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
          TextFormField(
            initialValue: options[0]['text'],
            decoration: InputDecoration(
              labelText: 'Jawaban',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
            onChanged: (value) => setState(() {
              options[0]['text'] = value;
            }),
          ),
          SizedBox(height: 12),
          TextFormField(
            initialValue: options[0]['percentage'].toString(),
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
              options[0]['percentage'] = int.tryParse(value) ?? 0;
            }),
          ),
          SizedBox(height: 12),
          TextFormField(
            initialValue: options[0]['feedback'],
            decoration: InputDecoration(
              labelText: 'Feedback',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            maxLines: 2,
            validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
            onChanged: (value) => setState(() {
              options[0]['feedback'] = value;
            }),
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
}
