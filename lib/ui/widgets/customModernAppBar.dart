import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class CustomModernAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final IconData icon;
  final AnimationController fabAnimationController;
  final Color primaryColor;
  final Color lightColor;
  final VoidCallback? onBackPressed;
  final double height;
  final bool showAddButton; // New parameter to control add button visibility
  final VoidCallback? onAddPressed; // New parameter for add button action
  final bool
      showArchiveButton; // New parameter to control archive button visibility
  final VoidCallback?
      onArchivePressed; // New parameter for archive button action
  final bool
      showFilterButton; // New parameter to control filter button visibility
  final VoidCallback? onFilterPressed; // New parameter for filter button action
  final bool
      showHelperButton; // New parameter to control helper button visibility
  final VoidCallback? onHelperPressed; // New parameter for helper button action
  final Widget Function(BuildContext)?
      tabBuilder; // New parameter for custom tabs in AppBar

  const CustomModernAppBar({
    Key? key,
    required this.title,
    required this.icon,
    required this.fabAnimationController,
    this.primaryColor = const Color(0xFF800020),
    this.lightColor = const Color(0xFFAA6976),
    this.onBackPressed,
    this.height = 80,
    this.showAddButton = false, // Default to hidden
    this.onAddPressed,
    this.showArchiveButton = false, // Default to hidden
    this.onArchivePressed,
    this.showFilterButton = false, // Default to hidden
    this.onFilterPressed,
    this.showHelperButton = false, // Default to hidden
    this.onHelperPressed,
    this.tabBuilder,
  }) : super(key: key);

  @override
  State<CustomModernAppBar> createState() => _CustomModernAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _CustomModernAppBarState extends State<CustomModernAppBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).padding.top + widget.height,
      child: Stack(
        children: [
          // Fancy gradient background with animated particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: widget.fabAnimationController,
              builder: (context, _) {
                return ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF690013),
                        widget.primaryColor,
                        Color(0xFFA12948),
                        widget.lightColor,
                      ],
                      stops: [0.0, 0.3, 0.6, 1.0],
                      transform: GradientRotation(
                          widget.fabAnimationController.value * 0.02),
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF800020),
                          Color(0xFF9A1E3C),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Decorative design elements
          Positioned.fill(
            child: CustomPaint(
              painter: AppBarDecorationPainter(
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ), // Animated glowing effect
          AnimatedBuilder(
            animation: widget.fabAnimationController,
            builder: (context, _) {
              return Positioned(
                top: MediaQuery.of(context).padding.top -
                    100 +
                    (widget.fabAnimationController.value * 20),
                right: -60 + (widget.fabAnimationController.value * 10),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ), // Main app bar content with frosted glass effect
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main AppBar content
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Back button with ripple effect
                          widget.onBackPressed != null
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      highlightColor:
                                          Colors.white.withOpacity(0.1),
                                      splashColor:
                                          Colors.white.withOpacity(0.2),
                                      onTap: widget.onBackPressed ??
                                          () => Navigator.of(context).pop(),
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.arrow_back_ios_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                  .animate()
                                  .fadeIn(
                                      duration: 400.ms, curve: Curves.easeOut)
                                  .slideX(begin: -0.3, end: 0)
                              : SizedBox(),

                          // Animated divider
                          widget.onBackPressed != null
                              ? Container(
                                  height: 24,
                                  width: 1.5,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withOpacity(0.0),
                                        Colors.white.withOpacity(0.4),
                                        Colors.white.withOpacity(0.0),
                                      ],
                                    ),
                                  ),
                                )
                              : SizedBox(),

                          // Title with animated badge
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Main title
                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Animated icon
                                      AnimatedBuilder(
                                        animation:
                                            widget.fabAnimationController,
                                        builder: (context, child) {
                                          return Transform.rotate(
                                            angle: widget.fabAnimationController
                                                    .value *
                                                0.05,
                                            child: Container(
                                              padding: EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.white
                                                        .withOpacity(0.9),
                                                    Colors.white
                                                        .withOpacity(0.4),
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                widget.icon,
                                                color: widget.primaryColor,
                                                size: 20,
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      SizedBox(width: 12),

                                      // Title text with glowing effect
                                      ShaderMask(
                                        shaderCallback: (Rect bounds) {
                                          return LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white,
                                              Colors.white.withOpacity(0.9),
                                            ],
                                          ).createShader(bounds);
                                        },
                                        blendMode: BlendMode.srcIn,
                                        child: Text(
                                          widget.title,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black26,
                                                offset: Offset(0, 1),
                                                blurRadius: 3,
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

                          // Add divider before the Add button
                          widget.showAddButton
                              ? Container(
                                  height: 24,
                                  width: 1.5,
                                  margin: const EdgeInsets.only(right: 8.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withOpacity(0.0),
                                        Colors.white.withOpacity(0.4),
                                        Colors.white.withOpacity(0.0),
                                      ],
                                    ),
                                  ),
                                ).animate().fadeIn(
                                  duration: 300.ms, curve: Curves.easeOut)
                              : SizedBox(), // Enhanced Add Button - elegant & attractive design, only shown when showAddButton is true
                          if (widget.showAddButton)
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(50),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  highlightColor:
                                      Colors.white.withOpacity(0.15),
                                  splashColor: Colors.white.withOpacity(0.25),
                                  onTap: widget.onAddPressed,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                          spreadRadius: 0.5,
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.35),
                                        width: 1.5,
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          widget.lightColor.withOpacity(0.7),
                                          widget.primaryColor.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Subtle glow effect
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.3),
                                                Colors.white.withOpacity(0.0),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Icon with crisp shadow
                                        Icon(
                                          Icons.add_rounded,
                                          color: Colors.white,
                                          size: 24,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                                .slideX(
                                    begin: 0.3,
                                    end:
                                        0), // No divider between archive and add buttons
                          SizedBox(),

                          // // Add divider before the Archive button
                          // widget.showArchiveButton
                          //     ? Container(
                          //         height: 24,
                          //         width: 1.5,
                          //         margin: const EdgeInsets.only(right: 8.0),
                          //         decoration: BoxDecoration(
                          //           gradient: LinearGradient(
                          //             begin: Alignment.topCenter,
                          //             end: Alignment.bottomCenter,
                          //             colors: [
                          //               Colors.white.withOpacity(0.0),
                          //               Colors.white.withOpacity(0.4),
                          //               Colors.white.withOpacity(0.0),
                          //             ],
                          //           ),
                          //         ),
                          //       )
                          //         .animate()
                          //         .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                          // : SizedBox(), // Enhanced Archive Button - elegant & attractive design, only shown when showArchiveButton is true
                          if (widget.showArchiveButton)
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(50),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  highlightColor:
                                      Colors.white.withOpacity(0.15),
                                  splashColor: Colors.white.withOpacity(0.25),
                                  onTap: widget.onArchivePressed,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                          spreadRadius: 0.5,
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.35),
                                        width: 1.5,
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          widget.lightColor.withOpacity(0.7),
                                          widget.primaryColor.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Subtle glow effect
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.3),
                                                Colors.white.withOpacity(0.0),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Icon with crisp shadow
                                        Icon(
                                          Icons.archive_rounded,
                                          color: Colors.white,
                                          size: 24,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                                .slideX(begin: 0.3, end: 0),

                          // Filter Button - elegant & attractive design, only shown when showFilterButton is true
                          if (widget.showFilterButton)
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(50),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  highlightColor:
                                      Colors.white.withOpacity(0.15),
                                  splashColor: Colors.white.withOpacity(0.25),
                                  onTap: widget.onFilterPressed,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                          spreadRadius: 0.5,
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.35),
                                        width: 1.5,
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          widget.lightColor.withOpacity(0.7),
                                          widget.primaryColor.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Subtle glow effect
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.3),
                                                Colors.white.withOpacity(0.0),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Icon with crisp shadow
                                        Icon(
                                          Icons.filter_list,
                                          color: Colors.white,
                                          size: 24,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                                .slideX(begin: 0.3, end: 0),

                          // Helper Button - elegant & attractive design, only shown when showHelperButton is true
                          if (widget.showHelperButton)
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(50),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  highlightColor:
                                      Colors.white.withOpacity(0.15),
                                  splashColor: Colors.white.withOpacity(0.25),
                                  onTap: widget.onHelperPressed,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                          spreadRadius: 0.5,
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.35),
                                        width: 1.5,
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          widget.lightColor.withOpacity(0.7),
                                          widget.primaryColor.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Subtle glow effect
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.3),
                                                Colors.white.withOpacity(0.0),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Icon with crisp shadow
                                        Icon(
                                          Icons
                                              .help, // Using the help icon as requested
                                          color: Colors.white,
                                          size: 24,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                                .slideX(begin: 0.3, end: 0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Tab content if provided
                if (widget.tabBuilder != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: widget.tabBuilder!(context),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                        .scale(
                          begin: Offset(0.95, 0.95),
                          end: Offset(1.0, 1.0),
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for decorative elements in the app bar
class AppBarDecorationPainter extends CustomPainter {
  final Color color;

  AppBarDecorationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.2), 30, paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), 20, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.15), 15, paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), 10, paint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.4), 8, paint);

    // Draw arc
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final arcRect = Rect.fromLTRB(size.width * 0.1, size.height * 0.2,
        size.width * 0.6, size.height * 0.6);
    canvas.drawArc(arcRect, 0.2, 1.5, false, arcPaint);

    // Draw another arc
    final arcRect2 = Rect.fromLTRB(size.width * 0.5, size.height * 0.4,
        size.width * 0.9, size.height * 0.8);
    canvas.drawArc(arcRect2, 3, 1.5, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
