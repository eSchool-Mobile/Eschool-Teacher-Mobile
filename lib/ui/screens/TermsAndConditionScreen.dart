import 'dart:math';
import 'dart:ui';
import 'package:eschool_saas_staff/cubits/settingCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class TermsAndConditionScreen extends StatefulWidget {
  const TermsAndConditionScreen({super.key});

  static Widget getRouteInstance() {
    return BlocProvider(
      create: (context) => SettingsCubit(),
      child: const TermsAndConditionScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<TermsAndConditionScreen> createState() =>
      _TermsAndConditionScreenState();
}

class _TermsAndConditionScreenState extends State<TermsAndConditionScreen>
    with TickerProviderStateMixin {
  String? cachedData;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late AnimationController _fabAnimationController;
  final ScrollController _scrollController = ScrollController();
  final Color _maroonPrimary = AppColorPalette.primaryMaroon;
  final Color _maroonLight = AppColorPalette.secondaryMaroon;

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().getSettings("terms_condition");
    _loadCachedData();

    _scrollController.addListener(_scrollListener);
    _fabAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  void _scrollListener() {
    if (_scrollController.offset > 50) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadCachedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cachedData = prefs.getString("terms_condition");
    });
  }

  String generateRandomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  String parseCustomHtml(String input) {
    String placeholderBold = generateRandomString(10);
    String placeholderItalic = generateRandomString(10);

    while (placeholderItalic == placeholderBold) {
      placeholderItalic = generateRandomString(10);
      placeholderBold = generateRandomString(10);
    }

    input = input
        .replaceAll('\\*', placeholderBold)
        .replaceAll('\\/', placeholderItalic);

    bool isBold = false;
    bool isItalic = false;
    String output = '';

    for (int i = 0; i < input.length; i++) {
      if (input[i] == '*') {
        isBold = !isBold;
        output += isBold ? '<b>' : '</b>';
      } else if (input[i] == '/') {
        isItalic = !isItalic;
        output += isItalic ? '<i>' : '</i>';
      } else {
        output += input[i];
      }
    }

    output = output
        .replaceAll(placeholderBold, '*')
        .replaceAll(placeholderItalic, '/')
        .replaceAll("\n", "<br/>");

    return output;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColorPalette.primaryMaroon,
              secondary: AppColorPalette.secondaryMaroon,
              surface: AppColorPalette.warmBeige,
              background: AppColorPalette.warmBeige,
            ),
      ),
      child: Scaffold(
        backgroundColor: AppColorPalette.warmBeige,
        body: BlocConsumer<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state is SettingsFailure) {
              Utils.showSnackBar(message: state.errorMessage, context: context);
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                // Animated Background Pattern
                AnimatedPositioned(
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  top: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height,
                  child: AnimatedOpacity(
                    duration: const Duration(seconds: 1),
                    opacity: 0.1,
                    child: CustomPaint(
                      painter: BackgroundPainter(
                        color: AppColorPalette.primaryMaroon,
                      ),
                    ),
                  ),
                ),

                // Main Content
                SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    top:
                        Utils.appContentTopScrollPadding(context: context) + 25,
                  ),
                  child: Column(
                    children: [
                      // Header Section
                      FadeInDown(
                        duration: const Duration(milliseconds: 800),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColorPalette.primaryMaroon.withOpacity(0.9),
                                AppColorPalette.secondaryMaroon
                                    .withOpacity(0.9),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColorPalette.primaryMaroon
                                    .withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.gavel_rounded,
                                size: 48,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Syarat & Ketentuan',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Bacalah dengan seksama ketentuan penggunaan layanan kami',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Content Section
                      Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: state is SettingsSuccess
                            ? FadeIn(
                                child: HtmlWidget(
                                  parseCustomHtml(state.data),
                                  textStyle: GoogleFonts.poppins(
                                    fontSize: 15,
                                    height: 1.6,
                                    color: Colors.black87,
                                  ),
                                  customStylesBuilder: (element) {
                                    if (element.localName == 'h1' ||
                                        element.localName == 'h2') {
                                      return {
                                        'color': AppColorPalette.primaryMaroon
                                            .toString(),
                                        'font-weight': 'bold',
                                        'margin': '16px 0',
                                      };
                                    }
                                    return null;
                                  },
                                ),
                              )
                            : const Center(
                                child: CustomCircularProgressIndicator(),
                              ),
                      ),
                    ],
                  ),
                ),

                // Glassmorphic AppBar
                _buildAppBar(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: MediaQuery.of(context).padding.top + 80,
        child: Stack(
          children: [
            // Fancy gradient background with animated particles
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _fabAnimationController,
                builder: (context, _) {
                  return ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF690013),
                          _maroonPrimary,
                          Color(0xFFA12948),
                          _maroonLight,
                        ],
                        stops: [0.0, 0.3, 0.6, 1.0],
                        transform: GradientRotation(
                            _fabAnimationController.value * 0.02),
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColorPalette.primaryMaroon,
                            AppColorPalette.secondaryMaroon,
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
            ),

            // Animated glowing effect
            AnimatedBuilder(
              animation: _fabAnimationController,
              builder: (context, _) {
                return Positioned(
                  top: -100 + (_fabAnimationController.value * 20),
                  right: -60 + (_fabAnimationController.value * 10),
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
            ),

            // Main app bar content with frosted glass effect
            Positioned(
              bottom: 10,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              highlightColor: Colors.white.withOpacity(0.1),
                              splashColor: Colors.white.withOpacity(0.2),
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Animated divider
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
                                    AnimatedBuilder(
                                      animation: _fabAnimationController,
                                      builder: (context, child) {
                                        return Transform.rotate(
                                          angle: _fabAnimationController.value *
                                              0.05,
                                          child: Container(
                                            padding: EdgeInsets.all(6),
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
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.gavel_rounded,
                                              color: _maroonPrimary,
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
                                        Utils.getTranslatedLabel(
                                            termsAndConditionKey),
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
                      ],
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

class BackgroundPainter extends CustomPainter {
  final Color color;

  BackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var i = 0; i < size.width; i += 20) {
      for (var j = 0; j < size.height; j += 20) {
        canvas.drawCircle(Offset(i.toDouble(), j.toDouble()), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) => false;
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

class AppColorPalette {
  static const Color primaryMaroon = Color(0xFF8B1F41);
  static const Color secondaryMaroon = Color(0xFFA84B5C);
  static const Color lightMaroon = Color(0xFFE7C8CD);
  static const Color accentPink = Color(0xFFF4D0D9);
  static const Color warmBeige = Color(0xFFF5E6E8);
}
