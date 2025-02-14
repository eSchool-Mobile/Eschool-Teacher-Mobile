import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/onlineExam/onlineExamCubit.dart';
import 'package:eschool_saas_staff/data/models/subjectDetail.dart';
import 'package:get/get.dart';

class CreateOnlineExam extends StatefulWidget {
  @override
  _CreateOnlineExamState createState() => _CreateOnlineExamState();
}

class _CreateOnlineExamState extends State<CreateOnlineExam> {
  @override
  void initState() {
    super.initState();
    // Muat data subjects saat screen dibuka
    context.read<OnlineExamCubit>().getOnlineExams();
    print("HITTING");
  }

  final _formKey = GlobalKey<FormState>();

  SubjectDetail? selectedSubject;
  String title = '';
  String examKey = '';
  int duration = 0;
  DateTime? startDate;
  DateTime? endDate;

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Buat Ujian Online',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      centerTitle: true,
    );
  }

  Widget _buildSubjectDropdown() {
    return BlocBuilder<OnlineExamCubit, OnlineExamState>(
      builder: (context, state) {
        if (state is OnlineExamLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is OnlineExamSuccess) {
          final subjects = state.subjectDetails;

          if (subjects.isEmpty) {
            return Text('Tidak ada mata pelajaran yang tersedia');
          }

          return DropdownButtonFormField<SubjectDetail>(
            value: selectedSubject,
            decoration: InputDecoration(
              labelText: 'Pilih Mata Pelajaran',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.subject),
            ),
            items: subjects.map((detail) {
              final subjectDetail = SubjectDetail.fromJson(detail);
              return DropdownMenuItem<SubjectDetail>(
                value: subjectDetail,
                child: Text(
                  '${subjectDetail.classSection.name} - ${subjectDetail.subject.name}',
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedSubject = value;
                print('Selected id: ${value?.id}'); // SubjectDetail id
                print('Selected class_section_id: ${value?.classSection.id}');
                print('Selected subject_id: ${value?.subject.id}');
              });
            },
            validator: (value) => value == null ? 'Pilih mata pelajaran' : null,
          );
        }
        return SizedBox();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject Selection
              _buildSubjectDropdown(),
              SizedBox(height: 16),

              // Title Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Judul Ujian',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => title = value,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Masukkan judul ujian' : null,
              ),
              SizedBox(height: 16),

              // Exam Key Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Kunci Ujian',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => examKey = value,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Masukkan kunci ujian' : null,
              ),
              SizedBox(height: 16),

              // Duration Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Durasi (menit)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => duration = int.tryParse(value) ?? 0,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Masukkan durasi';
                  if (int.tryParse(value!) == null)
                    return 'Masukkan angka yang valid';
                  if (int.parse(value) < 1) return 'Durasi minimal 1 menit';
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Date Selection
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Tanggal Mulai',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      controller: TextEditingController(
                        text: startDate?.toString().split(' ')[0] ?? '',
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (date != null) setState(() => startDate = date);
                      },
                      validator: (value) =>
                          startDate == null ? 'Pilih tanggal mulai' : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Tanggal Selesai',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      controller: TextEditingController(
                        text: endDate?.toString().split(' ')[0] ?? '',
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: startDate ?? DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (date != null) setState(() => endDate = date);
                      },
                      validator: (value) {
                        if (endDate == null) return 'Pilih tanggal selesai';
                        if (startDate != null &&
                            endDate!.isBefore(startDate!)) {
                          return 'Tanggal selesai harus setelah tanggal mulai';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _submitForm,
          child: Text('Buat Ujian'),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    print("classSectionId: ${selectedSubject!.classSection.id}");
    print("classSubjectId: ${selectedSubject!.subject.id}");
    if (_formKey.currentState?.validate() ?? false) {
      // Use the correct IDs from the selected subject
      context
          .read<OnlineExamCubit>()
          .createOnlineExam(
            classSectionId: selectedSubject!.classSection.id,
            classSubjectId: selectedSubject!.class_subject_id,
            title: title,
            examKey: examKey,
            duration: duration,
            startDate: startDate!,
            endDate: endDate!,
          )
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ujian berhasil dibuat'),
            backgroundColor: Colors.green,
          ),
        );
        Get.back();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat ujian: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }
}
