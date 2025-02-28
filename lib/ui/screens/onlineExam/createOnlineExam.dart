import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/onlineExam/onlineExamCubit.dart';
import 'package:eschool_saas_staff/data/models/subjectDetail.dart';
import 'package:get/get.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class CreateOnlineExam extends StatefulWidget {
  @override
  _CreateOnlineExamState createState() => _CreateOnlineExamState();
}

class _CreateOnlineExamState extends State<CreateOnlineExam> {
  final _formKey = GlobalKey<FormState>();

  SubjectDetail? selectedSubject;
  String title = '';
  String examKey = '';
  int duration = 0;
  DateTime? startDate;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _examKeyController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<OnlineExamCubit>().getOnlineExams();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        _startDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  // Add this method to generate random exam key
  String _generateExamKey() {
    const chars = '0123456789'; // Changed to only numbers
    final random = Random();
    return List.generate(
            6,
            (index) => chars[random.nextInt(
                chars.length)]) // Changed length to 6 for better readability
        .join();
  }

  // Update the _buildAnimatedTextField method to accept a suffix icon
  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    Color? iconColor,
    Color? labelColor,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon, // Add this parameter
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: labelColor ?? Theme.of(context).colorScheme.secondary,
        ),
        prefixIcon: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.primary,
        ),
        suffixIcon: suffixIcon, // Add this line
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildBasicInfoSection() {
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
            'Informasi Dasar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 20),
          // Subject dropdown moved above title input
          _buildSubjectDropdown(),
          SizedBox(height: 15),
          _buildAnimatedTextField(
            controller: _titleController,
            label: 'Judul Ujian',
            icon: Icons.title,
          ),
          SizedBox(height: 15),
          _buildAnimatedTextField(
            controller: _examKeyController,
            label: 'Kunci Ujian',
            icon: Icons.key,
            keyboardType:
                TextInputType.number, // Add this to show numeric keyboard
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ], // Add this to restrict input to numbers only
            suffixIcon: IconButton(
              icon: Icon(Icons.refresh_rounded),
              onPressed: () {
                setState(() {
                  _examKeyController.text = _generateExamKey();
                });
              },
              tooltip: 'Generate Kunci Ujian',
              color: Color(0xFF8B0000),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamDetailsSection() {
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
            'Detail Ujian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 20),
          _buildAnimatedTextField(
            controller: _durationController,
            label: 'Durasi (menit)',
            icon: Icons.timer,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          SizedBox(height: 15),
          _buildAnimatedTextField(
            controller: _startDateController,
            label: 'Tanggal Mulai',
            icon: Icons.calendar_today,
            onTap: () => _selectStartDate(context),
            readOnly: true,
          ),
        ],
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
              onTap: _submitForm,
              borderRadius: BorderRadius.circular(15),
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Buat Ujian',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectDropdown() {
    return BlocBuilder<OnlineExamCubit, OnlineExamState>(
      builder: (context, state) {
        List<SubjectDetail> subjects = [];
        if (state is OnlineExamSuccess) {
          subjects = state.subjectDetails
              .map((e) => SubjectDetail.fromJson(e))
              .toList();
        }

        return DropdownButtonFormField<SubjectDetail>(
          value: selectedSubject,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.school_rounded, color: Color(0xFF8B0000)),
            labelText: 'Pilih Kelas & Mata Pelajaran',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF8B0000)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF8B0000)),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          items: subjects.map((SubjectDetail detail) {
            return DropdownMenuItem<SubjectDetail>(
              value: detail,
              child: Text(
                '${detail.classSection.name} - ${detail.subject.name}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
            );
          }).toList(),
          onChanged: (SubjectDetail? value) {
            setState(() {
              selectedSubject = value;
            });
          },
          isExpanded: true,
          hint: Text(
            'Pilih Kelas & Mata Pelajaran',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          validator: (value) => value == null ? 'Pilih mata pelajaran' : null,
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (selectedSubject == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pilih mata pelajaran terlebih dahulu')),
        );
        return;
      }

      context
          .read<OnlineExamCubit>()
          .createOnlineExam(
            classSectionId: selectedSubject!.classSection.id,
            classSubjectId: selectedSubject!.class_subject_id,
            title: _titleController.text,
            examKey: _examKeyController.text,
            duration: int.parse(_durationController.text),
            startDate: startDate!,
          )
          .then((_) {
        // Show success dialog
        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 60,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Berhasil!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Ujian online berhasil dibuat',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Get.back(); // Close dialog
                      Get.offAllNamed(
                          Routes.onlineExamScreen); // Navigate to exam list
                    },
                    child: Text(
                      'Lihat Daftar Ujian',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
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
                        'Buat Ujian Online',
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
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    physics: BouncingScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          FadeInUp(
                            duration: Duration(milliseconds: 800),
                            child: _buildBasicInfoSection(),
                          ),
                          SizedBox(height: 25),
                          FadeInUp(
                            duration: Duration(milliseconds: 1000),
                            child: _buildExamDetailsSection(),
                          ),
                          SizedBox(height: 30),
                          _buildSubmitButton(),
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
}
