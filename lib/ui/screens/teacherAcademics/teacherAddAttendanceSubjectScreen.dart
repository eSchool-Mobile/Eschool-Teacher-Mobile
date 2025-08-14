import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/studentsByClassSectionCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/attendence/attendanceSubjectCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/attendence/submitAttendanceSubjectCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/teacherMyTimetableCubit.dart';
import 'package:eschool_saas_staff/data/models/attendanceStudent.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/studentAttendance.dart';
import 'package:eschool_saas_staff/data/models/timeTableSlot.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/holidayAttendanceContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/studentAttendanceContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherAddAttendanceSubjectScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SubmitAttendanceSubjectCubit(),
        ),
        BlocProvider(
          create: (context) => SubjectAttendanceCubit(),
        ),
        BlocProvider(create: (context) => StudentsByClassSectionCubit()),
        BlocProvider(
          create: (context) => ClassesCubit(),
        ),
        BlocProvider(create: (context) => TeacherMyTimetableCubit()),
      ],
      child: const TeacherAddAttendanceSubjectScreen(),
    );
  }

  static Map<String, dynamic> buildArguments({
    required ClassSection? classSection,
    required TimeTableSlot? timeTableSlot,
  }) {
    return {
      "classSection": classSection,
      "timeTableSlot": timeTableSlot,
    };
  }

  const TeacherAddAttendanceSubjectScreen({super.key});

  @override
  State<TeacherAddAttendanceSubjectScreen> createState() =>
      _TeacherAddAttendanceScreenSubjectState();
}

