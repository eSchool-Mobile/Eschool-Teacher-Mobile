import 'dart:ui';
import 'package:eschool_saas_staff/cubits/academics/sessionYearsAndMediumsCubit.dart';
import 'package:eschool_saas_staff/cubits/exam/offlineExamsCubit.dart';
import 'package:eschool_saas_staff/data/models/medium.dart';
import 'package:eschool_saas_staff/data/models/offlineExam.dart';
import 'package:eschool_saas_staff/data/models/offlineExamTimetableSlot.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.only(top: 8),
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
                                  ? DateFormat('dd/MM/yyyy').format(_startDate!)
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
                  // Status Filter Options
                  Column(
                    children: [
                      _buildFilterOption('Semua', setModalState),
                      _buildFilterOption('Selesai', setModalState),
                      _buildFilterOption('Akan Datang', setModalState),
                      _buildFilterOption('Sedang Berlangsung', setModalState),
                    ],
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
                          foregroundColor: Colors.grey[700],
                        ),
                        child: Text('Reset Filter'),
                      ),
                    ),
                ],
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
        final monthYear = "${months[dateTime.month - 1]} ${dateTime.year}";

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
    final bool hasTimetable = (exam.timetableSlots ?? []).isNotEmpty;
    DateTime? examDate;
    String dayString = "";
    String monthString = "";

    // Parse and format date safely
    if (exam.examStartingDate != null && exam.examStartingDate!.isNotEmpty) {
      try {
        examDate = DateTime.parse(exam.examStartingDate!);
        dayString = examDate.day.toString();
        monthString = months[examDate.month - 1].substring(0, 3);
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
                    timetableSlots: exam.timetableSlots ?? [],
                    primaryColor: primaryColor,
                    exam: exam,
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
                                        Utils.formatDate(examDate),
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
                                            color:
                                                Colors.white.withOpacity(0.85),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),

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
                      ),

                      // Footer with timetable indicator
                      if (hasTimetable)
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
                                  Text(
                                    "${exam.timetableSlots?.length ?? 0} Mata Pelajaran",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "Lihat Detail",
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
        ),
      )
          .animate(delay: (80 * index).ms)
          .fadeIn(duration: 600.ms, curve: Curves.easeOut)
          .slideY(
              begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOutQuint)
          .scale(
              begin: const Offset(0.97, 0.97),
              end: const Offset(1.0, 1.0),
              duration: 800.ms,
              curve: Curves.easeOutQuint),
    );
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LottieBuilder.network(
            'https://assets1.lottiefiles.com/packages/lf20_kljv8dtk.json',
            width: 220,
            height: 220,
          ),
          SizedBox(height: 20),
          Text(
            _filterStatus == "Semua"
                ? "Belum ada jadwal ujian tersedia"
                : "Tidak ditemukan hasil pencarian",
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
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
              icon: Icon(Icons.refresh_rounded),
              label: Text("Refresh"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background dengan animated gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryColor.withOpacity(0.05),
                  Colors.white,
                ],
              ),
            ),
          ),

          // Main content with curved container
          BlocBuilder<SessionYearsAndMediumsCubit, SessionYearsAndMediumsState>(
            builder: (context, state) {
              if (state is SessionYearsAndMediumsFetchSuccess) {
                if (state.mediums.isNotEmpty && state.sessionYears.isNotEmpty) {
                  return SafeArea(
                    child: Stack(
                      children: [
                        // Modern header - pindahkan ke belakang
                        Container(
                          height: Get.height, // Tambahkan height penuh
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primaryColor,
                                Color(0xFF5A2223), // Deeper shade
                              ],
                            ),
                          ),
                        ),

                        // Header content
                        _buildHeader(),

                        // Curved container with exams content - posisikan di atas dengan margin top
                        Positioned(
                          top: 170, // Sesuaikan dengan tinggi header
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.95),
                                  Color(0xFFFFF0F0),
                                ],
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                  offset: Offset(0, -5),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 30,
                                  offset: Offset(0, -10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                              child: BlocBuilder<OfflineExamsCubit,
                                  OfflineExamsState>(
                                builder: (context, state) {
                                  if (state is OfflineExamsFetchSuccess) {
                                    List<OfflineExam> filteredExams =
                                        _filterExams(state.offlineExams);
                                    final groupedExams =
                                        _groupExamsByMonth(filteredExams);

                                    if (groupedExams.isEmpty) {
                                      return _buildEmptyState();
                                    }

                                    return RefreshIndicator(
                                      color: primaryColor,
                                      backgroundColor: Colors.white,
                                      strokeWidth: 3,
                                      onRefresh: getExams,
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        padding: EdgeInsets.fromLTRB(
                                            appContentHorizontalPadding,
                                            8,
                                            appContentHorizontalPadding,
                                            30),
                                        itemCount: groupedExams.length,
                                        itemBuilder: (context, index) {
                                          final monthYear = groupedExams.keys
                                              .elementAt(index);
                                          final exams =
                                              groupedExams[monthYear]!;

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20,
                                                    bottom: 16,
                                                    left: 6),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 8),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            primaryColor,
                                                            primaryColor
                                                                .withOpacity(
                                                                    0.8),
                                                          ],
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: primaryColor
                                                                .withOpacity(
                                                                    0.3),
                                                            blurRadius: 8,
                                                            offset:
                                                                const Offset(
                                                                    0, 3),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Text(
                                                        monthYear,
                                                        style:
                                                            GoogleFonts.poppins(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Divider(
                                                        height: 20,
                                                        thickness: 1,
                                                        indent: 14,
                                                        endIndent: 8,
                                                        color: Colors.grey[300],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              ...List.generate(
                                                exams.length,
                                                (i) => _buildExamItem(
                                                        exams[i], i)
                                                    .animate(delay: (80 * i).ms)
                                                    .fadeIn(
                                                        duration: 500.ms,
                                                        curve: Curves.easeOut)
                                                    .slideY(
                                                        begin: 0.2,
                                                        end: 0,
                                                        duration: 600.ms,
                                                        curve: Curves
                                                            .easeOutQuint),
                                              ),
                                            ],
                                          )
                                              .animate(delay: (150 * index).ms)
                                              .fadeIn(duration: 500.ms);
                                        },
                                      ),
                                    );
                                  }

                                  if (state is OfflineExamsFetchFailure) {
                                    return Center(
                                      child: ErrorContainer(
                                        errorMessage: state.errorMessage,
                                        onTapRetry: getExams,
                                      ),
                                    );
                                  }

                                  if (state is OfflineExamsFetchInProgress) {
                                    return _buildLoadingShimmer();
                                  }

                                  return Center(
                                    child: CustomCircularProgressIndicator(
                                      indicatorColor: primaryColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              }

              if (state is SessionYearsAndMediumsFetchFailure) {
                return Center(
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      context
                          .read<SessionYearsAndMediumsCubit>()
                          .getSessionYearsAndMediums();
                    },
                  ),
                );
              }

              return Center(
                child: CustomCircularProgressIndicator(
                  indicatorColor: primaryColor,
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildHeader() {
    return SlideInDown(
      duration: Duration(milliseconds: 800),
      child: Padding(
        padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Back button with advanced ripple and glow effects
                _buildGlowingIconButton(
                  Icons.arrow_back_rounded,
                  () {
                    HapticFeedback.mediumImpact();
                    Get.back();
                  },
                ),
                SizedBox(width: 15),

                // Title with modern styling
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Jadwal Ujian",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Ujian Siswa',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter button instead of search
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _showFilterBottomSheet(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          boxShadow: [
                            BoxShadow(
                              color: _highlightColor.withOpacity(
                                  0.1 + 0.1 * _pulseAnimation.value),
                              blurRadius: 12 * (1 + _pulseAnimation.value),
                              spreadRadius: 2 * _pulseAnimation.value,
                            )
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(
                                0.1 + 0.05 * _pulseAnimation.value),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.filter_list,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    );
                  },
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
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.close,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  "Reset Filter",
                                  style: TextStyle(
                                    color: Colors.white,
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
                  begin: -0.2, end: 0, duration: 300.ms, curve: Curves.easeOut),

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
                    if (_selectedSessionYear != null || _selectedMedium != null)
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
                  begin: -0.2, end: 0, duration: 300.ms, curve: Curves.easeOut),
          ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
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
                color: primaryColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
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
  final List<OfflineExamTimeTableSlot> timetableSlots;
  final Color primaryColor;
  final OfflineExam exam;

  const OfflineExamTimetableBottomsheet({
    super.key,
    required this.timetableSlots,
    this.primaryColor = const Color(0xFF6A4C93),
    required this.exam,
  });

  @override
  Widget build(BuildContext context) {
    // Sort slots by date
    final sortedSlots = timetableSlots.toList()
      ..sort((a, b) {
        try {
          final dateA = DateTime.parse(a.date!);
          final dateB = DateTime.parse(b.date!);
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });

    return CustomBottomsheet(
      titleLabelKey: exam.name ?? "Jadwal Ujian",
      child: Column(
        mainAxisSize: MainAxisSize.min, // Fix for flex layout error
        children: [
          // Exam details card
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Kelas",
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            Utils().cleanClassName(exam.className ?? "-"),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildExamInfoItem(
                      icon: Icons.calendar_today_rounded,
                      label: "Tanggal Mulai",
                      value: exam.examStartingDate != null
                          ? Utils.formatDate(
                              DateTime.parse(exam.examStartingDate!))
                          : "-",
                    ),
                    const SizedBox(width: 16),
                    _buildExamInfoItem(
                      icon: Icons.calendar_today_rounded,
                      label: "Tanggal Selesai",
                      value: exam.examEndingDate != null
                          ? Utils.formatDate(
                              DateTime.parse(exam.examEndingDate!))
                          : "-",
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Timeline of exam subjects - using Flexible instead of Expanded to fix layout issue
          Flexible(
            child: sortedSlots.isEmpty
                ? Center(
                    child: Text(
                      "Tidak ada jadwal tersedia",
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 15,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true, // Add shrinkWrap to fix layout issue
                    itemCount: sortedSlots.length,
                    padding: const EdgeInsets.only(bottom: 32),
                    itemBuilder: (context, index) {
                      final slot = sortedSlots[index];
                      final bool isLast = index == sortedSlots.length - 1;
                      DateTime? slotDate;

                      try {
                        slotDate = DateTime.parse(slot.date!);
                      } catch (e) {
                        // Handle date parsing error
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Timeline indicator
                          Column(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 100,
                                  color: primaryColor.withOpacity(0.3),
                                ),
                            ],
                          ),

                          // Subject details
                          Expanded(
                            child: Container(
                              margin:
                                  const EdgeInsets.only(left: 16, bottom: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.book,
                                          size: 20,
                                          color: primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomTextContainer(
                                              textKey: slot.subject
                                                      ?.getSybjectNameWithType() ??
                                                  "-",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (slotDate != null)
                                              Text(
                                                Utils.formatDate(slotDate),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Time info
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 18,
                                          color: primaryColor,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "${Utils.formatTime(
                                            timeOfDay: TimeOfDay(
                                              hour:
                                                  Utils.getHourFromTimeDetails(
                                                      time: slot.startTime!),
                                              minute: Utils
                                                  .getMinuteFromTimeDetails(
                                                      time: slot.startTime!),
                                            ),
                                            context: context,
                                          )} - ${Utils.formatTime(
                                            timeOfDay: TimeOfDay(
                                              hour:
                                                  Utils.getHourFromTimeDetails(
                                                      time: slot.endTime!),
                                              minute: Utils
                                                  .getMinuteFromTimeDetails(
                                                      time: slot.endTime!),
                                            ),
                                            context: context,
                                          )}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Marks details
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildMarkInfo(
                                          label: "Total Nilai",
                                          value: "${slot.totalMarks ?? 0}",
                                          icon: Icons.grade_rounded,
                                          color: primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildMarkInfo(
                                          label: "Nilai Kelulusan",
                                          value: "${slot.passingMarks ?? 0}",
                                          icon: Icons.check_circle_rounded,
                                          color: const Color(0xFF43A047),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .slideX(
                                  begin: 0.3,
                                  end: 0,
                                  duration: const Duration(milliseconds: 600),
                                  delay: Duration(milliseconds: 100 * index),
                                  curve: Curves.easeOutQuint,
                                )
                                .fadeIn(
                                  duration: const Duration(milliseconds: 600),
                                  delay: Duration(milliseconds: 100 * index),
                                ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkInfo({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
