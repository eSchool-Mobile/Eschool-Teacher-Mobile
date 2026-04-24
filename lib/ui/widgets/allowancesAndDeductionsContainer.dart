import 'package:eschool_saas_staff/data/models/staffTeacher/staffSalary.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AllowancesAndDeductionsContainer extends StatefulWidget {
  final List<StaffSalary> allowances;
  final List<StaffSalary> deductions;
  final double? baseSalary; // Add this to calculate percentage amounts

  const AllowancesAndDeductionsContainer({
    super.key,
    required this.allowances,
    required this.deductions,
    this.baseSalary,
  });

  @override
  State<AllowancesAndDeductionsContainer> createState() =>
      _AllowancesAndDeductionsContainerState();
}

class _AllowancesAndDeductionsContainerState
    extends State<AllowancesAndDeductionsContainer>
    with TickerProviderStateMixin {
  bool _allowancesExpanded = false;
  bool _deductionsExpanded = false;

  String formatCurrency(double amount) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatCurrency.format(amount);
  }

  // Calculate total amount including percentage-based amounts
  double calculateTotalAmount(List<StaffSalary> items) {
    return items.fold<double>(0, (sum, item) {
      if (item.allowanceOrDeductionInPercentage()) {
        // Convert percentage to nominal amount using base salary
        final baseAmount = widget.baseSalary ?? 0;
        final percentage = item.percentage ?? 0;
        return sum + (baseAmount * percentage / 100);
      } else {
        return sum + (item.amount ?? 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Enhanced Color Palette - More refined and accessible
    const primaryGreen =
        Color(0xFF059669); // Professional green for allowances
    const primaryRed = Color(0xFFDC2626); // Clear red for deductions
    const softBackground = Color(0xFFF8FAFC); // Clean background

    return Container(
      decoration: const BoxDecoration(
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
        children: widget.allowances.isEmpty && widget.deductions.isEmpty
            ? [
                _buildEmptyState(context),
              ]
            : [
                // Enhanced Statistics Header with better spacing
                _buildStatsHeader(context, primaryGreen, primaryRed),
                const SizedBox(height: 20), // Improved spacing

                // Enhanced layout with better visual hierarchy
                if (widget.allowances.isNotEmpty ||
                    widget.deductions.isNotEmpty) ...[
                  // Content wrapper for better organization
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4), // Refined margins
                    child: Column(
                      children: [
                        // Allowances Section with improved layout
                        if (widget.allowances.isNotEmpty) ...[
                          _buildModernSectionHeader(
                            title: Utils.getTranslatedLabel(allowancesKey),
                            subtitle: "${widget.allowances.length} tunjangan",
                            icon: Icons.trending_up_rounded,
                            color: primaryGreen,
                            count: widget.allowances.length,
                            isExpanded: _allowancesExpanded,
                            onToggle: () {
                              setState(() {
                                _allowancesExpanded = !_allowancesExpanded;
                              });
                            },
                          ),
                          const SizedBox(height: 12),

                          // Expandable allowances list
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            height: _allowancesExpanded ? null : 0,
                            child: _allowancesExpanded
                                ? Column(
                                    children: _buildModernCardList(
                                      items: widget.allowances,
                                      isAllowance: true,
                                      color: primaryGreen,
                                      startIndex: 0,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Deductions Section with improved layout
                        if (widget.deductions.isNotEmpty) ...[
                          _buildModernSectionHeader(
                            title: Utils.getTranslatedLabel(deductionsKey),
                            subtitle: "${widget.deductions.length} potongan",
                            icon: Icons.trending_down_rounded,
                            color: primaryRed,
                            count: widget.deductions.length,
                            isExpanded: _deductionsExpanded,
                            onToggle: () {
                              setState(() {
                                _deductionsExpanded = !_deductionsExpanded;
                              });
                            },
                          ),
                          const SizedBox(height: 12),

                          // Expandable deductions list
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            height: _deductionsExpanded ? null : 0,
                            child: _deductionsExpanded
                                ? Column(
                                    children: _buildModernCardList(
                                      items: widget.deductions,
                                      isAllowance: false,
                                      color: primaryRed,
                                      startIndex: widget.allowances.length,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
      ),
    );
  }

  // New method for modern card layout
  List<Widget> _buildModernCardList({
    required List<StaffSalary> items,
    required bool isAllowance,
    required Color color,
    required int startIndex,
  }) {
    return items.asMap().entries.map((entry) {
      int index = entry.key;
      StaffSalary staffSalary = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildModernCard(
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

  // Modern section header with dropdown functionality
  Widget _buildModernSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int count,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Modern icon design
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.2)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Enhanced title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                "$count",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Dropdown indicator
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: color,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced empty state with improved design and messaging
  Widget _buildEmptyState(BuildContext context) {
    const primaryColor = Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.08),
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
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
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
                    color: primaryColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 30,
                  height: 2,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.3),
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

  // Enhanced statistics header with improved layout and visual hierarchy
  Widget _buildStatsHeader(
      BuildContext context, Color allowanceColor, Color deductionColor) {
    final totalAllowances = calculateTotalAmount(widget.allowances);
    final totalDeductions = calculateTotalAmount(widget.deductions);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2937).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF70122E), // Darker maroon
                Color(0xFF8B1E3F), // Deep maroon
                Color(0xFF9D2A4C), // Medium maroon
              ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Subtle background pattern
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
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
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
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
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
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
                                    color:
                                        allowanceColor, // Using the theme color for consistency
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: allowanceColor.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
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
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${widget.allowances.length}",
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
                                      color: allowanceColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color:
                                              allowanceColor.withValues(alpha: 0.3),
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
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
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
                                        color: deductionColor.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
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
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${widget.deductions.length}",
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
                                      color: deductionColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color:
                                              deductionColor.withValues(alpha: 0.3),
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

  // Modern card design with icon-based indicators
  Widget _buildModernCard({
    required StaffSalary staffSalary,
    required bool isAllowance,
    required int index,
    required Color color,
  }) {
    final isPercentage = staffSalary.allowanceOrDeductionInPercentage();

    // Calculate actual amount for display
    double actualAmount;
    if (isPercentage) {
      final baseAmount = widget.baseSalary ?? 0;
      final percentage = staffSalary.percentage ?? 0;
      actualAmount = baseAmount * percentage / 100;
    } else {
      actualAmount = staffSalary.amount ?? 0;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              children: [
                // Modern gradient icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.15),
                        color.withValues(alpha: 0.25),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Icon(
                    isAllowance
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: color,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staffSalary.payRollSetting?.name ?? "",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isAllowance
                                ? Icons.add_rounded
                                : Icons.remove_rounded,
                            size: 16,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isAllowance ? "Penambahan" : "Pengurangan",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Amount and type indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Type indicator with icon
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isPercentage
                        ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
                        : const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPercentage
                          ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
                          : const Color(0xFF10B981).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPercentage
                            ? Icons.percent_rounded
                            : Icons.monetization_on_outlined,
                        size: 16,
                        color: isPercentage
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPercentage
                            ? "${staffSalary.percentage?.toStringAsFixed(1) ?? "0"}%"
                            : "Nominal",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isPercentage
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount display
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.1),
                        color.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isPercentage) ...[
                        Text(
                          "${staffSalary.percentage?.toStringAsFixed(1) ?? "0"}%",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: color.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        formatCurrency(actualAmount),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: color,
                          height: 1,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
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
