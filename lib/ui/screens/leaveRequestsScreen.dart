// filepath: d:\UBIG\eSchool\eschool_saas_staff\lib\ui\screens\leaveRequestsScreen.dart
import 'package:eschool_saas_staff/cubits/leave/approveOrRejectLeaveRequestCubit.dart';
import 'package:eschool_saas_staff/cubits/leave/approveOrRejectStudentLeaveRequestCubit.dart';
import 'package:eschool_saas_staff/cubits/leave/leaveRequestsCubit.dart';
import 'package:eschool_saas_staff/cubits/leave/studentLeaveRequestsCubit.dart';
import 'package:eschool_saas_staff/data/models/leaveRequest.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/homeContainer.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/studyMaterialContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/rejectReasonDialog.dart';
import 'package:eschool_saas_staff/ui/widgets/customErrorWidget.dart';
import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'dart:ui';

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({super.key});

  static Widget getRouteInstance() => const LeaveRequestsScreen();

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _fabAnimationController.repeat(reverse: true);

    // Note: Leave requests are now fetched when BlocProvider is created
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void rejectOrApproveLeave(
      {required LeaveRequest leaveRequest,
      required bool approveLeave,
      required bool isStaffLeave}) {
    if (!approveLeave) {
      // Tampilkan dialog untuk input alasan penolakan
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => RejectReasonDialog(
          onReject: (String rejectReason) {
            Navigator.of(context).pop(); // Tutup dialog
            // Tampilkan bottomsheet dengan alasan penolakan
            _showApprovalBottomsheet(
              leaveRequest: leaveRequest,
              approveLeave: false,
              rejectReason: rejectReason,
              isStaffLeave: isStaffLeave,
            );
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      );
    } else {
      // Untuk approval, langsung tampilkan bottomsheet
      _showApprovalBottomsheet(
        leaveRequest: leaveRequest,
        approveLeave: true,
        isStaffLeave: isStaffLeave,
      );
    }
  }

  void _showApprovalBottomsheet({
    required LeaveRequest leaveRequest,
    required bool approveLeave,
    String? rejectReason,
    required bool isStaffLeave,
  }) {
    Utils.showBottomSheet(
            child: isStaffLeave
                ? BlocProvider<ApproveOrRejectLeaveRequestCubit>(
                    create: (context) => ApproveOrRejectLeaveRequestCubit(),
                    child: LeaveRequestDetailsBottomsheet(
                      approveLeave: approveLeave,
                      leaveRequest: leaveRequest,
                      rejectReason: rejectReason,
                      isStaffLeave: isStaffLeave,
                    ),
                  )
                : BlocProvider<ApproveOrRejectStudentLeaveRequestCubit>(
                    create: (context) =>
                        ApproveOrRejectStudentLeaveRequestCubit(),
                    child: LeaveRequestDetailsBottomsheet(
                      approveLeave: approveLeave,
                      leaveRequest: leaveRequest,
                      rejectReason: rejectReason,
                      isStaffLeave: isStaffLeave,
                    ),
                  ),
            context: context)
        .then((value) {
      final refreshLeaveRequests = (value as bool?) ?? false;
      if (refreshLeaveRequests) {
        if (mounted) {
          if (isStaffLeave) {
            context.read<LeaveRequestsCubit>().getLeaveRequests();
          } else {
            context.read<StudentLeaveRequestsCubit>().getStudentLeaveRequests();
          }
        }
      }
    });
  }

  // Modern card with soft shadows for leave request details
  Widget _buildLeaveRequestDetails(
      {required LeaveRequest leaveRequest, required bool isStaffLeave}) {
    final Color maroonPrimary = const Color(0xFF800020);
    final Color maroonLight = const Color(0xFFAA6976);

    final titleTextStyle = TextStyle(
        fontSize: Utils.getScaledValue(context, 13),
        fontFamily: GoogleFonts.poppins().fontFamily,
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.75));

    final dateTextStyle = TextStyle(
        fontSize: Utils.getScaledValue(context, 14),
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontWeight: FontWeight.w600);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: maroonPrimary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Decorative accent element - left side gradient
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 8,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      maroonPrimary,
                      maroonLight,
                    ],
                  ),
                ),
              ),
            ),

            // Decorative accent circle
            Positioned(
              right: -15,
              top: -15,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: maroonPrimary.withOpacity(0.05),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.all(appContentHorizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with user info and days count
                  Row(
                    children: [
                      // User profile image with animated border
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  maroonPrimary.withOpacity(0.2),
                                  maroonPrimary.withOpacity(0.6),
                                  maroonPrimary,
                                  maroonLight,
                                  maroonPrimary.withOpacity(0.2),
                                ],
                              ),
                            ),
                          )
                              .animate(
                                  onPlay: (controller) => controller.repeat())
                              .rotate(
                                  duration: const Duration(seconds: 3),
                                  curve: Curves.linear),
                          Container(
                            width: 46,
                            height: 46,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(23),
                              child: ProfileImageContainer(
                                imageUrl: leaveRequest.user?.image ?? "",
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 12),

                      // User name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomTextContainer(
                              textKey: leaveRequest.user?.fullName ??
                                  (leaveRequest.user?.firstName != null &&
                                          leaveRequest.user?.lastName != null
                                      ? "${leaveRequest.user?.firstName} ${leaveRequest.user?.lastName}"
                                      : leaveRequest.user?.firstName ??
                                          (leaveRequest.userId != null
                                              ? "Siswa ID: ${leaveRequest.userId}"
                                              : "Nama tidak tersedia")),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: Utils.getScaledValue(context, 16),
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Leave days count
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: maroonPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomTextContainer(
                              textKey: (leaveRequest.leaveDetail?.length ?? 1)
                                  .toString(),
                              style: TextStyle(
                                color: maroonPrimary,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontSize: Utils.getScaledValue(context, 20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          CustomTextContainer(
                            textKey: totalKey,
                            style: TextStyle(
                              fontSize: Utils.getScaledValue(context, 13),
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.76),
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(
                              delay: const Duration(milliseconds: 300),
                              duration: const Duration(milliseconds: 500))
                          .slideY(begin: 0.2, end: 0),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 400))
                      .slideX(begin: -0.1, end: 0),

                  const SizedBox(height: 16),

                  // Divider with gradient effect
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          maroonLight.withOpacity(0.3),
                          maroonPrimary.withOpacity(0.5),
                          maroonLight.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Date information with modern design
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: maroonPrimary.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: maroonPrimary.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextContainer(
                                textKey: fromDateKey,
                                style: titleTextStyle.copyWith(
                                  color: maroonPrimary.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              CustomTextContainer(
                                textKey: Utils.formatDate(
                                  DateTime.parse(leaveRequest.fromDate ?? ""),
                                ),
                                style: dateTextStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: maroonPrimary.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: maroonPrimary.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CustomTextContainer(
                                textKey: toDateKey,
                                style: titleTextStyle.copyWith(
                                  color: maroonPrimary.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              CustomTextContainer(
                                textKey: Utils.formatDate(
                                  DateTime.parse(leaveRequest.toDate ?? ""),
                                ),
                                style: dateTextStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(
                          delay: const Duration(milliseconds: 100),
                          duration: const Duration(milliseconds: 400))
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),

                  // Reason section with elegant styling
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: maroonPrimary.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: maroonPrimary.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextContainer(
                          textKey: leaveReasonKey,
                          style: titleTextStyle.copyWith(
                            color: maroonPrimary.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        CustomTextContainer(
                          textKey: leaveRequest.reason ?? "",
                          style: dateTextStyle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 400))
                      .slideY(begin: 0.2, end: 0),

                  // Tampilkan alasan penolakan jika status = rejected dan ada reject_reason
                  if (leaveRequest.status == 2 &&
                      leaveRequest.rejectReason != null &&
                      leaveRequest.rejectReason!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.red[700],
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Alasan Penolakan",
                                  style: titleTextStyle.copyWith(
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            CustomTextContainer(
                              textKey: leaveRequest.rejectReason ?? "",
                              style: dateTextStyle.copyWith(
                                color: Colors.red[800],
                              ),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(
                            delay: const Duration(milliseconds: 250),
                            duration: const Duration(milliseconds: 400))
                        .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 20),

                  // Action buttons with improved styling
                  LayoutBuilder(
                    builder: (context, boxConstraints) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Reject button with elegant styling
                          SizedBox(
                            width: boxConstraints.maxWidth * 0.48,
                            child: CustomRoundedButton(
                              radius: 12,
                              height: 45,
                              widthPercentage: 1.0,
                              backgroundColor: Colors.white,
                              buttonTitle: rejectKey,
                              borderColor: maroonPrimary,
                              titleColor: maroonPrimary,
                              showBorder: true,
                              onTap: () {
                                rejectOrApproveLeave(
                                  leaveRequest: leaveRequest,
                                  approveLeave: false,
                                  isStaffLeave: isStaffLeave,
                                );
                              },
                            ),
                          ),

                          // Approve button with elegant styling
                          SizedBox(
                            width: boxConstraints.maxWidth * 0.48,
                            child: CustomRoundedButton(
                              radius: 12,
                              height: 45,
                              widthPercentage: 1.0,
                              backgroundColor: maroonPrimary,
                              buttonTitle: approveKey,
                              showBorder: false,
                              onTap: () {
                                rejectOrApproveLeave(
                                  leaveRequest: leaveRequest,
                                  approveLeave: true,
                                  isStaffLeave: isStaffLeave,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  )
                      .animate()
                      .fadeIn(
                          delay: const Duration(milliseconds: 300),
                          duration: const Duration(milliseconds: 400))
                      .slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 500))
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  @override
  Widget build(BuildContext context) {
    // Define our custom maroon colors for the design
    const Color maroonPrimary = Color(0xFF800020);
    const Color maroonLight = Color(0xFFAA6976);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor:
            Colors.grey[50], // Light background for better contrast
        body: Stack(
          children: [
            // Subtle background pattern for visual interest
            Positioned.fill(
              child: Opacity(
                opacity: 0.03,
                child: Image.network(
                  'https://www.transparenttextures.com/patterns/cubes.png',
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),

            // Main content with tabs
            Column(
              children: [
                // Tab Bar
                Container(
                  margin: EdgeInsets.only(
                    top:
                        Utils.appContentTopScrollPadding(context: context) + 10,
                    left: appContentHorizontalPadding,
                    right: appContentHorizontalPadding,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: maroonPrimary.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: maroonPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: maroonPrimary,
                    tabs: const [
                      Tab(text: "Cuti Staff"),
                      Tab(text: "Izin Siswa"),
                    ],
                  ),
                ),

                // Tab Bar View
                Expanded(
                  child: TabBarView(
                    children: [
                      // Staff Leave Tab
                      BlocProvider(
                        create: (context) {
                          final cubit = LeaveRequestsCubit();
                          // Fetch leave requests when cubit is created
                          Future.microtask(() => cubit.getLeaveRequests());
                          return cubit;
                        },
                        child: _buildLeaveRequestsTab(isStaffLeave: true),
                      ),
                      // Student Leave Tab
                      BlocProvider(
                        create: (context) {
                          final cubit = StudentLeaveRequestsCubit();
                          // Fetch student leave requests when cubit is created
                          Future.microtask(
                              () => cubit.getStudentLeaveRequests());
                          return cubit;
                        },
                        child: _buildLeaveRequestsTab(isStaffLeave: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Modern App Bar replacement
            Align(
              alignment: Alignment.topCenter,
              child: CustomModernAppBar(
                title: leaveRequestKey.tr,
                icon: Icons.pending_actions_rounded,
                fabAnimationController: _fabAnimationController,
                primaryColor: maroonPrimary,
                lightColor: maroonLight,
                onBackPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveRequestsTab({required bool isStaffLeave}) {
    const Color maroonPrimary = Color(0xFF800020);

    if (isStaffLeave) {
      return BlocConsumer<LeaveRequestsCubit, LeaveRequestsState>(
        listener: (context, state) {
          if (state is LeaveRequestsFetchSuccess) {
            HomeContainer.widgetKey.currentState?.updateLeaveRequestCount(
                totalLeaveRequests: state.leaveRequests.length);
          }
        },
        builder: (context, state) {
          if (state is LeaveRequestsFetchSuccess) {
            return Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    left: appContentHorizontalPadding,
                    right: appContentHorizontalPadding,
                    top: 20,
                    bottom: 30),
                child: Column(
                  children: [
                    // Animated intro text
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: maroonPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Permintaan Cuti Staff",
                            style: TextStyle(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: maroonPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${state.leaveRequests.length} Permintaan",
                              style: TextStyle(
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: maroonPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 400))
                        .slideY(begin: -0.2, end: 0),

                    // Leave request cards
                    ...state.leaveRequests
                        .map((leaveRequest) => _buildLeaveRequestDetails(
                            leaveRequest: leaveRequest, isStaffLeave: true))
                        .toList(),
                  ],
                ),
              ),
            );
          }
          if (state is LeaveRequestsFetchFailure) {
            return Center(
              child: CustomErrorWidget(
                message: state.errorMessage,
                onRetry: () {
                  context.read<LeaveRequestsCubit>().getLeaveRequests();
                },
                primaryColor: maroonPrimary,
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 400));
          }

          return Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomCircularProgressIndicator(
                indicatorColor: maroonPrimary,
              ),
              const SizedBox(height: 20),
              Text(
                "Memuat permintaan...",
                style: TextStyle(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ).animate().fadeIn(duration: const Duration(milliseconds: 400)));
        },
      );
    } else {
      // Student Leave Tab
      return BlocConsumer<StudentLeaveRequestsCubit, StudentLeaveRequestsState>(
        listener: (context, state) {
          // Handle student leave state changes if needed
        },
        builder: (context, state) {
          if (state is StudentLeaveRequestsFetchSuccess) {
            return Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    left: appContentHorizontalPadding,
                    right: appContentHorizontalPadding,
                    top: 20,
                    bottom: 30),
                child: Column(
                  children: [
                    // Animated intro text
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.school,
                            color: maroonPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Permintaan Izin Siswa",
                            style: TextStyle(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: maroonPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${state.leaveRequests.length} Permintaan",
                              style: TextStyle(
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: maroonPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 400))
                        .slideY(begin: -0.2, end: 0),

                    // Leave request cards
                    ...state.leaveRequests
                        .map((leaveRequest) => _buildLeaveRequestDetails(
                            leaveRequest: leaveRequest, isStaffLeave: false))
                        .toList(),
                  ],
                ),
              ),
            );
          }
          if (state is StudentLeaveRequestsFetchFailure) {
            return Center(
              child: CustomErrorWidget(
                message: state.errorMessage,
                onRetry: () {
                  context
                      .read<StudentLeaveRequestsCubit>()
                      .getStudentLeaveRequests();
                },
                primaryColor: maroonPrimary,
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 400));
          }

          return Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomCircularProgressIndicator(
                indicatorColor: maroonPrimary,
              ),
              const SizedBox(height: 20),
              Text(
                "Memuat permintaan...",
                style: TextStyle(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ).animate().fadeIn(duration: const Duration(milliseconds: 400)));
        },
      );
    }
  }
}

class LeaveRequestDetailsBottomsheet extends StatelessWidget {
  final bool approveLeave;
  final LeaveRequest leaveRequest;
  final String? rejectReason;
  final bool isStaffLeave;

  const LeaveRequestDetailsBottomsheet({
    super.key,
    required this.approveLeave,
    required this.leaveRequest,
    this.rejectReason,
    required this.isStaffLeave,
  });

  @override
  Widget build(BuildContext context) {
    final hasAttachments = leaveRequest.attachments?.isNotEmpty ?? false;
    final Color maroonPrimary = const Color(0xFF800020);

    return CustomBottomsheet(
        titleLabelKey: leaveDetailsKey,
        child: Column(
          children: [
            // Enhanced list with better visual styling
            ...leaveRequest.leaveDetail
                    ?.map((leaveDetail) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: maroonPrimary.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: maroonPrimary.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: maroonPrimary.withOpacity(0.1),
                              ),
                              child: Center(
                                child: Text(
                                  DateTime.parse(leaveDetail.date!)
                                      .day
                                      .toString(),
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily,
                                    fontWeight: FontWeight.bold,
                                    color: maroonPrimary,
                                  ),
                                ),
                              ),
                            ),
                            title: CustomTextContainer(
                                textKey:
                                    "${Utils.formatDate(DateTime.parse(leaveDetail.date!))}, ${Utils.weekDays[DateTime.parse(leaveDetail.date!).weekday - 1].tr}"),
                            subtitle: CustomTextContainer(
                                textKey: leaveDetail.type ?? ""),
                          ),
                        ).animate().fadeIn(
                            duration: const Duration(milliseconds: 300),
                            delay: Duration(
                                milliseconds: 100 *
                                    (leaveRequest.leaveDetail!
                                        .indexOf(leaveDetail)))))
                    .toList() ??
                [],
            const SizedBox(
              height: 25.0,
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
              child: LayoutBuilder(builder: (context, boxConstraints) {
                return Row(
                  children: [
                    hasAttachments
                        ? SizedBox(
                            width: boxConstraints.maxWidth * 0.475,
                            child: CustomRoundedButton(
                                radius: 12,
                                height: 45,
                                widthPercentage: 1.0,
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                buttonTitle: attachmentsKey,
                                titleColor: maroonPrimary,
                                borderColor: maroonPrimary,
                                showBorder: true,
                                onTap: () {
                                  Utils.showBottomSheet(
                                      child: LeaveAttachmentsBottomsheet(
                                          files: leaveRequest.attachments!),
                                      context: context);
                                }),
                          )
                        : const SizedBox(),
                    hasAttachments ? const Spacer() : const SizedBox(),
                    isStaffLeave
                        ? BlocConsumer<ApproveOrRejectLeaveRequestCubit,
                            ApproveOrRejectLeaveRequestState>(
                            listener: (context, state) {
                              if (state is ApproveOrRejectLeaveRequestSuccess) {
                                Get.back(result: true);
                                Get.snackbar(
                                  'Sukses',
                                  approveLeave
                                      ? 'Cuti berhasil disetujui.'
                                      : 'Cuti berhasil ditolak.',
                                  backgroundColor: approveLeave
                                      ? Colors.green[50]
                                      : Colors.red[50],
                                  colorText: approveLeave
                                      ? Colors.green[900]
                                      : Colors.red[900],
                                );
                              } else if (state
                                  is ApproveOrRejectLeaveRequestFailure) {
                                Utils.showSnackBar(
                                    message: state.errorMessage,
                                    context: context);
                              }
                            },
                            builder: (context, state) {
                              return _buildApprovalButton(
                                  context,
                                  state,
                                  leaveRequest,
                                  approveLeave,
                                  rejectReason,
                                  isStaffLeave,
                                  boxConstraints,
                                  hasAttachments);
                            },
                          )
                        : BlocConsumer<ApproveOrRejectStudentLeaveRequestCubit,
                            ApproveOrRejectStudentLeaveRequestState>(
                            listener: (context, state) {
                              if (state
                                  is ApproveOrRejectStudentLeaveRequestSuccess) {
                                Get.back(result: true);
                                Get.snackbar(
                                  'Sukses',
                                  approveLeave
                                      ? 'Izin siswa berhasil disetujui.'
                                      : 'Izin siswa berhasil ditolak.',
                                  backgroundColor: approveLeave
                                      ? Colors.green[50]
                                      : Colors.red[50],
                                  colorText: approveLeave
                                      ? Colors.green[900]
                                      : Colors.red[900],
                                );
                              } else if (state
                                  is ApproveOrRejectStudentLeaveRequestFailure) {
                                Utils.showSnackBar(
                                    message: state.errorMessage,
                                    context: context);
                              }
                            },
                            builder: (context, state) {
                              return _buildApprovalButton(
                                  context,
                                  state,
                                  leaveRequest,
                                  approveLeave,
                                  rejectReason,
                                  isStaffLeave,
                                  boxConstraints,
                                  hasAttachments);
                            },
                          ),
                  ],
                );
              }),
            )
          ],
        ));
  }

  Widget _buildApprovalButton(
      BuildContext context,
      dynamic state,
      LeaveRequest leaveRequest,
      bool approveLeave,
      String? rejectReason,
      bool isStaffLeave,
      BoxConstraints boxConstraints,
      bool hasAttachments) {
    final Color maroonPrimary = const Color(0xFF800020);
    final bool isInProgress =
        (isStaffLeave && state is ApproveOrRejectLeaveRequestInProgress) ||
            (!isStaffLeave &&
                state is ApproveOrRejectStudentLeaveRequestInProgress);

    return PopScope(
      canPop: !isInProgress,
      child: SizedBox(
        width: boxConstraints.maxWidth * (hasAttachments ? 0.475 : 1.0),
        child: CustomRoundedButton(
          radius: 12,
          height: 45,
          widthPercentage: 1.0,
          backgroundColor: maroonPrimary,
          buttonTitle: approveLeave ? approveKey : rejectKey,
          showBorder: false,
          child: isInProgress ? const CustomCircularProgressIndicator() : null,
          onTap: () {
            if (isInProgress) {
              return;
            }
            if (isStaffLeave) {
              context
                  .read<ApproveOrRejectLeaveRequestCubit>()
                  .approveOrRejectLeaveRequest(
                      leaveRequestId: leaveRequest.id ?? 0,
                      approveLeave: approveLeave,
                      rejectReason: rejectReason);
            } else {
              context
                  .read<ApproveOrRejectStudentLeaveRequestCubit>()
                  .approveOrRejectStudentLeaveRequest(
                      leaveRequestId: leaveRequest.id ?? 0,
                      approveLeave: approveLeave,
                      rejectReason: rejectReason);
            }
          },
        ),
      ),
    );
  }
}

class LeaveAttachmentsBottomsheet extends StatelessWidget {
  final List<StudyMaterial> files;
  const LeaveAttachmentsBottomsheet({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
        titleLabelKey: viewAttachmentsKey,
        child: Column(
          children: files
              .map((file) => Padding(
                    padding: EdgeInsets.all(appContentHorizontalPadding),
                    child: StudyMaterialContainer(
                        studyMaterial: file, showEditAndDeleteButton: false),
                  ).animate().fadeIn(
                      duration: const Duration(milliseconds: 200),
                      delay: Duration(milliseconds: 100)))
              .toList(),
        ));
  }
}
