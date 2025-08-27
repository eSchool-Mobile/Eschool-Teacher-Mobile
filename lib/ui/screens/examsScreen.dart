import 'dart:ui';
import 'package:eschool_saas_staff/cubits/academics/sessionYearsAndMediumsCubit.dart';
import 'package:eschool_saas_staff/cubits/exam/offlineExamsCubit.dart';
import 'package:eschool_saas_staff/data/models/medium.dart';
import 'package:eschool_saas_staff/data/models/offlineExam.dart';
import 'package:eschool_saas_staff/data/models/offlineExamTimetableSlot.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customErrorWidget.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ExamsScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SessionYearsAndMediumsCubit(),
        ),
        BlocProvider(
          create: (context) => OfflineExamsCubit(),
        ),
      ],
      child: const ExamsScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen>
    with TickerProviderStateMixin {
  SessionYear? _selectedSessionYear;
  Medium? _selectedMedium;
  late AnimationController _controller;
  final ScrollController _scrollController = ScrollController();
  late ConfettiController _confettiController;
  bool _isRefreshing = false;
  String _filterStatus = "Semua"; // New variable for status filter
  bool _isFiltering = false;
  DateTime? _startDate; // For date range filtering
  DateTime? _endDate; // For date range filtering

  // Refined elegant maroon-based color palette
  final Color primaryColor = const Color(0xFF8B2635); // Deep maroon primary
  final Color accentColor = const Color(0xFFD4A59A); // Soft rose accent
  final Color completedColor =
      const Color(0xFF7D3C50); // Elegant maroon - sophisticated and modern
  final Color ongoingColor =
      const Color(0xFF7D3C50); // Navy blue - deeper and more elegant
  final Color upcomingColor =
      const Color(0xFF7D3C50); // Burgundy red - less harsh
  final Color cardBackgroundColor = const Color(0xFFFAF3F0); // Cream background
  final Color cardBorderColor = const Color(0xFFE7D8D1); // Soft border color
  final Color cardTextPrimary = const Color(0xFF3F3F3F); // Dark gray for text
  final Color cardTextSecondary =
      const Color(0xFF6D6D6D); // Medium gray for secondary text

  bool _showFilters = false;
  late AnimationController _pulseController;
  Color _highlightColor = const Color(0xFFD98E73); // Same as accentColor

  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _controller.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    // Fetch session years and mediums
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<SessionYearsAndMediumsCubit>().getSessionYearsAndMediums();

        // Immediately fetch exams without waiting for filters
        // This will load all exams with default parameters
        getExams();
      }
    });

    // Play confetti when the page loads
    Future.delayed(const Duration(milliseconds: 500), () {
      _confettiController.play();
    });
  }

  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void changeSelectedSessionYear(SessionYear sessionYear) {
    setState(() {
      _selectedSessionYear = sessionYear;
    });
  }

  void changeSelectedMedium(Medium medium) {
    setState(() {
      _selectedMedium = medium;
    });
  }

  Future<void> getExams() async {
    setState(() {
      _isRefreshing = true;
    });

    context.read<OfflineExamsCubit>().getOfflineExams(
        status: 3,
        mediumId: _selectedMedium?.id,
        sessionYearId: _selectedSessionYear?.id);

    setState(() {
      _isRefreshing = false;
    });
  }

  void _toggleFilter() {
    setState(() {
      _isFiltering = !_isFiltering;
      if (!_isFiltering) {
        _filterStatus = 'Semua';
        _startDate = null;
        _endDate = null;
        getExams();
      }
    });
  }

  List<OfflineExam> _filterExams(List<OfflineExam> exams) {
    if (_filterStatus == "Semua" && _startDate == null && _endDate == null) {
      return exams;
    }

    return exams.where((exam) {
      // Filter by status
      if (_filterStatus != "Semua") {
        final statusKey = exam.getOfflineStatusKey().toLowerCase();
        if (_filterStatus == "Selesai" && statusKey != 'completed')
          return false;
        if (_filterStatus == "Sedang Berlangsung" && statusKey != 'ongoing')
          return false;
        if (_filterStatus == "Akan Datang" && statusKey != 'upcoming')
          return false;
      }

      // Filter by date range
      if (_startDate != null || _endDate != null) {
        try {
          if (exam.examStartingDate == null || exam.examStartingDate!.isEmpty) {
            return false;
          }

          final examDate = DateTime.parse(exam.examStartingDate!);

          if (_startDate != null && examDate.isBefore(_startDate!)) {
            return false;
          }

          if (_endDate != null) {
            // Add one day to include the end date fully
            final endDatePlusOne = _endDate!.add(Duration(days: 1));
            if (examDate.isAfter(endDatePlusOne)) {
              return false;
            }
          }
        } catch (e) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the modal to take up more space
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: EdgeInsets.only(top: 8, bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Title
                    Text(
                      'Filter Ujian',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    // Date Range Filter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: modalContext,
                                initialDate: _startDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  _startDate = picked;
                                });
                                setState(() {
                                  _startDate = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _startDate != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(_startDate!)
                                    : 'Dari',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[800]),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '-',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: modalContext,
                                initialDate: _endDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  _endDate = picked;
                                });
                                setState(() {
                                  _endDate = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _endDate != null
                                    ? DateFormat('dd/MM/yyyy').format(_endDate!)
                                    : 'Sampai',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[800]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Status Filter Options - wrap in Container with fixed height
                    Container(
                      constraints: BoxConstraints(maxHeight: 200),
                      child: ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          _buildFilterOption('Semua', setModalState),
                          _buildFilterOption('Selesai', setModalState),
                          _buildFilterOption('Akan Datang', setModalState),
                          _buildFilterOption(
                              'Sedang Berlangsung', setModalState),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    // Apply Filter Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isFiltering = true;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Terapkan Filter'),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Reset Filter Button
                    if (_filterStatus != "Semua" ||
                        _startDate != null ||
                        _endDate != null)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            setModalState(() {
                              _filterStatus = "Semua";
                              _startDate = null;
                              _endDate = null;
                            });
                            setState(() {
                              _filterStatus = "Semua";
                              _startDate = null;
                              _endDate = null;
                              _isFiltering = false;
                            });
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor:
                                primaryColor, // Changed to maroon color
                          ),
                          child: Text(
                            'Reset Filter',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption(String label, StateSetter setModalState) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setModalState(() {
              _filterStatus = label;
            });
            setState(() {
              _filterStatus = label;
            });
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                Radio<String>(
                  value: label,
                  groupValue: _filterStatus,
                  onChanged: (value) {
                    setModalState(() {
                      _filterStatus = value ?? 'Semua';
                    });
                    setState(() {
                      _filterStatus = value ?? 'Semua';
                    });
                  },
                  activeColor: primaryColor,
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: Colors.grey[300]),
      ],
    );
  }

  Map<String, List<OfflineExam>> _groupExamsByMonth(List<OfflineExam> exams) {
    final Map<String, List<OfflineExam>> grouped = {};

    // Sort exams by date first
    final sortedExams = exams.toList()
      ..sort((a, b) {
        try {
          // Safely parse dates with null checks
          final DateTime dateA =
              a.examStartingDate != null && a.examStartingDate!.isNotEmpty
                  ? DateTime.parse(a.examStartingDate!)
                  : DateTime.now();
          final DateTime dateB =
              b.examStartingDate != null && b.examStartingDate!.isNotEmpty
                  ? DateTime.parse(b.examStartingDate!)
                  : DateTime.now();
          return dateA.compareTo(dateB);
        } catch (e) {
          // Handle parse errors by returning 0 (equal)
          return 0;
        }
      });

    for (var exam in sortedExams) {
      // Skip if date is missing or empty
      if (exam.examStartingDate == null || exam.examStartingDate!.isEmpty)
        continue;
      try {
        final dateTime = DateTime.parse(exam.examStartingDate!);
        final monthYear =
            "${Utils.getMonthFullName(dateTime.month)} ${dateTime.year}";

        if (!grouped.containsKey(monthYear)) {
          grouped[monthYear] = [];
        }

        grouped[monthYear]!.add(exam);
      } catch (e) {
        // Skip this exam if date parsing fails
        continue;
      }
    }

    return grouped;
  }

  Widget _buildExamItem(OfflineExam exam, int index) {
    // Check if timetable is still loading or has items
    final bool isLoading = exam.timetableSlots == null;
    final bool hasTimetable = isLoading ||
        exam.timetableSlots!
            .isNotEmpty; // Consider as having timetable if it's loading
    DateTime? examDate;
    String dayString = "";
    String monthString = ""; // Parse and format date safely
    if (exam.examStartingDate != null && exam.examStartingDate!.isNotEmpty) {
      try {
        examDate = DateTime.parse(exam.examStartingDate!);
        dayString = examDate.day.toString();
        monthString = Utils.getMonthName(examDate.month);
      } catch (e) {
        // Keep default values if parsing fails
      }
    }

    final statusKey = exam.getOfflineStatusKey().toLowerCase();
    final isCompleted = statusKey == 'completed';
    final isUpcoming = statusKey == 'upcoming';
    final isOngoing = statusKey == 'ongoing';

    final statusColor = _getStatusColor(statusKey);

    // Define header colors to match page header
    final headerStartColor = primaryColor; // 0xFF8B2635
    final headerEndColor =
        Color(0xFF5A2223); // Deeper shade matching page header

    // Generate random angle for the background pattern
    final randomAngle = (index * 37) % 360;

    return Hero(
        tag: 'exam-${exam.id}',
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: statusColor.withOpacity(0.1),
              highlightColor: statusColor.withOpacity(0.05),
              onTap: () {
                if (hasTimetable) {
                  HapticFeedback.mediumImpact();
                  Utils.showBottomSheet(
                    child: OfflineExamTimetableBottomsheet(
                      timetableSlots: exam.timetableSlots,
                      primaryColor: primaryColor,
                      exam: exam,
                      isLoading: isLoading,
                    ),
                    context: context,
                  );
                }
              },
              child: Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CustomPaint(
                        painter: ExamCardBackgroundPainter(
                          color: statusColor.withOpacity(0.06),
                          angle: randomAngle.toDouble(),
                        ),
                      ),
                    ),
                  ),

                  // Main card content
                  Container(
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header with status & date - Updated to match page header gradient
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  headerStartColor,
                                  headerEndColor,
                                ],
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            child: Row(
                              children: [
                                // Status indicator with icon
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isCompleted
                                        ? Icons.check_circle
                                        : isOngoing
                                            ? Icons.access_time_filled
                                            : Icons.event_available,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  _getStatusText(statusKey),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Spacer(),
                                // Date display
                                if (examDate != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          examDate != null
                                              ? _getDayName(examDate.weekday)
                                              : "-",
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Main content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Day container - Updated to match page header gradient
                              Container(
                                width: 65,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      headerStartColor,
                                      headerEndColor,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: headerStartColor.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(2, 3),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Background pattern
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Opacity(
                                          opacity: 0.15,
                                          child: CustomPaint(
                                            painter: CirclePatternPainter(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Content
                                    Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            dayString,
                                            style: GoogleFonts.poppins(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            monthString,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white
                                                  .withOpacity(0.85),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Exam details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exam.name ?? "-",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: statusColor.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.groups_rounded,
                                            size: 16,
                                            color: statusColor.withOpacity(0.7),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            Utils().cleanClassName(
                                                exam.className ?? "-"),
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ), // Footer with timetable indicator - always show, with loading state when needed
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.05),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            border: Border(
                              top: BorderSide(
                                color: statusColor.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color: statusColor.withOpacity(0.7),
                                  ),
                                  SizedBox(width: 8),
                                  // Show loading indicator if timetableSlots is null
                                  exam.timetableSlots == null
                                      ? Row(
                                          children: [
                                            SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: statusColor,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Memuat...",
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          "${exam.timetableSlots!.length} Mata Pelajaran",
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                ],
                              ),
                              Text(
                                "Selengkapnya",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate(delay: (80 * index).ms)
              .fadeIn(duration: 600.ms, curve: Curves.easeOut)
              .slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 800.ms,
                  curve: Curves.easeOutQuint)
              .scale(
                  begin: const Offset(0.97, 0.97),
                  end: const Offset(1.0, 1.0),
                  duration: 800.ms,
                  curve: Curves.easeOutQuint),
        ));
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return upcomingColor;
      case 'ongoing':
        return ongoingColor;
      case 'completed':
        return completedColor;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return "Akan Datang";
      case 'ongoing':
        return "Sedang Berlangsung";
      case 'completed':
        return "Selesai";
      default:
        return "Tidak Diketahui";
    }
  }

  String _getDayName(int weekday) {
    const days = [
      '',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    return days[weekday];
  }

  Widget _buildEmptyState() {
    String emptyMessage;
    IconData emptyIcon;

    // Determine the appropriate message and icon based on filters
    if (_filterStatus == "Semua" && _startDate == null && _endDate == null) {
      emptyMessage = "Belum ada jadwal ujian tersedia";
      emptyIcon = Icons.event_note_outlined;
    } else {
      // Generate specific messages based on active filters
      if (_filterStatus == "Akan Datang") {
        emptyMessage = "Tidak ada ujian yang akan datang";
        emptyIcon = Icons.schedule_outlined;
      } else if (_filterStatus == "Sedang Berlangsung") {
        emptyMessage = "Tidak ada ujian yang sedang berlangsung";
        emptyIcon = Icons.play_circle_outline;
      } else if (_filterStatus == "Selesai") {
        emptyMessage = "Tidak ada ujian yang telah selesai";
        emptyIcon = Icons.check_circle_outline;
      } else if (_startDate != null || _endDate != null) {
        emptyMessage = "Tidak ada ujian pada rentang tanggal yang dipilih";
        emptyIcon = Icons.date_range_outlined;
      } else {
        emptyMessage = "Tidak ditemukan hasil pencarian";
        emptyIcon = Icons.search_off_outlined;
      }
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with subtle animation
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              emptyIcon,
              size: 64,
              color: primaryColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 20),
          Text(
            emptyMessage,
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            "Coba ubah filter atau refresh halaman",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset filter button (if filters are active)
              if (_filterStatus != "Semua" ||
                  _startDate != null ||
                  _endDate != null)
                Container(
                  margin: EdgeInsets.only(right: 8),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _filterStatus = "Semua";
                        _startDate = null;
                        _endDate = null;
                      });
                      getExams();
                    },
                    icon: Icon(Icons.clear_all, size: 18),
                    label: Text("Reset Filter"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor.withOpacity(0.5)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              // Refresh button
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: getExams,
                  icon: Icon(Icons.refresh_rounded, size: 18),
                  label: Text("Refresh"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms).scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1.0, 1.0),
        duration: 600.ms,
        curve: Curves.easeOutQuint);
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.only(bottom: 20),
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return SlideInDown(
      duration: Duration(milliseconds: 800),
      child: Padding(
        padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Title with modern styling
                  Expanded(
                    child: Text(
                      "Jadwal Ujian",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              // Filter indicator chips - show applied filters
              if (_isFiltering)
                Container(
                  margin: EdgeInsets.only(top: 16),
                  height: 40,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_filterStatus != "Semua")
                          _buildFilterChip(
                            label: _filterStatus,
                            color: _getFilterStatusColor(_filterStatus),
                          ),
                        if (_startDate != null && _endDate != null)
                          _buildFilterChip(
                            label:
                                "${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}",
                            color: primaryColor,
                          )
                        else if (_startDate != null)
                          _buildFilterChip(
                            label:
                                "Dari ${DateFormat('dd/MM/yyyy').format(_startDate!)}",
                            color: primaryColor,
                          )
                        else if (_endDate != null)
                          _buildFilterChip(
                            label:
                                "Sampai ${DateFormat('dd/MM/yyyy').format(_endDate!)}",
                            color: primaryColor,
                          ),
                        if (_isFiltering)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _filterStatus = "Semua";
                                _startDate = null;
                                _endDate = null;
                                _isFiltering = false;
                              });
                              getExams();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(
                                    0.1), // Changed to maroon with opacity
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: primaryColor.withOpacity(
                                      0.5), // Changed to maroon with opacity
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.close,
                                      color: primaryColor,
                                      size: 16), // Changed to maroon color
                                  SizedBox(width: 4),
                                  Text(
                                    "Reset",
                                    style: TextStyle(
                                      color:
                                          primaryColor, // Changed to maroon color
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(
                    begin: -0.2,
                    end: 0,
                    duration: 300.ms,
                    curve: Curves.easeOut),

              // Show filters row - Session Years and Medium filters remain
              if (_showFilters)
                Container(
                  margin: EdgeInsets.only(top: 16, bottom: 8),
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterOptionChip(
                        label: _selectedSessionYear?.name ?? "Tahun Ajaran",
                        icon: Icons.calendar_today_outlined,
                        onTap: () {
                          if (context.read<SessionYearsAndMediumsCubit>().state
                              is SessionYearsAndMediumsFetchSuccess) {
                            final state = context
                                .read<SessionYearsAndMediumsCubit>()
                                .state as SessionYearsAndMediumsFetchSuccess;

                            Utils.showBottomSheet(
                              context: context,
                              child: FilterSelectionBottomsheet(
                                titleKey: "Pilih Tahun Ajaran",
                                values: state.sessionYears
                                    .map((e) => {
                                          "id": e.id,
                                          "title": e.name,
                                        })
                                    .toList(),
                                selectedValue: _selectedSessionYear?.id,
                                onSelection: (selectedItem) {
                                  final sessionYear =
                                      state.sessionYears.firstWhere(
                                    (element) =>
                                        element.id ==
                                        (selectedItem
                                            as Map<String, dynamic>)['id'],
                                  );
                                  changeSelectedSessionYear(sessionYear);
                                  getExams();
                                },
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(width: 10),
                      _buildFilterOptionChip(
                        label: _selectedMedium?.name ?? "Bahasa",
                        icon: Icons.language_rounded,
                        onTap: () {
                          if (context.read<SessionYearsAndMediumsCubit>().state
                              is SessionYearsAndMediumsFetchSuccess) {
                            final state = context
                                .read<SessionYearsAndMediumsCubit>()
                                .state as SessionYearsAndMediumsFetchSuccess;

                            Utils.showBottomSheet(
                              context: context,
                              child: FilterSelectionBottomsheet(
                                titleKey: "Pilih Bahasa",
                                values: state.mediums
                                    .map((e) => {
                                          "id": e.id,
                                          "title": e.name,
                                        })
                                    .toList(),
                                selectedValue: _selectedMedium?.id,
                                onSelection: (selectedItem) {
                                  final medium = state.mediums.firstWhere(
                                    (element) =>
                                        element.id ==
                                        (selectedItem
                                            as Map<String, dynamic>)['id'],
                                  );
                                  changeSelectedMedium(medium);
                                  getExams();
                                },
                              ),
                            );
                          }
                        },
                      ),
                      if (_selectedSessionYear != null ||
                          _selectedMedium != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: _buildFilterOptionChip(
                            label: "Reset Filter",
                            icon: Icons.refresh_rounded,
                            onTap: () {
                              setState(() {
                                _selectedSessionYear = null;
                                _selectedMedium = null;
                              });
                              getExams();
                            },
                          ),
                        ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(
                    begin: -0.2,
                    end: 0,
                    duration: 300.ms,
                    curve: Curves.easeOut),
            ],
          ),
        ),
      ),
    );
  }

  Color _getFilterStatusColor(String status) {
    switch (status) {
      case "Selesai":
        return completedColor;
      case "Sedang Berlangsung":
        return ongoingColor;
      case "Akan Datang":
        return upcomingColor;
      default:
        return primaryColor;
    }
  }

  Widget _buildFilterChip({
    required String label,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFilterOptionChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final bool isResetFilter = label == "Reset";

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: isResetFilter
                ? primaryColor
                : Colors.white, // Changed for Reset Filter
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isResetFilter
                    ? Colors.white
                    : primaryColor, // Changed for Reset Filter
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isResetFilter
                        ? Colors.white
                        : Colors.grey[800], // Changed for Reset Filter
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: isResetFilter
                    ? Colors.white.withOpacity(0.8)
                    : Colors.grey[600], // Changed for Reset Filter
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomModernAppBar(
        title: "Jadwal Ujian Offline",
        icon: Icons.assignment_rounded,
        fabAnimationController: _controller,
        primaryColor: primaryColor,
        lightColor: accentColor,
        onBackPressed: () => Navigator.pop(context),
        showFilterButton: true,
        onFilterPressed: () => _showFilterBottomSheet(context),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: BlocBuilder<OfflineExamsCubit, OfflineExamsState>(
              builder: (context, state) {
                if (state is OfflineExamsFetchSuccess) {
                  final filteredExams = _filterExams(state.offlineExams);
                  final groupedExams = _groupExamsByMonth(filteredExams);

                  if (filteredExams.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 20),
                    itemCount: groupedExams.length,
                    itemBuilder: (context, index) {
                      final monthYear = groupedExams.keys.elementAt(index);
                      final exams = groupedExams[monthYear]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                              monthYear,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          ...exams
                              .asMap()
                              .entries
                              .map((entry) =>
                                  _buildExamItem(entry.value, entry.key))
                              .toList(),
                        ],
                      );
                    },
                  );
                } else if (state is OfflineExamsFetchInProgress) {
                  return _buildLoadingShimmer();
                } else {
                  return CustomErrorWidget(
                    onRetry: getExams,
                    message: "Gagal memuat data ujian",
                    primaryColor: primaryColor,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

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
                  color: primaryColor
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

  Animation<double> get _pulseAnimation => CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      );
}

class OfflineExamTimetableBottomsheet extends StatelessWidget {
  final List<OfflineExamTimeTableSlot>? timetableSlots;
  final Color primaryColor;
  final OfflineExam exam;
  final bool isLoading;

  const OfflineExamTimetableBottomsheet({
    super.key,
    required this.timetableSlots,
    this.primaryColor = const Color(0xFF8B2635),
    required this.exam,
    this.isLoading = false,
  });
  @override
  Widget build(BuildContext context) {
    // Check if timetableSlots is null or empty
    final bool hasTimetableData =
        timetableSlots != null && timetableSlots!.isNotEmpty;

    // Sort slots by date if they exist
    final sortedSlots = hasTimetableData
        ? (timetableSlots!.toList()
          ..sort((a, b) {
            try {
              final dateA = DateTime.parse(a.date!);
              final dateB = DateTime.parse(b.date!);
              return dateA.compareTo(dateB);
            } catch (e) {
              return 0;
            }
          }))
        : <OfflineExamTimeTableSlot>[];

    // Group slots by date if they exist
    Map<String, List<OfflineExamTimeTableSlot>> groupedByDate = {};
    if (hasTimetableData) {
      for (var slot in sortedSlots) {
        if (slot.date == null) continue;

        String formattedDate = '';
        try {
          final date = DateTime.parse(slot.date!);
          formattedDate = Utils.formatDate(date);
        } catch (e) {
          continue;
        }

        if (!groupedByDate.containsKey(formattedDate)) {
          groupedByDate[formattedDate] = [];
        }
        groupedByDate[formattedDate]!.add(slot);
      }
    }

    return CustomBottomsheet(
      titleLabelKey: "Jadwal Ujian",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Exam Header Card with glass effect
          _buildExamHeaderCard(context),
          SizedBox(height: 20), // Timetable content
          Flexible(
            child: timetableSlots == null
                ? _buildLoadingState() // Tampilkan loading state jika timetableSlots == null
                : sortedSlots.isEmpty
                    ? _buildEmptyState()
                    : _buildTimetableContent(context, groupedByDate),
          ),
        ],
      ),
    );
  }

  Widget _buildExamHeaderCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Fancy gradient background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF690013),
                      primaryColor,
                      const Color(0xFFA12948),
                      const Color(0xFFAA6976),
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Decorative pattern elements
            Positioned.fill(
              child: CustomPaint(
                painter: ModernPatternPainter(
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),

            // Glowing effect
            Positioned(
              top: -70,
              right: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Section with icon and title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon container
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.9),
                              Colors.white.withOpacity(0.4),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          color: primaryColor,
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Title and class info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Exam name
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white,
                                    Colors.white.withOpacity(0.9),
                                  ],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcIn,
                              child: Text(
                                exam.name ?? "Jadwal Ujian",
                                style: GoogleFonts.poppins(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: const Offset(0, 1),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Class name
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                Utils().cleanClassName(exam.className ?? "-"),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Info Section with glass effect
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Dates Row
                            Row(
                              children: [
                                // Start date
                                _buildDateInfo(
                                  icon: Icons.calendar_today_rounded,
                                  title: "Tanggal Mulai",
                                  value: exam.examStartingDate != null &&
                                          exam.examStartingDate!.isNotEmpty
                                      ? Utils.formatDate(DateTime.parse(
                                          exam.examStartingDate!))
                                      : "-",
                                ),

                                SizedBox(width: 16),

                                // End date
                                _buildDateInfo(
                                  icon: Icons.event_rounded,
                                  title: "Tanggal Selesai",
                                  value: exam.examEndingDate != null &&
                                          exam.examEndingDate!.isNotEmpty
                                      ? Utils.formatDate(
                                          DateTime.parse(exam.examEndingDate!))
                                      : "-",
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            Divider(
                                color: Colors.white.withOpacity(0.2),
                                height: 1),
                            SizedBox(height: 12),

                            // Stats Row
                            Row(
                              children: [
                                // Subject count
                                _buildStatInfo(
                                  icon: Icons.subject_rounded,
                                  value: "${timetableSlots?.length ?? "-"}",
                                  label: "Pelajaran",
                                ),

                                const SizedBox(width: 24),

                                // Duration
                                _buildStatInfo(
                                  icon: Icons.timer_outlined,
                                  value: _calculateTotalDuration(),
                                  label: "Total Durasi",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.easeOutQuint,
        );
  }

  // Helper method for date information
  Widget _buildDateInfo({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for stat information
  Widget _buildStatInfo({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _calculateTotalDuration() {
    try {
      if (timetableSlots == null) {
        return "-";
      }

      int totalMinutes = 0;

      for (var slot in timetableSlots!) {
        if (slot.startTime != null && slot.endTime != null) {
          final startHour = Utils.getHourFromTimeDetails(time: slot.startTime!);
          final startMinute =
              Utils.getMinuteFromTimeDetails(time: slot.startTime!);
          final endHour = Utils.getHourFromTimeDetails(time: slot.endTime!);
          final endMinute = Utils.getMinuteFromTimeDetails(time: slot.endTime!);

          final startTotalMinutes = startHour * 60 + startMinute;
          final endTotalMinutes = endHour * 60 + endMinute;
          final duration = endTotalMinutes - startTotalMinutes;

          if (duration > 0) {
            totalMinutes += duration;
          }
        }
      }

      final hours = totalMinutes ~/ 60;
      return hours > 0 ? "$hours jam" : "${totalMinutes % 60} menit";
    } catch (e) {
      return "-";
    }
  }

  Widget _buildTimetableContent(BuildContext context,
      Map<String, List<OfflineExamTimeTableSlot>> groupedByDate) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: 24),
      itemCount: groupedByDate.length,
      itemBuilder: (context, dateIndex) {
        final date = groupedByDate.keys.elementAt(dateIndex);
        final slots = groupedByDate[date]!;
        final firstDateSlot = slots.first;

        // Parse the date to extract day number and day name
        DateTime? parsedDate;
        String dayName = "";
        String dayNumber = "";

        try {
          parsedDate = DateTime.parse(firstDateSlot.date!);
          dayName = _getDayName(parsedDate.weekday);
          dayNumber = parsedDate.day.toString();
        } catch (e) {
          // Use defaults
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern date header with day visualization
            Container(
              margin: const EdgeInsets.only(bottom: 18, top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Adding padding to shift the circular date to the right
                  SizedBox(width: 15),
                  // Day number in circle
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, Color(0xFF5A2223)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        dayNumber,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 14),

                  // Day name and date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dayName,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              parsedDate != null
                                  ? DateFormat('MMMM yyyy', 'id')
                                      .format(parsedDate)
                                  : "-",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Exam count chip
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(
                  duration: 400.ms,
                  delay: (100 * dateIndex).ms,
                )
                .slideX(
                  begin: -0.1,
                  end: 0,
                  duration: 500.ms,
                  delay: (100 * dateIndex).ms,
                  curve: Curves.easeOutQuint,
                ),

            // Subjects for this date in a timeline layout
            ...List.generate(
              slots.length,
              (index) => _buildSubjectTimelineCard(context, slots[index],
                  dateIndex * 100 + index, index == slots.length - 1),
            ),
          ],
        );
      },
    );
  }

  String _getDayName(int weekday) {
    const days = [
      '',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    return days[weekday];
  }

  Widget _buildSubjectTimelineCard(BuildContext context,
      OfflineExamTimeTableSlot slot, int animationIndex, bool isLast) {
    final subjectName = slot.subject?.getSybjectNameWithType() ?? "-";
    return Container(
      margin: EdgeInsets.only(left: 41, right: 26, bottom: isLast ? 0 : 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject header with time
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor,
                          Color(0xFF5A2223), // Deeper complementary shade
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Decorative elegant circle patterns
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: CustomPaint(
                              painter: ElegantCirclesDecorationPainter(
                                  color: Colors.white),
                            ),
                          ),
                        ),

                        // Main content
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 18, vertical: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Subject icon
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.book,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 14),

                              // Subject name with improved typography
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pelajaran',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white.withOpacity(0.7),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    CustomTextContainer(
                                      textKey: subjectName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        height: 1.2,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Elegant time display
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.95),
                                      Colors.white.withOpacity(0.85),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 14,
                                      color: primaryColor,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "${Utils.formatTime(
                                        timeOfDay: TimeOfDay(
                                          hour: Utils.getHourFromTimeDetails(
                                              time: slot.startTime!),
                                          minute:
                                              Utils.getMinuteFromTimeDetails(
                                                  time: slot.startTime!),
                                        ),
                                        context: context,
                                      )}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Details section
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Time and duration info
                        Row(
                          children: [
                            _buildInfoItem(
                              title: "Durasi",
                              value: _calculateDuration(
                                  slot.startTime!, slot.endTime!),
                              icon: Icons.timer_outlined,
                              color: primaryColor,
                            ),
                            SizedBox(width: 8),
                            _buildInfoItem(
                              title: "Waktu Selesai",
                              value: Utils.formatTime(
                                timeOfDay: TimeOfDay(
                                  hour: Utils.getHourFromTimeDetails(
                                      time: slot.endTime!),
                                  minute: Utils.getMinuteFromTimeDetails(
                                      time: slot.endTime!),
                                ),
                                context: context,
                              ),
                              icon: Icons.access_time_filled_rounded,
                              color: Color(0xFF5A6ACF),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        // Marks row
                        Row(
                          children: [
                            _buildInfoItem(
                              title: "Nilai Total",
                              value: "${slot.totalMarks ?? 0}",
                              icon: Icons.assignment_rounded,
                              color: Color(0xFF43A047),
                            ),
                            SizedBox(width: 8),
                            _buildInfoItem(
                              title: "Nilai Kelulusan",
                              value: "${slot.passingMarks ?? 0}",
                              icon: Icons.check_circle_rounded,
                              color: Color(0xFFE57373),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: (80 * animationIndex).ms)
        .slideX(
            begin: 0.1,
            end: 0,
            curve: Curves.easeOutQuint,
            duration: 600.ms,
            delay: (80 * animationIndex).ms);
  }

  Widget _buildInfoItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy,
              size: 64,
              color: primaryColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Tidak ada jadwal tersedia",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Jadwal ujian akan ditampilkan di sini",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  String _calculateDuration(String startTime, String endTime) {
    try {
      final startHour = Utils.getHourFromTimeDetails(time: startTime);
      final startMinute = Utils.getMinuteFromTimeDetails(time: startTime);
      final endHour = Utils.getHourFromTimeDetails(time: endTime);
      final endMinute = Utils.getMinuteFromTimeDetails(time: endTime);

      final startMinutes = startHour * 60 + startMinute;
      final endMinutes = endHour * 60 + endMinute;
      final durationMinutes = endMinutes - startMinutes;

      if (durationMinutes <= 0) return "N/A";

      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;

      if (hours > 0) {
        return "$hours jam ${minutes > 0 ? "$minutes menit" : ""}";
      } else {
        return "$minutes menit";
      }
    } catch (e) {
      return "N/A";
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: primaryColor,
          ),
          SizedBox(height: 16),
          Text(
            "Memuat data ujian...",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

class ExamCardBackgroundPainter extends CustomPainter {
  final Color color;
  final double angle;

  ExamCardBackgroundPainter({required this.color, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw patterned background with rotated lines
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle * (3.14159 / 180));
    canvas.translate(-center.dx, -center.dy);

    final spacing = 12.0;
    for (double i = -size.width; i < size.width * 2; i += spacing) {
      canvas.drawLine(
        Offset(i, -size.height),
        Offset(i + size.height * 2, size.height * 2),
        paint..strokeWidth = 4,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CirclePatternPainter extends CustomPainter {
  final Color color;

  CirclePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw decorative circles
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.3),
      size.width * 0.4,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.7),
      size.width * 0.3,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CornerDecoratorPainter extends CustomPainter {
  final Color color;

  CornerDecoratorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..moveTo(size.width * 0.3, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.7)
      ..close();

    canvas.drawPath(path, paint);

    // Draw a smaller accent path
    final path2 = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.5)
      ..close();

    canvas.drawPath(path2, paint..color = color.withOpacity(0.6));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ModernPatternPainter extends CustomPainter {
  final Color color;

  ModernPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw decorative patterns
    // Abstract circular patterns
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.3),
      size.width * 0.2,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.7),
      size.width * 0.15,
      paint,
    );

    // Draw diagonal lines
    for (int i = 0; i < 5; i++) {
      final offset = i * 20.0;
      canvas.drawLine(
        Offset(size.width - offset, 0),
        Offset(size.width, offset),
        paint,
      );
    }

    // Draw abstract decorations in the corner
    final path = Path()
      ..moveTo(size.width, size.height * 0.7)
      ..lineTo(size.width * 0.7, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ElegantCirclesDecorationPainter extends CustomPainter {
  final Color color;

  ElegantCirclesDecorationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw multiple decorative circles with varying sizes and positions
    for (int i = 0; i < 5; i++) {
      double opacity = 0.1 - (i * 0.02);
      paint.color = color.withOpacity(opacity > 0 ? opacity : 0.01);

      // Large circle in the top right
      canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.3),
        size.width * (0.25 + i * 0.1),
        paint,
      );

      // Small circle in the bottom left
      canvas.drawCircle(
        Offset(size.width * 0.15, size.height * 0.7),
        size.width * (0.15 + i * 0.05),
        paint,
      );
    }

    // Add a few accent dots
    paint.style = PaintingStyle.fill;
    paint.color = color.withOpacity(0.2);

    canvas.drawCircle(
      Offset(size.width * 0.95, size.height * 0.15),
      3,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.05, size.height * 0.85),
      2,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.9),
      4,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
