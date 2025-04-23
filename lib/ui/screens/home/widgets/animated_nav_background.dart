import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class AnimatedNavBackground extends StatelessWidget {
  final int selectedIndex;
  final int itemCount;

  const AnimatedNavBackground({
    Key? key,
    required this.selectedIndex,
    required this.itemCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlayAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
      builder: (context, value, child) {
        return CustomPaint(
          painter: FlowingBackgroundPainter(
            selectedIndex: selectedIndex,
            itemCount: itemCount,
            animationValue: value,
            primaryColor: const Color(0xFF7A1E23),
            secondaryColor: Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFF8D7DA)
                : const Color(0xFF3D1012),
          ),
          child: child,
        );
      },
    );
  }
}

class FlowingBackgroundPainter extends CustomPainter {
  final int selectedIndex;
  final int itemCount;
  final double animationValue;
  final Color primaryColor;
  final Color secondaryColor;

  FlowingBackgroundPainter({
    required this.selectedIndex,
    required this.itemCount,
    required this.animationValue,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final itemWidth = width / itemCount;

    // Background gradient
    final rect = Rect.fromLTWH(0, 0, width, height);
    final gradient = LinearGradient(
      colors: [
        secondaryColor.withOpacity(0.2),
        secondaryColor.withOpacity(0.1)
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Flowing curve
    final path = Path();
    final curveHeight = height * 0.4;

    final selectedCenterX = itemWidth * (selectedIndex + 0.5);

    path.moveTo(0, height);

    for (int i = 0; i <= 100; i++) {
      final x = width * (i / 100);
      final distanceFromCenter = (x - selectedCenterX).abs();
      final normalizedDistance = min(distanceFromCenter / (width * 0.3), 1.0);

      // Create wave effect
      final waveFactor = cos(i / 3 + animationValue * 2) * 5;
      final y = height -
          curveHeight * (1 - normalizedDistance) * animationValue -
          waveFactor;

      path.lineTo(x, y);
    }

    path.lineTo(width, height);
    path.close();

    // Glowing effect
    final glowPaint = Paint()
      ..color = primaryColor.withOpacity(0.25)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawPath(path, glowPaint);

    // Main fill
    final mainPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          primaryColor.withOpacity(0.85),
          primaryColor.withOpacity(0.6),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);

    canvas.drawPath(path, mainPaint);

    // Add shimmer effect
    final shimmerPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 3; i++) {
      final offset = sin(animationValue * pi * 2 + i) * width * 0.1;
      final shimmerPath = Path();
      shimmerPath.moveTo(offset, height);

      for (int j = 0; j <= 20; j++) {
        final x = offset + width * (j / 20);
        final waveHeight = sin(j / 2 + animationValue * 5) * 5;
        shimmerPath.lineTo(
            x,
            height -
                curveHeight *
                    0.7 *
                    (1 - (x - selectedCenterX).abs() / (width * 0.4)) +
                waveHeight);
      }

      canvas.drawPath(shimmerPath, shimmerPaint);
    }
  }

  @override
  bool shouldRepaint(FlowingBackgroundPainter oldDelegate) =>
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.animationValue != animationValue;
}
