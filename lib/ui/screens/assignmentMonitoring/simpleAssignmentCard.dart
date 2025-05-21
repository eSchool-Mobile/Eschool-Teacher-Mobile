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
            // Navigate to assignment detail if needed
            HapticFeedback.mediumImpact();
            // Navigator.pushNamed(context, Routes.assignmentDetailScreen, arguments: assignment.id);
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

                // Student count (former submission info) - now just displays student data in smaller display
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_alt_outlined,
                        size: 15,
                        color: textMediumColor,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Total siswa: ${assignment.points}",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: textMediumColor,
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
    ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOutQuad).slideY(
        begin: 0.05, end: 0, duration: 500.ms, curve: Curves.easeOutQuad);
  }
}
