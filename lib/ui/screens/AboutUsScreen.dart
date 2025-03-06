import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:eschool_saas_staff/cubits/settingCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  static Widget getRouteInstance() {
    return BlocProvider(
      create: (context) => SettingsCubit(),
      child: const AboutUsScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>
    with SingleTickerProviderStateMixin {
  String? cachedData;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().getSettings("about_us");
    _loadCachedData();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCachedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cachedData = prefs.getString("about_us");
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
    final size = MediaQuery.of(context).size;

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
        body: BlocBuilder<SettingsCubit, SettingsState>(
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
                  height: size.height,
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

                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: Utils.appContentTopScrollPadding(context: context),
                  ),
                  child: Column(
                    children: [
                      // Hero Section with glassmorphism
                      FadeInDown(
                        duration: const Duration(milliseconds: 800),
                        child: Container(
                          height: size.height * 0.4,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColorPalette.primaryMaroon,
                                AppColorPalette.secondaryMaroon,
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColorPalette.primaryMaroon
                                    .withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Animated background pattern
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(30),
                                    bottomRight: Radius.circular(30),
                                  ),
                                  child: CustomPaint(
                                    painter: BackgroundPainter(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                              ),

                              // Content
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SlideInDown(
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColorPalette
                                                  .primaryMaroon
                                                  .withOpacity(0.3),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.school,
                                          size: 60,
                                          color: AppColorPalette.primaryMaroon,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    FadeIn(
                                      child: Text(
                                        'eSchool SaaS',
                                        style: GoogleFonts.poppins(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    FadeIn(
                                      delay: const Duration(milliseconds: 300),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Transforming Education Through Technology',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Stats Section with new design

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard(
                              icon: Icons.people,
                              label: 'Students',
                              value: '1000+',
                              gradient: [
                                AppColorPalette.primaryMaroon.withOpacity(0.1),
                                AppColorPalette.secondaryMaroon
                                    .withOpacity(0.2),
                              ],
                            ),
                            _buildStatCard(
                              icon: Icons.school,
                              label: 'Schools',
                              value: '50+',
                              gradient: [
                                AppColorPalette.secondaryMaroon
                                    .withOpacity(0.1),
                                AppColorPalette.primaryMaroon.withOpacity(0.2),
                              ],
                            ),
                            _buildStatCard(
                              icon: Icons.star,
                              label: 'Rating',
                              value: '4.8',
                              gradient: [
                                AppColorPalette.primaryMaroon.withOpacity(0.1),
                                AppColorPalette.secondaryMaroon
                                    .withOpacity(0.2),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Feature Cards with new design

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildFeatureCard(
                              icon: Icons.computer,
                              title: 'Modern Learning',
                              description:
                                  'State-of-the-art digital learning platform',
                              gradient: [
                                AppColorPalette.warmBeige,
                                AppColorPalette.lightMaroon.withOpacity(0.3),
                              ],
                            ),
                            _buildFeatureCard(
                              icon: Icons.analytics,
                              title: 'Smart Analytics',
                              description:
                                  'Real-time performance tracking and insights',
                              gradient: [
                                AppColorPalette.warmBeige,
                                AppColorPalette.accentPink.withOpacity(0.3),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Main Content with glassmorphism

                      if (state is SettingsSuccess)
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColorPalette.primaryMaroon
                                    .withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: HtmlWidget(
                            parseCustomHtml(state.data),
                            textStyle: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColorPalette.primaryMaroon
                                  .withOpacity(0.8),
                            ),
                            customStylesBuilder: (element) {
                              if (element.localName == 'b') {
                                return {
                                  'color':
                                      AppColorPalette.primaryMaroon.toString(),
                                  'font-weight': 'bold',
                                };
                              }
                              if (element.localName == 'i') {
                                return {
                                  'color': AppColorPalette.secondaryMaroon
                                      .toString(),
                                  'font-style': 'italic',
                                };
                              }
                              return null;
                            },
                          ),
                        )
                      else if (state is SettingsFailure)
                        Center(
                          child: Text(
                            'Error: ${state.errorMessage}',
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        )
                      else
                        const Center(
                          child: CustomCircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),

                // Glassmorphic AppBar
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColorPalette.warmBeige.withOpacity(0.8),
                      ),
                      child: CustomAppbar(
                        titleKey: aboutUsKey,
                        onBackButtonTap: () => Get.back(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Helper widgets implementation...
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradient,
  }) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColorPalette.primaryMaroon.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 30, color: AppColorPalette.primaryMaroon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColorPalette.primaryMaroon,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColorPalette.primaryMaroon.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradient,
  }) {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColorPalette.primaryMaroon.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: AppColorPalette.primaryMaroon),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColorPalette.primaryMaroon,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColorPalette.primaryMaroon.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppColorPalette {
  static const Color primaryMaroon = Color(0xFF8B1F41);
  static const Color secondaryMaroon = Color(0xFFA84B5C);
  static const Color lightMaroon = Color(0xFFE7C8CD);
  static const Color accentPink = Color(0xFFF4D0D9);
  static const Color warmBeige = Color(0xFFF5E6E8);
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
