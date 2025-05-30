import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

/// A modern, animated AppBar with customizable filters
/// Provides a premium look with frosted glass effects, animations, and custom gradients
class CustomFilterModernAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  /// The title to display in the appbar
  final String title;

  /// The icon to display next to the title
  final IconData titleIcon;

  /// Primary color for the AppBar gradient
  final Color primaryColor;

  /// Secondary color for the AppBar gradient
  final Color? secondaryColor;

  /// Optional callback when the back button is pressed
  final VoidCallback? onBackPressed;

  /// Optional callback to provide custom animation controller
  final AnimationController? animationController;

  /// First filter widget - shown on the left side of the filter row
  final FilterItemConfig? firstFilterItem;

  /// Second filter widget - shown in the middle of the filter row
  final FilterItemConfig? secondFilterItem;

  /// Third filter widget - shown on the right side of the filter row
  final FilterItemConfig? thirdFilterItem;

  /// Whether to enable animations on the AppBar
  final bool enableAnimations;

  /// Optional gradient colors for the background
  final List<Color>? gradientColors;

  /// Total height of the AppBar (including status bar)
  final double? height;

  /// Whether to show filters row or not
  final bool showFiltersRow;
  const CustomFilterModernAppBar({
    Key? key,
    required this.title,
    this.titleIcon = Icons.dashboard_rounded,
    required this.primaryColor,
    this.secondaryColor,
    this.onBackPressed,
    this.animationController,
    this.firstFilterItem,
    this.secondFilterItem,
    this.thirdFilterItem,
    this.enableAnimations = true,
    this.gradientColors,
    this.height,
    this.showFiltersRow = true,
  }) : super(key: key);

  @override
  State<CustomFilterModernAppBar> createState() =>
      _CustomFilterModernAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height ?? 150);
}

