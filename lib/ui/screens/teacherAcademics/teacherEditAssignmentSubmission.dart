import 'package:eschool_saas_staff/cubits/teacherAcademics/assignmentSubmissions/editAssignmetSubmissionCubit.dart';
import 'package:eschool_saas_staff/data/models/assignmentSubmission.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/studyMaterialContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
                        assignmentSubmissionStatus: isAccepting ? 1 : 2,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF7A1E23), // Softer deep maroon
              Color(0xFF5A2223), // Softer deeper maroon
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              SlideInDown(
                duration: Duration(milliseconds: 500),
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      // Back button with glowing effect
                      _buildGlowingIconButton(
                        Icons.arrow_back_rounded,
                        () {
                          HapticFeedback.mediumImpact();
                          Get.back();
                        },
                      ),

                      SizedBox(width: 16),

                      // Title and subtitle in column
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Utils.getTranslatedLabel(
                                  reviewAssignmentSubmissionKey),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Nilai dan berikan umpan balik',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: BlocBuilder<EditAssignmentSubmissionCubit,
                      EditAssignmentSubmissionState>(
                    builder: (context, state) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          child: IgnorePointer(
                            ignoring:
                                state is EditAssignmentSubmissionInProgress,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      physics: BouncingScrollPhysics(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Header with Icon
                                            Center(
                                            child: Container(
                                              width: double.infinity, // Making it take full width
                                              padding: EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.9),
                                                Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.7),
                                                ],
                                              ),
                                              borderRadius:
                                                BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 10,
                                                spreadRadius: 1,
                                                offset: Offset(0, 2),
                                                )
                                              ],
                                              ),
                                              child: Column(
                                              mainAxisAlignment:
                                                MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                              children: [
                                                Icon(
                                                Icons.assignment_outlined,
                                                size: 38,
                                                color: Colors.white,
                                                )
                                                  .animate()
                                                  .scale(duration: 500.ms)
                                                  .then()
                                                  .shimmer(duration: 1000.ms),
                                                SizedBox(height: 12),
                                                Text(
                                                widget.assignmentSubmission
                                                  .assignment.name,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.5,
                                                  color: Colors.white,
                                                  shadows: [
                                                  Shadow(
                                                    blurRadius: 8,
                                                    color: Colors.black26,
                                                    offset: Offset(1, 1),
                                                  ),
                                                  ],
                                                ),
                                                ),
                                                SizedBox(height: 6),
                                                Text(
                                                widget.assignmentSubmission
                                                  .assignment.subject
                                                  .getSybjectNameWithType(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white
                                                    .withOpacity(0.9),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                ),
                                              ],
                                              ),
                                            ),
                                            ),


                                          SizedBox(height: 16),

                                          // Student Information
                                          Container(
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.08),
                                                  spreadRadius: 1,
                                                  blurRadius: 8,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Informasi Siswa',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                  ),
                                                ),
                                                SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary
                                                              .withOpacity(0.1),
                                                      child: Icon(
                                                        Icons.person_outlined,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            Utils.getTranslatedLabel(
                                                                studentNameKey),
                                                            style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade600,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            widget
                                                                .assignmentSubmission
                                                                .student
                                                                .fullName,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          SizedBox(height: 16),

                                          // Submission Review
                                          Container(
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.08),
                                                  spreadRadius: 1,
                                                  blurRadius: 8,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Penilaian Tugas',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                  ),
                                                ),
                                                SizedBox(height: 16),

                                                // Status Selection
                                                Text(
                                                  Utils.getTranslatedLabel(
                                                      statusKey),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                                SizedBox(height: 8),

                                                if (isNonEditable) ...[
                                                  // Non-editable status display
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10,
                                                            horizontal: 14),
                                                    decoration: BoxDecoration(
                                                      color: widget
                                                                  .assignmentSubmission
                                                                  .submissionStatus
                                                                  .filter ==
                                                              AssignmentSubmissionFilters
                                                                  .accepted
                                                          ? Colors.green
                                                              .withOpacity(0.1)
                                                          : Colors.red
                                                              .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color: widget
                                                                    .assignmentSubmission
                                                                    .submissionStatus
                                                                    .filter ==
                                                                AssignmentSubmissionFilters
                                                                    .accepted
                                                            ? Colors.green
                                                                .withOpacity(
                                                                    0.3)
                                                            : Colors.red
                                                                .withOpacity(
                                                                    0.3),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          widget
                                                                      .assignmentSubmission
                                                                      .submissionStatus
                                                                      .filter ==
                                                                  AssignmentSubmissionFilters
                                                                      .accepted
                                                              ? Icons
                                                                  .check_circle_outline
                                                              : Icons
                                                                  .cancel_outlined,
                                                          color: widget
                                                                      .assignmentSubmission
                                                                      .submissionStatus
                                                                      .filter ==
                                                                  AssignmentSubmissionFilters
                                                                      .accepted
                                                              ? Colors.green
                                                              : Colors.red,
                                                        ),
                                                        SizedBox(width: 12),
                                                        Text(
                                                          Utils.getTranslatedLabel(widget
                                                              .assignmentSubmission
                                                              .submissionStatus
                                                              .titleKey),
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ] else ...[
                                                  // Selectable status buttons
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              isAccepting =
                                                                  true;
                                                            });
                                                          },
                                                          child:
                                                              AnimatedContainer(
                                                            duration: Duration(
                                                                milliseconds:
                                                                    300),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        10),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isAccepting
                                                                  ? Colors.green
                                                                      .withOpacity(
                                                                          0.15)
                                                                  : Colors.grey
                                                                      .withOpacity(
                                                                          0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border:
                                                                  Border.all(
                                                                color: isAccepting
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .transparent,
                                                                width: 1.5,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .check_circle_outline,
                                                                  color: isAccepting
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .grey,
                                                                  size: 18,
                                                                ),
                                                                SizedBox(
                                                                    width: 8),
                                                                Text(
                                                                  Utils.getTranslatedLabel(
                                                                      acceptKey),
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: isAccepting
                                                                        ? Colors
                                                                            .green
                                                                        : Colors
                                                                            .grey
                                                                            .shade700,
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
                                                              isAccepting =
                                                                  false;
                                                              _pointsTextEditingController
                                                                  .text = "";
                                                            });
                                                          },
                                                          child:
                                                              AnimatedContainer(
                                                            duration: Duration(
                                                                milliseconds:
                                                                    300),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        10),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: !isAccepting
                                                                  ? Colors.red
                                                                      .withOpacity(
                                                                          0.15)
                                                                  : Colors.grey
                                                                      .withOpacity(
                                                                          0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border:
                                                                  Border.all(
                                                                color: !isAccepting
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .transparent,
                                                                width: 1.5,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .cancel_outlined,
                                                                  color: !isAccepting
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .grey,
                                                                  size: 18,
                                                                ),
                                                                SizedBox(
                                                                    width: 8),
                                                                Text(
                                                                  Utils.getTranslatedLabel(
                                                                      rejectKey),
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: !isAccepting
                                                                        ? Colors
                                                                            .red
                                                                        : Colors
                                                                            .grey
                                                                            .shade700,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],

                                                SizedBox(height: 16),

                                                // Points Field
                                                if ((isAccepting ||
                                                        (isNonEditable &&
                                                            widget
                                                                    .assignmentSubmission
                                                                    .submissionStatus
                                                                    .filter ==
                                                                AssignmentSubmissionFilters
                                                                    .accepted)) &&
                                                    widget.assignmentSubmission
                                                            .assignment.points !=
                                                        0) ...[
                                                  Text(
                                                    Utils.getTranslatedLabel(
                                                        pointsKey),
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  _buildAnimatedTextField(
                                                    controller:
                                                        _pointsTextEditingController,
                                                    label: 'Poin',
                                                    icon: Icons.star_outline,
                                                    readOnly: isNonEditable,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                      LengthLimitingTextInputFormatter(
                                                          widget
                                                              .assignmentSubmission
                                                              .assignment
                                                              .points
                                                              .toString()
                                                              .length),
                                                    ],
                                                    suffix: Container(
                                                      height: 32,
                                                      margin: EdgeInsets.only(
                                                          right: 8),
                                                      alignment:
                                                          Alignment.center,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      child: Text(
                                                        "/ ${widget.assignmentSubmission.assignment.points}",
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 16),
                                                ],

                                                // Feedback Field
                                                Text(
                                                  Utils.getTranslatedLabel(
                                                      feedbackKey),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                                SizedBox(height: 8),

                                                if (isNonEditable) ...[
                                                  Container(
                                                    width: double.infinity,
                                                    padding: EdgeInsets.all(14),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey.shade200,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      widget
                                                          .assignmentSubmission
                                                          .feedback,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ] else ...[
                                                  _buildAnimatedTextField(
                                                    controller:
                                                        _feedbackTextEditingController,
                                                    label: 'Umpan Balik',
                                                    icon:
                                                        Icons.comment_outlined,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),

                                          SizedBox(height: 16),

                                          // Student Answer Section
                                          if (widget.assignmentSubmission
                                              .content.isNotEmpty) ...[
                                            Container(
                                              padding: EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.08),
                                                    spreadRadius: 1,
                                                    blurRadius: 8,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .short_text_rounded,
                                                        size: 18,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        "Jawaban Siswa",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 12),
                                                  Container(
                                                    width: double.infinity,
                                                    padding: EdgeInsets.all(14),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey.shade200,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      widget
                                                          .assignmentSubmission
                                                          .content,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                          ],

                                          // Attachments Section
                                          if (widget.assignmentSubmission.file
                                              .isNotEmpty) ...[
                                            Container(
                                              padding: EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.08),
                                                    spreadRadius: 1,
                                                    blurRadius: 8,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .attachment_outlined,
                                                        size: 18,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        Utils
                                                            .getTranslatedLabel(
                                                                filesKey),
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 12),
                                                  ...widget
                                                      .assignmentSubmission.file
                                                      .map(
                                                        (studyMaterial) =>
                                                            Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 10.0),
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary
                                                                  .withOpacity(
                                                                      0.05),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border:
                                                                  Border.all(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary
                                                                    .withOpacity(
                                                                        0.2),
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child:
                                                                StudyMaterialContainer(
                                                              showOnlyStudyMaterialTitles:
                                                                  true,
                                                              showEditAndDeleteButton:
                                                                  false,
                                                              studyMaterial:
                                                                  studyMaterial,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                ],
                                              ),
                                            ),
                                          ],

                                          // Add spacing at the bottom if there's a submit button
                                          if (!isNonEditable)
                                            SizedBox(height: 12),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Submit button inside the white container
                                  if (!isNonEditable)
                                    _buildSubmitButton(context),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
