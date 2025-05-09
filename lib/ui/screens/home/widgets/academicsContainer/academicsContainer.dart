import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/academicsContainer/widgets/staffAcademicsContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/academicsContainer/widgets/teacherAcademicsContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AcademicsContainer extends StatelessWidget {
  const AcademicsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style to ensure status bar is properly handled
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // Get profile image from AuthCubit
    final profileImage = context.read<AuthCubit>().getUserDetails().image ?? "";

    // Maroon color palette matching the homeContainerAppbar
    final Color maroonPrimary = const Color(0xFF800020); // Deep maroon
    final Color maroonLight = const Color(0xFFAA6976); // Light maroon
    final Color maroonDark =
        const Color.fromARGB(255, 124, 9, 31); // Darker variant

    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: BlocBuilder<StaffAllowedPermissionsAndModulesCubit,
              StaffAllowedPermissionsAndModulesState>(
            builder: (context, state) {
              if (state is StaffAllowedPermissionsAndModulesFetchSuccess) {
                return SingleChildScrollView(
                    padding: EdgeInsetsDirectional.only(
                        top:
                            Utils.appContentTopScrollPadding(context: context) +
                                20,
                        end: appContentHorizontalPadding,
                        start: appContentHorizontalPadding,
                        bottom: 100),
                    child: context.read<AuthCubit>().isTeacher()
                        ? const TeacherAcademicsContainer()
                        : const StaffAcademicsContainer());
              } else if (state
                  is StaffAllowedPermissionsAndModulesFetchFailure) {
                return Center(
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      context
                          .read<StaffAllowedPermissionsAndModulesCubit>()
                          .getPermissionAndAllowedModules();
                    },
                  ),
                );
              } else {
                return Center(
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              }
            },
          ),
        ),
        // New Stylish Appbar that matches homeContainerAppbar
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 140 + MediaQuery.of(context).padding.top,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                // Background with dramatically curved bottom that extends to the top edge
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CustomPaint(
                    painter: DramaticCurvedGradientPainter(
                      colors: [
                        maroonDark,
                        maroonPrimary,
                        Color(0xFF9A1E3C),
                        maroonLight,
                      ],
                      stops: [0.0, 0.3, 0.6, 1.0],
                    ),
                  ),
                ),

                // Static decorative elements with larger size for better visibility
                Positioned(
                  top: -40,
                  right: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.07),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.07),
                    ),
                  ),
                ),
                Positioned(
                  top: 35,
                  left: MediaQuery.of(context).size.width * 0.65,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.07),
                    ),
                  ),
                ),

                // Enhanced static wave pattern
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    painter: EnhancedWavePatternPainter(
                      color1: Colors.white.withOpacity(0.1),
                      color2: Colors.white.withOpacity(0.07),
                    ),
                    child: SizedBox(
                      height: 80,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                ),

                // Main content container with elevation
                Positioned(
                  bottom: 10,
                  left: 16,
                  right: 16,
                  child: Container(
                    height: 75,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: maroonPrimary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: maroonLight.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Profile image with elegant gradient border
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [maroonPrimary, maroonDark],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: maroonPrimary.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(2),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 25,
                            backgroundImage: profileImage.isNotEmpty
                                ? CachedNetworkImageProvider(
                                    profileImage,
                                  )
                                : null,
                            child: profileImage.isEmpty
                                ? Icon(
                                    Icons.person,
                                    color: maroonPrimary,
                                    size: 30,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 15.0),
                        // Title with improved typography using Google Fonts
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Akademik",
                                style: GoogleFonts.poppins(
                                  height: 1.1,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: maroonPrimary,
                                ),
                              ),
                              Text(
                                "Kelola konten akademik",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Back button with gradient matching the maroon palette
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              // Navigate back or perform any action when pressed
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [maroonPrimary, maroonDark],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: maroonPrimary.withOpacity(0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.grid_view_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

// Custom painter for dramatically curved gradient background with a double-wave effect
class DramaticCurvedGradientPainter extends CustomPainter {
  final List<Color> colors;
  final List<double> stops;

  DramaticCurvedGradientPainter({
    required this.colors,
    required this.stops,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Create gradient
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
      stops: stops,
    ).createShader(rect);

    // Create dramatic double-curved path with deep valleys
    final path = Path();
    path.lineTo(
        0, size.height - 60); // Start from bottom-left with larger offset

    // First dramatic curve
    final firstControlPoint = Offset(
        size.width * 0.25, size.height + 30); // Control point below the bottom
    final firstEndPoint = Offset(size.width * 0.5, size.height - 40);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    // Second dramatic curve
    final secondControlPoint = Offset(size.width * 0.75,
        size.height - 110); // Higher control point for deeper curve
    final secondEndPoint = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    // Complete the path
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);

    // Add more dramatic highlights for enhanced depth
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final highlightPath = Path();
    highlightPath.moveTo(0, size.height - 58);
    highlightPath.quadraticBezierTo(firstControlPoint.dx,
        firstControlPoint.dy - 4, firstEndPoint.dx, firstEndPoint.dy - 3);
    highlightPath.quadraticBezierTo(secondControlPoint.dx,
        secondControlPoint.dy - 3, secondEndPoint.dx, secondEndPoint.dy - 3);

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Enhanced wave pattern for more visual impact
class EnhancedWavePatternPainter extends CustomPainter {
  final Color color1;
  final Color color2;

  EnhancedWavePatternPainter({
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // First enhanced wave with more dramatic peaks and valleys
    final path = Path();
    path.moveTo(0, size.height * 0.3);

    // First dramatic curve set - more pronounced waves
    path.cubicTo(size.width * 0.15, size.height * 0.1, size.width * 0.35,
        size.height * 0.6, size.width * 0.5, size.height * 0.2);

    // Second dramatic curve set
    path.cubicTo(
        size.width * 0.65,
        size.height * -0.2, // Negative value for more extreme peak
        size.width * 0.85,
        size.height * 0.4,
        size.width,
        size.height * 0.3);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    paint.color = color1;
    canvas.drawPath(path, paint);

    // Second enhanced wave with different pattern
    final secondPath = Path();
    secondPath.moveTo(0, size.height * 0.5);

    // First dramatic curve
    secondPath.cubicTo(size.width * 0.2, size.height * 0.3, size.width * 0.4,
        size.height * 0.8, size.width * 0.6, size.height * 0.4);

    // Second dramatic curve
    secondPath.cubicTo(size.width * 0.75, size.height * 0.1, size.width * 0.9,
        size.height * 0.6, size.width, size.height * 0.35);

    secondPath.lineTo(size.width, size.height);
    secondPath.lineTo(0, size.height);
    secondPath.close();

    paint.color = color2;
    canvas.drawPath(secondPath, paint);

    // Add more dramatic decorative elements
    final circlePaint = Paint()
      ..color = color1
      ..style = PaintingStyle.fill;

    // Larger circles for better visibility
    canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.2), 25, circlePaint);
    canvas.drawCircle(
        Offset(size.width * 0.15, size.height * 0.7), 20, circlePaint);
    canvas.drawCircle(
        Offset(size.width * 0.6, size.height * 0.6), 15, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
