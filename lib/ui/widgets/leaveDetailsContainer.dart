import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/leaveDetails.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';

class LeaveDetailsContainer extends StatefulWidget {
  final LeaveDetails leaveDetails;
  final bool? overflow;

  const LeaveDetailsContainer({
    super.key,
    required this.leaveDetails,
    this.overflow,
  });

  @override
  State<LeaveDetailsContainer> createState() => _LeaveDetailsContainerState();
}

class _LeaveDetailsContainerState extends State<LeaveDetailsContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovering = false;

  // Refined maroon color palette with added accent colors
  final Color _maroonPrimary = const Color(0xFF7D2027);
  final Color _maroonLight = const Color(0xFFBF8A8D);
  final Color _maroonDark = const Color(0xFF5A171C);
  final Color _maroonAccent = const Color(0xFFE5C6C8);
  final Color _goldAccent = const Color(0xFFE6D2AA);

  @override
  void initState() {
    super.initState();
    context.read<ClassesCubit>().getClasses();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuint,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String getClassSectionName(int? classSectionId) {
    if (classSectionId == null) return '-';

    final classesCubit = context.read<ClassesCubit>();
    final allClasses = classesCubit.getAllClasses();

    final classSection = allClasses.firstWhere(
      (classSection) => classSection.id == classSectionId,
      orElse: () => ClassSection(name: '-'),
    );

    return classSection.name ?? 'Unknown Class';
  }

  String translateRole(String role) {
    final Map<String, String> roleTranslations = {
      "Teacher": "Guru",
    };
    return roleTranslations[role] ?? role;
  }

  String translateLeaveType(String type) {
    final Map<String, String> leaveTranslations = {
      "Full": "Sehari Penuh",
      "First Half": "Setengah Pertama",
      "Second Half": "Setengah Kedua",
      "sick": "Sakit",
    };
    return leaveTranslations[type] ?? type;
  }

  String formatDateToIndonesian(String dateStr) {
    if (dateStr.isEmpty) return '';
    
    try {
      final DateTime date = DateTime.parse(dateStr);
      
      // List of month names in Indonesian
      final List<String> monthNames = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      
      // Format: day monthName year (e.g., 01 Januari 2023)
      return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
    } catch (e) {
      // Return original string if parsing fails
      return dateStr;
    }
  }

  Widget _buildLeaveTypeChip(String type) {
    Color backgroundColor;
    Color textColor;
    Color shadowColor;
    String translatedType = translateLeaveType(type);
    IconData iconData;

    // Set defaults based on type
    if (type.toLowerCase() == 'sick') {
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      shadowColor = Colors.red.shade200.withOpacity(0.3);
      iconData = Icons.healing;
    } else {
      // Default to Leave or any other type
      backgroundColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
      shadowColor = Colors.blue.shade200.withOpacity(0.3);
      iconData = Icons.event_busy;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: textColor.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: textColor, size: 18),
          const SizedBox(width: 8),
          Text(
            translatedType,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassesCubit, ClassesState>(
      builder: (context, state) {
        if (state is ClassesFetchSuccess) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildSuccessUI(),
                ),
              );
            },
          );
        } else if (state is ClassesFetchFailure) {
          return _buildErrorUI();
        } else {
          return _buildLoadingUI();
        }
      },
    );
  }

  Widget _buildSuccessUI() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        margin: EdgeInsets.symmetric(
          horizontal: appContentHorizontalPadding,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: _isHovering
                  ? _maroonPrimary.withOpacity(0.25)
                  : Colors.black.withOpacity(0.06),
              blurRadius: _isHovering ? 18 : 8,
              offset: Offset(0, _isHovering ? 6 : 4),
              spreadRadius: _isHovering ? 2 : 0,
            ),
          ],
          border: Border.all(
            color: _isHovering
                ? _maroonPrimary.withOpacity(0.3)
                : _maroonLight.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background pattern and decorative elements
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _maroonAccent.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      radius: 0.7,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -15,
                left: -15,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _goldAccent.withOpacity(0.15),
                        Colors.transparent,
                      ],
                      radius: 0.7,
                    ),
                  ),
                ),
              ),

              // Main content
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with leave type and attachment button
                 

                    // Student info header section with enhanced styling
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _maroonPrimary.withOpacity(0.8),
                                _maroonDark,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _maroonPrimary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.leaveDetails.leave?.user?.firstName ??
                                    "",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 20 : 22,
                                  fontWeight: FontWeight.bold,
                                  color: _maroonDark,
                                  letterSpacing: 0.3,
                                  height: 1.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 8),
                            
                              const SizedBox(height: 8),
                        
                            ],
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              _maroonLight.withOpacity(0.6),
                              _maroonLight.withOpacity(0.6),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.2, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Reason section with enhanced styling
                 

                    // Footer with date in a more elegant style
                    if (widget.leaveDetails.leaveDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // School branding indicator
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _maroonDark,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "S",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      "eSchool",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _maroonDark.withOpacity(0.8),
                                        letterSpacing: 0.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Date container
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 12 : 16,
                                    vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _maroonLight.withOpacity(0.2),
                                      _goldAccent.withOpacity(0.15),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: _maroonLight.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 16,
                                      color: _maroonDark,
                                    ),
                                    SizedBox(width: isSmallScreen ? 6 : 10),
                                    Flexible(
                                      child: Text(
                                        // Format the date to Indonesian format
                                        formatDateToIndonesian(widget.leaveDetails.leaveDate ?? ''),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _maroonDark,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildErrorUI() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                margin: EdgeInsets.symmetric(
                    horizontal: appContentHorizontalPadding),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red.shade50,
                      Colors.red.shade100,
                    ],
                  ),
                  border: Border.all(color: Colors.red.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade100.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade300.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red.shade700,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Gagal memuat data',
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Silakan coba lagi dalam beberapa saat',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
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
        );
      },
    );
  }

  Widget _buildLoadingUI() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: 60 * value,
                          height: 60 * value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _maroonPrimary.withOpacity(0.1 * value),
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(_maroonPrimary),
                            strokeWidth: 4,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _maroonPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Memuat data...',
                  style: TextStyle(
                    color: _maroonPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 140,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.grey.shade200,
                  ),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        left: value > 0.5 ? 0 : 140 * (1 - value * 2),
                        right: value > 0.5 ? 140 * (1 - (value - 0.5) * 2) : 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: _maroonPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
