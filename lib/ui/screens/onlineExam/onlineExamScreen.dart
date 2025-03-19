import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/onlineExam/onlineExamCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/data/models/onlineExam.dart' as exam;
import 'package:eschool_saas_staff/data/models/subjectDetail.dart';
import '../../../app/routes.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class OnlineExamScreen extends StatefulWidget {
  @override
  State<OnlineExamScreen> createState() => _OnlineExamScreenState();
}

class _OnlineExamScreenState extends State<OnlineExamScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? selectedSubject;
  int? selectedSessionYearId;
  late AnimationController _animationController;
  late Animation<double> _animation;

  SubjectDetail? selectedSubjectDetail;
  List<SubjectDetail> subjectDetails = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _refreshExams();

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
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _refreshExams() {
    context.read<OnlineExamCubit>().getOnlineExams();
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
              _buildAnimatedHeader(),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: _buildAnimatedBody(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return FadeInDown(
      duration: Duration(milliseconds: 800),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 100,
        borderRadius: 0,
        blur: 20,
        alignment: Alignment.center,
        border: 0,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.2),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16), // Reduced padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - Back button and title
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero, // Remove padding
                      constraints: BoxConstraints(), // Remove constraints
                    ),
                    SizedBox(width: 8), // Reduced spacing
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ujian Online',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20, // Slightly smaller
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2), // Reduced spacing
                          Text(
                            'Manajemen Ujian',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14, // Smaller font
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Right side - Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Archive Button
                  SizedBox(
                    height: 36, // Fixed height
                    child: ElevatedButton.icon(
                      onPressed: () => Get.toNamed(Routes.archiveOnlineExam),
                      icon: Icon(Icons.archive_outlined, size: 18),
                      label: Text('Arsip'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.secondary,
                        backgroundColor: Colors.white.withOpacity(0.9),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8), // Reduced spacing
                  // Create Exam Button
                  SizedBox(
                    height: 36, // Fixed height
                    child: ElevatedButton.icon(
                      onPressed: () => Get.toNamed(Routes.createOnlineExam),
                      icon: Icon(Icons.add, size: 18),
                      label: Text('Buat'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.secondary,
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateExamButton() {
    return ElevatedButton.icon(
      onPressed: () => Get.toNamed(Routes.createOnlineExam),
      icon: Icon(Icons.add, size: 20),
      label: Text('Buat Ujian'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.secondary,
        backgroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildAnimatedBody() {
    return AnimationLimiter(
      child: CustomScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        slivers: [
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
                  child: _buildError(state.message),
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
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          onChanged: (value) {
            context.read<OnlineExamCubit>().getOnlineExams(
                  search: value,
                  subjectId: selectedSubjectDetail?.subject.id,
                  classSectionId: selectedSubjectDetail?.classSection.id,
                );
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
          subjects = state.subjectDetails
              .map((e) => SubjectDetail.fromJson(e))
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
                        style: TextStyle(color: Color(0xFF8B0000)),
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
                  child: _buildExamCard(context, state.exams[index]),
                ),
              ),
            );
          },
          childCount: state.exams.length,
        ),
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, exam.OnlineExam exam) {
    // Define color palette for maroon theme
    final maroonColors = {
      'primary': Color.fromARGB(255, 162, 44, 50), // Softer deep maroon
      'accent': Color(0xFF9D3C3C), // Softer medium maroon
      'highlight': Color(0xFFB84D4D), // Softer bright maroon
      'energy': Color(0xFFCE6D6D), // Softer light maroon
      'glow': Color(0xFFAF4F4F), // Softer rich maroon
    };

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      child: GestureDetector(
        onTap: () => Get.toNamed('/exam-questions/${exam.id}'),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: maroonColors['primary']!.withOpacity(0.12),
                blurRadius: 40,
                offset: Offset(0, 15),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Header with Pattern
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        maroonColors['primary']!,
                        Color.lerp(
                            maroonColors['primary']!, Colors.black, 0.2)!,
                        maroonColors['primary']!.withOpacity(0.85),
                      ],
                      stops: [0.2, 0.6, 0.9],
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Advanced geometric pattern effect
                      CustomPaint(
                        painter: UltraModernPatternPainter(
                          primaryColor: Colors.white.withOpacity(0.12),
                          secondaryColor: Colors.white.withOpacity(0.06),
                        ),
                      ),

                      // Radial glow effect (adds depth)
                      Positioned(
                        top: -40,
                        right: -40,
                        child: Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0),
                              ],
                              stops: [0.1, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Duration Badge
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer_outlined,
                                  size: 18, color: maroonColors['primary']),
                              SizedBox(width: 8),
                              Text(
                                '${exam.duration} Menit',
                                style: TextStyle(
                                  color: maroonColors['primary'],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Exam Title
                      Positioned(
                        bottom: 22,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exam.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28, // Increased from 22
                                fontWeight: FontWeight.w800, // Made bolder
                                height:
                                    1.2, // Tighter line height for larger text
                                letterSpacing: 0.5, // Increased letter spacing
                                shadows: [
                                  Shadow(
                                    color: Colors.black
                                        .withOpacity(0.6), // Deeper shadow
                                    offset:
                                        Offset(0, 3), // Slightly lower offset
                                    blurRadius: 6, // More blur for depth
                                  ),
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                                decoration: TextDecoration.none,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 12),
                            // Decorative element that adapts to title length
                            LayoutBuilder(
                              builder: (context, constraints) {
                                // Calculate text width - use about 70% of text width
                                final textWidth = TextPainter(
                                  text: TextSpan(
                                    text: exam.title,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  textDirection: ui.TextDirection.ltr,
                                  maxLines: 1,
                                )..layout(maxWidth: constraints.maxWidth);

                                final width = textWidth.width * 0.7;
                                // Ensure minimum width of 60 and maximum of container width
                                final finalWidth =
                                    width.clamp(60.0, constraints.maxWidth);

                                return Container(
                                  width: finalWidth,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Section
                Container(
                  padding: EdgeInsets.fromLTRB(24, 26, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section title with modern accent
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: maroonColors['primary'],
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Detail Ujian",
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 18),

                      // Date and Info Container - Horizontal Layout
                      Container(
                        padding: EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Date Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Start Date
                                  _buildInfoRow(
                                    icon: Icons.event_outlined,
                                    text: DateFormat('dd MMM yyyy')
                                        .format(exam.startDate),
                                    label: 'Tanggal Mulai',
                                    color: maroonColors['primary']!,
                                    fontSize: 14,
                                  ),
                                  SizedBox(height: 12),
                                  // End Date
                                  _buildInfoRow(
                                    icon: Icons.event_outlined,
                                    text: DateFormat('dd MMM yyyy')
                                        .format(exam.endDate),
                                    label: 'Tanggal Selesai',
                                    color: maroonColors['primary']!,
                                    fontSize: 14,
                                  ),
                                ],
                              ),
                            ),

                            // Exam Icon
                          ],
                        ),
                      ),

                      SizedBox(height: 18),

                      // Questions Button
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Colors.grey.shade50,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              spreadRadius: 0,
                              offset: Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: maroonColors['primary']!.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    maroonColors['primary']!.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.question_answer_rounded,
                                color: maroonColors['primary'],
                                size: 22,
                              ),
                            ),
                            SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kelola Soal Ujian',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey[800],
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Lihat dan atur soal pada ujian ini',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color:
                                    maroonColors['primary']!.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: maroonColors['primary'],
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Ultra-modern Action Footer
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(24),
                  child: Row(
                    children: [
                      // Edit Button - Premium Design
                      Expanded(
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                                colors: [
                                Color(0xFF4AE54A), // Bright lime green
                                Color(0xFF2DCB5C), // Vibrant green
                                Color(0xFF00A067), // Deep emerald
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF66B58F).withOpacity(0.25),
                                blurRadius: 15,
                                offset: Offset(0, 6),
                                spreadRadius: -4,
                              ),
                              BoxShadow(
                                color: Color(0xFF66B58F).withOpacity(0.1),
                                blurRadius: 3,
                                offset: Offset(0, 1),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Get.toNamed(
                                    Routes.editOnlineExam,
                                    arguments: exam,
                                  );
                                },
                                splashColor: Colors.white.withOpacity(0.2),
                                highlightColor: Colors.transparent,
                                child: Stack(
                                  children: [
                                    // Subtle pattern overlay
                                    Opacity(
                                      opacity: 0.07,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                'https://www.transparenttextures.com/patterns/diamond-upholstery.png'),
                                            repeat: ImageRepeat.repeat,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Content
                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.edit_outlined,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Edit Ujian',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              letterSpacing: 0.5,
                                              height: 1.2,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black12,
                                                  offset: Offset(0, 1),
                                                  blurRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Shine effect
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 20,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white.withOpacity(0.15),
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
                          ),
                        ),
                      ),

                      SizedBox(width: 14),

                      // Archive Button - Premium Design
                      Expanded(
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                                colors: [
                                Color(0xFFFF5252), // Bright red
                                Color(0xFFFF1744), // Vibrant crimson
                                Color(0xFFD50000), // Deep red
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFE28B7D).withOpacity(0.25),
                                blurRadius: 15,
                                offset: Offset(0, 6),
                                spreadRadius: -4,
                              ),
                              BoxShadow(
                                color: Color(0xFFE28B7D).withOpacity(0.1),
                                blurRadius: 3,
                                offset: Offset(0, 1),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _showDeleteConfirmation(exam),
                                splashColor: Colors.white.withOpacity(0.2),
                                highlightColor: Colors.transparent,
                                child: Stack(
                                  children: [
                                    // Subtle pattern overlay
                                    Opacity(
                                      opacity: 0.07,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                'https://www.transparenttextures.com/patterns/diamond-upholstery.png'),
                                            repeat: ImageRepeat.repeat,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Content
                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.archive_outlined,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Arsipkan',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              letterSpacing: 0.5,
                                              height: 1.2,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black12,
                                                  offset: Offset(0, 1),
                                                  blurRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Shine effect
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 20,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white.withOpacity(0.15),
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required String label,
    required Color color,
    double fontSize = 11, // Default smaller font size
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withOpacity(0.8)),
        SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required double height,
    required double fontSize,
  }) {
    return SizedBox(
      height: height,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 14,
          color: Colors.white, // Warna ikon diubah menjadi putih
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.white, // Warna teks diubah menjadi putih
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(horizontal: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status.toLowerCase() == 'active'
                  ? Color(0xFF006400)
                  : Color(0xFFB8860B),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            status.capitalize!,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeIn(
      duration: Duration(milliseconds: 800),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return FadeIn(
      duration: Duration(milliseconds: 800),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            SizedBox(height: 20),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _refreshExams,
                icon: Icon(Icons.refresh, color: Colors.white),
                label: Text('Coba Lagi', 
                style: TextStyle(color: Colors.white),
                ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8B0000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add this function to get varied icons

  // Tambahkan fungsi ini di dalam class _OnlineExamScreenState
  void _showDeleteConfirmation(exam.OnlineExam exam) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orange[700], size: 28),
              SizedBox(width: 10),
              Text(
                'Konfirmasi',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih tindakan untuk ujian "${exam.title}":',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        try {
                          await context
                              .read<OnlineExamCubit>()
                              .deleteOnlineExam(
                                examId: exam.id,
                                mode: 'archive',
                              );

                          // Tampilkan snackbar sukses
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Ujian berhasil diarsipkan'),
                              backgroundColor: Colors.green,
                              action: SnackBarAction(
                                label: 'Lihat Arsip',
                                textColor: Colors.white,
                                onPressed: () {
                                  Get.toNamed(Routes.archiveOnlineExam);
                                },
                              ),
                            ),
                          );
                        } catch (e) {
                          // Tampilkan snackbar error
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal mengarsipkan ujian'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.archive_outlined),
                      label: Text('Arsipkan'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class UltraModernPatternPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  UltraModernPatternPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Diagonal lines for a premium pattern effect
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double spacing = 30;
    for (double i = -size.width; i < size.width * 2; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    // Add some perpendicular lines for a grid effect
    final secondPaint = Paint()
      ..color = secondaryColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (double i = spacing; i < size.width; i += spacing * 2) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        secondPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
