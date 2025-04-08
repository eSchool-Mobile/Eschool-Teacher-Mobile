import 'dart:ui';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/sendPasswordResetEmailCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/signInCubit.dart';
import 'package:eschool_saas_staff/ui/screens/login/widgets/forgotPasswordBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/showHidePasswordButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static Widget getRouteInstance() => BlocProvider(
        create: (context) => SignInCubit(),
        child: const LoginScreen(),
      );

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late final AnimationController _backgroundAnimationController;
  late final AnimationController _formAnimationController;
  late final AnimationController _logoAnimationController;
  late final AnimationController _floatingElementsController;

  // Animations for background elements
  late final Animation<double> _backgroundFadeAnimation;
  late final Animation<double> _blurAnimation;

  // Animations for floating elements
  late final Animation<double> _float1;
  late final Animation<double> _float2;
  late final Animation<double> _float3;

  // Animations for form elements
  late final Animation<Offset> _formSlideAnimation;
  late final Animation<double> _formFadeAnimation;

  // Animations for individual form fields
  late final Animation<Offset> _schoolCodeSlideAnimation;
  late final Animation<Offset> _emailSlideAnimation;
  late final Animation<Offset> _passwordSlideAnimation;
  late final Animation<Offset> _buttonSlideAnimation;
  late final Animation<Offset> _termsSlideAnimation;

  // Logo animation
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoRotateAnimation;
  late final Animation<double> _logoGlowAnimation;

  // State variables
  bool _hidePassword = true;
  bool _isSchoolCodeFocused = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

  // Focus nodes
  late final FocusNode _schoolCodeFocusNode = FocusNode();
  late final FocusNode _emailFocusNode = FocusNode();
  late final FocusNode _passwordFocusNode = FocusNode();

  // Text controllers
  late final _schoolCodeController =
      TextEditingController(text: defaultSchoolCode);
  late final TextEditingController _emailTextEditingController =
      TextEditingController(text: defaultEmail);
  late final TextEditingController _passwordTextEditingController =
      TextEditingController(text: defaultPassword);

  // Brand colors
  final Color primaryMaroon = const Color(0xFF8B0000);
  final Color lightMaroon = const Color(0xFFC41E3A);
  final Color maroonRich = const Color(0xFF8C1D40);
  final Color accentColor = const Color(0xFFFFD700);
  final Color accentGold = const Color(0xFFFFD700);
  final Color accentSky = const Color(0xFF87CEEB);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupFocusListeners();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Initialize controllers with different durations
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _formAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _floatingElementsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // Background animations
    _backgroundFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _blurAnimation = Tween<double>(begin: 0.0, end: 3.0).animate(
      CurvedAnimation(
        parent: _backgroundAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Floating animations
    _float1 = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _floatingElementsController,
        curve: Curves.easeInOut,
      ),
    );

    _float2 = Tween<double>(begin: -3.0, end: 7.0).animate(
      CurvedAnimation(
        parent: _floatingElementsController,
        curve: Curves.easeInOut,
      ),
    );

    _float3 = Tween<double>(begin: 2.0, end: -6.0).animate(
      CurvedAnimation(
        parent: _floatingElementsController,
        curve: Curves.easeInOut,
      ),
    );

    // Form animations
    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    // Individual field animations with staggered timing
    _schoolCodeSlideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _emailSlideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _passwordSlideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _termsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Logo animations
    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 60,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _logoRotateAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.3, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoGlowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 4.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 4.0, end: 0.0),
        weight: 60,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  void _startAnimations() {
    _backgroundAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _logoAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _formAnimationController.forward();
    });
    _floatingElementsController.forward();
  }

  void _setupFocusListeners() {
    _schoolCodeFocusNode.addListener(() {
      setState(() {
        _isSchoolCodeFocused = _schoolCodeFocusNode.hasFocus;
      });
    });

    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
      });
    });

    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _formAnimationController.dispose();
    _logoAnimationController.dispose();
    _floatingElementsController.dispose();
    _schoolCodeController.dispose();
    _emailTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    _schoolCodeFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveTeacherId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('teacher Id', id);
    print("Saved teacher Id: $id");
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: TextButton(
        onPressed: () {
          if (context.read<SignInCubit>().state is SignInInProgress) {
            return;
          }
          Utils.showBottomSheet(
            child: BlocProvider(
              create: (context) => SendPasswordResetEmailCubit(),
              child: const ForgotPasswordBottomsheet(),
            ),
            context: context,
          );
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          Utils.getTranslatedLabel(forgotPasswordKey) + "?",
          style: TextStyle(
            color: primaryMaroon,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTermsConditionAndPrivacyPolicyContainer() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return SlideTransition(
      position: _termsSlideAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 15),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextContainer(
              textKey: bySignInYouAgreeToOurKey,
              style: TextStyle(
                fontSize:
                    Utils.getScaledValue(context, isSmallScreen ? 12 : 14),
                color: Colors.black54,
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CustomTextButton(
                  onTapButton: () {
                    if (context.read<SignInCubit>().state is SignInInProgress) {
                      return;
                    }
                    Get.toNamed(Routes.termsAndConditionScreen);
                  },
                  buttonTextKey: termsAndConditionKey,
                  textStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: primaryMaroon,
                      decoration: TextDecoration.underline,
                      decorationThickness: 1.5,
                      fontSize: Utils.getScaledValue(
                          context, isSmallScreen ? 13 : 15)),
                ),
                const SizedBox(width: 4),
                CustomTextContainer(
                  textKey: andKey,
                  style: TextStyle(
                      fontSize: Utils.getScaledValue(
                          context, isSmallScreen ? 12 : 14)),
                ),
                CustomTextButton(
                  onTapButton: () {
                    if (context.read<SignInCubit>().state is SignInInProgress) {
                      return;
                    }
                    Get.toNamed(Routes.privacyPolicyScreen);
                  },
                  buttonTextKey: privacyPolicyKey,
                  textStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: primaryMaroon,
                      decoration: TextDecoration.underline,
                      decorationThickness: 1.5,
                      fontSize: Utils.getScaledValue(
                          context, isSmallScreen ? 13 : 15)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassyFormContainer() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return FadeTransition(
      opacity: _formFadeAnimation,
      child: SlideTransition(
        position: _formSlideAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16.0 : 24.0,
              vertical: isSmallScreen ? 10.0 : 20.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(28.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryMaroon.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10.0,
                sigmaY: 10.0,
              ),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 20.0 : 28.0),
                child: _buildLoginFormContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_logoAnimationController, _floatingElementsController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _float2.value),
          child: Transform.scale(
            scale: _logoScaleAnimation.value,
            child: Transform.rotate(
              angle: _logoRotateAnimation.value,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: primaryMaroon.withOpacity(0.3),
                      blurRadius: 15 + _logoGlowAnimation.value,
                      spreadRadius: 3 + _logoGlowAnimation.value / 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          lightMaroon,
                          primaryMaroon,
                          maroonRich,
                        ],
                        center: Alignment.topLeft,
                        radius: 1.0,
                        stops: const [0.2, 0.5, 0.9],
                      ),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildElegantTextField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    required bool obscureText,
    required IconData icon,
    required Animation<Offset> slideAnimation,
    Widget? suffixWidget,
    required bool isFocused,
    required FocusNode focusNode,
  }) {
    final Color darkTextColor = const Color(0xFF303030);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return SlideTransition(
      position: slideAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: primaryMaroon.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
          border: Border.all(
            color: isFocused ? primaryMaroon : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20, top: isSmallScreen ? 8 : 12),
              child: Text(
                labelText,
                style: TextStyle(
                  color: isFocused ? primaryMaroon : Colors.grey.shade600,
                  fontSize: isSmallScreen ? 12 : 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              style: TextStyle(
                color: darkTextColor,
                fontWeight: FontWeight.w500,
                fontSize: isSmallScreen ? 15 : 16,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Padding(
                  padding:
                      EdgeInsets.only(left: 15, right: isSmallScreen ? 8 : 12),
                  child: Icon(
                    icon,
                    color: isFocused ? primaryMaroon : Colors.grey.shade500,
                    size: isSmallScreen ? 20 : 22,
                  ),
                ),
                suffixIcon: suffixWidget,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.fromLTRB(0, isSmallScreen ? 8 : 10, 16, 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return SlideTransition(
      position: _buttonSlideAnimation,
      child: BlocConsumer<SignInCubit, SignInState>(
        listener: (context, state) {
          if (state is SignInSuccess) {
            context.read<AuthCubit>().authenticateUser(
                  authToken: state.authToken,
                  schoolCode: state.schoolCode,
                  userDetails: state.userDetails,
                );
            Get.offNamed(Routes.homeScreen);
            _saveTeacherId(state.userDetails.id!);
          } else if (state is SignInFailure) {
            Utils.showSnackBar(message: state.errorMessage, context: context);
          }
        },
        builder: (context, state) {
          return Container(
            width: double.infinity,
            height: isSmallScreen ? 56 : 62,
            margin: EdgeInsets.only(top: isSmallScreen ? 8 : 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: primaryMaroon.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                  spreadRadius: 1,
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  lightMaroon,
                  primaryMaroon,
                  maroonRich,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (state is SignInInProgress) return;

                  if (_schoolCodeController.text.trim().isEmpty) {
                    Utils.showSnackBar(
                        message: pleaseEnterSchoolCodeKey, context: context);
                    return;
                  }
                  if (_emailTextEditingController.text.trim().isEmpty) {
                    Utils.showSnackBar(
                        message: pleaseEnterEmailKey, context: context);
                    return;
                  }
                  if (_passwordTextEditingController.text.trim().isEmpty) {
                    Utils.showSnackBar(
                        message: pleaseEnterPasswordKey, context: context);
                    return;
                  }

                  context.read<SignInCubit>().signInUser(
                        email: _emailTextEditingController.text.trim(),
                        password: _passwordTextEditingController.text.trim(),
                        schoolCode: _schoolCodeController.text.trim(),
                      );
                },
                borderRadius: BorderRadius.circular(22),
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Center(
                  child: state is SignInInProgress
                      ? const CustomCircularProgressIndicator(
                          strokeWidth: 3,
                          widthAndHeight: 26,
                          indicatorColor: Colors.white,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              Utils.getTranslatedLabel(signInKey),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginFormContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _buildAnimatedLogo()),
        SizedBox(height: isSmallScreen ? 16 : 26),
        Text(
          'Selamat Datang',
          style: TextStyle(
            fontSize: isSmallScreen ? 24 : 28,
            fontWeight: FontWeight.bold,
            color: maroonRich,
            letterSpacing: 0.5,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        CustomTextContainer(
          textKey: teacherAndStaffKey,
          style: TextStyle(
            fontSize: Utils.getScaledValue(context, isSmallScreen ? 17 : 19),
            fontWeight: FontWeight.w700,
            color: primaryMaroon,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextContainer(
          textKey: signInScreenSubTitleKey,
          style: TextStyle(
            fontSize: Utils.getScaledValue(context, isSmallScreen ? 14 : 16),
            height: 1.4,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: isSmallScreen ? 20 : 32),
        _buildElegantTextField(
          controller: _schoolCodeController,
          hintText: Utils.getTranslatedLabel(schoolCodeKey),
          labelText: 'Kode Sekolah',
          obscureText: false,
          icon: Icons.domain_rounded,
          slideAnimation: _schoolCodeSlideAnimation,
          isFocused: _isSchoolCodeFocused,
          focusNode: _schoolCodeFocusNode,
        ),
        _buildElegantTextField(
          controller: _emailTextEditingController,
          hintText: Utils.getTranslatedLabel(emailKey),
          labelText: 'Email',
          obscureText: false,
          icon: Icons.alternate_email_rounded,
          slideAnimation: _emailSlideAnimation,
          isFocused: _isEmailFocused,
          focusNode: _emailFocusNode,
        ),
        _buildElegantTextField(
          controller: _passwordTextEditingController,
          hintText: "••••••••",
          labelText: Utils.getTranslatedLabel(passwordKey),
          obscureText: _hidePassword,
          icon: Icons.lock_outline_rounded,
          slideAnimation: _passwordSlideAnimation,
          suffixWidget: IconButton(
            icon: Icon(
              _hidePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: _isPasswordFocused ? primaryMaroon : Colors.grey.shade500,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _hidePassword = !_hidePassword;
              });
            },
          ),
          isFocused: _isPasswordFocused,
          focusNode: _passwordFocusNode,
        ),
        _buildForgotPasswordButton(),
        const SizedBox(height: 18),
        _buildLoginButton(),
        const SizedBox(height: 24),
        Center(child: _buildTermsConditionAndPrivacyPolicyContainer()),
      ],
    );
  }

  Widget _buildFloatingElement({
    required double top,
    required double left,
    required double size,
    required Color color,
    required Animation<double> animation,
    double? angle,
    Widget? child,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: AnimatedBuilder(
        animation: _floatingElementsController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, animation.value),
            child: Transform.rotate(
              angle: angle ?? 0,
              child: FadeTransition(
                opacity: _backgroundFadeAnimation,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(size / 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientDecorativeElement({
    required double top,
    required double left,
    required double size,
    required List<Color> colors,
    required Animation<double> animation,
    required double angle,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: AnimatedBuilder(
        animation: _floatingElementsController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, animation.value),
            child: Transform.rotate(
              angle: angle,
              child: FadeTransition(
                opacity: _backgroundFadeAnimation,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(size / 3),
                    boxShadow: [
                      BoxShadow(
                        color: colors.first.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Background color
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.shade50,
                Colors.grey.shade100,
                Colors.white,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        ),

        // Decorative floating elements
        _buildFloatingElement(
          top: -40,
          left: -30,
          size: screenWidth * 0.4,
          color: primaryMaroon.withOpacity(0.15),
          animation: _float1,
        ),

        _buildGradientDecorativeElement(
          top: screenHeight * 0.12,
          left: screenWidth * 0.7,
          size: screenWidth * 0.3,
          colors: [lightMaroon.withOpacity(0.4), maroonRich.withOpacity(0.1)],
          animation: _float2,
          angle: -math.pi / 6,
        ),

        _buildFloatingElement(
          top: screenHeight * 0.55,
          left: -screenWidth * 0.15,
          size: screenWidth * 0.3,
          color: accentGold.withOpacity(0.1),
          animation: _float3,
          angle: math.pi / 4,
        ),

        _buildGradientDecorativeElement(
          top: screenHeight * 0.75,
          left: screenWidth * 0.6,
          size: screenWidth * 0.4,
          colors: [
            primaryMaroon.withOpacity(0.1),
            lightMaroon.withOpacity(0.05)
          ],
          animation: _float1,
          angle: math.pi / 8,
        ),

        // Add some small floating dots
        for (int i = 0; i < 8; i++)
          _buildFloatingElement(
            top: screenHeight * (0.2 + i * 0.1) % screenHeight,
            left: screenWidth * (0.1 + i * 0.12) % screenWidth,
            size: 8 + (i % 4) * 3,
            color: i % 3 == 0
                ? primaryMaroon.withOpacity(0.2)
                : i % 3 == 1
                    ? accentGold.withOpacity(0.3)
                    : accentSky.withOpacity(0.3),
            animation: i % 3 == 0
                ? _float1
                : i % 3 == 1
                    ? _float2
                    : _float3,
          ),

        // Blur effect that increases over time
        AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _blurAnimation.value,
                  sigmaY: _blurAnimation.value,
                ),
                child: Container(
                  color: Colors.transparent,
                ),
              );
            }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            // Stylish background with animated elements
            _buildBackground(),

            // Main scrollable content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.width < 360
                              ? 10
                              : 20),
                      _buildGlassyFormContainer(),
                      SizedBox(
                          height: MediaQuery.of(context).size.width < 360
                              ? 16
                              : 24),
                    ],
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
