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
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.63, // Decreased to make cards taller
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return AnimationConfiguration.staggeredGrid(
              position: index,
              columnCount: 2,
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
    final cardColors = {
      'header': Color(0xFF8B0000).withOpacity(0.9),
      'icon': Color(0xFF8B0000),
      'text': Color(0xFF800000),
      'badge': Color(0xFFFFCCCC),
      'border': Color.fromARGB(255, 150, 37, 37),
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Smaller radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 8, vertical: 6), // Smaller padding
              decoration: BoxDecoration(color: cardColors['header']),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6), // Smaller padding
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getExamIcon(exam),
                      color: cardColors['icon'],
                      size: 16, // Smaller icon
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8), // Smaller padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      exam.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13, // Smaller font
                        color: cardColors['text'],
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8), // Smaller spacing

                    // Duration badge
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4), // Smaller padding
                      decoration: BoxDecoration(
                        color: cardColors['badge'],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 14, color: cardColors['text']),
                          SizedBox(width: 4),
                          Text(
                            '${exam.duration} Menit',
                            style: TextStyle(
                              color: cardColors['text'],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),

                    // Dates
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: cardColors['badge']!),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            icon: Icons.event_outlined,
                            text: DateFormat('dd MMM').format(exam.startDate),
                            label: 'Mulai',
                            color: cardColors['text']!,
                            fontSize: 11, // Smaller font
                          ),
                          SizedBox(height: 4),
                          _buildInfoRow(
                            icon: Icons.event_outlined,
                            text: DateFormat('dd MMM').format(exam.endDate),
                            label: 'Selesai',
                            color: cardColors['text']!,
                            fontSize: 11, // Smaller font
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Buttons
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // View Questions Button
                  SizedBox(
                    height: 32, // Smaller height
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Using Get.toNamed() to navigate with exam ID parameter
                        Get.toNamed('/exam-questions/${exam.id}');
                      },
                      icon: Icon(Icons.question_answer_rounded,
                          size: 14, color: Colors.white),
                      label: Text(
                        'Lihat Soal',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cardColors['header'],
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 6),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.edit_rounded,
                          label: 'Edit',
                          onTap: () {
                            Get.toNamed(
                              Routes.editOnlineExam,
                              arguments:
                                  exam, // Pass the exam object as argument
                            );
                          },
                          color: Colors.green[700]!,
                          height: 28, // Tinggi tombol
                          fontSize: 11, // Ukuran font
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.delete_outline,
                          label: 'Hapus',
                          onTap: () => _showDeleteConfirmation(exam),
                          color: Colors.red[700]!,
                          height: 36,
                          fontSize: 12,
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
    );
  }

  // Update helper methods
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
              icon: Icon(Icons.refresh),
              label: Text('Coba Lagi'),
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
  IconData _getExamIcon(exam.OnlineExam exam) {
    // You can customize the conditions based on your exam properties
    if (exam.title.toLowerCase().contains('uts')) {
      return Icons.assignment_outlined;
    } else if (exam.title.toLowerCase().contains('uas')) {
      return Icons.school_outlined;
    } else if (exam.title.toLowerCase().contains('quiz')) {
      return Icons.quiz_outlined;
    } else if (exam.title.toLowerCase().contains('ulangan')) {
      return Icons.note_alt_outlined;
    } else if (exam.duration > 120) {
      // If exam is longer than 2 hours
      return Icons.timer_outlined;
    } else if (exam.duration <= 60) {
      // If exam is 1 hour or less
      return Icons.speed_outlined;
    }

    // Default icon with random selection
    List<IconData> defaultIcons = [
      Icons.fact_check_outlined,
      Icons.library_books_outlined,
      Icons.psychology_outlined,
      Icons.lightbulb_outline,
      Icons.science_outlined,
      Icons.calculate_outlined,
      Icons.menu_book_outlined,
      Icons.cast_for_education_outlined,
    ];

    return defaultIcons[exam.title.length % defaultIcons.length];
  }

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
                        backgroundColor: Colors.orange[700],
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _showPermanentDeleteConfirmation(exam);
                      },
                      icon: Icon(Icons.delete_forever),
                      label: Text('Hapus'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red[700],
                        padding: EdgeInsets.symmetric(vertical: 12),
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
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPermanentDeleteConfirmation(exam.OnlineExam exam) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.dangerous_outlined, color: Colors.red[900], size: 28),
              SizedBox(width: 10),
              Text(
                'Hapus Permanen',
                style: TextStyle(
                  color: Colors.red[900],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Anda yakin ingin menghapus permanen ujian "${exam.title}"?\n\n'
            'Tindakan ini tidak dapat dibatalkan!',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await context.read<OnlineExamCubit>().deleteOnlineExam(
                        examId: exam.id,
                        mode: 'permanent',
                      );

                  // Tampilkan snackbar sukses
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ujian berhasil dihapus permanen'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  // Tampilkan snackbar error
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus ujian'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: Icon(Icons.delete_forever),
              label: Text('Hapus Permanen'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red[900],
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }
}
