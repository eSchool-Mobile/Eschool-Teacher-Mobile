import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:eschool_saas_staff/data/models/teacherAssignmentDetail.dart';

class SimpleAssignmentCard extends StatelessWidget {
  final TeacherAssignmentDetail assignment;
  final Color maroonPrimary;
  final Color maroonDark;
  final Color maroonLight;
  final Color textDarkColor;
  final Color textMediumColor;

  const SimpleAssignmentCard({
    Key? key,
    required this.assignment,
    required this.maroonPrimary,
    required this.maroonDark,
    required this.maroonLight,
    required this.textDarkColor,
    required this.textMediumColor,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Initialize date formatting for Indonesian locale
    initializeDateFormatting('id_ID', null);

    // Calculate days remaining until due date
    final daysRemaining = assignment.dueDate.difference(DateTime.now()).inDays;
    final bool isPastDue = daysRemaining < 0;

    // Get formatted due date with Indonesian month names
    final formattedDueDate =
        DateFormat('dd MMMM yyyy', 'id_ID').format(assignment.dueDate);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: maroonPrimary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: maroonLight.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Show assignment detail popup
            HapticFeedback.mediumImpact();
            _showAssignmentDetailPopup(context);
          },
          highlightColor: maroonPrimary.withOpacity(0.03),
          splashColor: maroonPrimary.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Middle section - Assignment details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Assignment name with improved typography
                          Text(
                            assignment.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textDarkColor,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: 6),

                          // Subject text - simplified but elegant
                          Text(
                            assignment.subject,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: maroonPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right side - Class badge with improved design
                    Container(
                      margin: EdgeInsets.only(left: 8, top: 0),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            maroonPrimary,
                            maroonLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: maroonPrimary.withOpacity(0.15),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        assignment.classSection,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                // Elegant divider
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.withOpacity(0.05),
                        Colors.grey.withOpacity(0.2),
                        Colors.grey.withOpacity(0.05),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),

                // Due date info - now takes full width
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isPastDue
                        ? Colors.red.withOpacity(0.05)
                        : maroonPrimary.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPastDue
                          ? Colors.red.withOpacity(0.15)
                          : maroonPrimary.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Calendar icon with refined design
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isPastDue
                              ? Colors.red.withOpacity(0.1)
                              : maroonPrimary.withOpacity(0.1),
                          boxShadow: [
                            BoxShadow(
                              color: (isPastDue ? Colors.red : maroonPrimary)
                                  .withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: isPastDue ? Colors.red : maroonPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Use Flexible instead of just Column to allow text wrapping if needed
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPastDue
                                  ? 'Sudah Lewat Tenggat'
                                  : 'Tenggat Waktu',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isPastDue ? Colors.red : textMediumColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              formattedDueDate,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isPastDue ? Colors.red : maroonPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Submission info in simpler format - pushed to the right
                      // const SizedBox(width: 4), // Smaller spacing
                      // Container(
                      //   padding: EdgeInsets.symmetric(
                      //       horizontal: 10,
                      //       vertical: 6), // Reduced horizontal padding
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(10),
                      //     border: Border.all(
                      //       color: maroonLight.withOpacity(0.2),
                      //     ),
                      //   ),
                      //   child: Text(
                      //     "${assignment.submissionsCount}/${assignment.points} siswa",
                      //     style: GoogleFonts.poppins(
                      //       fontSize: 12, // Slightly smaller font
                      //       fontWeight: FontWeight.w600,
                      //       color: textDarkColor,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOutQuad).slideY(
        begin: 0.05, end: 0, duration: 500.ms, curve: Curves.easeOutQuad);
  }
  // Method to show assignment detail popup
  void _showAssignmentDetailPopup(BuildContext context) {
    // Initialize date formatting for Indonesian locale
    initializeDateFormatting('id_ID', null);

    // Format dates for display
    final formattedStartDate =
        DateFormat('dd MMMM yyyy', 'id_ID').format(assignment.startDate);
    final formattedDueDate =
        DateFormat('dd MMMM yyyy', 'id_ID').format(assignment.dueDate);
    final formattedEndDate =
        DateFormat('dd MMMM yyyy', 'id_ID').format(assignment.endDate);
    final formattedCreatedAt =
        DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(assignment.createdAt);

    // Calculate submission rate as percentage
    final submissionRate = assignment.submissionsCount > 0
        ? "${assignment.submissionsCount}"
        : "0";

    // Determine status color based on due date
    final bool isPastDue = assignment.dueDate.isBefore(DateTime.now());
    final statusColor = isPastDue ? Colors.red : Colors.green;
    final statusText = isPastDue ? "Telah Lewat" : "Berlangsung";

    // Disable autofill to avoid the AutofillManager warning
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Main container
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: maroonPrimary.withOpacity(0.2),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with gradient
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(24, 60, 24, 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            maroonDark,
                            maroonPrimary,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Assignment name
                          Text(
                            assignment.name,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),

                          // Subject and class in a row
                          Row(
                            children: [
                              // Subject chip
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  assignment.subject,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),

                              // Class chip
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  assignment.classSection,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),                    // Content
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.7,
                      ),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          // Status & Submission Count
                          Row(
                            children: [
                              // Status Indicator
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: statusColor.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      statusText,
                                      style: GoogleFonts.poppins(
                                        color: statusColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Spacer(),

                              // Submission count
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: maroonPrimary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.assignment_turned_in_rounded,
                                      size: 16,
                                      color: maroonPrimary,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "$submissionRate Pengajuan",
                                      style: GoogleFonts.poppins(
                                        color: maroonPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20),

                          // Instructions
                          Text(
                            "Instruksi:",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textDarkColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: Text(
                              assignment.instructions.isNotEmpty
                                  ? assignment.instructions
                                  : "Tidak ada instruksi khusus untuk tugas ini.",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: textMediumColor,
                                height: 1.5,
                              ),
                            ),
                          ),

                          SizedBox(height: 20),                          // Information Grid with more flexible layout
                          Container(
                            width: double.infinity,
                            child: Column(
                              children: [
                                // First row - points info
                                Row(
                                  children: [
                                    // Points
                                    Expanded(
                                      child: _buildInfoCard(
                                        icon: Icons.star_rounded,
                                        title: "Poin",
                                        value: "${assignment.points}",
                                        iconColor: Colors.amber,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    // Min Points
                                    Expanded(
                                      child: _buildInfoCard(
                                        icon: Icons.star_half_rounded,
                                        title: "Min Poin",
                                        value: "${assignment.minPoints}",
                                        iconColor: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: 12),
                                
                                // Second row - created date and due date
                                Row(
                                  children: [
                                    // Created Date
                                    Expanded(
                                      child: _buildInfoCard(
                                        icon: Icons.calendar_today_rounded,
                                        title: "Dibuat",
                                        value: formattedCreatedAt,
                                        iconColor: Colors.blue,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    // Due Date
                                    Expanded(
                                      child: _buildInfoCard(
                                        icon: Icons.event_rounded,
                                        title: "Batas Waktu",
                                        value: formattedDueDate,
                                        iconColor:
                                            isPastDue ? Colors.red : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: 12),
                                
                                // Third row - start date and end date
                                Row(
                                  children: [
                                    // Start Date
                                    Expanded(
                                      child: _buildInfoCard(
                                        icon: Icons.play_circle_filled_rounded,
                                        title: "Mulai",
                                        value: formattedStartDate,
                                        iconColor: Colors.green,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    // End Date
                                    Expanded(
                                      child: _buildInfoCard(
                                        icon: Icons.flag_rounded,
                                        title: "Selesai",
                                        value: formattedEndDate,
                                        iconColor: Colors.red,
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

              // Assignment Icon at top
              Positioned(
                top: -40,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        maroonLight,
                        maroonPrimary,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: maroonPrimary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.assignment_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).scale(
              begin: Offset(0.8, 0.8),
              end: Offset(1.0, 1.0),
              duration: 300.ms,
              curve: Curves.easeOutBack,
            );
      },
    );
  }
  // Helper method to build info cards in the grid
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32, // Slightly reduced width
            height: 32, // Slightly reduced height
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                size: 16, // Slightly smaller icon
                color: iconColor,
              ),
            ),
          ),
          SizedBox(width: 6), // Slightly reduced spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Use minimum space needed
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 9, // Slightly smaller font
                    fontWeight: FontWeight.w500,
                    color: textMediumColor,
                  ),
                ),
                SizedBox(height: 2), // Control spacing between text
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 11, // Slightly smaller font
                    fontWeight: FontWeight.w600,
                    color: textDarkColor,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible, // No ellipsis, show all text
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
