import 'package:eschool_saas_staff/data/models/leaveDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LeaveDetailsContainer extends StatefulWidget {
  final LeaveDetails leaveDetails;
  const LeaveDetailsContainer({super.key, required this.leaveDetails});

  @override
  State<LeaveDetailsContainer> createState() => _LeaveDetailsContainerState();
}

class _LeaveDetailsContainerState extends State<LeaveDetailsContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Enhanced maroon color scheme
  final Color maroonPrimary = Color(0xFF800020);
  final Color maroonLight = Color(0xFF9A6478);
  final Color maroonDark = Color(0xFF5A0018);
  final Color maroonAccent = Color(0xFFB5495B);
  final Color creamBackground = Color(0xFFFDF6F8);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.1, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.8, curve: Curves.easeOutCirc),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String translateRole(String role) {
    final Map<String, String> roleTranslations = {
      "Teacher": "Guru",
    };

    return roleTranslations[role] ?? role;
  }

  String translateLeaveType(String leaveType) {
    final Map<String, String> leaveTranslations = {
      "Full": "Sehari Penuh",
      "First Half": "Setengah Pertama",
      "Second Half": "Setengah Kedua",
    };
    return leaveTranslations[leaveType] ?? leaveType ?? '';
  }

  Color _getStatusColor() {
    // This can be enhanced based on actual status in your data model
    return Colors.green.shade600;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: appContentHorizontalPadding,
                  vertical: 12.0,
                ),
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.0),
                  boxShadow: [
                    BoxShadow(
                      color: maroonDark.withOpacity(0.08),
                      blurRadius: 10.0,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: maroonDark.withOpacity(0.05),
                      blurRadius: 25.0,
                      offset: Offset(0, 10),
                      spreadRadius: -5,
                    )
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      creamBackground,
                    ],
                  ),
                  border: Border.all(
                    color: maroonLight.withOpacity(0.4),
                    width: 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        // Add a subtle scale animation on tap
                        _animationController.reset();
                        _animationController.forward();
                      },
                      splashColor: maroonPrimary.withOpacity(0.1),
                      highlightColor: maroonPrimary.withOpacity(0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Decorative top strip
                          Container(
                            height: 5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  maroonPrimary,
                                  maroonAccent,
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top section with leave type and date
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Leave type badge
                                    Flexible(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color:
                                              maroonPrimary.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color:
                                                maroonPrimary.withOpacity(0.2),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.event_note_rounded,
                                              size: 18,
                                              color: maroonPrimary,
                                            ),
                                            SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                translateLeaveType(
                                                    widget.leaveDetails.type ??
                                                        ""),
                                                style: TextStyle(
                                                  color: maroonDark,
                                                  fontSize:
                                                      Utils.getScaledValue(
                                                          context, 14),
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.3,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            8), // Add spacing between containers
                                    // Date badge
                                    Flexible(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  maroonDark.withOpacity(0.08),
                                              blurRadius: 6.0,
                                              offset: Offset(0, 2),
                                            )
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              size: 16,
                                              color: maroonPrimary,
                                            ),
                                            SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                widget.leaveDetails.leaveDate ??
                                                    "",
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize:
                                                      Utils.getScaledValue(
                                                          context, 14),
                                                  fontWeight: FontWeight.w500,
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
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.0),
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          maroonLight.withOpacity(0.6),
                                          maroonLight.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Profile section with enhanced design
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Profile image with enhanced styling
                                    Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: maroonPrimary
                                                  .withOpacity(0.7),
                                              width: 2.0,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: maroonDark
                                                    .withOpacity(0.15),
                                                blurRadius: 8.0,
                                                offset: Offset(0, 4),
                                              )
                                            ],
                                          ),
                                          child: ProfileImageContainer(
                                            imageUrl: widget.leaveDetails.leave
                                                    ?.user?.image ??
                                                "",
                                          ),
                                        ),
                                        // Status indicator dot
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _getStatusColor(),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2.0,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 2.0,
                                                  offset: Offset(0, 1),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 18.0),
                                    // User details with enhanced typography
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.leaveDetails.leave?.user
                                                    ?.firstName ??
                                                "",
                                            style: TextStyle(
                                              fontSize: Utils.getScaledValue(
                                                  context, 18),
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          // Role badge with enhanced styling
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: maroonPrimary
                                                  .withOpacity(0.07),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: maroonPrimary
                                                    .withOpacity(0.15),
                                                width: 1.0,
                                              ),
                                            ),
                                            child: Text(
                                              "${Utils.getTranslatedLabel(roleKey)} : ${translateRole(widget.leaveDetails.leave?.user?.roles?.first.name ?? "")}",
                                              style: TextStyle(
                                                fontSize: Utils.getScaledValue(
                                                    context, 14),
                                                color: maroonDark,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Enhanced arrow button
  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
