import 'package:flutter/material.dart';

class ElegantCurvePainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  ElegantCurvePainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;

    // Beautiful flowing wave at the bottom
    paint.color = secondaryColor.withValues(alpha: 0.1);
    var path1 = Path();
    path1.moveTo(0, size.height * 0.65);
    path1.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.8,
      size.width * 0.5,
      size.height * 0.65,
    );
    path1.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.5,
      size.width,
      size.height * 0.7,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    canvas.drawPath(path1, paint);

    // Middle elegant curve
    paint.color = primaryColor.withValues(alpha: 0.08);
    var path2 = Path();
    path2.moveTo(0, size.height * 0.75);
    path2.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.85,
      size.width * 0.65,
      size.height * 0.7,
    );
    path2.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.6,
      size.width,
      size.height * 0.8,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    canvas.drawPath(path2, paint);

    // Subtle top curve decoration
    paint.color = accentColor.withValues(alpha: 0.05);
    var path3 = Path();
    path3.moveTo(0, size.height * 0.15);
    path3.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.2,
      size.width * 0.7,
      size.height * 0.1,
    );
    path3.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.05,
      size.width,
      size.height * 0.15,
    );
    path3.lineTo(size.width, 0);
    path3.lineTo(0, 0);
    canvas.drawPath(path3, paint);

    // Decorative floating circles with gradients
    final circleGradient = RadialGradient(
      colors: [
        primaryColor.withValues(alpha: 0.1),
        primaryColor.withValues(alpha: 0.05),
        Colors.transparent,
      ],
    );

    final circlePaint = Paint()
      ..shader = circleGradient.createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.8, size.height * 0.2),
          radius: 60,
        ),
      );

    // Large floating circle
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      60,
      circlePaint,
    );

    // Smaller floating circles
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.6),
      40,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.4),
      25,
      circlePaint,
    );

    // Add some thin decorative lines
    final linePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.03)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (var i = 1; i <= 3; i++) {
      var path = Path();
      path.moveTo(size.width * (0.2 * i), 0);
      path.quadraticBezierTo(
        size.width * (0.2 * i + 0.1),
        size.height * 0.2,
        size.width * (0.2 * i),
        size.height * 0.4,
      );
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
