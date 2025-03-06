import 'dart:math';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:eschool_saas_staff/cubits/settingCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/colorPalette.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return BlocProvider(
      create: (context) => SettingsCubit(),
      child: const ContactUsScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String? cachedData;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
    context.read<SettingsCubit>().getSettings("contact_us");
    _loadCachedData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  Future<void> _loadCachedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cachedData = prefs.getString("contact_us");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: CustomPaint(
                  painter: BackgroundPainter(
                    color: AppColorPalette.lightMaroon.withOpacity(0.1),
                  ),
                ),
              ),

              // Main Content with Animation
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: Utils.appContentTopScrollPadding(context: context),
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildHeaderCard(),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: state is SettingsProgress
                            ? const Center(
                                child: CustomCircularProgressIndicator())
                            : Column(
                                children: [
                                  _buildContactCard(
                                    Icons.email_rounded,
                                    'Email Us',
                                    'support@eschool.com',
                                  ),
                                  _buildContactCard(
                                    Icons.phone_rounded,
                                    'Call Us',
                                    '+1 234 567 890',
                                  ),
                                  _buildContactCard(
                                    Icons.location_on_rounded,
                                    'Visit Us',
                                    '123 Education Street',
                                  ),
                                  if (state is SettingsSuccess) ...[
                                    const SizedBox(height: 24),
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: AppColorPalette.accentPink
                                            .withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: AppColorPalette.primaryMaroon
                                              .withOpacity(0.1),
                                        ),
                                      ),
                                      child: HtmlWidget(
                                        parseCustomHtml(state.data),
                                        textStyle: GoogleFonts.poppins(
                                          color: AppColorPalette.primaryMaroon,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // Glassmorphic AppBar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColorPalette.warmBeige.withOpacity(0.9),
                            AppColorPalette.warmBeige.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: CustomAppbar(
                        titleKey: contactUsKey,
                        onBackButtonTap: () => Get.back(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorPalette.primaryMaroon,
            AppColorPalette.secondaryMaroon,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorPalette.primaryMaroon.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'How can we help you?',
                  textStyle: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              totalRepeatCount: 1,
            ),
            const SizedBox(height: 16),
            Text(
              'We\'re here to assist you with any questions',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColorPalette.lightMaroon,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String content) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0.95, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColorPalette.primaryMaroon.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => HapticFeedback.lightImpact(),
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColorPalette.accentPink.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          icon,
                          color: AppColorPalette.primaryMaroon,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColorPalette.primaryMaroon,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              content,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppColorPalette.secondaryMaroon,
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
        );
      },
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
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.7,
      size.width * 0.5,
      size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.9,
      size.width,
      size.height * 0.8,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