class _CustomFilterModernAppBarState extends State<CustomFilterModernAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = widget.animationController ??
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
          value: 1.0, // Start with full value when not externally controlled
        );

    if (widget.animationController == null && widget.enableAnimations) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    // Only dispose if we created the controller internally
    if (widget.animationController == null) {
      _animationController.dispose();
    }
    super.dispose();
  }

  Color get _secondaryColor =>
      widget.secondaryColor ?? _getLightenedColor(widget.primaryColor, 0.3);

  /// Helper function to generate a lighter version of a color
  Color _getLightenedColor(Color baseColor, double factor) {
    HSLColor hsl = HSLColor.fromColor(baseColor);
    return hsl
        .withLightness((hsl.lightness + factor).clamp(0.0, 1.0))
        .toColor();
  }

  /// Helper function to generate a darkened version of a color
  Color _getDarkenedColor(Color baseColor, double factor) {
    HSLColor hsl = HSLColor.fromColor(baseColor);
    return hsl
        .withLightness((hsl.lightness - factor).clamp(0.0, 1.0))
        .toColor();
  }

  List<Color> get _gradientColors =>
      widget.gradientColors ??
      [
        _getDarkenedColor(widget.primaryColor, 0.1),
        widget.primaryColor,
        _getLightenedColor(widget.primaryColor, 0.1),
        _secondaryColor,
      ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.preferredSize.height,
      child: Stack(
        children: [
          // Fancy gradient background with animated particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) {
                return ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _gradientColors,
                      stops: const [0.0, 0.3, 0.6, 1.0],
                      transform: GradientRotation(widget.enableAnimations
                          ? _animationController.value * 0.02
                          : 0),
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.primaryColor,
                          _secondaryColor,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
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
          ),
          // Animated glowing effect
          if (widget.enableAnimations)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) {
                return Positioned(
                  top: -100 + (_animationController.value * 20),
                  right: -60 + (_animationController.value * 10),
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
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ), // Main app bar content with frosted glass effect - TOP ROW
          Positioned(
            top: MediaQuery.of(context).padding.top + 5, // Moved up slightly
            left: 16,
            right: 16,
            child: ClipRRect(
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
                      if (widget.onBackPressed != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              highlightColor: Colors.white.withOpacity(0.1),
                              splashColor: Colors.white.withOpacity(0.2),
                              onTap: widget.onBackPressed,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Animated divider when back button is present
                      if (widget.onBackPressed != null)
                        Container(
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
                        ),

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
                                  if (widget.enableAnimations)
                                    AnimatedBuilder(
                                      animation: _animationController,
                                      builder: (context, child) {
                                        return Transform.rotate(
                                          angle:
                                              _animationController.value * 0.05,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.white.withOpacity(0.9),
                                                  Colors.white.withOpacity(0.4),
                                                ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              widget.titleIcon,
                                              color: widget.primaryColor,
                                              size: 20,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.9),
                                            Colors.white.withOpacity(0.4),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        widget.titleIcon,
                                        color: widget.primaryColor,
                                        size: 20,
                                      ),
                                    ),

                                  const SizedBox(width: 12),

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
                                            offset: const Offset(0, 1),
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

                      // Optional space for action buttons
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ), // BOTTOM ROW - Filters with frosted glass effect (when filters are enabled)
          if (widget.showFiltersRow &&
              (widget.firstFilterItem != null ||
                  widget.secondFilterItem != null ||
                  widget.thirdFilterItem != null))
            Positioned(
              bottom: 16, // Position closer to the bottom
              left: 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    // Use taller container and column layout when there are three filters
                    height: widget.thirdFilterItem != null
                        ? 120
                        : 70, // Increased height for better spacing
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: widget.thirdFilterItem != null
                        ? Column(
                            children: [
                              // Top row with two filters
                              Expanded(
                                child: Row(
                                  children: [
                                    // First filter item
                                    if (widget.firstFilterItem != null)
                                      Expanded(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap:
                                                widget.firstFilterItem!.onTap,
                                            highlightColor:
                                                Colors.white.withOpacity(0.1),
                                            splashColor:
                                                Colors.white.withOpacity(0.2),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    widget
                                                        .firstFilterItem!.icon,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Text(
                                                      widget.firstFilterItem!
                                                          .title,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                    // Divider between first and second filters
                                    if (widget.firstFilterItem != null &&
                                        widget.secondFilterItem != null)
                                      Container(
                                        height: 24,
                                        width: 1.5,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8),
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
                                      ),

                                    // Second filter item
                                    if (widget.secondFilterItem != null)
                                      Expanded(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap:
                                                widget.secondFilterItem!.onTap,
                                            highlightColor:
                                                Colors.white.withOpacity(0.1),
                                            splashColor:
                                                Colors.white.withOpacity(0.2),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    widget
                                                        .secondFilterItem!.icon,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Text(
                                                      widget.secondFilterItem!
                                                          .title,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Horizontal divider
                              Container(
                                height: 1.5,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.white.withOpacity(0.0),
                                      Colors.white.withOpacity(0.4),
                                      Colors.white.withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),

                              // Bottom row with third filter
                              if (widget.thirdFilterItem != null)
                                Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: widget.thirdFilterItem!.onTap,
                                      highlightColor:
                                          Colors.white.withOpacity(0.1),
                                      splashColor:
                                          Colors.white.withOpacity(0.2),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              widget.thirdFilterItem!.icon,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                widget.thirdFilterItem!.title,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Row(
                            children: [
                              // First filter item
                              if (widget.firstFilterItem != null)
                                _buildFilterItem(
                                  widget.firstFilterItem!.icon,
                                  widget.firstFilterItem!.title,
                                  widget.firstFilterItem!.onTap,
                                  expanded: true,
                                ),

                              // Divider between first and second filters
                              if (widget.firstFilterItem != null &&
                                  widget.secondFilterItem != null)
                                Container(
                                  height: 24,
                                  width: 1.5,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal:
                                          12), // Increased horizontal margin for more spacing
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
                                ),

                              // Second filter item
                              if (widget.secondFilterItem != null)
                                _buildFilterItem(
                                  widget.secondFilterItem!.icon,
                                  widget.secondFilterItem!.title,
                                  widget.secondFilterItem!.onTap,
                                  expanded: true,
                                ),
                            ],
                          ),
                  ),
                ),
              ),
            )
                .animate(
                  controller: _animationController,
                )
                .fadeIn(
                  duration: 500.ms,
                  delay: 200.ms,
                )
                .slideY(
                  begin: -0.2,
                  end: 0,
                  curve: Curves.easeOutQuad,
                ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool expanded = true,
  }) {
    return expanded
        ? Expanded(
            child: _buildFilterItemContent(icon, title, onTap),
          )
        : _buildFilterItemContent(icon, title, onTap);
  }

  Widget _buildFilterItemContent(
      IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Add haptic feedback for better UX
          HapticFeedback.lightImpact();
          onTap();
        },
        highlightColor: Colors.white.withOpacity(0.1),
        splashColor: Colors.white.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 18, vertical: 14), // Increased padding for more space
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 18, // Slightly larger icon
              ),
              const SizedBox(
                  width: 10), // Increased spacing between icon and text
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing:
                        0.3, // Added letter spacing for better readability
                    fontWeight: FontWeight.w500, // Slightly bolder text
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Configuration for a filter item in the AppBar
class FilterItemConfig {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  FilterItemConfig({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

/// Custom painter for decorative elements in the AppBar
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
