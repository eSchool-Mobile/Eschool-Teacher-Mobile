import 'package:eschool_saas_staff/data/models/bottomNavItem.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

class AnimatedBottomNavItemContainer extends StatefulWidget {
  final int index;
  final BottomNavItem bottomNavItem;
  final Function onTap;
  final int selectedBottomNavIndex;

  const AnimatedBottomNavItemContainer({
    Key? key,
    required this.index,
    required this.bottomNavItem,
    required this.onTap,
    required this.selectedBottomNavIndex,
  }) : super(key: key);

  @override
  State<AnimatedBottomNavItemContainer> createState() =>
      _AnimatedBottomNavItemContainerState();
}

class _AnimatedBottomNavItemContainerState
    extends State<AnimatedBottomNavItemContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  // Colors - Soft Maroon palette to match OnlineExamScreen
  final Color _primaryColor = Color(0xFF7A1E23); // Softer deep maroon
  final Color _accentColor = Color(0xFF9D3C3C); // Softer medium maroon
  final Color _highlightColor = Color(0xFFB84D4D); // Softer bright maroon
  final Color _energyColor = Color(0xFFCE6D6D); // Softer light maroon
  final Color _glowColor = Color(0xFFAF4F4F); // Softer rich maroon

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _slideAnimation = Tween<double>(begin: 8.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    if (widget.selectedBottomNavIndex == widget.index) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedBottomNavItemContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedBottomNavIndex == widget.index &&
        oldWidget.selectedBottomNavIndex != widget.index) {
      _animationController.forward();
    } else if (widget.selectedBottomNavIndex != widget.index &&
        oldWidget.selectedBottomNavIndex == widget.index) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.selectedBottomNavIndex == widget.index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact(); // Enhanced haptic feedback
        widget.onTap(widget.index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutQuart,
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background glow effect (only for selected item)
            if (isSelected)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Positioned(
                    bottom: 0,
                    child: Container(
                      width: 60,
                      height: 3,
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // NeumorphismBackground (subtle raised effect)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? _primaryColor.withOpacity(0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          offset: Offset(0, -2),
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with animations
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -_slideAnimation.value),
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return isSelected
                                  ? ui.Gradient.linear(
                                      const Offset(0, 0),
                                      Offset(0, bounds.height),
                                      [
                                        _primaryColor,
                                        _accentColor,
                                      ],
                                    )
                                  : ui.Gradient.linear(
                                      const Offset(0, 0),
                                      const Offset(0, 24),
                                      [
                                        Colors.grey.shade600,
                                        Colors.grey.shade500,
                                      ],
                                    );
                            },
                            child: SvgPicture.asset(
                              "assets/images/${isSelected ? widget.bottomNavItem.selectedIconPath : widget.bottomNavItem.iconPath}",
                              width: 24,
                              height: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 8),

                  // Text with animations
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: isSelected ? 12 : 11,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? _primaryColor
                          : Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.7),
                      letterSpacing: isSelected ? 0.2 : 0,
                    ),
                    child: Text(
                      widget.bottomNavItem.title,
                    ),
                  ),
                ],
              ),
            ),

            // Ripple effect on tap
            if (isSelected)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 200),
                    opacity: 0.1,
                    child: CustomPaint(
                      painter: RipplePainter(
                        color: _primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Custom Ripple Effect
class RipplePainter extends CustomPainter {
  final Color color;

  RipplePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.4);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Main glow
    canvas.drawCircle(center, size.width * 0.2, paint);

    // Outer subtle glow
    final outerPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(center, size.width * 0.1, outerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
