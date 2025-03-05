import 'dart:ui';
import 'dart:math';
import 'package:eschool_saas_staff/cubits/teacherAcademics/teacherClassSectionDetailsCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/classListItemContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';

class TeacherClassSectionScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return BlocProvider(
      create: (context) => TeacherClassSectionDetailsCubit(),
      child: const TeacherClassSectionScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const TeacherClassSectionScreen({super.key});

  @override
  State<TeacherClassSectionScreen> createState() =>
      _TeacherClassSectionScreenState();
}

class _TeacherClassSectionScreenState extends State<TeacherClassSectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    Future.delayed(Duration.zero, () {
      getClassSectionDetails();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void getClassSectionDetails() async {
    context
        .read<TeacherClassSectionDetailsCubit>()
        .getTeacherClassSectionDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColorPalette.primaryMaroon,
              secondary: AppColorPalette.secondaryMaroon,
              surface: AppColorPalette.warmBeige,
              background: AppColorPalette.warmBeige,
            ),
      ),
      child: Scaffold(
        backgroundColor: AppColorPalette.warmBeige,
        body: Stack(
          children: [
            // Animated Background Pattern
            AnimatedPositioned(
              duration: Duration(seconds: 2),
              curve: Curves.easeInOut,
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height,
              child: AnimatedOpacity(
                duration: Duration(seconds: 1),
                opacity: 0.1,
                child: CustomPaint(
                  painter: BackgroundPainter(
                    color: AppColorPalette.primaryMaroon,
                  ),
                ),
              ),
            ),

            // Main Content with Animation
            SafeArea(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _controller.value) * 50),
                    child: Opacity(
                      opacity: _controller.value,
                      child: BlocBuilder<TeacherClassSectionDetailsCubit,
                          TeacherClassSectionDetailsState>(
                        builder: (context, state) {
                          if (state is TeacherClassSectionDetailsFetchSuccess) {
                            if (state.classSectionDetails.isEmpty) {
                              return _buildEmptyState(context);
                            }
                            return _buildSuccessState(context, state);
                          }

                          if (state is TeacherClassSectionDetailsFetchFailure) {
                            return _buildErrorState(context, state);
                          }

                          return _buildLoadingState(context);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Glassmorphic AppBar with Animation
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10 * _controller.value,
                        sigmaY: 10 * _controller.value,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColorPalette.warmBeige.withOpacity(0.8),
                              AppColorPalette.warmBeige.withOpacity(0.6),
                            ],
                          ),
                        ),
                        child: const CustomAppbar(titleKey: classSectionKey),
                      ),
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

  Widget _buildEmptyState(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 1 + sin(_controller.value * 2 * pi) * 0.1,
                child: Icon(
                  Icons.school_outlined,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ).createShader(bounds),
                child: CustomTextContainer(
                  textKey: Utils.getTranslatedLabel(noClassSectionSelectedKey),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuccessState(
      BuildContext context, TeacherClassSectionDetailsFetchSuccess state) {
    return AnimationLimiter(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: Utils.appContentTopScrollPadding(context: context) + 25,
                bottom: 16,
                left: appContentHorizontalPadding,
                right: appContentHorizontalPadding,
              ),
              child: _buildHeaderCard(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 475),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildClassCard(
                            context, state.classSectionDetails[index], index),
                      ),
                    ),
                  ),
                ),
                childCount: state.classSectionDetails.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Hero(
      tag: 'class_list_title',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Stack(
          children: [
            Card(
              elevation: 12,
              shadowColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextContainer(
                            textKey: classListKey,
                            style: GoogleFonts.poppins(
                              fontSize: Utils.getScaledValue(context, 20),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.class_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Academic Year 2024',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                Icons.school,
                size: 80,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(
      BuildContext context, ClassSection details, int index) {
    final cardGradient = [
      HSLColor.fromColor(Theme.of(context).colorScheme.primary)
          .withLightness(0.95)
          .toColor(),
      HSLColor.fromColor(Theme.of(context).colorScheme.secondary)
          .withLightness(0.95)
          .toColor(),
    ];

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0.95, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => HapticFeedback.lightImpact(),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: cardGradient,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.08),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.04),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildCardHeader(context, details),
                      _buildCardBody(context, details),
                      _buildCardFooter(context, details),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardHeader(BuildContext context, ClassSection details) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          _buildAvatarBadge(context, details),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.name ?? 'Class Section',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Academic Year 2024-2025',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          _buildStatusIndicator(context, details),
        ],
      ),
    );
  }

  Widget _buildAvatarBadge(BuildContext context, ClassSection details) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.transparent,
        child: Icon(
          Icons.school_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildCardBody(BuildContext context, ClassSection details) {
    // Get current teacher's subject from the list
    final currentTeacherSubject = details.subjectTeachers
            ?.firstWhere(
              (teacher) =>
                  teacher.teacher?.id ==
                  getCurrentTeacherId(), // You need to implement this method
              orElse: () => details.subjectTeachers!.first,
            )
            .subject
            ?.name ??
        '-';

    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoRow(context, 'Class Teacher',
              details.getClassTeacherNames(), Icons.person_outline,
              gradient: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ]),
          SizedBox(height: 16),
          _buildInfoRow(
              context,
              'Teacher Subject', // Changed label
              currentTeacherSubject, // Show only current teacher's subject
              Icons.book_outlined,
              gradient: [
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              ]),
        ],
      ),
    );
  }

  // Add this method to get current teacher ID from your authentication system
  int getCurrentTeacherId() {
    // Implement this to return the current teacher's ID
    // Example:
    // return AuthService.getCurrentUser()?.teacherId ?? 0;
    return 0; // Temporary return value
  }

  Widget _buildInfoRow(
      BuildContext context, String label, String value, IconData icon,
      {required List<Color> gradient}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon,
                size: 24, color: Theme.of(context).colorScheme.primary),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFooter(BuildContext context, ClassSection details) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon(
                //   Icons.badge_outlined,
                //   size: 20,
                //   color: Theme.of(context).colorScheme.primary,
                // ),
                SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, TeacherClassSectionDetailsFetchFailure state) {
    return Center(
      child: ErrorContainer(
        errorMessage: state.errorMessage,
        onTapRetry: () => getClassSectionDetails(),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 1000),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (value * 0.2),
            child: CustomCircularProgressIndicator(
              indicatorColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, ClassSection details) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Active',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final Color color;

  BackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.1,
        size.width,
        size.height * 0.3,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AppColorPalette {
  static const Color primaryMaroon = Color(0xFF8B1F41);
  static const Color secondaryMaroon = Color(0xFFA84B5C);
  static const Color lightMaroon = Color(0xFFE7C8CD);
  static const Color accentPink = Color(0xFFF4D0D9);
  static const Color warmBeige = Color(0xFFF5E6E8);
}
