import 'package:flutter/material.dart';

class ModernCurvePainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  ModernCurvePainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;

    // First wave (bottom layer)
    paint.color = secondaryColor.withOpacity(0.1);
    var path1 = Path();
    path1.moveTo(0, size.height * 0.75);
    path1.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.85,
      size.width * 0.5,
      size.height * 0.75,
    );
    path1.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.65,
      size.width,
      size.height * 0.75,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    canvas.drawPath(path1, paint);

    // Second wave (middle layer)
    paint.color = primaryColor.withOpacity(0.1);
    var path2 = Path();
    path2.moveTo(0, size.height * 0.8);
    path2.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.7,
      size.width * 0.5,
      size.height * 0.8,
    );
    path2.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.9,
      size.width,
      size.height * 0.8,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    canvas.drawPath(path2, paint);

    // Top decorative curves
    paint.color = accentColor.withOpacity(0.05);
    var path3 = Path();
    path3.moveTo(0, size.height * 0.2);
    path3.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.1,
      size.width * 0.6,
      size.height * 0.2,
    );
    path3.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.3,
      size.width,
      size.height * 0.2,
    );
    path3.lineTo(size.width, 0);
    path3.lineTo(0, 0);
    canvas.drawPath(path3, paint);

    // Subtle accent curves
    paint.color = accentColor.withOpacity(0.03);
    var path4 = Path();
    path4.moveTo(0, size.height * 0.45);
    path4.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.35,
      size.width * 0.7,
      size.height * 0.45,
    );
    path4.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.5,
      size.width,
      size.height * 0.45,
    );
    canvas.drawPath(path4, paint);

    // Floating circles decoration
    final decorPaint = Paint()
      ..color = primaryColor.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Large circle at top right
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      30,
      decorPaint,
    );

    // Medium circle at bottom left
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.7),
      40,
      decorPaint,
    );

    // Small floating circles
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.5),
      15,
      decorPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.3),
      20,
      decorPaint,
    );

    // Additional flowing curves
    paint.color = secondaryColor.withOpacity(0.03);
    var flowPath = Path();
    flowPath.moveTo(0, size.height * 0.4);
    flowPath.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.5,
      size.width * 0.6,
      size.height * 0.3,
    );
    flowPath.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.1,
      size.width,
      size.height * 0.4,
    );
    canvas.drawPath(flowPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
