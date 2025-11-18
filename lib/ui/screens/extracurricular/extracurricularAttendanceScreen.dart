import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import 'package:eschool_saas_staff/cubits/extracurricularAttendance/extracurricularAttendanceCubit.dart';
import 'package:eschool_saas_staff/cubits/extracurricularAttendance/extracurricularAttendanceState.dart';
import 'package:eschool_saas_staff/data/repositories/extracurricularAttendanceRepository.dart';
import 'package:eschool_saas_staff/data/models/extracurricularAttendance.dart';
import 'package:eschool_saas_staff/data/models/studentAttendance.dart';
import 'package:eschool_saas_staff/data/models/studentDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/studentAttendanceContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';

class ExtracurricularAttendanceScreen extends StatefulWidget {
  const ExtracurricularAttendanceScreen({Key? key}) : super(key: key);

  static Widget getRouteInstance() {
    return BlocProvider(
      create: (context) => ExtracurricularAttendanceCubit(
        ExtracurricularAttendanceRepository(),
      ),
      child: const ExtracurricularAttendanceScreen(),
    );
  }

  @override
  State<ExtracurricularAttendanceScreen> createState() =>
      _ExtracurricularAttendanceScreenState();
}

class _ExtracurricularAttendanceScreenState
    extends State<ExtracurricularAttendanceScreen>
    with TickerProviderStateMixin {
  // Controllers and variables
  DateTime _selectedDate = DateTime.now();
  int? _selectedExtracurricularId;
  String? _selectedExtracurricularName;
  List<Map<String, dynamic>> _extracurricularList = [];
  List<ExtracurricularAttendance> _attendanceList = [];
  List<({StudentAttendanceStatus status, int studentId})> attendanceReport = [];

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchVisible = false;

  // Animation controllers
  late AnimationController _fabAnimationController;
  late final ScrollController _scrollController = ScrollController();

  // Theme colors
  final Color _maroonPrimary = const Color(0xFF8B1F41);
  final Color _maroonLight = const Color(0xFFAC3B5C);

  @override
  void initState() {
    super.initState();

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fabAnimationController.forward();

    // Load extracurricular list
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<ExtracurricularAttendanceCubit>().getExtracurricularList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  // Format date for API (YYYY-MM-DD ISO format)
  String _formatDateForApi(DateTime date) {
    return date.toIso8601String().split('T')[0]; // YYYY-MM-DD
  }

  // Load attendance data
  void _loadAttendanceData() {
    if (_selectedExtracurricularId != null) {
      // Use extracurricular ID as attendance ID for now
      // This might need adjustment based on actual backend implementation
      context.read<ExtracurricularAttendanceCubit>().getAttendanceData(
            attendanceId: _selectedExtracurricularId!,
            extracurricularId: _selectedExtracurricularId,
            date: _formatDateForApi(_selectedDate),
          );
    }
  }

  // Save attendance data
  void _saveAttendance() {
    if (_selectedExtracurricularId != null && attendanceReport.isNotEmpty) {
      print('🔍 [ATTENDANCE SCREEN] Preparing to save attendance...');
      print(
          '🔍 [ATTENDANCE SCREEN] Attendance report count: ${attendanceReport.length}');

      // Convert attendance report to API format
      final attendanceData = attendanceReport.map((report) {
        print(
            '🔍 [ATTENDANCE SCREEN] Converting report: StudentID=${report.studentId}, Status=${report.status}');
        return AttendanceData(
          studentId: report.studentId,
          type: _convertStatusToInt(report.status),
        );
      }).toList();

      print(
          '🔍 [ATTENDANCE SCREEN] Final attendance data: ${attendanceData.map((e) => 'StudentID=${e.studentId}, Type=${e.type}').toList()}');

      context.read<ExtracurricularAttendanceCubit>().saveAttendance(
            sessionId: 1, // This should be actual session/staff ID
            extracurricularId: _selectedExtracurricularId!,
            date: _formatDateForApi(_selectedDate),
            attendanceData: attendanceData,
          );
    } else {
      print(
          '❌ [ATTENDANCE SCREEN] Cannot save: ExtracurricularId=${_selectedExtracurricularId}, ReportCount=${attendanceReport.length}');
    }
  }

  // Convert StudentAttendanceStatus to int
  int _convertStatusToInt(StudentAttendanceStatus status) {
    switch (status) {
      case StudentAttendanceStatus.present:
        return 1;
      case StudentAttendanceStatus.absent:
        return 0;
      case StudentAttendanceStatus.sick:
        return 2;
      case StudentAttendanceStatus.permission:
        return 3;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: CustomModernAppBar(
        title: 'Absensi Kurikuler',
        icon: Icons.edit_calendar_rounded,
        fabAnimationController: _fabAnimationController,
        primaryColor: _maroonPrimary,
        lightColor: _maroonLight,
        onBackPressed: () {
          _fabAnimationController.stop();
          Get.back();
        },
        height: 160,
        showSearchButton: true,
        onSearchPressed: () {
          setState(() {
            _isSearchVisible = !_isSearchVisible;
            if (!_isSearchVisible) {
              _searchQuery = '';
              _searchController.clear();
            }
          });
        },
        tabBuilder: (context) {
          // Show search input if search is active
          if (_isSearchVisible) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari nama anggota...',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: Colors.white.withOpacity(0.8),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            );
          }

          // Default tab content for filters
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
                        inititalDate: _selectedDate,
                        lastDate: DateTime.now(),
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 30)),
                      );

                      if (selectedDate != null) {
                        setState(() {
                          _selectedDate = selectedDate;
                        });
                        _loadAttendanceData();
                      }
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              Utils.formatDate(_selectedDate),
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

              // Divider
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

              // Extracurricular selection
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showExtracurricularPicker(),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sports_soccer,
                              color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _selectedExtracurricularName ??
                                  'Pilih Ekstrakurikuler',
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
            ],
          );
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ExtracurricularAttendanceCubit,
                ExtracurricularAttendanceState>(
              listener: (context, state) {
                print(
                    '🔍 [ATTENDANCE SCREEN] State changed: ${state.runtimeType}');

                if (state is ExtracurricularAttendanceSuccess) {
                  print('🔍 [ATTENDANCE SCREEN] Success state received');

                  if (state.extracurricularList != null) {
                    print(
                        '🔍 [ATTENDANCE SCREEN] Extracurricular list received: ${state.extracurricularList!.length} items');
                    print(
                        '🔍 [ATTENDANCE SCREEN] List content: ${state.extracurricularList}');
                    setState(() {
                      _extracurricularList = state.extracurricularList!;
                    });
                  }
                  if (state.attendanceData != null) {
                    print(
                        '🔍 [ATTENDANCE SCREEN] Attendance data received: ${state.attendanceData!.members.length} members');
                    setState(() {
                      _attendanceList = state.attendanceData!.members;
                      _initializeAttendanceReport();
                    });
                  }
                }

                if (state is ExtracurricularAttendanceSaveSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.message,
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  // Reload data after save
                  _loadAttendanceData();
                }

                if (state is ExtracurricularAttendanceFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.errorMessage,
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ExtracurricularAttendanceLoading) {
                  return _buildLoadingSkeleton();
                }

                if (state is ExtracurricularAttendanceFailure) {
                  return ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      if (_selectedExtracurricularId != null) {
                        _loadAttendanceData();
                      } else {
                        context
                            .read<ExtracurricularAttendanceCubit>()
                            .getExtracurricularList();
                      }
                    },
                  );
                }

                return _buildAttendanceContent();
              },
            ),
          ),

          // Submit button
          if (_selectedExtracurricularId != null && _attendanceList.isNotEmpty)
            _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildAttendanceContent() {
    if (_selectedExtracurricularId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 80,
              color: _maroonPrimary.withOpacity(0.3),
            ),
            SizedBox(height: 20),
            Text(
              'Pilih Ekstrakurikuler',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Silakan pilih ekstrakurikuler terlebih dahulu',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return _buildStudentsContainer();
  }

  Widget _buildStudentsContainer() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(top: 20, bottom: 90),
        child: Column(
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
                    'Kehadiran Anggota Ekstrakurikuler',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _maroonPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Students attendance container
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
                        ),

                        const SizedBox(width: 16),

                        // Title text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daftar Kehadiran Anggota',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Student attendance list
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildStudents(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudents() {
    if (_attendanceList.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.people_alt_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada anggota untuk ditampilkan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan pilih ekstrakurikuler dan tanggal',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Convert ExtracurricularAttendance to StudentAttendance format
    final studentAttendances = _attendanceList.map((member) {
      print(
          '🔍 [ATTENDANCE SCREEN] Converting member: AttendanceID=${member.attendanceId}, StudentID=${member.studentId}, Name=${member.studentName}, Status=${member.status.label}');

      // Create StudentDetails from ExtracurricularAttendance
      final studentDetails = StudentDetails.fromJson({
        'id': member.studentId,
        'full_name': member.studentName,
        'first_name': member.studentName.split(' ').first,
        'last_name': member.studentName.split(' ').skip(1).join(' '),
        'gr_number': member.studentNisn,
        'class_section': {
          'full_name': member.className,
        },
      });

      print(
          '🔍 [ATTENDANCE SCREEN] Created StudentDetails: ID=${studentDetails.id}');

      return StudentAttendance.fromStudentDetails(
        studentDetails: studentDetails,
        type: member.status.value,
      );
    }).toList();

    // Filter students based on search query
    final filteredStudents = _searchQuery.isEmpty
        ? studentAttendances
        : studentAttendances.where((attendance) {
            final fullName =
                (attendance.studentDetails?.fullName ?? '').toLowerCase();
            return fullName.contains(_searchQuery.toLowerCase());
          }).toList();

    return StudentAttendanceContainer(
      studentAttendances: filteredStudents,
      allStudentAttendances: studentAttendances,
      onStatusChanged: (attendanceStatuses) {
        attendanceReport = attendanceStatuses;
      },
      isForAddAttendance: true,
      showSummary: true,
    );
  }

  void _initializeAttendanceReport() {
    // Initialize attendance report with current data
    attendanceReport = _attendanceList.map((member) {
      print(
          '🔍 [ATTENDANCE SCREEN] Initializing report for student ID: ${member.studentId}, Status: ${member.status.label}');

      return (
        status: _convertAttendanceStatusToStudentStatus(member.status),
        studentId: member.studentId,
      );
    }).toList();

    print(
        '🔍 [ATTENDANCE SCREEN] Initialized ${attendanceReport.length} attendance reports');
  }

  // Convert AttendanceStatus to StudentAttendanceStatus
  StudentAttendanceStatus _convertAttendanceStatusToStudentStatus(
      AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.absent:
        return StudentAttendanceStatus.absent;
      case AttendanceStatus.present:
        return StudentAttendanceStatus.present;
      case AttendanceStatus.sick:
        return StudentAttendanceStatus.sick;
      case AttendanceStatus.permission:
        return StudentAttendanceStatus.permission;
    }
  }

  // Convert int to StudentAttendanceStatus
  StudentAttendanceStatus _convertIntToStatus(int type) {
    switch (type) {
      case 0:
        return StudentAttendanceStatus.absent;
      case 1:
        return StudentAttendanceStatus.present;
      case 2:
        return StudentAttendanceStatus.sick;
      case 3:
        return StudentAttendanceStatus.permission;
      default:
        return StudentAttendanceStatus.present;
    }
  }

  void _showExtracurricularPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pilih Ekstrakurikuler',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _maroonPrimary,
                ),
              ),
            ),
            Expanded(
              child: _extracurricularList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sports_soccer,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada ekstrakurikuler',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Belum ada data ekstrakurikuler yang tersedia',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Retry loading
                              context
                                  .read<ExtracurricularAttendanceCubit>()
                                  .getExtracurricularList();
                            },
                            child: Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _extracurricularList.length,
                      itemBuilder: (context, index) {
                        final extracurricular = _extracurricularList[index];
                        return ListTile(
                          leading:
                              Icon(Icons.sports_soccer, color: _maroonPrimary),
                          title: Text(
                            extracurricular['name'],
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            extracurricular['description'] ?? '',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedExtracurricularId =
                                  extracurricular['id'];
                              _selectedExtracurricularName =
                                  extracurricular['name'];
                            });
                            Navigator.pop(context);
                            _loadAttendanceData();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BlocBuilder<ExtracurricularAttendanceCubit,
          ExtracurricularAttendanceState>(
        builder: (context, state) {
          final isLoading = state is ExtracurricularAttendanceSaveLoading;

          return ElevatedButton(
            onPressed: isLoading ? null : _saveAttendance,
            style: ElevatedButton.styleFrom(
              backgroundColor: _maroonPrimary,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Simpan Absensi',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Center(
      child: CircularProgressIndicator(
        color: _maroonPrimary,
      ),
    );
  }
}
