import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/sendPasswordResetEmailCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/signInCubit.dart';
import 'package:eschool_saas_staff/ui/screens/login/widgets/forgotPasswordBottomsheet.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import 'package:animate_do/animate_do.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static Widget getRouteInstance() => BlocProvider(
        create: (context) => SignInCubit(),
        child: const LoginScreen(),
      );

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late bool _hidePassword = true;

  late final _schoolCodeController =
      TextEditingController(text: defaultSchoolCode);

  late final TextEditingController _emailTextEditingController =
      TextEditingController(text: defaultEmail);

  late final TextEditingController _passwordTextEditingController =
      TextEditingController(text: defaultPassword);

  @override
  void dispose() {
    _schoolCodeController.dispose();
    _emailTextEditingController.dispose();
    _passwordTextEditingController.dispose();
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
      child: CustomTextButton(
          textStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: Utils.getScaledValue(context, 16)),
          buttonTextKey: forgotPasswordKey,
          onTapButton: () {
            if (context.read<SignInCubit>().state is SignInInProgress) {
              return;
            }
            Utils.showBottomSheet(
                child: BlocProvider(
                  create: (context) => SendPasswordResetEmailCubit(),
                  child: const ForgotPasswordBottomsheet(),
                ),
                context: context);
          }),
    );
  }

  Widget _buildTermsConditionAndPrivacyPolicyContainer() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextContainer(
            textKey: bySignInYouAgreeToOurKey,
            style: TextStyle(fontSize: Utils.getScaledValue(context, 16)),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
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
                    decoration: TextDecoration.underline,
                    decorationThickness: 1.5,
                    fontSize: Utils.getScaledValue(context, 15)),
              ),
              const SizedBox(width: 4),
              CustomTextContainer(
                textKey: andKey,
                style: TextStyle(fontSize: Utils.getScaledValue(context, 14)),
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
                    decoration: TextDecoration.underline,
                    decorationThickness: 1.5,
                    fontSize: Utils.getScaledValue(context, 15)),
              ),
            ],
          ),
          SizedBox(
            height: Utils().getResponsiveHeight(context, 20),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background design
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
          ),
          
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: appContentHorizontalPadding,
              right: appContentHorizontalPadding,
              top: MediaQuery.of(context).padding.top,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                
                // Title and Subtitle
                FadeInLeft(
                  duration: Duration(milliseconds: 800),
                  child: CustomTextContainer(
                    textKey: teacherAndStaffKey,
                    style: TextStyle(
                      fontSize: Utils.getScaledValue(context, 25),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                
                FadeInLeft(
                  duration: Duration(milliseconds: 1000),
                  child: CustomTextContainer(
                    textKey: signInScreenSubTitleKey,
                    style: TextStyle(
                      fontSize: Utils.getScaledValue(context, 16),
                      height: 1.1,
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Login Form Card
                FadeInUp(
                  duration: Duration(milliseconds: 1000),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 15,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // School Code Field
                        _buildAnimatedTextField(
                          controller: _schoolCodeController,
                          hint: schoolCodeKey,
                          icon: Icons.school_outlined,
                          delay: 200,
                        ),
                        
                        // Email Field
                        _buildAnimatedTextField(
                          controller: _emailTextEditingController,
                          hint: emailKey,
                          icon: Icons.email_outlined,
                          delay: 400,
                        ),
                        
                        // Password Field
                        _buildAnimatedTextField(
                          controller: _passwordTextEditingController,
                          hint: passwordKey,
                          icon: Icons.lock_outline,
                          isPassword: true,
                          delay: 600,
                        ),
                        
                        // Forgot Password
                        FadeInRight(
                          delay: Duration(milliseconds: 800),
                          child: _buildForgotPasswordButton(),
                        ),
                        
                        const SizedBox(height: 25),
                        
                        // Login Button
                        FadeInUp(
                          delay: Duration(milliseconds: 1000),
                          child: BlocConsumer<SignInCubit, SignInState>(
                            listener: (context, state) {
                              if (state is SignInSuccess) {
                                context.read<AuthCubit>().authenticateUser(
                                    authToken: state.authToken,
                                    schoolCode: state.schoolCode,
                                    userDetails: state.userDetails);
                                Get.offNamed(Routes.homeScreen);
                                _saveTeacherId(
                                    state.userDetails.id!); // Simpan teacherId
                              } else if (state is SignInFailure) {
                                Utils.showSnackBar(
                                    message: state.errorMessage, context: context);
                              }
                            },
                            builder: (context, state) {
                              return _buildLoginButton(context, state);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Terms and Privacy
          FadeInUp(
            delay: Duration(milliseconds: 1200),
            child: _buildTermsConditionAndPrivacyPolicyContainer(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required int delay,
  }) {
    return FadeInLeft(
      delay: Duration(milliseconds: delay),
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: CustomTextFieldContainer(
          prefixWidget: Icon(
            icon,
            color: Theme.of(context).colorScheme.secondary,
          ),
          textEditingController: controller,
          hintTextKey: hint,
          hideText: isPassword ? _hidePassword : false,
          suffixWidget: isPassword
              ? ShowHidePasswordButton(
                  hidePassword: _hidePassword,
                  onTapButton: () {
                    setState(() {
                      _hidePassword = !_hidePassword;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, SignInState state) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: FadeInUp(
        duration: Duration(milliseconds: 600),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                Color.fromARGB(255, 251, 44, 44),  // Light red
                Color.fromARGB(255, 194, 15, 15),  // Slightly darker red
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (state is SignInInProgress) return;
                
                if (_schoolCodeController.text.trim().isEmpty) {
                  Utils.showSnackBar(message: pleaseEnterSchoolCodeKey, context: context);
                  return;
                }
                if (_emailTextEditingController.text.trim().isEmpty) {
                  Utils.showSnackBar(message: pleaseEnterEmailKey, context: context);
                  return;
                }
                if (_passwordTextEditingController.text.trim().isEmpty) {
                  Utils.showSnackBar(message: pleaseEnterPasswordKey, context: context);
                  return;
                }

                context.read<SignInCubit>().signInUser(
                  email: _emailTextEditingController.text.trim(),
                  password: _passwordTextEditingController.text.trim(),
                  schoolCode: _schoolCodeController.text.trim(),
                );
              },
              borderRadius: BorderRadius.circular(15),
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state is SignInInProgress) ...[
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                    ],
                    Text(
                        state is SignInInProgress ? 'Memproses...' : 'Masuk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (!(state is SignInInProgress)) ...[
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 22,
                      ).animate(onPlay: (controller) {
                        controller.repeat(reverse: true);
                      }).slideX(
                        begin: 0,
                        end: 0.3,
                        duration: Duration(milliseconds: 1000),
                        curve: Curves.easeInOut,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
