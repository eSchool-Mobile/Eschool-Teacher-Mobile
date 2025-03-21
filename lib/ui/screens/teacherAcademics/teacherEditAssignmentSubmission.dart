import 'package:eschool_saas_staff/cubits/teacherAcademics/assignmentSubmissions/editAssignmetSubmissionCubit.dart';
import 'package:eschool_saas_staff/data/models/assignmentSubmission.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/studyMaterialContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customDropdownSelectionButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

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
    with SingleTickerProviderStateMixin {
  bool isAccepting = true;
  late final TextEditingController _feedbackTextEditingController =
      TextEditingController();
  late final TextEditingController _pointsTextEditingController =
      TextEditingController(
          text: widget.assignmentSubmission.points.toString());

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _feedbackTextEditingController.dispose();
    _pointsTextEditingController.dispose();
    _animationController.dispose();
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: BlocConsumer<EditAssignmentSubmissionCubit,
          EditAssignmentSubmissionState>(
        listener: (context, state) {
          if (state is EditAssignmentSubmissionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.green,
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      Utils.getTranslatedLabel(
                          assignmentReviewAddedSuccessfullyKey),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: CustomRoundedButton(
              height: 58,
              widthPercentage: 1.0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              buttonTitle: submitKey,
              showBorder: false,
              onTap: () {
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
                          widget.assignmentSubmission.assignment.points <= 0 ||
                                  !isAccepting
                              ? "0"
                              : _pointsTextEditingController.text.trim(),
                      assignmentSubmissionFeedBack:
                          _feedbackTextEditingController.text.trim(),
                    );
              },
              child: state is EditAssignmentSubmissionInProgress
                  ? const CustomCircularProgressIndicator(
                      strokeWidth: 2.5, widthAndHeight: 24)
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Utils.getTranslatedLabel(submitKey),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.send_rounded, size: 20, color: Colors.white),
                      ],
                    ),
            ),
          );
        },
      ),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppbar(titleKey: reviewAssignmentSubmissionKey),
      body: BlocBuilder<EditAssignmentSubmissionCubit,
          EditAssignmentSubmissionState>(
        builder: (context, state) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: IgnorePointer(
              ignoring: state is EditAssignmentSubmissionInProgress,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card with Assignment and Student Info
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.8),
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).shadowColor.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.3),
                                child: Icon(
                                  Icons.school_outlined,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget
                                          .assignmentSubmission.assignment.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      widget.assignmentSubmission.assignment
                                          .subject
                                          .getSybjectNameWithType(),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.3),
                                child: Icon(
                                  Icons.person_outlined,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Utils.getTranslatedLabel(studentNameKey),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      widget.assignmentSubmission.student
                                          .fullName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
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
                    SizedBox(height: 20),

                    // Form Content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Status Section
                                Text(
                                  Utils.getTranslatedLabel(statusKey),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                SizedBox(height: 8),
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: isAccepting
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    border: Border.all(
                                      color: isAccepting
                                          ? Colors.green.withOpacity(0.3)
                                          : Colors.red.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Icon(
                                          isAccepting
                                              ? Icons.check_circle_outline
                                              : Icons.cancel_outlined,
                                          color: isAccepting
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      Expanded(
                                        child:
                                            CustomSelectionDropdownSelectionButton(
                                          onTap: isNonEditable
                                              ? () {}
                                              : () {
                                                  Utils.showBottomSheet(
                                                    child:
                                                        FilterSelectionBottomsheet<
                                                            String>(
                                                      onSelection: (value) {
                                                        Get.back();
                                                        setState(() {
                                                          isAccepting = value ==
                                                              acceptKey;
                                                          if (!isAccepting) {
                                                            _pointsTextEditingController
                                                                .text = "";
                                                          }
                                                        });
                                                      },
                                                      selectedValue: isAccepting
                                                          ? acceptKey
                                                          : rejectKey,
                                                      titleKey: statusKey,
                                                      showFilterByLabel: false,
                                                      values: const [
                                                        acceptKey,
                                                        rejectKey
                                                      ],
                                                    ),
                                                    context: context,
                                                  );
                                                },
                                          titleKey: isNonEditable
                                              ? widget.assignmentSubmission
                                                  .submissionStatus.titleKey
                                              : (isAccepting
                                                  ? acceptKey
                                                  : rejectKey),
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 24),

                                // Points Field (Improved)
                                if ((isAccepting ||
                                        (isNonEditable &&
                                            widget.assignmentSubmission
                                                    .submissionStatus.filter ==
                                                AssignmentSubmissionFilters
                                                    .accepted)) &&
                                    widget.assignmentSubmission.assignment
                                            .points !=
                                        0) ...[
                                  Text(
                                    Utils.getTranslatedLabel(pointsKey),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.star_outline,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            size: 24,
                                          ),
                                        ),
                                        Expanded(
                                          child: isNonEditable
                                              ? Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0,
                                                      horizontal: 4.0),
                                                  child: Text(
                                                    _pointsTextEditingController
                                                        .text,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                    ),
                                                  ),
                                                )
                                              : TextField(
                                                  controller:
                                                      _pointsTextEditingController,
                                                  enabled: !isNonEditable,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlignVertical:
                                                      TextAlignVertical
                                                          .center, // Memusatkan teks secara vertikal
                                                  decoration: InputDecoration(
                                                    hintText: Utils
                                                        .getTranslatedLabel(
                                                            pointsKey),
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 14,
                                                            horizontal: 4),
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
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
                                                ),
                                        ),
                                        Container(
                                          height: 36,
                                          margin: EdgeInsets.only(right: 8),
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            "/ ${widget.assignmentSubmission.assignment.points}",
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                ],

                                // Feedback Field (Improved)
                                Text(
                                  Utils.getTranslatedLabel(feedbackKey),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, top: 16.0),
                                        child: Icon(
                                          Icons.comment_outlined,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          size: 24,
                                        ),
                                      ),
                                      Expanded(
                                        child: isNonEditable
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Text(
                                                  widget.assignmentSubmission
                                                      .feedback,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                ),
                                              )
                                            : TextField(
                                                controller:
                                                    _feedbackTextEditingController,
                                                maxLines: 5,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      Utils.getTranslatedLabel(
                                                          feedbackKey),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.all(16),
                                                ),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 24),

                                if (widget.assignmentSubmission.content
                                    .isNotEmpty) ...[
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.short_text_rounded,
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Jawaban",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            widget.assignmentSubmission.content,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                          ),
                                        )),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                ],

                                // Files Section (Improved)
                                if (widget
                                    .assignmentSubmission.file.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.attachment_outlined,
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        Utils.getTranslatedLabel(filesKey),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: widget.assignmentSubmission.file
                                          .map(
                                            (studyMaterial) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 6.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withOpacity(0.05),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: StudyMaterialContainer(
                                                  showOnlyStudyMaterialTitles:
                                                      true,
                                                  showEditAndDeleteButton:
                                                      false,
                                                  studyMaterial: studyMaterial,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Submit button
                    if (!isNonEditable) _buildSubmitButton(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
