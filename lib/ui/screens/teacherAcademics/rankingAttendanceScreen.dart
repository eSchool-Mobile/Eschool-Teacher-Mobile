import 'package:eschool_saas_staff/cubits/teacherAcademics/attendence/attendanceRankingCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/classSectionsAndSubjects.dart';
import 'package:eschool_saas_staff/data/models/attendanceRanking.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/ui/widgets/attendanceRankingContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customErrorWidget.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class RankingAttendanceScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AttendanceRankingCubit()..getAttendanceRanking(),
        ),
        BlocProvider(
          create: (context) => ClassSectionsAndSubjectsCubit(),
        ),
      ],
      child: const RankingAttendanceScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const RankingAttendanceScreen({super.key});

  @override
  State<RankingAttendanceScreen> createState() =>
      _RankingAttendanceScreenState();
}

class _RankingAttendanceScreenState extends State<RankingAttendanceScreen>
    with TickerProviderStateMixin {
  String? selectedClassLevel;
  ClassSection? _selectedClassSection;

  // Color scheme for maroon theme matching recapAttendanceSubjectScreen
  final Color _maroonPrimary = const Color(0xFF800020);
  final Color _maroonLight = const Color(0xFFAA6976);

  // Animation controllers
  late AnimationController _fabAnimationController;
  final ScrollController _scrollController = ScrollController();

  // Search functionality
  bool _isSearchActive = false;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Cache for class levels to keep filter always available
  List<String> _cachedClassLevels = [];
  AttendanceRanking? _cachedAttendanceData;
  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scrollController
        .addListener(_scrollListener); // Initialize class sections data
    Future.delayed(Duration.zero, () {
      if (mounted) {
        print("RankingAttendanceScreen: Initializing class sections data...");
        context
            .read<ClassSectionsAndSubjectsCubit>()
            .getClassSectionsAndSubjects();
      }
    }); // Listen to class sections state changes for debugging
    context.read<ClassSectionsAndSubjectsCubit>().stream.listen((state) {
      if (state is ClassSectionsAndSubjectsFetchSuccess) {
        print(
            "RankingAttendanceScreen: Classes loaded successfully - ${state.classSections.length} classes");
        state.classSections
            .forEach((cls) => print("Class: ${cls.name} (${cls.id})"));
      } else if (state is ClassSectionsAndSubjectsFetchFailure) {
        print(
            "RankingAttendanceScreen: Failed to load classes - ${state.errorMessage}");
      } else if (state is ClassSectionsAndSubjectsFetchInProgress) {
        print("RankingAttendanceScreen: Loading classes...");
      }
    }); // Listen to attendance ranking state changes to cache class levels
    context.read<AttendanceRankingCubit>().stream.listen((state) {
      if (state is AttendanceRankingFetchSuccess) {
        print(
            "RankingAttendanceScreen: Caching attendance data and class levels");
        _cachedAttendanceData = state.attendanceRanking;
        _cachedClassLevels = getClassLevels(state.attendanceRanking);
        print(
            "RankingAttendanceScreen: Cached ${_cachedClassLevels.length} class levels: $_cachedClassLevels");
      } else if (state is AttendanceRankingFetchFailure) {
        print(
            "RankingAttendanceScreen: Failed to load attendance data - ${state.errorMessage}");
      } else if (state is AttendanceRankingInProgress) {
        print("RankingAttendanceScreen: Loading attendance data...");
      }
    });

    // Initialize cache from current state if already loaded
    final currentAttendanceState = context.read<AttendanceRankingCubit>().state;
    if (currentAttendanceState is AttendanceRankingFetchSuccess) {
      _cachedAttendanceData = currentAttendanceState.attendanceRanking;
      _cachedClassLevels =
          getClassLevels(currentAttendanceState.attendanceRanking);
      print(
          "RankingAttendanceScreen: Initial cache from current state - ${_cachedClassLevels.length} class levels");
    }
  }

  void _scrollListener() {
    if (_scrollController.offset > 50) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<String> getClassLevels(AttendanceRanking data) {
    return (data.groupedByClassLevel ?? [])
        .map((e) => e.classLevel ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  List<String> getAvailableClassLevels() {
    // First try cached data
    if (_cachedClassLevels.isNotEmpty) {
      return _cachedClassLevels;
    }

    // Then try current state
    final currentState = context.read<AttendanceRankingCubit>().state;
    if (currentState is AttendanceRankingFetchSuccess) {
      final levels = getClassLevels(currentState.attendanceRanking);
      _cachedClassLevels = levels; // Update cache
      return levels;
    }

    // Return empty if no data available
    return [];
  }

  void changeSelectedClassSection(ClassSection? classSection) {
    if (_selectedClassSection != classSection) {
      _selectedClassSection = classSection;
      // Reset class level filter when class section changes
      selectedClassLevel = null;
      setState(() {});
      // Refresh attendance ranking data with new class section filter
      context.read<AttendanceRankingCubit>().getAttendanceRanking();
    }
  }

  void changeSelectedClassLevel(String? classLevel) {
    if (selectedClassLevel != classLevel) {
      selectedClassLevel = classLevel;
      setState(() {});
      print(
          "RankingAttendanceScreen: Class level changed to: $selectedClassLevel");
    }
  }

  Widget _buildRecapTable(AttendanceRanking attendanceRankings) {
    // Debug: Print original data
    print(
        "DEBUG: Original data - allStudents count: ${attendanceRankings.allStudents?.length ?? 0}");
    print(
        "DEBUG: Original data - groupedByClassLevel count: ${attendanceRankings.groupedByClassLevel?.length ?? 0}");

    // Update cache with fresh data
    _cachedAttendanceData = attendanceRankings;
    _cachedClassLevels = getClassLevels(attendanceRankings);
    print("DEBUG: Updated cache - class levels: $_cachedClassLevels");

    AttendanceRanking filteredData;

    // First filter by class section if selected
    AttendanceRanking classSectionFilteredData = attendanceRankings;
    if (_selectedClassSection != null) {
      // Filter by selected class section
      classSectionFilteredData = AttendanceRanking(
        groupedByClassLevel: attendanceRankings.groupedByClassLevel
            ?.where((classLevel) =>
                classLevel.classLevel
                    ?.contains(_selectedClassSection!.name ?? '') ??
                false)
            .toList(),
        allStudents: attendanceRankings.allStudents
            ?.where((student) =>
                student.className
                    ?.contains(_selectedClassSection!.name ?? '') ??
                false)
            .toList(),
      );
    } // Then filter by class level if selected
    if (selectedClassLevel == null) {
      // For "Semua Tingkat", we want to show all students
      filteredData = classSectionFilteredData;

      // If allStudents is empty but we have groupedByClassLevel data,
      // create allStudents from groupedByClassLevel
      if ((filteredData.allStudents?.isEmpty ?? true) &&
          (filteredData.groupedByClassLevel?.isNotEmpty ?? false)) {
        print(
            "DEBUG: Converting groupedByClassLevel to allStudents for Semua Tingkat");

        List<AllStudents> generatedAllStudents = [];

        for (var classLevel in filteredData.groupedByClassLevel!) {
          for (var topStudent in (classLevel.topStudents ?? [])) {
            generatedAllStudents.add(AllStudents(
              studentId: topStudent.studentId,
              studentName: topStudent.studentName,
              classLevel: classLevel.classLevel,
              className: topStudent.className,
              jumlahJpSum: topStudent.jumlahJpSum,
              point: topStudent.point,
              alpha_count: topStudent.alpha_count,
            ));
          }
        }

        // Sort by point (assuming higher points are better)
        generatedAllStudents.sort((a, b) {
          double pointA = double.tryParse(a.point?.toString() ?? '0') ?? 0;
          double pointB = double.tryParse(b.point?.toString() ?? '0') ?? 0;
          return pointB.compareTo(pointA); // Descending order
        });

        filteredData = AttendanceRanking(
          groupedByClassLevel: filteredData.groupedByClassLevel,
          allStudents: generatedAllStudents,
        );

        print(
            "DEBUG: Generated ${generatedAllStudents.length} students for allStudents");
      }
    } else {
      // Filter by specific class level
      filteredData = AttendanceRanking(
        groupedByClassLevel: classSectionFilteredData.groupedByClassLevel
            ?.where((classLevel) => classLevel.classLevel == selectedClassLevel)
            .toList(),
        // For specific class level, filter allStudents by class level too
        allStudents: classSectionFilteredData.allStudents
            ?.where((student) => student.classLevel == selectedClassLevel)
            .toList(),
      );
    } // Check if data is empty based on the selected filter
    bool hasNoData = false;
    if (selectedClassLevel == null) {
      // For "Semua Tingkat", check if allStudents is empty
      hasNoData = (filteredData.allStudents?.isEmpty ?? true);
      print(
          "DEBUG: Semua Tingkat - allStudents count: ${filteredData.allStudents?.length ?? 0}");
      print("DEBUG: Semua Tingkat - hasNoData: $hasNoData");
    } else {
      // For specific class level, check if groupedByClassLevel is empty
      hasNoData = (filteredData.groupedByClassLevel?.isEmpty ?? true);
      print(
          "DEBUG: Specific Level - groupedByClassLevel count: ${filteredData.groupedByClassLevel?.length ?? 0}");
      print("DEBUG: Specific Level - hasNoData: $hasNoData");
    }

    // Additional check: if both data sources are empty, show no data
    if ((filteredData.allStudents?.isEmpty ?? true) &&
        (filteredData.groupedByClassLevel?.isEmpty ?? true)) {
      hasNoData = true;
      print("DEBUG: Both data sources are empty");
    }

    if (hasNoData) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 16),
              Text(
                "Tidak ada data peringkat kehadiran",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_selectedClassSection != null ||
                  selectedClassLevel != null) ...[
                SizedBox(height: 8),
                Text(
                  "Coba ubah filter yang dipilih",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    } // Check if search query is active and no results found
    if (_searchQuery.isNotEmpty && _hasNoSearchResults(filteredData)) {
      return _buildNoSearchResults();
    }

    // Debug print to help verify filter logic
    print("RankingAttendanceScreen: selectedClassLevel = $selectedClassLevel");
    print(
        "RankingAttendanceScreen: showAllStudents = ${selectedClassLevel == null}");
    print(
        "RankingAttendanceScreen: allStudents count = ${filteredData.allStudents?.length ?? 0}");
    print(
        "RankingAttendanceScreen: groupedByClassLevel count = ${filteredData.groupedByClassLevel?.length ?? 0}");

    return AttendanceRankingContainer(
      attendanceRankings: filteredData,
      showAllStudents: selectedClassLevel == null,
      searchQuery: _searchQuery,
    ).animate().fadeIn(duration: 500.ms).slideY(
          begin: 0.05,
          end: 0,
          curve: Curves.easeOutQuad,
        );
  }

  Widget _buildAppBar() {
    return CustomModernAppBar(
      title: "Peringkat Kehadiran",
      icon: Icons.trending_up_rounded,
      fabAnimationController: _fabAnimationController,
      primaryColor: _maroonPrimary,
      lightColor: _maroonLight,
      onBackPressed: () => Navigator.pop(context),
      height: 150, // Increased height to accommodate tab filters
      showArchiveButton: true,
      onArchivePressed: _toggleSearch, // Search button next to title
      archiveIcon: _isSearchActive
          ? Icons.close_rounded
          : Icons.search_rounded, // Dynamic search icon
      tabBuilder: (context) {
        // Custom tab content for filters like in teacherAddAttendanceScreen
        return Row(
          children: [
            // Class Section filter
            Expanded(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _showClassSectionFilter,
                  highlightColor: Colors.white.withOpacity(0.1),
                  splashColor: Colors.white.withOpacity(0.2),
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
                            _selectedClassSection?.name ?? 'Semua Kelas',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 14,
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

            // Class Level filter
            Expanded(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _showClassLevelFilter,
                  highlightColor: Colors.white.withOpacity(0.1),
                  splashColor: Colors.white.withOpacity(0.2),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_list_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            selectedClassLevel ?? 'Semua Tingkat',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 14,
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
    );
  }

  // Helper method for class section filter
  void _showClassSectionFilter() {
    final currentState = context.read<ClassSectionsAndSubjectsCubit>().state;

    if (currentState is ClassSectionsAndSubjectsFetchSuccess) {
      if (currentState.classSections.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Tidak ada kelas yang tersedia"),
            backgroundColor: _maroonPrimary,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
        return;
      }
      HapticFeedback.lightImpact();

      // Create list with "Semua Kelas" option
      List<String> classNames = [
        "Semua Kelas",
        ...currentState.classSections.map((e) => e.name ?? "")
      ];

      Utils.showBottomSheet(
          child: FilterSelectionBottomsheet<String>(
            onSelection: (value) {
              if (value != null) {
                if (value == "Semua Kelas") {
                  changeSelectedClassSection(null);
                } else {
                  // Find the corresponding ClassSection
                  final selectedClass = currentState.classSections
                      .firstWhere((classSection) => classSection.name == value);
                  changeSelectedClassSection(selectedClass);
                }
                Get.back();
              }
            },
            selectedValue: _selectedClassSection?.name ?? "Semua Kelas",
            values: classNames,
            titleKey: "Pilih Kelas",
          ),
          context: context);
    } else if (currentState is ClassSectionsAndSubjectsFetchInProgress) {
      // Show loading message if data is currently loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text("Sedang memuat data kelas..."),
            ],
          ),
          backgroundColor: _maroonPrimary,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    } else if (currentState is ClassSectionsAndSubjectsFetchFailure) {
      // Show error message and retry option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat data kelas. Coba lagi."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          action: SnackBarAction(
            label: "Retry",
            textColor: Colors.white,
            onPressed: () {
              context
                  .read<ClassSectionsAndSubjectsCubit>()
                  .getClassSectionsAndSubjects();
            },
          ),
        ),
      );
    } else {
      // Initial state - trigger data loading
      context
          .read<ClassSectionsAndSubjectsCubit>()
          .getClassSectionsAndSubjects();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text("Memuat data kelas..."),
            ],
          ),
          backgroundColor: _maroonPrimary,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  // Helper method for class level filter
  void _showClassLevelFilter() {
    final attendanceState = context.read<AttendanceRankingCubit>().state;

    // Use cached class levels if available, otherwise try to get from current state
    List<String> availableClassLevels = _cachedClassLevels;

    // If cache is empty, try to get from current state
    if (availableClassLevels.isEmpty &&
        attendanceState is AttendanceRankingFetchSuccess) {
      availableClassLevels = getClassLevels(attendanceState.attendanceRanking);
      // Update cache
      _cachedClassLevels = availableClassLevels;
    }

    print("DEBUG: Available class levels for filter: $availableClassLevels");

    if (availableClassLevels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text("Tingkat kelas sedang dimuat..."),
            ],
          ),
          backgroundColor: _maroonPrimary,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );

      // Try to trigger data load
      context.read<AttendanceRankingCubit>().getAttendanceRanking();
      return;
    }

    HapticFeedback.lightImpact();
    Utils.showBottomSheet(
      child: FilterSelectionBottomsheet(
        onSelection: (value) {
          if (value != null) {
            changeSelectedClassLevel(value == "Semua Tingkat" ? null : value);
            Get.back();
          }
        },
        selectedValue: selectedClassLevel ?? "Semua Tingkat",
        titleKey: 'Pilih Tingkat Kelas',
        values: ["Semua Tingkat", ...availableClassLevels],
      ),
      context: context,
    );
  }

  // Helper method for search toggle
  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        _searchQuery = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // This container will hold the content (search is now in the AppBar)
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top +
                    150), // Adjusted for increased CustomModernAppBar height
            child: Column(
              children: [
                // Search field appears when search is active
                if (_isSearchActive)
                  Container(
                    height: 56,
                    margin: EdgeInsets.fromLTRB(16, 8, 16, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Cari nama siswa...',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: _maroonPrimary,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      autofocus: true,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: -0.2, end: 0),

                // Content area - now with correct layout constraints
                Expanded(
                  child: BlocBuilder<ClassSectionsAndSubjectsCubit,
                      ClassSectionsAndSubjectsState>(
                    builder: (context, classSectionState) {
                      return BlocBuilder<AttendanceRankingCubit,
                          AttendanceRankingState>(
                        builder: (context, attendanceState) {
                          print(
                              "Current attendance state: ${attendanceState.runtimeType}");

                          if (attendanceState is AttendanceRankingInProgress) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (attendanceState
                              is AttendanceRankingFetchFailure) {
                            return CustomErrorWidget(
                              message: attendanceState.errorMessage,
                              onRetry: () {
                                context
                                    .read<AttendanceRankingCubit>()
                                    .getAttendanceRanking();
                              },
                              retryButtonText: "Coba Lagi",
                              primaryColor: _maroonPrimary,
                              title: "Gagal Memuat Data Ranking",
                            );
                          } else if (attendanceState
                              is AttendanceRankingFetchSuccess) {
                            return SingleChildScrollView(
                              child: _buildRecapTable(
                                  attendanceState.attendanceRanking),
                            );
                          }

                          // Handle initial state - show cached data if available
                          if (_cachedAttendanceData != null) {
                            return SingleChildScrollView(
                              child: _buildRecapTable(_cachedAttendanceData!),
                            );
                          }

                          // Show loading state
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: _maroonPrimary,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Memuat data peringkat...",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          _buildAppBar(),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimationController.value,
            child: FloatingActionButton(
              onPressed: () {
                print("Manual refresh triggered via FAB");
                HapticFeedback.lightImpact();
                context
                    .read<ClassSectionsAndSubjectsCubit>()
                    .getClassSectionsAndSubjects();
                context.read<AttendanceRankingCubit>().getAttendanceRanking();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text("Memuat ulang data..."),
                      ],
                    ),
                    backgroundColor: _maroonPrimary,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              },
              backgroundColor: _maroonPrimary,
              child: Icon(Icons.refresh_rounded, color: Colors.white),
              tooltip: "Refresh Data",
            ),
          );
        },
      ),
    );
  }

  bool _hasNoSearchResults(AttendanceRanking filteredData) {
    if (_searchQuery.isEmpty) return false;

    // Check if showing all students (selectedClassLevel == null)
    if (selectedClassLevel == null) {
      // Filter all students by search query
      final filteredStudents = (filteredData.allStudents ?? [])
          .where((student) => (student.studentName?.toLowerCase() ?? '')
              .contains(_searchQuery.toLowerCase()))
          .toList();
      return filteredStudents.isEmpty;
    } else {
      // Filter grouped students by search query
      final filteredStudents = (filteredData.groupedByClassLevel ?? [])
          .expand((classLevel) => (classLevel.topStudents ?? []))
          .where((student) => (student.studentName?.toLowerCase() ?? '')
              .contains(_searchQuery.toLowerCase()))
          .toList();
      return filteredStudents.isEmpty;
    }
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated search icon with modern styling
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _maroonPrimary.withOpacity(0.1),
                    _maroonLight.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _maroonPrimary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64,
                color: _maroonPrimary.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 32),

            // Main message
            Text(
              'Tidak Ada Hasil',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _maroonPrimary,
              ),
            ),
            SizedBox(height: 12),

            // Search query display
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _maroonPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: _maroonPrimary.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search,
                    size: 18,
                    color: _maroonPrimary.withOpacity(0.7),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '"$_searchQuery"',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _maroonPrimary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Description
            Text(
              'Tidak ditemukan siswa yang sesuai dengan pencarian Anda.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coba gunakan nama yang berbeda atau periksa ejaan.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
            SizedBox(height: 32),

            // Clear search button with modern design
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: _maroonPrimary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = "";
                    _isSearchActive = false;
                  });
                },
                icon: Icon(Icons.clear_rounded, size: 20),
                label: Text(
                  'Hapus Pencarian',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _maroonPrimary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for decorative elements
class AppBarDecorationPainter extends CustomPainter {
  final Color color;

  AppBarDecorationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.2), 30, paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), 20, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.15), 15, paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), 10, paint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.4), 8, paint);

    // Draw arc
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final arcRect = Rect.fromLTRB(size.width * 0.1, size.height * 0.2,
        size.width * 0.6, size.height * 0.6);
    canvas.drawArc(arcRect, 0.2, 1.5, false, arcPaint);

    // Draw another arc
    final arcRect2 = Rect.fromLTRB(size.width * 0.5, size.height * 0.4,
        size.width * 0.9, size.height * 0.8);
    canvas.drawArc(arcRect2, 3, 1.5, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
