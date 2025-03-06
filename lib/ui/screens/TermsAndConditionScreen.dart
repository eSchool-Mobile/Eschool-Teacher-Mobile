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
    with SingleTickerProviderStateMixin {
  String? cachedData;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().getSettings("terms_condition");
    _loadCachedData();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColorPalette.warmBeige.withOpacity(0.8),
                      ),
                      child: CustomAppbar(
                        titleKey: termsAndConditionKey,
                        onBackButtonTap: () {
                          if (state is! SettingsProgress) {
                            Get.back();
                          }
                        },
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

class AppColorPalette {
  static const Color primaryMaroon = Color(0xFF8B1F41);
  static const Color secondaryMaroon = Color(0xFFA84B5C);
  static const Color lightMaroon = Color(0xFFE7C8CD);
  static const Color accentPink = Color(0xFFF4D0D9);
  static const Color warmBeige = Color(0xFFF5E6E8);
}
