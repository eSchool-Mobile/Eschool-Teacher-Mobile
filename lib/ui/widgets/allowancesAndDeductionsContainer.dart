import 'package:eschool_saas_staff/data/models/staffSalary.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AllowancesAndDeductionsContainer extends StatelessWidget {
  final List<StaffSalary> allowances;
  final List<StaffSalary> deductions;
  const AllowancesAndDeductionsContainer(
      {super.key, required this.allowances, required this.deductions});

  String formatCurrency(double amount) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatCurrency.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    // Enhanced Color Palette - More refined and accessible
    final primaryGreen =
        const Color(0xFF059669); // Professional green for allowances
    final primaryRed = const Color(0xFFDC2626); // Clear red for deductions
    final softBackground = const Color(0xFFF8FAFC); // Clean background

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            softBackground,
            Colors.white,
          ],
          stops: [0.0, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: allowances.isEmpty && deductions.isEmpty
            ? [
                _buildEmptyState(context),
              ]
            : [
                // Enhanced Statistics Header with better spacing
                _buildStatsHeader(context, primaryGreen, primaryRed),
                const SizedBox(height: 20), // Improved spacing

                // Enhanced layout with better visual hierarchy
                if (allowances.isNotEmpty || deductions.isNotEmpty) ...[
                  // Content wrapper for better organization
                  Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 4), // Refined margins
                    child: Column(
                      children: [
                        // Allowances Section with improved layout
                        if (allowances.isNotEmpty) ...[
                          _buildSectionHeader(
                            context: context,
                            title: Utils.getTranslatedLabel(allowancesKey),
                            subtitle: "${allowances.length} tunjangan",
                            icon: Icons.add_circle_outline_rounded,
                            color: primaryGreen,
                            count: allowances.length,
                          ),
                          const SizedBox(height: 12), // Consistent spacing

                          // Enhanced grid layout for better organization
                          ..._buildEnhancedCardList(
                            items: allowances,
                            isAllowance: true,
                            color: primaryGreen,
                            startIndex: 0,
                          ),
                          const SizedBox(height: 24), // Section spacing
                        ],

                        // Deductions Section with improved layout
                        if (deductions.isNotEmpty) ...[
                          _buildSectionHeader(
                            context: context,
                            title: Utils.getTranslatedLabel(deductionsKey),
                            subtitle: "${deductions.length} potongan",
                            icon: Icons.remove_circle_outline_rounded,
                            color: primaryRed,
                            count: deductions.length,
                          ),
                          const SizedBox(height: 12), // Consistent spacing

                          // Enhanced grid layout for better organization
                          ..._buildEnhancedCardList(
                            items: deductions,
                            isAllowance: false,
                            color: primaryRed,
                            startIndex: allowances.length,
                          ),
                          const SizedBox(height: 20), // Bottom spacing
                        ],
                      ],
                    ),
                  ),
                ],
              ],
      ),
    );
  }

  // New method for enhanced card layout
  List<Widget> _buildEnhancedCardList({
    required List<StaffSalary> items,
    required bool isAllowance,
    required Color color,
    required int startIndex,
  }) {
    return items.asMap().entries.map((entry) {
      int index = entry.key;
      StaffSalary staffSalary = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8), // Consistent card spacing
        child: _buildEnhancedCard(
          staffSalary: staffSalary,
          isAllowance: isAllowance,
          index: index,
          color: color,
        )
            .animate(delay: Duration(milliseconds: 100 * (startIndex + index)))
            .fadeIn(duration: 500.ms, curve: Curves.easeOut)
            .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic)
            .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOut),
      );
    }).toList();
  }

  // Enhanced empty state with improved design and messaging
  Widget _buildEmptyState(BuildContext context) {
    final primaryColor = const Color(0xFF6B7280);

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            // Enhanced icon with layered design
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 28,
                    color: primaryColor,
                  ),
                ),
              ],
            )
                .animate(delay: 200.ms)
                .scale(duration: 600.ms, curve: Curves.easeOut),

            const SizedBox(height: 24),

            // Enhanced title
            Text(
              "Belum Ada Data",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            )
                .animate(delay: 400.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2),

            const SizedBox(height: 12),

            // Enhanced description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                Utils.getTranslatedLabel(noAllowancesAndDeductionsKey),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            )
                .animate(delay: 600.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2),

            const SizedBox(height: 24),

            // Decorative element
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 2,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 30,
                  height: 2,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            )
                .animate(delay: 800.ms)
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOut),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).scale(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1.0, 1.0),
        curve: Curves.easeOut);
  }

  // Enhanced section header with improved design and spacing
  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int count,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Clean icon design
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.2), width: 1),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          )
              .animate(delay: 100.ms)
              .scale(duration: 400.ms, curve: Curves.easeOut),

          const SizedBox(width: 16),

          // Enhanced title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                    height: 1.2,
                  ),
                )
                    .animate(delay: 150.ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.2),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.2),
              ],
            ),
          ),

          // Clean count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              "$count",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          )
              .animate(delay: 250.ms)
              .scale(duration: 400.ms, curve: Curves.easeOut),
        ],
      ),
    );
  }

  // Enhanced statistics header with improved layout and visual hierarchy
  Widget _buildStatsHeader(
      BuildContext context, Color allowanceColor, Color deductionColor) {
    final totalAllowances = allowances.fold<double>(
        0,
        (sum, item) =>
            sum +
            (item.allowanceOrDeductionInPercentage() ? 0 : (item.amount ?? 0)));
    final totalDeductions = deductions.fold<double>(
        0,
        (sum, item) =>
            sum +
            (item.allowanceOrDeductionInPercentage() ? 0 : (item.amount ?? 0)));

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2937).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                const Color(0xFF70122E), // Darker maroon
                const Color(0xFF8B1E3F), // Deep maroon
                const Color(0xFF9D2A4C), // Medium maroon
                ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Subtle background pattern
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'data:image/svg+xml,<svg width="40" height="40" xmlns="http://www.w3.org/2000/svg"><defs><pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse"><path d="M 40 0 L 0 0 0 40" fill="none" stroke="rgba(255,255,255,0.02)" stroke-width="1"/></pattern></defs><rect width="100%" height="100%" fill="url(%23grid)"/></svg>'),
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Enhanced title with icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.analytics_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        )
                            .animate()
                            .scale(duration: 600.ms, curve: Curves.easeOut),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Ringkasan Tunjangan & Potongan",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          )
                              .animate()
                              .fadeIn(duration: 500.ms)
                              .slideX(begin: 0.2),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        // Enhanced Allowances summary
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                  color: allowanceColor, // Using the theme color for consistency
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                    color: allowanceColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                    ),
                                  ],
                                  ),
                                  child: Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: Colors.white,
                                  size: 24,
                                  ),
                                ).animate(delay: 200.ms).scale(
                                  duration: 600.ms, curve: Curves.easeOut),
                                const SizedBox(height: 12),
                                Text(
                                  "Tunjangan",
                                  style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${allowances.length}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (totalAllowances > 0) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: allowanceColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color:
                                              allowanceColor.withOpacity(0.3),
                                          width: 1),
                                    ),
                                    child: Text(
                                      formatCurrency(totalAllowances),
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                              .animate(delay: 300.ms)
                              .fadeIn(duration: 600.ms)
                              .slideX(begin: -0.3, curve: Curves.easeOut),
                        ),

                        const SizedBox(width: 12),

                        // Enhanced Deductions summary
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: deductionColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: deductionColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.remove_circle_outline_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ).animate(delay: 250.ms).scale(
                                    duration: 600.ms, curve: Curves.easeOut),
                                const SizedBox(height: 12),
                                Text(
                                  "Potongan",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${deductions.length}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (totalDeductions > 0) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: deductionColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color:
                                              deductionColor.withOpacity(0.3),
                                          width: 1),
                                    ),
                                    child: Text(
                                      formatCurrency(totalDeductions),
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                              .animate(delay: 400.ms)
                              .fadeIn(duration: 600.ms)
                              .slideX(begin: 0.3, curve: Curves.easeOut),
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
    );
  }

  // Enhanced card design with improved layout and readability
  Widget _buildEnhancedCard({
    required StaffSalary staffSalary,
    required bool isAllowance,
    required int index,
    required Color color,
  }) {
    final isPercentage = staffSalary.allowanceOrDeductionInPercentage();
    final amount = isPercentage
        ? "${staffSalary.percentage?.toStringAsFixed(1) ?? "0"}%"
        : formatCurrency(staffSalary.amount ?? 0);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Enhanced icon with cleaner design
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.2), width: 1),
              ),
              child: Icon(
                isAllowance
                    ? Icons.add_circle_outline_rounded
                    : Icons.remove_circle_outline_rounded,
                color: color,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Enhanced content with better typography
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with improved readability
                  Text(
                    staffSalary.payRollSetting?.name ?? "",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Type indicator with improved design
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPercentage
                              ? const Color(0xFF3B82F6).withOpacity(0.1)
                              : const Color(0xFF6B7280).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isPercentage
                                ? const Color(0xFF3B82F6).withOpacity(0.2)
                                : const Color(0xFF6B7280).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPercentage
                                  ? Icons.percent_rounded
                                  : Icons.attach_money_rounded,
                              size: 12,
                              color: isPercentage
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              isPercentage ? "Persen" : "Nominal",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isPercentage
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: color.withOpacity(0.2), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAllowance
                                  ? Icons.add_rounded
                                  : Icons.remove_rounded,
                              size: 12,
                              color: color,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              isAllowance ? "Tambah" : "Kurang",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: color,
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

            const SizedBox(width: 12),

            // Enhanced amount display with better hierarchy
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Amount with improved styling
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: color.withOpacity(0.15), width: 1),
                  ),
                  child: Text(
                    amount,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color,
                      height: 1,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
