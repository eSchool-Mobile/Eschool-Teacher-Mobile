import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/assignment/teacherAssignmentDetailCubit.dart';
import 'package:eschool_saas_staff/data/models/teacherAssignmentDetail.dart';
import 'package:eschool_saas_staff/data/repositories/assignmentMonitoringRepository.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AssignmentDetailMonitoringScreen extends StatefulWidget {
  final int teacherId;
  final String teacherName;

  const AssignmentDetailMonitoringScreen({
    Key? key,
    required this.teacherId,
    required this.teacherName,
  }) : super(key: key);

  static Widget getRouteInstance(
      {required int teacherId, required String teacherName}) {
    return BlocProvider(
      create: (context) => TeacherAssignmentDetailCubit(
        AssignmentMonitoringRepository(),
      ),
      child: AssignmentDetailMonitoringScreen(
        teacherId: teacherId,
        teacherName: teacherName,
      ),
    );
  }

  @override
  State<AssignmentDetailMonitoringScreen> createState() =>
      _AssignmentDetailMonitoringScreenState();
}

class _AssignmentDetailMonitoringScreenState
    extends State<AssignmentDetailMonitoringScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // Define colors
  final Color maroonPrimary = const Color(0xFF8B1F41);
  final Color maroonLight = const Color(0xFFAC3B5C);
  final Color maroonDark = const Color(0xFF6A0F2A);
  final Color accentColor = const Color(0xFFF5EBE0);
  final Color bgColor = const Color(0xFFFAF6F2);
  final Color cardColor = Colors.white;
  final Color textDarkColor = const Color(0xFF2D2D2D);
  final Color textMediumColor = const Color(0xFF717171);
  final Color borderColor = const Color(0xFFE8E8E8);

  // Filter variables
  String _selectedClass = '';
  String _selectedSubject = '';
  String _submissionStatus = '';
  DateTime? _startDate;
  DateTime? _endDate;

  // Lists for dropdown options
  final List<String> _classes = [];
  final List<String> _subjects = [];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Start animations
    _animationController.forward();

    // Set current date range to the last 30 days by default
    _endDate = DateTime.now();
    _startDate = _endDate?.subtract(const Duration(days: 30));

    // Set default submission status as empty (show all)
    _submissionStatus = '';

    // Load initial data
    _fetchTeacherAssignmentDetails();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _fetchTeacherAssignmentDetails() {
    final String? formattedStartDate = _startDate != null
        ? DateFormat('yyyy-MM-dd').format(_startDate!)
        : null;

    final String? formattedEndDate =
        _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null;

    context.read<TeacherAssignmentDetailCubit>().getTeacherAssignmentDetails(
          teacherId: widget.teacherId,
          submissionStatus: _submissionStatus,
          startDate: formattedStartDate,
          endDate: formattedEndDate,
        );
  }

  void _changeSubmissionStatus(String status) {
    HapticFeedback.lightImpact();
    setState(() {
      _submissionStatus = status;
    });
    _fetchTeacherAssignmentDetails();
  }

  void _changeClass(String className) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedClass = className;
    });
    // Here you would filter assignments based on the selected class
    // We'll implement the visual filtering in the UI layer since we don't have API endpoint for that
  }

  void _changeSubject(String subject) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedSubject = subject;
    });
    // Here you would filter assignments based on the selected subject
    // We'll implement the visual filtering in the UI layer since we don't have API endpoint for that
  }

  void _changeDateRange(DateTime? start, DateTime? end) {
    if (start != null && end != null) {
      HapticFeedback.lightImpact();
      setState(() {
        _startDate = start;
        _endDate = end;
      });
      _fetchTeacherAssignmentDetails();
    }
  }

  void _showClassFilter(BuildContext context) {
    // Get unique classes from the assignments
    final assignments = (context.read<TeacherAssignmentDetailCubit>().state
                as TeacherAssignmentDetailSuccess?)
            ?.assignments ??
        [];

    final Set<String> uniqueClasses =
        assignments.map((assignment) => assignment.classSection).toSet();

    final List<String> options = ['Semua Kelas', ...uniqueClasses];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Kelas',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: maroonDark,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(options[index]),
                      leading: Radio(
                        value: options[index],
                        groupValue: _selectedClass == '' && index == 0
                            ? 'Semua Kelas'
                            : _selectedClass,
                        activeColor: maroonPrimary,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _changeClass(
                              value == 'Semua Kelas' ? '' : value ?? '');
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSubjectFilter(BuildContext context) {
    // Get unique subjects from the assignments
    final assignments = (context.read<TeacherAssignmentDetailCubit>().state
                as TeacherAssignmentDetailSuccess?)
            ?.assignments ??
        [];

    final Set<String> uniqueSubjects =
        assignments.map((assignment) => assignment.subject).toSet();

    final List<String> options = ['Semua Mata Pelajaran', ...uniqueSubjects];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Mata Pelajaran',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: maroonDark,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(options[index]),
                      leading: Radio(
                        value: options[index],
                        groupValue: _selectedSubject == '' && index == 0
                            ? 'Semua Mata Pelajaran'
                            : _selectedSubject,
                        activeColor: maroonPrimary,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _changeSubject(value == 'Semua Mata Pelajaran'
                              ? ''
                              : value ?? '');
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDateRangePicker(BuildContext context) {
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        end: _endDate ?? DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: maroonPrimary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    ).then((dateRange) {
      if (dateRange != null) {
        _changeDateRange(dateRange.start, dateRange.end);
      }
    });
  }

  void _showSubmissionStatusFilter(BuildContext context) {
    final List<Map<String, String>> statusOptions = [
      {"value": "", "label": "Semua Status"},
      {"value": "submitted", "label": "Dikumpulkan"},
      {"value": "not_submitted", "label": "Belum Dikumpulkan"},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Status',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: maroonDark,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: statusOptions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(statusOptions[index]["label"]!),
                    leading: Radio(
                      value: statusOptions[index]["value"]!,
                      groupValue: _submissionStatus,
                      activeColor: maroonPrimary,
                      onChanged: (value) {
                        Navigator.pop(context);
                        _changeSubmissionStatus(value ?? '');
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 100,
            color: maroonLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada tugas ditemukan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textMediumColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter atau cek di lain waktu',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: textMediumColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentItem(TeacherAssignmentDetail assignment) {
    // Skip filtering if no filter is selected
    if (_selectedClass.isNotEmpty &&
        !assignment.classSection.contains(_selectedClass)) {
      return const SizedBox.shrink();
    }

    if (_selectedSubject.isNotEmpty &&
        !assignment.subject.contains(_selectedSubject)) {
      return const SizedBox.shrink();
    }

    // Calculate submission rate
    final submissionRate = assignment.points > 0
        ? (assignment.submissionsCount / assignment.points * 100).toInt()
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to assignment detail if needed
            // Navigator.pushNamed(context, Routes.assignmentDetailScreen, arguments: assignment.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Assignment name with subject badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: maroonPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              assignment.subject,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: maroonPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            assignment.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textDarkColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Class badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Text(
                        assignment.classSection,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Due date and points
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: textMediumColor),
                        const SizedBox(width: 6),
                        Text(
                          'Terakhir: ${DateFormat('dd MMM yyyy').format(assignment.dueDate)}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: textMediumColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.people_outline,
                            size: 16, color: textMediumColor),
                        const SizedBox(width: 6),
                        Text(
                          '${assignment.submissionsCount}/${assignment.points} siswa',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: textMediumColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress Pengumpulan',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textDarkColor,
                          ),
                        ),
                        Text(
                          '$submissionRate%',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _getProgressColor(submissionRate),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: submissionRate / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(submissionRate),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Color _getProgressColor(int rate) {
    if (rate >= 75) return Colors.green;
    if (rate >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Custom App Bar with filters
          CustomModernAppBar(
            title: widget.teacherName,
            icon: Icons.assignment_outlined,
            fabAnimationController: _animationController,
            primaryColor: maroonPrimary,
            lightColor: maroonLight,
            height: 80,
            onBackPressed: () => Navigator.pop(context),
            showFilterButton: true,
            onFilterPressed: () => _showDateRangePicker(context),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Class filter
                  FilterChip(
                    label: Text(
                      _selectedClass.isEmpty ? 'Kelas' : _selectedClass,
                      style: GoogleFonts.poppins(
                        color: _selectedClass.isEmpty
                            ? textMediumColor
                            : maroonPrimary,
                      ),
                    ),
                    selected: _selectedClass.isNotEmpty,
                    selectedColor: maroonPrimary.withOpacity(0.1),
                    backgroundColor: Colors.white,
                    onSelected: (_) => _showClassFilter(context),
                    avatar: Icon(
                      Icons.class_outlined,
                      size: 18,
                      color: _selectedClass.isEmpty
                          ? textMediumColor
                          : maroonPrimary,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Subject filter
                  FilterChip(
                    label: Text(
                      _selectedSubject.isEmpty
                          ? 'Mata Pelajaran'
                          : _selectedSubject,
                      style: GoogleFonts.poppins(
                        color: _selectedSubject.isEmpty
                            ? textMediumColor
                            : maroonPrimary,
                      ),
                    ),
                    selected: _selectedSubject.isNotEmpty,
                    selectedColor: maroonPrimary.withOpacity(0.1),
                    backgroundColor: Colors.white,
                    onSelected: (_) => _showSubjectFilter(context),
                    avatar: Icon(
                      Icons.book_outlined,
                      size: 18,
                      color: _selectedSubject.isEmpty
                          ? textMediumColor
                          : maroonPrimary,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Submission status filter
                  FilterChip(
                    label: Text(
                      _submissionStatus.isEmpty
                          ? 'Semua Status'
                          : _submissionStatus == 'submitted'
                              ? 'Dikumpulkan'
                              : 'Belum Dikumpulkan',
                      style: GoogleFonts.poppins(
                        color: _submissionStatus.isEmpty
                            ? textMediumColor
                            : maroonPrimary,
                      ),
                    ),
                    selected: _submissionStatus.isNotEmpty,
                    selectedColor: maroonPrimary.withOpacity(0.1),
                    backgroundColor: Colors.white,
                    onSelected: (_) => _showSubmissionStatusFilter(context),
                    avatar: Icon(
                      Icons.filter_list,
                      size: 18,
                      color: _submissionStatus.isEmpty
                          ? textMediumColor
                          : maroonPrimary,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Date range filter
                  FilterChip(
                    label: Text(
                      _startDate != null && _endDate != null
                          ? '${DateFormat('dd/MM').format(_startDate!)} - ${DateFormat('dd/MM').format(_endDate!)}'
                          : 'Tanggal',
                      style: GoogleFonts.poppins(
                        color: _startDate != null
                            ? maroonPrimary
                            : textMediumColor,
                      ),
                    ),
                    selected: _startDate != null,
                    selectedColor: maroonPrimary.withOpacity(0.1),
                    backgroundColor: Colors.white,
                    onSelected: (_) => _showDateRangePicker(context),
                    avatar: Icon(
                      Icons.date_range,
                      size: 18,
                      color:
                          _startDate != null ? maroonPrimary : textMediumColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main content
          Expanded(
            child: BlocBuilder<TeacherAssignmentDetailCubit,
                TeacherAssignmentDetailState>(
              builder: (context, state) {
                if (state is TeacherAssignmentDetailLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: maroonPrimary,
                    ),
                  );
                } else if (state is TeacherAssignmentDetailFailure) {
                  return ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () => _fetchTeacherAssignmentDetails(),
                  );
                } else if (state is TeacherAssignmentDetailSuccess) {
                  // Filter assignments based on selected class and subject (if API doesn't support)
                  final assignments = state.assignments;

                  if (assignments.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    color: maroonPrimary,
                    onRefresh: () async => _fetchTeacherAssignmentDetails(),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Assignment count and date info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Daftar Tugas (${assignments.length})',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textDarkColor,
                              ),
                            ),
                            if (_startDate != null && _endDate != null)
                              Text(
                                '${DateFormat('dd/MM').format(_startDate!)} - ${DateFormat('dd/MM').format(_endDate!)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: textMediumColor,
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Assignment list with filtered view
                        ...assignments.map(_buildAssignmentItem).toList(),
                      ],
                    ),
                  );
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: maroonLight.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pilih filter untuk melihat tugas',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: textMediumColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilterChip extends StatelessWidget {
  final Widget label;
  final bool selected;
  final Color backgroundColor;
  final Color selectedColor;
  final Function(bool)? onSelected;
  final Widget? avatar;

  const FilterChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.backgroundColor,
    required this.selectedColor,
    this.onSelected,
    this.avatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected?.call(!selected),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? selectedColor : backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? selectedColor : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (avatar != null) ...[
                avatar!,
                const SizedBox(width: 6),
              ],
              label,
            ],
          ),
        ),
      ),
    );
  }
}
