import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import 'package:eschool_saas_staff/cubits/extracurricularAttendance/extracurricularAttendanceCubit.dart';
import 'package:eschool_saas_staff/cubits/extracurricularAttendance/extracurricularAttendanceState.dart';
import 'package:eschool_saas_staff/data/repositories/extracurricularAttendanceRepository.dart';
import 'package:eschool_saas_staff/data/models/extracurricularAttendance.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
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
  List<AttendanceData> _attendanceReport = [];

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
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  // Format date for API (d-m-Y)
  String _formatDateForApi(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
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
    if (_selectedExtracurricularId != null && _attendanceReport.isNotEmpty) {
      // Use staff ID as session ID (this might need adjustment)
      context.read<ExtracurricularAttendanceCubit>().saveAttendance(
            sessionId: 1, // This should be actual session/staff ID
            extracurricularId: _selectedExtracurricularId!,
            date: _formatDateForApi(_selectedDate),
            attendanceData: _attendanceReport,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: CustomModernAppBar(
        title: 'Absensi Ekstrakurikuler',
        icon: Icons.edit_calendar_rounded,
        fabAnimationController: _fabAnimationController,
        primaryColor: _maroonPrimary,
        lightColor: _maroonLight,
        onBackPressed: () {
          _fabAnimationController.stop();
          Get.back();
        },
        height: 160,
        tabBuilder: (context) {
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
                if (state is ExtracurricularAttendanceSuccess) {
                  if (state.extracurricularList != null) {
                    setState(() {
                      _extracurricularList = state.extracurricularList!;
                    });
                  }
                  if (state.attendanceData != null) {
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

    if (_attendanceList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outlined,
              size: 80,
              color: _maroonPrimary.withOpacity(0.3),
            ),
            SizedBox(height: 20),
            Text(
              'Belum Ada Data Absensi',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Belum ada data absensi untuk tanggal ini',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.only(
        top: Utils.appContentTopScrollPadding(context: context) + 20,
        left: 16,
        right: 16,
        bottom: 100,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
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
            child: Row(
              children: [
                Icon(Icons.people_alt_rounded, color: _maroonPrimary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Daftar Absensi',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _maroonPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _maroonPrimary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${_attendanceList.length} Anggota',
                    style: GoogleFonts.poppins(
                      color: _maroonPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Attendance list
          ...List.generate(_attendanceList.length, (index) {
            final member = _attendanceList[index];
            return _buildAttendanceCard(member, index);
          }),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(ExtracurricularAttendance member, int index) {
    final currentAttendance = _attendanceReport.firstWhere(
      (report) => report.id == member.studentId,
      orElse: () => AttendanceData(id: member.studentId ?? 0, type: 1),
    );

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _maroonPrimary.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Student info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.studentName ?? 'Nama tidak tersedia',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'NISN: ${member.studentNisn ?? '-'}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Kelas: ${member.className ?? '-'}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Attendance status dropdown
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getAttendanceColor(currentAttendance.type)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getAttendanceColor(currentAttendance.type)
                      .withOpacity(0.3),
                ),
              ),
              child: DropdownButton<int>(
                value: currentAttendance.type,
                underline: SizedBox(),
                items: [
                  DropdownMenuItem(
                      value: 1,
                      child: Text('Hadir',
                          style: GoogleFonts.poppins(fontSize: 12))),
                  DropdownMenuItem(
                      value: 0,
                      child: Text('Tidak Hadir',
                          style: GoogleFonts.poppins(fontSize: 12))),
                  DropdownMenuItem(
                      value: 2,
                      child: Text('Sakit',
                          style: GoogleFonts.poppins(fontSize: 12))),
                  DropdownMenuItem(
                      value: 3,
                      child: Text('Izin',
                          style: GoogleFonts.poppins(fontSize: 12))),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _updateAttendanceReport(member.studentId ?? 0, value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAttendanceColor(int type) {
    switch (type) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _updateAttendanceReport(int studentId, int type) {
    setState(() {
      final existingIndex =
          _attendanceReport.indexWhere((report) => report.id == studentId);
      if (existingIndex != -1) {
        _attendanceReport[existingIndex] =
            AttendanceData(id: studentId, type: type);
      } else {
        _attendanceReport.add(AttendanceData(id: studentId, type: type));
      }
    });
  }

  void _initializeAttendanceReport() {
    _attendanceReport = _attendanceList.map((member) {
      return AttendanceData(
        id: member.studentId ?? 0,
        type: member.attendanceType ?? 1,
      );
    }).toList();
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
              child: ListView.builder(
                itemCount: _extracurricularList.length,
                itemBuilder: (context, index) {
                  final extracurricular = _extracurricularList[index];
                  return ListTile(
                    leading: Icon(Icons.sports_soccer, color: _maroonPrimary),
                    title: Text(
                      extracurricular['name'],
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      extracurricular['description'] ?? '',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedExtracurricularId = extracurricular['id'];
                        _selectedExtracurricularName = extracurricular['name'];
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