class _TeacherAddAttendanceScreenSubjectState
    extends State<TeacherAddAttendanceSubjectScreen>
    with TickerProviderStateMixin {
  List<({StudentAttendanceStatus status, int studentId})> attendanceReport = [];

  final TextEditingController _materiController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  int? _selectedGradeLevelId;
  ClassSection? _selectedClassSection;
  int _selectedTimeTableId = 0;
  int _selectedJumlahJp = 0;
  String _selectedMateri = '';
  String? _selectedLampiran;

  // Color scheme for maroon theme
  final Color _maroonPrimary = const Color(0xFF800020);
  final Color _maroonLight = const Color(0xFFAA6976);

  // Animation controllers
  late AnimationController _fabAnimationController;
  late final ScrollController _scrollController = ScrollController()
    ..addListener(scrollListener);

  @override
  void dispose() {
    _materiController.dispose();
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void scrollListener() {
    // Animate elements based on scroll
    if (_scrollController.offset > 50) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  // Helper method to check if all required data is valid for fetching attendance
  bool _isDataValidForFetch() {
    return _selectedClassSection != null && _selectedClassSection!.id != null;
  }

  // Helper method to get validation message for missing data
  String _getValidationMessage() {
    if (_selectedClassSection == null || _selectedClassSection!.id == null) {
      return "Pilih kelas terlebih dahulu";
    }
    return "";
  }

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime.now();
    _selectedClassSection = null; // Reset selected class section
    _selectedTimeTableId = 0; // Reset selected timetable ID
    _selectedJumlahJp = 0; // Reset jumlah JP
    _selectedMateri = ''; // Reset materi
    _selectedLampiran = null; // Reset lampiran

    // Initialize animation controllers
    _fabAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    Future.delayed(Duration.zero, () {
      final arguments = Get.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        _selectedClassSection = arguments['classSection'] as ClassSection?;
        final timeTableSlot = arguments['timeTableSlot'] as TimeTableSlot?;
        if (timeTableSlot != null) {
          _selectedTimeTableId = timeTableSlot.id!;
        }
        // Extract grade level from class section if available
        if (_selectedClassSection != null) {
          _selectedGradeLevelId = _selectedClassSection!.gradeLevelId;
        }
      }

      context.read<ClassesCubit>().getClasses();
      context.read<TeacherMyTimetableCubit>().getTeacherMyTimetable();

      // Only fetch attendance if we have class section selected
      if (_selectedClassSection != null && _selectedClassSection!.id != null) {
        getAttendance();
        getStudentList();
      }
    }); // Listen to attendance cubit state changes
    context.read<SubjectAttendanceCubit>().stream.listen((state) {
      if (state is SubjectAttendanceFetchSuccess) {
        setState(() {
          _materiController.text = state.materi ?? ''; // Set saved materi
          _selectedMateri = state.materi ?? '';

          // Display previously uploaded lampiran if available
          if (state.lampiran != null && state.lampiran!.isNotEmpty) {
            print("Loading previously uploaded attachment: ${state.lampiran}");
            _selectedLampiran = state.lampiran;
          }
        });
      }
    });
  }

  void getAttendance() {
    print("Fetching attendance data for:");
    print("- Date: ${_selectedDateTime}");
    print("- Grade Level ID: ${_selectedGradeLevelId}");
    print("- Class Section ID: ${_selectedClassSection?.id}");
    print("- Timetable ID: $_selectedTimeTableId");

    // Use helper method for validation
    if (!_isDataValidForFetch()) {
      String message = _getValidationMessage();
      if (message.isNotEmpty) {
        Utils.showSnackBar(message: message, context: context);
      }
      return;
    }

    // Set default timetable ID if not set
    int timetableIdToUse = _selectedTimeTableId > 0 ? _selectedTimeTableId : 1;
    int gradeLevelIdToUse =
        _selectedGradeLevelId ?? _selectedClassSection!.gradeLevelId ?? 1;

    context.read<SubjectAttendanceCubit>().fetchSubjectAttendance(
          date: _selectedDateTime,
          gradeLevelId: gradeLevelIdToUse,
          classSectionId: _selectedClassSection!.id!,
          timetableId: timetableIdToUse,
        );
  }

  void getStudentList() {
    attendanceReport.clear();
    print(
        "Fetching students for class section ID: ${_selectedClassSection?.id}");
    print("Getting student list");
    print("Selected class section: ${_selectedClassSection?.id}");
    print("Selected timetable: $_selectedTimeTableId");

    if (_selectedClassSection == null || _selectedClassSection!.id == null) {
      Utils.showSnackBar(
          message: "Pilih kelas terlebih dahulu", context: context);
      return;
    }

    context.read<StudentsByClassSectionCubit>().fetchStudents(
          status:
              StudentListStatus.all, // Tampilkan semua siswa termasuk non-aktif
          classSectionId: _selectedClassSection!.id!,
        );
  }

  void changeClassSectionSelection(ClassSection? newSelectedClassSection) {
    _selectedClassSection = newSelectedClassSection;
    _selectedTimeTableId = 0; // Reset jadwal pelajaran ketika kelas berubah

    // Extract grade level from class section if available
    if (newSelectedClassSection != null) {
      _selectedGradeLevelId = newSelectedClassSection.gradeLevelId;
    }

    setState(() {});
    if (newSelectedClassSection != null && newSelectedClassSection.id != null) {
      getStudentList();
      getAttendance(); // Directly call getAttendance since we have class selection
      context.read<TeacherMyTimetableCubit>().getTeacherMyTimetable();
    }

    // Clear previous attendance data when class changes
    attendanceReport.clear();
  }

  void changeGradeLevelSelection(int? newGradeLevelId) {
    // Method kept for compatibility but simplified
    setState(() {
      _selectedGradeLevelId = newGradeLevelId;
    });
  }

  void resetForm() {
    setState(() {
      _selectedMateri = '';

      // Only clear lampiran if it's a local file, not a server URL
      if (_selectedLampiran != null && !_selectedLampiran!.startsWith('http')) {
        _selectedLampiran = null;
        uploadedFiles.clear();
      }

      attendanceReport.clear();
    });
  }

  void changeTimetableSlotSelection(int? newSelectedTimetableId) {
    _selectedTimeTableId = newSelectedTimetableId ?? 0;

    // Set default jumlah JP ketika jadwal dipilih
    if (newSelectedTimetableId != null && newSelectedTimetableId > 0) {
      _selectedJumlahJp = 1; // Default 1 JP per jadwal
    } else {
      _selectedJumlahJp = 1; // Default to 1 JP even without specific timetable
    }

    setState(() {});

    // Refresh attendance data if we have class section
    if (_selectedClassSection != null && _selectedClassSection!.id != null) {
      getAttendance();
    }
  }

  String formatTime(String time) {
    return time.substring(0, 5).replaceAll(':', '.');
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = result.files.single;
      final fileSizeInMB = file.size / (1024 * 1024);

      if (fileSizeInMB > 2.5) {
        Utils.showSnackBar(message: maximumAttachmentKey, context: context);
        return;
      }
      setState(() {
        _selectedLampiran = file.path;
        uploadedFiles.add(file);
      });
    }
  }

  List<PlatformFile> uploadedFiles = [];

  Widget _buildStudents({required List<AttendanceStudent> attendance}) {
    return BlocBuilder<StudentsByClassSectionCubit,
        StudentsByClassSectionState>(
      builder: (BuildContext context, StudentsByClassSectionState state) {
        if (state is StudentsByClassSectionFetchSuccess) {
          if (state.studentDetailsList.isEmpty) {
            return const SizedBox.shrink();
          }

          final allStudents = state.studentDetailsList;
          return StudentAttendanceContainer(
            studentAttendances: allStudents.map((e) {
              // Find matching attendance from previous submission
              final matchedAttendance = attendance
                  .firstWhereOrNull((element) => element.studentId == e.id);

              return StudentAttendance.fromStudentDetails(
                studentDetails: e,
                type: matchedAttendance?.type ??
                    1, // Use stored type or default to present (1)
              );
            }).toList(),
            isForAddAttendance: true,
            isReadOnly: false, // Always allow editing
            onStatusChanged:
                (List<({StudentAttendanceStatus status, int studentId})>
                    attendanceStatuses) {
              attendanceReport = attendanceStatuses;
            },
          );
        } else if (state is StudentsByClassSectionFetchFailure) {
          return Center(
            child: Padding(
              padding:
                  EdgeInsets.only(top: topPaddingOfErrorAndLoadingContainer),
              child: ErrorContainer(
                errorMessage: state.errorMessage,
                onTapRetry: () {
                  getStudentList();
                },
              ),
            ),
          );
        } else {
          return Center(
            child: Padding(
              padding:
                  EdgeInsets.only(top: topPaddingOfErrorAndLoadingContainer),
              child: CustomCircularProgressIndicator(
                indicatorColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildStudentsContainer() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(
            bottom: 100), // Add bottom padding to prevent overlap
        child: BlocBuilder<SubjectAttendanceCubit, SubjectAttendanceState>(
          builder: (context, state) {
            if (state is SubjectAttendanceFetchInProgress) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                    CustomCircularProgressIndicator(
                      indicatorColor: _maroonPrimary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Memuat data kehadiran...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is SubjectAttendanceFetchSuccess) {
              if (state.isHoliday) {
                return HolidayAttendanceContainer(
                  holiday: state.holidayDetails,
                );
              }

              // Title and subtitle section
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and subtitle section
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kehadiran Siswa',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _maroonPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(
                      begin: -0.1,
                      end: 0,
                      curve: Curves
                          .easeOutQuad), // Form area with material input - Always show the form
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Form header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _maroonPrimary.withOpacity(0.9),
                                _maroonPrimary,
                                _maroonLight,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                            boxShadow: [
                              BoxShadow(
                                color: _maroonPrimary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit_note_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 300.ms)
                                  .slideX(begin: -0.2, end: 0),
                              const SizedBox(width: 16),
                              // Title text
                              Expanded(
                                child: Text(
                                  'Detail Pembelajaran',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Materi input field
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Label for Materi field with icon
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: _maroonPrimary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.menu_book_rounded,
                                      size: 18,
                                      color: _maroonPrimary,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Materi Pembelajaran',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              // Modern text field with shadow
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _materiController,
                                  minLines: 3,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Tuliskan materi pembelajaran di sini...',
                                    hintStyle: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[400],
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _maroonPrimary,
                                        width: 1.5,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedMateri = value;
                                    });
                                  },
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ), // File upload section
                              SizedBox(height: 24),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: _maroonPrimary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.attachment_rounded,
                                      size: 18,
                                      color: _maroonPrimary,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Lampiran (Opsional)',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              // File format description
                              Text(
                                'Format yang didukung: JPEG, PNG, JPG, GIF, SVG, DOC, DOCX, PDF',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              SizedBox(height: 8),

                              // Upload button
                              InkWell(
                                onTap: () => pickFile(),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _maroonLight.withOpacity(0.3),
                                      width: 1,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: _selectedLampiran != null
                                        ? _maroonPrimary.withOpacity(0.03)
                                        : Colors.white,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_selectedLampiran == null) ...[
                                        Icon(
                                          Icons.upload_file_rounded,
                                          size: 32,
                                          color: _maroonLight,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Klik untuk mengunggah lampiran',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: _maroonLight,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Maksimal 2.5 MB',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[400],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ] else ...[
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: _maroonPrimary
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                _selectedLampiran!
                                                        .startsWith('http')
                                                    ? Icons.cloud_done_rounded
                                                    : Icons.check_rounded,
                                                color: _maroonPrimary,
                                                size: 20,
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _selectedLampiran!
                                                            .startsWith('http')
                                                        ? 'Lampiran'
                                                        : 'File berhasil diunggah',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: _maroonPrimary,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    _selectedLampiran!
                                                            .startsWith('http')
                                                        ? _selectedLampiran!
                                                            .split('/')
                                                            .last
                                                        : _selectedLampiran!
                                                            .split('/')
                                                            .last,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                _selectedLampiran!
                                                        .startsWith('http')
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                        .delete_outline_rounded,
                                                color: _selectedLampiran!
                                                        .startsWith('http')
                                                    ? _maroonPrimary
                                                    : Colors.redAccent,
                                              ),
                                              onPressed: () async {
                                                if (_selectedLampiran!
                                                    .startsWith('http')) {
                                                  // Try to launch URL using Uri.parse
                                                  try {
                                                    final Uri url = Uri.parse(
                                                        _selectedLampiran!);
                                                    if (!await launchUrl(url)) {
                                                      Utils.showSnackBar(
                                                          message:
                                                              "Tidak dapat membuka URL: $_selectedLampiran",
                                                          context: context);
                                                    }
                                                  } catch (e) {
                                                    Utils.showSnackBar(
                                                        message:
                                                            "Tidak dapat membuka URL: $_selectedLampiran",
                                                        context: context);
                                                  }
                                                } else {
                                                  // Delete local file
                                                  setState(() {
                                                    _selectedLampiran = null;
                                                    uploadedFiles.clear();
                                                  });
                                                }
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 100.ms)
                      .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad),

                  // Students attendance list
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // List header with modern design
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _maroonPrimary.withOpacity(0.9),
                                _maroonPrimary,
                                _maroonLight,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                            boxShadow: [
                              BoxShadow(
                                color: _maroonPrimary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Animated icon
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.people_alt_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 300.ms)
                                  .slideX(begin: -0.2, end: 0),

                              const SizedBox(width: 16),

                              // Title text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daftar Kehadiran Siswa',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ), // Status badge - Always show as active
                            ],
                          ),
                        ),

                        // Student list
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: _buildStudents(attendance: state.attendance),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 200.ms)
                      .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad),
                ],
              );
            } else if (state is SubjectAttendanceFetchFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.2),
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      getAttendance();
                    },
                  ),
                ),
              );
            } else {
              // For initial state or other states, show instructions with class selector
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _maroonPrimary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 48,
                          color: _maroonPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Siap untuk mengambil absensi?',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _maroonPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pilih kelas untuk memulai',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Class selection dropdown
                      const SizedBox(height: 32),
                      BlocBuilder<ClassesCubit, ClassesState>(
                        builder: (context, state) {
                          if (state is ClassesFetchSuccess) {
                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: DropdownButtonFormField<ClassSection>(
                                value: _selectedClassSection,
                                items: state.classes
                                    .map((classSection) =>
                                        DropdownMenuItem<ClassSection>(
                                          value: classSection,
                                          child: Text(classSection.fullName ??
                                              'Unknown Class'),
                                        ))
                                    .toList(),
                                onChanged: (val) =>
                                    changeClassSectionSelection(val),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: _maroonPrimary.withOpacity(0.3),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: _maroonPrimary.withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: _maroonPrimary,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  prefixIcon: Icon(
                                    Icons.class_rounded,
                                    color: _maroonPrimary,
                                  ),
                                ),
                                hint: Text(
                                  'Pilih Kelas',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[500],
                                  ),
                                ),
                                style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }
                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: _maroonPrimary,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Memuat kelas...',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<SubjectAttendanceCubit, SubjectAttendanceState>(
      builder: (context, state) {
        if (state is SubjectAttendanceFetchSuccess) {
          if (state.isHoliday) {
            // Hide button only for holidays, not for teaching hours
            return const SizedBox();
          }
          return BlocConsumer<SubmitAttendanceSubjectCubit,
                  SubmitAttendanceSubjectState>(
              listener: (context, submitAttendanceSubjectState) {
            if (submitAttendanceSubjectState
                is SubmitAttendanceSubjectSuccess) {
              CustomSuccessMessage.show(
                context: context,
                message: "Berhasil menyimpan Kehadiran!",
                backgroundColor: Colors.green,
                textColor: Colors.white,
              );

              // Optional: Add haptic feedback
              HapticFeedback.mediumImpact();
              resetForm();
              Navigator.pop(context);
            } else if (submitAttendanceSubjectState
                is SubmitAttendanceSubjectFailure) {
              Utils.showSnackBar(
                context: context,
                message: submitAttendanceSubjectState.errorMessage,
              );
            }
          }, builder: (context, submitAttendanceSubjectState) {
            // Always active unless submission is in progress
            final bool isSubmitActive = !(submitAttendanceSubjectState
                is SubmitAttendanceSubjectInProgress);

            return Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.8),
                      Colors.white,
                      Colors.white,
                    ],
                    stops: [0.0, 0.2, 0.5, 1.0],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _maroonPrimary,
                        Color(0xFF9A1E3C),
                        _maroonLight,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _maroonPrimary.withOpacity(0.3),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      highlightColor: Colors.white.withOpacity(0.1),
                      splashColor: Colors.white.withOpacity(0.2),
                      onTap: () {
                        if (!isSubmitActive) {
                          return; // Only check if submission is in progress
                        }

                        // Validasi data sebelum submit
                        if (_selectedClassSection == null ||
                            _selectedClassSection!.id == null) {
                          Utils.showSnackBar(
                              message: "Pilih kelas terlebih dahulu",
                              context: context);
                          return;
                        }

                        // Set defaults for required fields
                        int gradeLevelIdToSubmit = _selectedGradeLevelId ??
                            _selectedClassSection!.gradeLevelId ??
                            1;
                        int timetableIdToSubmit =
                            _selectedTimeTableId > 0 ? _selectedTimeTableId : 1;
                        int jumlahJpToSubmit =
                            _selectedJumlahJp > 0 ? _selectedJumlahJp : 1;

                        if (_selectedMateri.isEmpty) {
                          Utils.showSnackBar(
                              message: "Materi pembelajaran harus diisi",
                              context: context);
                          return;
                        }

                        if (attendanceReport.isEmpty) {
                          Utils.showSnackBar(
                              message: "Data kehadiran siswa belum diisi",
                              context: context);
                          return;
                        }

                        // Log detailed submission data
                        print('=== ATTENDANCE SUBMISSION DATA ===');
                        print(
                            '📅 Date: ${Utils.formatDate(_selectedDateTime)}');
                        print(
                            '🏫 Class: ${_selectedClassSection?.fullName} (ID: ${_selectedClassSection?.id})');
                        print('📚 Timetable ID: $timetableIdToSubmit');
                        print('⏱️ JP Count: $jumlahJpToSubmit');
                        print(
                            '📝 Materi: ${_selectedMateri.isEmpty ? "(empty)" : _selectedMateri}');
                        print('📎 Lampiran: ${_selectedLampiran ?? "(none)"}');
                        print('👥 Attendance Report:');

                        for (var attendance in attendanceReport) {
                          String status = '';
                          switch (attendance.status) {
                            case StudentAttendanceStatus.present:
                              status = '✅ Present';
                              break;
                            case StudentAttendanceStatus.absent:
                              status = '❌ Absent';
                              break;
                            default:
                              status = '❓ Unknown';
                          }
                          print(
                              '   Student ID: ${attendance.studentId} - Status: $status');
                        }
                        print(
                            '================================'); // Only send lampiran if it's a local file path, not a URL
                        final String lampiranToSend =
                            (_selectedLampiran != null &&
                                    !_selectedLampiran!.startsWith('http'))
                                ? _selectedLampiran!
                                : '';

                        context
                            .read<SubmitAttendanceSubjectCubit>()
                            .submitSubjectAttendance(
                              date: _selectedDateTime,
                              classSectionId: _selectedClassSection!.id!,
                              attendanceReport: attendanceReport,
                              timetableId: timetableIdToSubmit,
                              jumlahJp: jumlahJpToSubmit,
                              materi: _selectedMateri,
                              lampiran: lampiranToSend,
                              gradeLevelId: gradeLevelIdToSubmit,
                            );
                      },
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            );
                          },
                          child: submitAttendanceSubjectState
                                  is SubmitAttendanceSubjectInProgress
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  key: ValueKey<String>("loading"),
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : Row(
                                  key: ValueKey<String>("button"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      Utils.getTranslatedLabel(submitKey),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    if (attendanceReport.isNotEmpty)
                                      Container(
                                        margin: EdgeInsets.only(left: 12),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          "${attendanceReport.length}",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 500.ms);
          });
        }
        return const SizedBox();
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomModernAppBar(
      title: 'Kehadiran Pelajaran',
      icon: Icons.edit_calendar_rounded,
      fabAnimationController: _fabAnimationController,
      primaryColor: _maroonPrimary,
      lightColor: _maroonLight,
      height: 150, // Decreased height to match TeacherAddAttendanceScreen
      onBackPressed: () => Navigator.of(context).pop(),
      tabBuilder: (context) {
        // Custom tab content for filters like in TeacherAddAttendanceScreen
        return Row(
          children: [
            // Date filter
            Expanded(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final selectedDate = await Utils.openDatePicker(
                      context: context,
                      inititalDate: _selectedDateTime,
                      lastDate: DateTime.now(),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 30)),
                    );

                    if (selectedDate != null) {
                      _selectedDateTime = selectedDate;
                      setState(() {});
                      if (_selectedClassSection != null) {
                        getAttendance();
                      }
                    }
                  },
                  highlightColor: Colors.white.withOpacity(0.1),
                  splashColor: Colors.white.withOpacity(0.2),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            Utils.formatDate(_selectedDateTime),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Vertical divider
            Container(
              height: 24,
              width: 1.5,
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),

            // Class selection filter (display only)
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.class_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _selectedClassSection?.fullName ?? 'Pilih Kelas',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          BlocBuilder<ClassesCubit, ClassesState>(
            builder: (context, state) {
              print("EMITT");
              print(state);
              if (state is ClassesFetchSuccess) {
                return Stack(children: [
                  _buildStudentsContainer(),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildSubmitButton(),
                  ),
                ]);
              }
              if (state is ClassesFetchFailure) {
                return Center(
                    child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context.read<ClassesCubit>().getClasses();
                  },
                ));
              }
              print("LOADING");
              return Center(
                child: CustomCircularProgressIndicator(
                  indicatorColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SnackBarUtils {
  static void showSnackBar({
    required BuildContext context,
    required String message,
    Color backgroundColor = Colors.black87, // Default color
    Color textColor = Colors.white, // Default text color
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class CustomSuccessMessage {
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = Colors.green,
    Color textColor = Colors.white,
    VoidCallback? onDismiss,
  }) {
    // Add haptic feedback for better UX
    HapticFeedback.mediumImpact();

    // Create overlay entry
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 30,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: textColor, size: 24),
                  SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Add to overlay
    overlayState.insert(overlayEntry);

    // Remove after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
        if (onDismiss != null) {
          onDismiss();
        }
      }
    });
  }
}
