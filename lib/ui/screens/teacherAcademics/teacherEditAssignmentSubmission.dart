import 'package:eschool_saas_staff/cubits/teacherAcademics/assignmentSubmissions/editAssignmetSubmissionCubit.dart';
import 'package:eschool_saas_staff/data/models/assignmentSubmission.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/studyMaterialContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/Get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherEditAssignmentSubmissionScreen extends StatefulWidget {
  final AssignmentSubmission assignmentSubmission;

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    return BlocProvider(
      create: (context) => EditAssignmentSubmissionCubit(),
      child: TeacherEditAssignmentSubmissionScreen(
        assignmentSubmission: arguments?['assignmentSubmission'] ?? false,
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required AssignmentSubmission assignmentSubmission}) {
    return {"assignmentSubmission": assignmentSubmission};
  }

  const TeacherEditAssignmentSubmissionScreen(
      {super.key, required this.assignmentSubmission});

  @override
  State<TeacherEditAssignmentSubmissionScreen> createState() =>
      _TeacherEditAssignmentSubmissionScreenState();
}

class _TeacherEditAssignmentSubmissionScreenState
    extends State<TeacherEditAssignmentSubmissionScreen>
    with TickerProviderStateMixin {
  bool isAccepting = true;
  late final TextEditingController _feedbackTextEditingController =
      TextEditingController();
  late final TextEditingController _pointsTextEditingController =
      TextEditingController(
          text: widget.assignmentSubmission.points.toString());
  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // AppBar animation controller
  late AnimationController _appBarAnimationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();

    // Pulse animation for glowing effects
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    // Initialize AppBar animation controller
    _appBarAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..forward();

    // Set initial state based on submission status
    final submissionStatus =
        widget.assignmentSubmission.submissionStatus.filter;
    if (submissionStatus == AssignmentSubmissionFilters.accepted) {
      isAccepting = true;
    } else if (submissionStatus == AssignmentSubmissionFilters.rejected) {
      isAccepting = false;
    }
  }

  @override
  void dispose() {
    _feedbackTextEditingController.dispose();
    _pointsTextEditingController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _appBarAnimationController.dispose();
    super.dispose();
  }

  void showErrorMessage(String errorMessageKey) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.redAccent,
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                errorMessageKey,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
      child: BlocConsumer<EditAssignmentSubmissionCubit,
          EditAssignmentSubmissionState>(
        listener: (context, state) {
          if (state is EditAssignmentSubmissionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        Utils.getTranslatedLabel(
                            assignmentReviewAddedSuccessfullyKey),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                backgroundColor: Colors.green.shade400,
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
            );

            Future.delayed(Duration(milliseconds: 800), () {
              Get.back(
                result: widget.assignmentSubmission.copyWith(
                  feedback: _feedbackTextEditingController.text.trim(),
                  status: isAccepting ? 1 : 2,
                  points: int.tryParse(_pointsTextEditingController.text) ?? 0,
                ),
              );
            });
          } else if (state is EditAssignmentSubmissionFailure) {
            showErrorMessage(
                Utils.getTranslatedLabel(assignmentReviewAddingFailedKey));
          }
        },
        builder: (context, state) {
          return Container(
            height: 54,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (state is EditAssignmentSubmissionInProgress) return;

                  if (isAccepting &&
                      widget.assignmentSubmission.assignment.points != 0) {
                    if (_pointsTextEditingController.text.trim().isEmpty) {
                      showErrorMessage("Mohon masukkan poin nilai");
                      return;
                    } else if ((int.tryParse(
                                _pointsTextEditingController.text.trim()) ??
                            0) >
                        widget.assignmentSubmission.assignment.points) {
                      showErrorMessage(
                          "Tidak Dapat Memberikan Poin Lebih dari Total");
                      return;
                    }
                  }
                  if (_feedbackTextEditingController.text.trim().isEmpty) {
                    showErrorMessage("Mohon berikan umpan balik");
                    return;
                  }
                  context
                      .read<EditAssignmentSubmissionCubit>()
                      .updateAssignmentSubmission(
                        assignmentSubmissionId: widget.assignmentSubmission.id,
                        assignmentSubmissionStatus: isAccepting ? 1 : 0,
                        assignmentSubmissionPoints:
                            widget.assignmentSubmission.assignment.points <=
                                        0 ||
                                    !isAccepting
                                ? "0"
                                : _pointsTextEditingController.text.trim(),
                        assignmentSubmissionFeedBack:
                            _feedbackTextEditingController.text.trim(),
                      );
                },
                borderRadius: BorderRadius.circular(15),
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Center(
                  child: state is EditAssignmentSubmissionInProgress
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Memproses...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              Utils.getTranslatedLabel(submitKey),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlowingIconButton(IconData icon, VoidCallback onTap) {
    final Color _highlightColor = Color(0xFFB84D4D); // Softer bright maroon

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

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: label == 'Umpan Balik' ? null : maxLines,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType:
          label == 'Umpan Balik' ? TextInputType.multiline : keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
        alignLabelWithHint: label == 'Umpan Balik',
        contentPadding: EdgeInsets.symmetric(
            horizontal: 15, vertical: label == 'Umpan Balik' ? 20 : 15),
      ),
      minLines: label == 'Umpan Balik' ? 3 : 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isNonEditable =
        widget.assignmentSubmission.submissionStatus.filter ==
                AssignmentSubmissionFilters.accepted ||
            widget.assignmentSubmission.submissionStatus.filter ==
                AssignmentSubmissionFilters.rejected;

    return Scaffold(
        extendBodyBehindAppBar: true, // Mengizinkan body di belakang AppBar
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: CustomModernAppBar(
            title: "Tinjau Pengumpulan",
            icon: Icons.assignment_outlined,
            fabAnimationController: _appBarAnimationController,
            primaryColor: Color(0xFF7A1E23),
            lightColor: Color(0xFF5A2223),
            onBackPressed: () {
              HapticFeedback.mediumImpact();
              Get.back();
            },
          ),
        ),
        body: Container(
          // Container utama dengan latar belakang putih, mentok sampai status bar
          color: Color(0xFFF5F5F5),
          child: BlocBuilder<EditAssignmentSubmissionCubit,
              EditAssignmentSubmissionState>(builder: (context, state) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.only(
                  top: kToolbarHeight +
                      MediaQuery.of(context).padding.top -
                      25, // Mengurangi jarak dari AppBar lebih banyak
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Student Information - Enhanced version
                            SlideInLeft(
                              duration: Duration(milliseconds: 500),
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: 0), // Tidak ada margin tambahan
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      spreadRadius: 0,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Student avatar with animated border
                                        AnimatedBuilder(
                                          animation: _pulseAnimation,
                                          builder: (context, child) {
                                            return Container(
                                              padding: EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withOpacity(0.2),
                                                    blurRadius: 8 *
                                                        (1 +
                                                            _pulseAnimation
                                                                    .value /
                                                                3),
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: CircleAvatar(
                                                radius: 30,
                                                backgroundColor: Colors.white,
                                                child: Text(
                                                  widget.assignmentSubmission
                                                      .student.fullName
                                                      .substring(0, 1)
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                        SizedBox(width: 16),

                                        // Student information
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Section title with hover effect
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  'Informasi Siswa',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                              )
                                                  .animate()
                                                  .fadeIn(duration: 400.ms),

                                              SizedBox(height: 12),

                                              // Student name
                                              Text(
                                                widget.assignmentSubmission
                                                    .student.fullName,
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.3,
                                                ),
                                              )
                                                  .animate()
                                                  .fadeIn(delay: 200.ms)
                                                  .slideX(
                                                      begin: 0.2,
                                                      end: 0,
                                                      duration: 500.ms),

                                              SizedBox(height: 8),

                                              // Additional student info
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Status badge
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 16),

                            // Penilaian Tugas - Enhanced version
                            SlideInRight(
                              duration: Duration(milliseconds: 500),
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      spreadRadius: 0,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Section title
                                    Row(
                                      children: [
                                        // Animated icon
                                        AnimatedBuilder(
                                          animation: _pulseAnimation,
                                          builder: (context, child) {
                                            return Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withOpacity(0.1 *
                                                            _pulseAnimation
                                                                .value),
                                                    blurRadius: 4,
                                                    spreadRadius: 1 *
                                                        _pulseAnimation.value,
                                                  )
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.rate_review_outlined,
                                                size: 18,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Penilaian Tugas',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ).animate().fadeIn(duration: 400.ms).slideY(
                                        begin: -0.2, end: 0, duration: 400.ms),

                                    // Divider with gradient
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 16),
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ).animate().fadeIn(delay: 300.ms).custom(
                                          duration: 600.ms,
                                          curve: Curves.easeOutExpo,
                                          builder: (context, value, child) {
                                            return SizedBox(
                                              width: value *
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width,
                                              child: child,
                                            );
                                          },
                                        ),

                                    // Status Selection Section
                                    Text(
                                      Utils.getTranslatedLabel(statusKey),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    if (isNonEditable) ...[
                                      // Non-editable status display with neumorphic design
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 14, horizontal: 18),
                                        decoration: BoxDecoration(
                                          color: widget
                                                      .assignmentSubmission
                                                      .submissionStatus
                                                      .filter ==
                                                  AssignmentSubmissionFilters
                                                      .accepted
                                              ? Colors.green.withOpacity(0.08)
                                              : Colors.red.withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white,
                                              offset: Offset(-3, -3),
                                              blurRadius: 6,
                                            ),
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              offset: Offset(3, 3),
                                              blurRadius: 6,
                                            ),
                                          ],
                                          border: Border.all(
                                            color: widget
                                                        .assignmentSubmission
                                                        .submissionStatus
                                                        .filter ==
                                                    AssignmentSubmissionFilters
                                                        .accepted
                                                ? Colors.green.withOpacity(0.2)
                                                : Colors.red.withOpacity(0.2),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            AnimatedBuilder(
                                              animation: _pulseAnimation,
                                              builder: (context, child) {
                                                return Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: widget
                                                                .assignmentSubmission
                                                                .submissionStatus
                                                                .filter ==
                                                            AssignmentSubmissionFilters
                                                                .accepted
                                                        ? Colors.green
                                                            .withOpacity(0.1 +
                                                                0.05 *
                                                                    _pulseAnimation
                                                                        .value)
                                                        : Colors.red
                                                            .withOpacity(0.1 +
                                                                0.05 *
                                                                    _pulseAnimation
                                                                        .value),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    widget
                                                                .assignmentSubmission
                                                                .submissionStatus
                                                                .filter ==
                                                            AssignmentSubmissionFilters
                                                                .accepted
                                                        ? Icons
                                                            .check_circle_outline
                                                        : Icons.cancel_outlined,
                                                    color: widget
                                                                .assignmentSubmission
                                                                .submissionStatus
                                                                .filter ==
                                                            AssignmentSubmissionFilters
                                                                .accepted
                                                        ? Colors.green
                                                        : Colors.red,
                                                    size: 20,
                                                  ),
                                                );
                                              },
                                            ),
                                            SizedBox(width: 14),
                                            Text(
                                              Utils.getTranslatedLabel(widget
                                                  .assignmentSubmission
                                                  .submissionStatus
                                                  .titleKey),
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ).animate().fadeIn(delay: 400.ms),
                                    ] else ...[
                                      // Interactive status buttons with enhanced design
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isAccepting = true;
                                                });
                                                HapticFeedback.lightImpact();
                                              },
                                              child: AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 300),
                                                curve: Curves.easeInOut,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 16,
                                                    horizontal: 12),
                                                decoration: BoxDecoration(
                                                  gradient: isAccepting
                                                      ? LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: [
                                                            Colors
                                                                .green.shade400,
                                                            Colors
                                                                .green.shade600,
                                                          ],
                                                        )
                                                      : null,
                                                  color: isAccepting
                                                      ? null
                                                      : Colors.grey
                                                          .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  boxShadow: isAccepting
                                                      ? [
                                                          BoxShadow(
                                                            color: Colors.green
                                                                .withOpacity(
                                                                    0.2),
                                                            blurRadius: 10,
                                                            spreadRadius: 1,
                                                            offset:
                                                                Offset(0, 3),
                                                          )
                                                        ]
                                                      : null,
                                                  border: Border.all(
                                                    color: isAccepting
                                                        ? Colors.green
                                                            .withOpacity(0.6)
                                                        : Colors.grey
                                                            .withOpacity(0.3),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    AnimatedBuilder(
                                                      animation:
                                                          _pulseAnimation,
                                                      builder:
                                                          (context, child) {
                                                        return Container(
                                                          padding:
                                                              EdgeInsets.all(6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: isAccepting
                                                                ? Colors.white
                                                                    .withOpacity(0.2 +
                                                                        0.1 *
                                                                            _pulseAnimation
                                                                                .value)
                                                                : Colors
                                                                    .transparent,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Icon(
                                                            Icons
                                                                .check_circle_outline,
                                                            color: isAccepting
                                                                ? Colors.white
                                                                : Colors.grey
                                                                    .shade600,
                                                            size: 20,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      Utils.getTranslatedLabel(
                                                          acceptKey),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isAccepting
                                                            ? Colors.white
                                                            : Colors
                                                                .grey.shade700,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isAccepting = false;
                                                  _pointsTextEditingController
                                                      .text = "";
                                                });
                                                HapticFeedback.lightImpact();
                                              },
                                              child: AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 300),
                                                curve: Curves.easeInOut,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 16,
                                                    horizontal: 12),
                                                decoration: BoxDecoration(
                                                  gradient: !isAccepting
                                                      ? LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: [
                                                            Colors.red.shade400,
                                                            Colors.red.shade600,
                                                          ],
                                                        )
                                                      : null,
                                                  color: !isAccepting
                                                      ? null
                                                      : Colors.grey
                                                          .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  boxShadow: !isAccepting
                                                      ? [
                                                          BoxShadow(
                                                            color: Colors.red
                                                                .withOpacity(
                                                                    0.2),
                                                            blurRadius: 10,
                                                            spreadRadius: 1,
                                                            offset:
                                                                Offset(0, 3),
                                                          )
                                                        ]
                                                      : null,
                                                  border: Border.all(
                                                    color: !isAccepting
                                                        ? Colors.red
                                                            .withOpacity(0.6)
                                                        : Colors.grey
                                                            .withOpacity(0.3),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    AnimatedBuilder(
                                                      animation:
                                                          _pulseAnimation,
                                                      builder:
                                                          (context, child) {
                                                        return Container(
                                                          padding:
                                                              EdgeInsets.all(6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: !isAccepting
                                                                ? Colors.white
                                                                    .withOpacity(0.2 +
                                                                        0.1 *
                                                                            _pulseAnimation
                                                                                .value)
                                                                : Colors
                                                                    .transparent,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Icon(
                                                            Icons
                                                                .cancel_outlined,
                                                            color: !isAccepting
                                                                ? Colors.white
                                                                : Colors.grey
                                                                    .shade600,
                                                            size: 20,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      Utils.getTranslatedLabel(
                                                          rejectKey),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: !isAccepting
                                                            ? Colors.white
                                                            : Colors
                                                                .grey.shade700,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ).animate().fadeIn(delay: 400.ms).moveX(
                                          begin: 10, end: 0, duration: 400.ms),
                                    ],
                                    SizedBox(height: 20),
                                    // Points Field with visual enhancements
                                    if ((isAccepting ||
                                            (isNonEditable &&
                                                widget
                                                        .assignmentSubmission
                                                        .submissionStatus
                                                        .filter ==
                                                    AssignmentSubmissionFilters
                                                        .accepted)) &&
                                        widget.assignmentSubmission.assignment
                                                .points !=
                                            0) ...[
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            size: 18,
                                            color: Colors.amber,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            Utils.getTranslatedLabel(pointsKey),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade800,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ).animate().fadeIn(delay: 500.ms),
                                      SizedBox(height: 10),
                                      // Enhanced points input with progress indicator
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              blurRadius: 6,
                                              spreadRadius: 0,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.15),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              controller:
                                                  _pointsTextEditingController,
                                              readOnly: isNonEditable,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    widget.assignmentSubmission
                                                        .assignment.points
                                                        .toString()
                                                        .length),
                                              ],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                              decoration: InputDecoration(
                                                labelText: 'Poin Nilai',
                                                labelStyle: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withOpacity(0.7),
                                                  fontSize: 14,
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.star_outline,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                                suffixIcon: Container(
                                                  margin: EdgeInsets.all(8),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                            .withOpacity(0.7),
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .secondary
                                                            .withOpacity(0.7),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Text(
                                                    "/ ${widget.assignmentSubmission.assignment.points}",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                                filled: true,
                                                fillColor: Colors.grey.shade50,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ).animate().fadeIn(delay: 600.ms).slideY(
                                          begin: 0.2, end: 0, duration: 400.ms),
                                      SizedBox(height: 24),
                                    ],

                                    // Feedback Field with enhanced styling
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.comment_outlined,
                                          size: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          Utils.getTranslatedLabel(feedbackKey),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade800,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ).animate().fadeIn(delay: 700.ms),
                                    SizedBox(height: 10),
                                    if (isNonEditable) ...[
                                      // Non-editable feedback display with card design
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.05),
                                              blurRadius: 6,
                                              spreadRadius: 0,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Quote marks for feedback
                                            Icon(
                                              Icons.format_quote,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.3),
                                              size: 24,
                                            ),
                                            SizedBox(height: 8),
                                            // Feedback text
                                            Text(
                                              widget.assignmentSubmission
                                                  .feedback,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87,
                                                height: 1.5,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            // Teacher signature
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "- Guru",
                                                  style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.grey.shade600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ).animate().fadeIn(delay: 800.ms),
                                    ] else ...[
                                      // Interactive feedback text field with enhanced styling
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              blurRadius: 6,
                                              spreadRadius: 0,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.15),
                                            width: 1,
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller:
                                              _feedbackTextEditingController,
                                          maxLines: null,
                                          minLines: 4,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                          decoration: InputDecoration(
                                            hintText:
                                                "Berikan umpan balik yang konstruktif...",
                                            hintStyle: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontSize: 14,
                                            ),
                                            prefixIconConstraints:
                                                BoxConstraints(
                                              minWidth: 40,
                                              minHeight: 40,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 16),
                                            alignLabelWithHint: true,
                                          ),
                                        ),
                                      ).animate().fadeIn(delay: 800.ms).slideY(
                                          begin: 0.2, end: 0, duration: 400.ms),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 16),

                            // Student Answer Section - Enhanced version
                            if (widget
                                .assignmentSubmission.content.isNotEmpty) ...[
                              SlideInLeft(
                                duration: Duration(milliseconds: 500),
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        spreadRadius: 0,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Section header with animated icon
                                      Row(
                                        children: [
                                          // Animated icon with glow effect
                                          AnimatedBuilder(
                                            animation: _pulseAnimation,
                                            builder: (context, child) {
                                              return Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                          .withOpacity(0.1 *
                                                              _pulseAnimation
                                                                  .value),
                                                      blurRadius: 4,
                                                      spreadRadius: 1 *
                                                          _pulseAnimation.value,
                                                    )
                                                  ],
                                                ),
                                                child: Icon(
                                                  Icons.text_snippet_outlined,
                                                  size: 18,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              );
                                            },
                                          ),

                                          SizedBox(width: 10),

                                          Text(
                                            "Jawaban Siswa",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              letterSpacing: 0.3,
                                            ),
                                          ),

                                          Spacer(),

                                         
                                        ],
                                      )
                                          .animate()
                                          .fadeIn(duration: 400.ms)
                                          .slideY(
                                              begin: -0.2,
                                              end: 0,
                                              duration: 400.ms),

                                      // Divider with gradient
                                      Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 16),
                                        height: 2,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.1),
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ).animate().fadeIn(delay: 300.ms).custom(
                                            duration: 600.ms,
                                            curve: Curves.easeOutExpo,
                                            builder: (context, value, child) {
                                              return SizedBox(
                                                width: value *
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                child: child,
                                              );
                                            },
                                          ),

                                      // Student answer with paper effect
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.03),
                                              blurRadius: 6,
                                              spreadRadius: 0,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Quote icon at the top
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.format_quote,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withOpacity(0.3),
                                                  size: 24,
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: 10),

                                            // Student answer text with special styling
                                            Text(
                                              widget
                                                  .assignmentSubmission.content,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87,
                                                height: 1.6,
                                                letterSpacing: 0.3,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),

                                            SizedBox(height: 10),

                                            // Line at the bottom with student signature
                                          ],
                                        ),
                                      ).animate().fadeIn(delay: 500.ms).scale(
                                            begin: Offset(0.98, 0.98),
                                            end: Offset(1, 1),
                                            duration: 500.ms,
                                            curve: Curves.easeOutQuad,
                                          ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                            ],

                            // Attachments Section - Enhanced version
                            if (widget
                                .assignmentSubmission.file.isNotEmpty) ...[
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      spreadRadius: 0,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Section header
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.cloud_upload_outlined,
                                            size: 18,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          Utils.getTranslatedLabel(filesKey),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        Spacer(),
                                        // File count badge
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.attach_file,
                                                size: 14,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                "${widget.assignmentSubmission.file.length} ${widget.assignmentSubmission.file.length > 1 ? 'files' : 'file'}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Divider with gradient
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 16),
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),

                                    // File list with consistent styling
                                    ...widget.assignmentSubmission.file.map(
                                      (studyMaterial) {
                                        final extension = studyMaterial.fileName
                                            .split('.')
                                            .last
                                            .toLowerCase();
                                        final extensionLabel =
                                            extension.length > 5
                                                ? extension.substring(0, 3)
                                                : extension;

                                        // Icons based on file type
                                        IconData fileIcon;
                                        if ([
                                          'jpg',
                                          'jpeg',
                                          'png',
                                          'gif',
                                          'bmp',
                                          'webp'
                                        ].contains(extension)) {
                                          fileIcon = Icons.image_outlined;
                                        } else if (['pdf']
                                            .contains(extension)) {
                                          fileIcon =
                                              Icons.picture_as_pdf_outlined;
                                        } else if (['doc', 'docx', 'txt', 'rtf']
                                            .contains(extension)) {
                                          fileIcon = Icons.description_outlined;
                                        } else if (['xls', 'xlsx', 'csv']
                                            .contains(extension)) {
                                          fileIcon = Icons.table_chart_outlined;
                                        } else if (['ppt', 'pptx']
                                            .contains(extension)) {
                                          fileIcon = Icons.slideshow_outlined;
                                        } else if ([
                                          'zip',
                                          'rar',
                                          '7z',
                                          'tar',
                                          'gz'
                                        ].contains(extension)) {
                                          fileIcon = Icons.folder_zip_outlined;
                                        } else {
                                          fileIcon =
                                              Icons.insert_drive_file_outlined;
                                        }

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.2),
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.03),
                                                blurRadius: 6,
                                                spreadRadius: 0,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ListTile(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8),
                                            leading: Container(
                                              width: 42,
                                              height: 42,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.12),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  fileIcon,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  size: 22,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              studyMaterial.fileName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            subtitle: Text(
                                              studyMaterial.fileUrl != null
                                                  ? "Tap to open file"
                                                  : "File unavailable",
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                            trailing: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                extensionLabel.toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                            onTap: () async {
                                              final url = studyMaterial.fileUrl;
                                              if (url != null &&
                                                  url.isNotEmpty) {
                                                if (url.startsWith('http')) {
                                                  // Buka di browser jika fileUrl adalah link online
                                                  if (await canLaunchUrl(
                                                      Uri.parse(url))) {
                                                    await launchUrl(
                                                        Uri.parse(url),
                                                        mode: LaunchMode
                                                            .externalApplication);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Tidak dapat membuka link file.'),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  // Buka file lokal
                                                  try {
                                                    await OpenFilex.open(url);
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Gagal membuka file lokal.'),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'File tidak tersedia.'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ],
                                ),
                              ),
                            ],

                            // Add spacing at the bottom if there's a submit button
                            if (!isNonEditable) SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    // Submit button inside the white container
                    if (!isNonEditable) _buildSubmitButton(context),
                  ],
                ),
              ),
            );
          }),
        ));
  }

  // Helper function to get file extension
  String _getFileExtension(String fileName) {
    return fileName.split('.').last.length > 5
        ? fileName.split('.').last.substring(0, 3)
        : fileName.split('.').last;
  }

  // Helper function to get color based on file type
  Color _getFileTypeColor(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return Colors.blue;
    } else if (['pdf'].contains(extension)) {
      return Colors.red;
    } else if (['doc', 'docx', 'txt', 'rtf'].contains(extension)) {
      return Colors.indigo;
    } else if (['xls', 'xlsx', 'csv'].contains(extension)) {
      return Colors.green;
    } else if (['ppt', 'pptx'].contains(extension)) {
      return Colors.orange;
    } else if (['zip', 'rar', '7z', 'tar', 'gz'].contains(extension)) {
      return Colors.purple;
    } else {
      return Colors.grey;
    }
  }
}
