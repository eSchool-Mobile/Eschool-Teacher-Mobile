import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/onlineExam/onlineExamCubit.dart';
import 'package:eschool_saas_staff/data/repositories/onlineExamRepository.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/classSectionsAndSubjects.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/data/models/onlineExam.dart' as exam;
import 'package:eschool_saas_staff/data/models/subjectDetail.dart';
import '../../../app/routes.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:eschool_saas_staff/ui/widgets/customErrorWidget.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';
import 'package:eschool_saas_staff/ui/widgets/no_search_results_widget.dart';

class OnlineExamScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OnlineExamCubit>(
          create: (context) => OnlineExamCubit(OnlineExamRepository()),
        ),
        BlocProvider<ClassSectionsAndSubjectsCubit>(
          create: (context) => ClassSectionsAndSubjectsCubit(),
        ),
      ],
      child: OnlineExamScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<OnlineExamScreen> createState() => _OnlineExamScreenState();
}

class _OnlineExamScreenState extends State<OnlineExamScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? selectedSubject;
  int? selectedSessionYearId;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String searchQuery = ""; // Tambahkan ini

  // Animation controller for CustomModernAppBar
  late AnimationController _appBarAnimationController;

  SubjectDetail? selectedSubjectDetail;
  List<SubjectDetail> subjectDetails = [];
  final ScrollController _scrollController = ScrollController();

  // Theme colors - Softer Maroon palette
  final Color _primaryColor = Color(0xFF7A1E23); // Softer deep maroon
  final Color _highlightColor =
      Color(0xFFB84D4D); // Softer bright maroon  @override
  void initState() {
    super.initState();
    // Initialize date formatting for Indonesian locale
    initializeDateFormatting('id_ID', null);
    _refreshExams();

    // Initialize class sections data untuk filter
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<ClassSectionsAndSubjectsCubit>()
            .getClassSectionsAndSubjects();
      }
    });

    // Add listener for state changes
    context.read<OnlineExamCubit>().stream.listen((state) {
      if (state is OnlineExamSuccess) {
        setState(() {
          // Update UI when new data arrives
        });
      }
    });

    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();

    // Add this new controller for pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    // Initialize the app bar animation controller
    _appBarAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    // Make sure to stop animations before disposing
    _animationController.stop();
    _pulseController.stop();
    _appBarAnimationController.stop();

    // Dispose all controllers
    _animationController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    _appBarAnimationController.dispose();

    super.dispose();
  }

  void _refreshExams() {
    // Cancel any existing subscriptions
    if (mounted) {
      context.read<OnlineExamCubit>().getOnlineExams();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh exams when returning to this screen
    _refreshExams();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to transparent with light icons for better visibility on dark app bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return WillPopScope(
      onWillPop: () async {
        // Make sure to stop animations before popping
        _animationController.stop();
        _pulseController.stop();
        _appBarAnimationController.stop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        extendBodyBehindAppBar: true,
        appBar: CustomModernAppBar(
          title: 'Ujian Online',
          icon: Icons.assignment_outlined,
          fabAnimationController: _appBarAnimationController,
          primaryColor: _primaryColor,
          lightColor: _highlightColor,
          showAddButton: true,
          onAddPressed: () async {
            // Navigate ke create exam screen dan tunggu hasil
            final result =
                await Navigator.pushNamed(context, Routes.createOnlineExam);
            // Jika kembali dengan result true, refresh data
            if (result == true) {
              _refreshExams();
            }
          },
          showArchiveButton: true,
          onArchivePressed: () {
            // Navigate to archived exams page
            Navigator.pushNamed(context, Routes.archiveOnlineExam);
          },
          onBackPressed: () {
            // Make sure to stop animations before popping
            _animationController.stop();
            _pulseController.stop();
            _appBarAnimationController.stop();
            Navigator.of(context).pop();
          },
        ),
        body: _buildAnimatedBody(),
      ),
    );
  }

  // _buildCreateExamButton method removed as we're using the CustomModernAppBar add button
  Widget _buildAnimatedBody() {
    return AnimationLimiter(
      child: CustomScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        slivers: [
          // Add padding for the app bar
          SliverPadding(
            padding: EdgeInsets.only(
                top:
                    120), // Increased padding to create more space between appbar and search
            sliver: SliverToBoxAdapter(child: SizedBox()),
          ),
          _buildSearchAndFilter(),
          BlocBuilder<OnlineExamCubit, OnlineExamState>(
            builder: (context, state) {
              if (state is OnlineExamLoading) {
                return SliverFillRemaining(
                  child: _buildShimmerLoading(),
                );
              }
              if (state is OnlineExamSuccess) {
                return state.exams.isEmpty
                    ? SliverFillRemaining(child: _buildEmptyState())
                    : _buildExamGrid(state);
              }
              if (state is OnlineExamFailure) {
                return SliverFillRemaining(
                  child: CustomErrorWidget(
                    message: ErrorMessageUtils.getReadableErrorMessage(
                        state.message),
                    onRetry: _refreshExams,
                    primaryColor: _primaryColor,
                  ),
                );
              }
              return SliverToBoxAdapter(child: SizedBox());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 20),
            _buildFilterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return FadeInDown(
      duration: Duration(milliseconds: 600),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Cari ujian...',
            prefixIcon:
                Icon(Icons.search, color: Theme.of(context).primaryColor),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear,
                        color: Theme.of(context).primaryColor),
                    onPressed: () {
                      setState(() {
                        searchQuery = "";
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return BlocBuilder<OnlineExamCubit, OnlineExamState>(
      builder: (context, state) {
        List<SubjectDetail> subjects = [];
        if (state is OnlineExamSuccess) {
          // Filter out null items and safely convert valid ones
          subjects = state.subjectDetails
              .where((e) => e != null) // Filter out null items
              .map((e) {
                try {
                  return SubjectDetail.fromJson(e);
                } catch (error) {
                  return null;
                }
              })
              .whereType<SubjectDetail>() // Filter out failed conversions
              .toList();
        }

        return FadeInDown(
          duration: Duration(milliseconds: 700),
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF8B0000).withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.filter_alt_rounded,
                            color: Color(0xFF8B0000)),
                        SizedBox(width: 10),
                        Text(
                          'Filter Ujian',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B0000),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedSubjectDetail = null;
                        });
                        context.read<OnlineExamCubit>().getOnlineExams();
                      },
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          color: Color(0xFF800020), // Maroon color
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                DropdownButtonFormField<SubjectDetail>(
                  value: selectedSubjectDetail,
                  decoration: InputDecoration(
                    prefixIcon:
                        Icon(Icons.school_rounded, color: Color(0xFF8B0000)),
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
                      selectedSubjectDetail = value;
                    });
                    if (value != null) {
                      context.read<OnlineExamCubit>().getOnlineExams(
                            subjectId: value.class_subject_id,
                            classSectionId: value.classSection.id,
                          );
                    } else {
                      context.read<OnlineExamCubit>().getOnlineExams();
                    }
                  },
                  isExpanded: true,
                  hint: Text(
                    'Pilih Kelas & Mata Pelajaran',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (bool selected) {
          // Handle filter selection
        },
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildExamGrid(OnlineExamSuccess state) {
    // Filter ujian berdasarkan kata kunci pencarian
    final filteredExams = searchQuery.isEmpty
        ? state.exams
        : state.exams
            .where((exam) =>
                exam.title.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    // Jika tidak ada ujian yang sesuai dengan pencarian, tampilkan NoSearchResultsWidget
    if (filteredExams.isEmpty && searchQuery.isNotEmpty) {
      return SliverFillRemaining(
        child: NoSearchResultsWidget(
          searchQuery: searchQuery,
          onClearSearch: () {
            setState(() {
              searchQuery = "";
            });
          },
          primaryColor: _primaryColor,
          accentColor: _highlightColor,
          title: 'Tidak Ada Ujian',
          description:
              'Tidak ditemukan ujian yang sesuai dengan pencarian Anda. Coba gunakan kata kunci yang berbeda.',
          clearButtonText: 'Hapus Pencarian',
          icon: Icons.assignment_outlined,
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: Duration(milliseconds: 500),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildExamCard(context, filteredExams[index]),
                ),
              ),
            );
          },
          childCount: filteredExams.length,
        ),
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, exam.OnlineExam exam) {
    // Define modern color scheme with soft maroon colors
    final colorScheme = {
      'primary': Color.fromARGB(255, 172, 33, 33),
      'gradient1': Color(0xFF7D1F1F), // Lighter maroon
      'gradient2': Color(0xFF9B2F2F), // Medium maroon
      'gradient3': Color(0xFFBF4040), // Soft bright maroon
    }; // Calculate the positioning for perfect centering
    final double estimatedTextHeight = (exam.title.length / 20).ceil() * 32.0;
    final double minHeight = 240.0; // Minimum height untuk header
    final double maxHeight = 400.0; // Maximum height untuk header

    // Sesuaikan headerHeight dengan batasan min dan max
    final double headerHeight = math.min(
      maxHeight,
      math.max(minHeight, estimatedTextHeight + 180.0),
    );

    return FadeInUp(
      duration: Duration(milliseconds: 600),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Get.toNamed('/exam-questions/${exam.id}'),
            borderRadius: BorderRadius.circular(32),
            highlightColor: Colors.transparent,
            splashColor: colorScheme['primary']!.withOpacity(0.05),
            child: Ink(
              decoration: BoxDecoration(
                color: Color.fromARGB(
                    255, 237, 237, 237), // Very slightly off-white
                borderRadius: BorderRadius.circular(32),
                // Keep your existing shadows if desired
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Exam Title
                      Container(
                        height: headerHeight, // Increased height
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme['gradient1']!,
                              colorScheme['gradient2']!,
                              colorScheme['gradient3']!,
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Decorative Pattern Overlay
                            Opacity(
                              opacity: 0.07,
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: Modern2025PatternPainter(
                                  primaryColor: Colors.white,
                                  secondaryColor: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),

                            // Glow Effect Corner
                            Positioned(
                              top: -30,
                              right: -30,
                              child: Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.2),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Duration Badge
                            Positioned(
                              top: 20,
                              right: 24,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: -5,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.timer_outlined,
                                        size: 16,
                                        color: colorScheme['primary']),
                                    SizedBox(width: 6),
                                    Text(
                                      '${exam.duration} min',
                                      style: TextStyle(
                                        color: colorScheme['primary'],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Exam Title - Updated position and styling
                            Positioned(
                              top: 80, // Move title more to top
                              left: 24,
                              right: 24,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                              64,
                                    ),
                                    child: Text(
                                      exam.title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24, // Slightly smaller font
                                        fontWeight: FontWeight.w800,
                                        height: 1.4, // Increased line height
                                        letterSpacing: 0.3,
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            offset: Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      textAlign: TextAlign
                                          .left, // Ensure left alignment
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Container(
                                    width: 60,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content Section - Add increased top padding for better spacing
                      Container(
                        padding: EdgeInsets.fromLTRB(
                            24, 120, 24, 24), // Increased top padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Actions Row - Modern Button Design
                            Row(
                              children: [
                                // Edit Button - Modern Design
                                Expanded(
                                  child: _buildModernActionButton(
                                    onTap: () async {
                                      // Navigate ke edit exam screen dan tunggu hasil
                                      final result = await Get.toNamed(
                                        Routes.editOnlineExam,
                                        arguments: exam,
                                      );
                                      // Jika kembali dengan result true, refresh data
                                      if (result == true) {
                                        _refreshExams();
                                      }
                                    },
                                    icon: Icons.edit_outlined,
                                    label: 'Edit',
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF26A69A),
                                        Color(0xFF00897B),
                                        Color(0xFF00796B),
                                      ],
                                    ),
                                    shadowColor:
                                        Color(0xFF26A69A).withOpacity(0.4),
                                  ),
                                ),

                                SizedBox(width: 16),

                                // Archive Button - Modern Design
                                Expanded(
                                  child: _buildModernActionButton(
                                    onTap: () => _showDeleteConfirmation(exam),
                                    icon: Icons.archive_outlined,
                                    label: 'Arsip',
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF9C4146), // Softer maroon
                                        Color(0xFF812A33), // Medium maroon
                                        Color(0xFF6A1B24), // Deep maroon
                                      ],
                                    ),
                                    shadowColor:
                                        Color(0xFF812A33).withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Overlapping Card - Adjust position based on new title position
                  Positioned(
                    top: headerHeight -
                        85, // Adjust this value to fine-tune positioning
                    left: 20,
                    right: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                            spreadRadius: -5,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 5,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () =>
                              Get.toNamed('/exam-questions/${exam.id}'),
                          splashColor:
                              colorScheme['primary']!.withOpacity(0.05),
                          highlightColor: Colors.transparent,
                          child: Column(
                            children: [
                              // Top section: Manage Questions
                              Padding(
                                padding: EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    // Icon Container - reduced padding
                                    Container(
                                      padding:
                                          EdgeInsets.all(10), // Reduced from 12
                                      decoration: BoxDecoration(
                                        color: colorScheme['primary']!
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.question_answer_rounded,
                                        color: colorScheme['primary'],
                                        size: 20, // Reduced from 22
                                      ),
                                    ),
                                    SizedBox(width: 12), // Reduced from 16

                                    // Text Content - with overflow handling
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Kelola Soal Ujian',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: colorScheme['neutral1'],
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Lihat dan atur soal pada ujian ini',
                                            style: TextStyle(
                                              color: colorScheme['neutral2'],
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Arrow Icon - reduced padding
                                    Container(
                                      padding:
                                          EdgeInsets.all(8), // Reduced from 10
                                      decoration: BoxDecoration(
                                        color: colorScheme['primary']!
                                            .withOpacity(0.07),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_rounded,
                                        color: colorScheme['primary'],
                                        size: 16, // Reduced from 18
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Divider
                              Divider(
                                height: 1,
                                thickness: 1,
                                color:
                                    colorScheme['primary']!.withOpacity(0.08),
                                indent: 20,
                                endIndent: 20,
                              ),

                              // Bottom section: Dates display
                              Padding(
                                padding: EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // Start Date
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              size: 16,
                                              color: colorScheme['primary'],
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'Mulai',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: colorScheme['neutral2'],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          DateFormat('dd MMM yyyy', 'id_ID')
                                              .format(exam.startDate),
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: colorScheme['neutral1'],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Divider
                                    Container(
                                      height: 35,
                                      width: 1,
                                      color: Colors.grey.shade200,
                                    ),

                                    // End Date
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.calendar_month_rounded,
                                              size: 16,
                                              color: colorScheme['accent'],
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'Selesai',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: colorScheme['neutral2'],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          DateFormat('dd MMM yyyy', 'id_ID')
                                              .format(exam.endDate),
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: colorScheme['neutral1'],
                                            fontWeight: FontWeight.w600,
                                          ),
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required Color shadowColor,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 15,
            offset: Offset(0, 5),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.transparent,
          child: Stack(
            children: [
              // Subtle pattern overlay
              Opacity(
                opacity: 0.05,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://www.transparenttextures.com/patterns/cubes.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // Button content
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Top highlight for 3D effect
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.0),
                      ],
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

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: 3,
        itemBuilder: (_, index) => Container(
          margin: EdgeInsets.symmetric(vertical: 16),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main card container
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header shimmer - matches the gradient header
                    Container(
                      height: 240,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Duration badge position
                          Positioned(
                            top: 20,
                            right: 24,
                            child: Container(
                              width: 80,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          // Title position
                          Positioned(
                            top: 80,
                            left: 24,
                            right: 24,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Container(
                                  width: 60,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(1.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content section with action buttons
                    Container(
                      padding: EdgeInsets.fromLTRB(24, 120, 24, 24),
                      child: Row(
                        children: [
                          // Edit button shimmer
                          Expanded(
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          // Archive button shimmer
                          Expanded(
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Overlapping card shimmer - matches the white overlay card
              Positioned(
                top: 155, // Matches the positioning in real card
                left: 20,
                right: 20,
                child: Container(
                  height: 170, // Approximate height of the overlay card
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Top section: Manage Questions shimmer
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // Icon container shimmer
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 12),
                            // Text content shimmer
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Arrow icon shimmer
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Divider
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey[200],
                        indent: 20,
                        endIndent: 20,
                      ),
                      // Bottom section: Dates shimmer
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Start Date shimmer
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  width: 80,
                                  height: 15,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                            // Divider shimmer
                            Container(
                              height: 35,
                              width: 1,
                              color: Colors.grey[200],
                            ),
                            // End Date shimmer
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  width: 80,
                                  height: 15,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
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
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeIn(
      duration: Duration(milliseconds: 800),
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                Icon(
                  Icons.assignment_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 20),
                Text(
                  'Belum ada ujian',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Tambahkan ujian baru dengan menekan tombol +',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(exam.OnlineExam exam) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF812A33).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.archive_rounded,
                  color: Color(0xFF812A33),
                  size: 28,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Arsipkan Ujian',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin mengarsipkan ujian "${exam.title}"?',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF555555),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Ujian yang diarsipkan dapat dilihat kembali di menu Arsip.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF888888),
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF9C4146), // Softer maroon
                            Color(0xFF812A33), // Medium maroon
                            Color(0xFF6A1B24), // Deep maroon
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF812A33).withOpacity(0.4),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            HapticFeedback.mediumImpact();
                            Navigator.pop(dialogContext);
                            try {
                              await context
                                  .read<OnlineExamCubit>()
                                  .deleteOnlineExam(
                                    examId: exam.id,
                                    mode: 'archive',
                                  );

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Container(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.white),
                                        SizedBox(width: 12),
                                        Text(
                                          'Ujian berhasil diarsipkan!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  backgroundColor: Color(0xFF2E7D32),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 4,
                                ),
                              );

                              Future.delayed(Duration(milliseconds: 800), () {
                                if (mounted) {
                                  _refreshExams();
                                }
                              });
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal mengarsipkan ujian'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          splashColor: Colors.white.withOpacity(0.2),
                          highlightColor: Colors.transparent,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.archive_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Arsipkan Sekarang',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Add these helper methods
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

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.15),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: CircleBorder(),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.2),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.white.withOpacity(0.1 + 0.1 * _pulseAnimation.value),
                blurRadius: 12 * (1 + _pulseAnimation.value),
                spreadRadius: 2 * _pulseAnimation.value,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: CircleBorder(),
            child: InkWell(
              customBorder: CircleBorder(),
              onTap: () {
                HapticFeedback.mediumImpact();
                Get.toNamed(Routes.createOnlineExam);
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class Modern2025PatternPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  Modern2025PatternPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create a sophisticated pattern with curved lines and dots
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    final double spacing = 40;

    // Draw curved lines
    for (double i = -size.width / 2; i < size.width * 1.5; i += spacing) {
      final path = Path();
      path.moveTo(i, 0);

      // Create a gentle curve
      path.quadraticBezierTo(
          i + size.width / 3, size.height / 2, i + size.width / 4, size.height);

      canvas.drawPath(path, paint);
    }

    // Add decorative dots
    for (int i = 0; i < 12; i++) {
      double x = (size.width / 12) * i + (i % 2 == 0 ? 10 : -10);
      double y = (i % 3 == 0)
          ? size.height * 0.2
          : (i % 3 == 1)
              ? size.height * 0.5
              : size.height * 0.8;

      // Vary dot sizes
      double radius = (i % 4 == 0)
          ? 3.0
          : (i % 4 == 1)
              ? 1.5
              : (i % 4 == 2)
                  ? 2.0
                  : 1.0;

      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
