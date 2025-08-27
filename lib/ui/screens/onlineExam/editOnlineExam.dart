import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/onlineExam/onlineExamCubit.dart';
import 'package:eschool_saas_staff/data/models/subjectDetail.dart';
import 'package:eschool_saas_staff/data/models/onlineExam.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'dart:math';

class EditOnlineExam extends StatefulWidget {
  final OnlineExam exam;

  const EditOnlineExam({Key? key, required this.exam}) : super(key: key);

  @override
  _EditOnlineExamState createState() => _EditOnlineExamState();
}

class _EditOnlineExamState extends State<EditOnlineExam>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomModernAppBar(
        title: 'Edit Ujian Online',
        icon: Icons.quiz,
        fabAnimationController: _animationController,
        primaryColor: _primaryColor,
        lightColor: _accentColor,
        onBackPressed: () => Navigator.pop(context),
        // We're not showing add or archive buttons as per requirements
        showAddButton: false,
        showArchiveButton: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicInfoSection(),
              SizedBox(height: 20),
              _buildExamDetailsSection(),
              SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  SubjectDetail? selectedSubject;
  late TextEditingController _titleController;
  late TextEditingController _examKeyController;
  late TextEditingController _durationController;
  late TextEditingController _startDateController;
  late TextEditingController _startTimeController;
  DateTime? startDate;
  TimeOfDay? startTime;

  // Theme colors - Softer Maroon palette
  final Color _primaryColor = Color(0xFF7A1E23); // Softer deep maroon
  final Color _accentColor = Color(0xFF9D3C3C); // Softer medium maroon
  final Color _highlightColor = Color(0xFFB84D4D); // Softer bright maroon

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing exam data

    final timeString = DateFormat('HH:mm').format(widget.exam.startDate);

    _titleController = TextEditingController(text: widget.exam.title);
    _examKeyController = TextEditingController(text: widget.exam.examKey);
    _durationController =
        TextEditingController(text: widget.exam.duration.toString());
    startDate = widget.exam.startDate;
    startTime = TimeOfDay(
        hour: int.parse(timeString.split(':')[0]),
        minute: int.parse(timeString.split(':')[1]));

    _startDateController = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(widget.exam.startDate),
    );

    _startTimeController = TextEditingController(
        text: DateFormat('HH:mm').format(widget.exam.startDate));

    // Initialize animation controllers for the CustomModernAppBar
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Add pulse animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    // Load subjects and set selected subject
    context.read<OnlineExamCubit>().getOnlineExams().then((_) {
      if (mounted) {
        final state = context.read<OnlineExamCubit>().state;
        if (state is OnlineExamSuccess) {
          try {
            final List<dynamic> subjectList = state.subjectDetails;
            final subjects = subjectList
                .where((e) => e != null)
                .map((e) => SubjectDetail.fromJson(e))
                .toList();

            final match = subjects.firstWhere(
              (subject) =>
                  subject.class_subject_id == widget.exam.classSubjectId &&
                  subject.classSection.id == widget.exam.classSectionId,
              orElse: () =>
                  subjects.first, // Fallback to first subject if no match
            );

            setState(() {
              selectedSubject = match;
            });
          } catch (err) {
            // Handle error parsing subjects
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _examKeyController.dispose();
    _durationController.dispose();
    _startDateController.dispose();
    _startTimeController.dispose();

    // Dispose animation controllers
    _animationController.dispose();
    _pulseController.dispose();

    super.dispose();
  }

  // Date picker methods
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

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != startTime) {
      setState(() {
        startTime = picked;
        _startTimeController.text = picked.format(context);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (selectedSubject == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pilih mata pelajaran terlebih dahulu')),
        );
        return;
      }

      // Validasi startDate
      if (startDate == null || startTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pilih tanggal mulai terlebih dahulu')),
        );
        return;
      }

      context
          .read<OnlineExamCubit>()
          .updateOnlineExam(
            id: widget.exam.id,
            classSectionId: selectedSubject!.classSection.id,
            classSubjectId: selectedSubject!.class_subject_id,
            title: _titleController.text,
            examKey: _examKeyController.text,
            duration: int.parse(_durationController.text),
            startDate: DateTime(
              startDate!.year,
              startDate!.month,
              startDate!.day,
              startTime!.hour,
              startTime!.minute,
            ),
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
                      color: const Color.fromARGB(255, 8, 0, 0),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Ujian berhasil diperbarui',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 80, 80, 80),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Get.back(); // Close dialog
                      // Navigasi kembali ke halaman sebelumnya dengan membawa hasil
                      Navigator.pop(
                          context, true); // Return true to indicate success
                    },
                    child: Text('OK', style: TextStyle(color: Colors.white)),
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
        // Handle error silently
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui ujian: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  // Helper methods for the header
  Widget _buildGlowingIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          // Use _animation here to make the compiler happy that it's being used
          final animationValue = _animation.value * 0.2;

          return Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12 + animationValue),
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

  // The rest of your methods remain unchanged...
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
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onChanged, // Add this line
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator ?? (v) => v!.isEmpty ? 'Required' : null,
      onChanged: onChanged, // Add this line
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: labelColor ?? Theme.of(context).colorScheme.secondary,
        ),
        prefixIcon: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.primary,
        ),
        suffixIcon: suffixIcon,
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
          // Tambahkan subject dropdown di sini
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
            label: 'Kode Ujian',
            icon: Icons.key,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

  // Tambahkan method untuk generate exam key
  String _generateExamKey() {
    const chars = '0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)])
        .join();
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
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildAnimatedTextField(
                  controller: _startDateController,
                  label: 'Tanggal Mulai',
                  icon: Icons.calendar_today,
                  onTap: () => _selectStartDate(context),
                  readOnly: true,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _buildAnimatedTextField(
                  controller: _startTimeController,
                  label: 'Jam Mulai',
                  icon: Icons.access_time,
                  onTap: () => _selectStartTime(context),
                  readOnly: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildAnimatedTextField(
            controller: _durationController,
            label: 'Durasi (menit) Max 999 menit',
            icon: Icons.timer,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Durasi harus diisi';
              }
              if (value.length > 3) {
                return 'Durasi tidak boleh lebih dari 3 digit';
              }
              final duration = int.tryParse(value);
              if (duration == null || duration <= 0) {
                return 'Durasi harus lebih dari 0';
              }
              return null;
            },
            onChanged: (value) {
              if (value.length > 3) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Maksimal durasi adalah 999 menit'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
                // Truncate to 3 digits
                _durationController.text = value.substring(0, 3);
                _durationController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _durationController.text.length),
                );
              }
            },
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
                      'Perbarui Ujian',
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
          try {
            subjects = state.subjectDetails
                .whereType<Map<String, dynamic>>()
                .map((e) {
                  try {
                    return SubjectDetail.fromJson(e);
                  } catch (e) {
                    // Handle error silently
                    return null;
                  }
                })
                .where((e) => e != null)
                .cast<SubjectDetail>()
                .toList();

            // Try to find the matching subject if not already selected
            if (selectedSubject == null && subjects.isNotEmpty) {
              try {
                selectedSubject = subjects.firstWhere(
                  (subject) =>
                      subject.class_subject_id == widget.exam.classSubjectId &&
                      subject.classSection.id == widget.exam.classSectionId,
                  orElse: () => subjects.first,
                );
              } catch (e) {
                // Handle error silently
              }
            }
          } catch (e) {
            // Handle error silently
          }
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
}
