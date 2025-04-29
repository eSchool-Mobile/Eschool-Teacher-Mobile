import 'package:eschool_saas_staff/cubits/authentication/changePasswordCubic.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/showHidePasswordButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  static Widget getRouteInstance() {
    return BlocProvider(
      create: (context) => ChangePasswoedCubit(),
      child: const ChangePasswordScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  late bool _hideOldPassword = true;
  late bool _hideNewPassword = true;
  late bool _hideConfirmPassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _passwordStrength = 0;

  // Maroon color palette
  final Color _primaryMaroon = const Color(0xFF7D1935);
  final Color _lightMaroon = const Color(0xFFC97B93);
  final Color _backgroundColor = const Color(0xFFFAF0F4);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Listen for password changes to calculate strength
    newPassword.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    final password = newPassword.text;
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    setState(() {
      _passwordStrength = strength;
    });
  }

  @override
  void dispose() {
    oldPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Color _getStrengthColor() {
    switch (_passwordStrength) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow.shade700;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStrengthText() {
    switch (_passwordStrength) {
      case 0:
        return "Masukkan kata sandi";
      case 1:
        return "Lemah";
      case 2:
        return "Sedang";
      case 3:
        return "Kuat";
      case 4:
        return "Sangat Kuat";
      default:
        return "";
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintKey,
    required bool hidePassword,
    required Function() toggleVisibility,
    String? helperText,
    Widget? strengthIndicator,
  }) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _primaryMaroon.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller,
                  obscureText: hidePassword,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                  decoration: InputDecoration(
                    hintText: hintKey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: _primaryMaroon,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                        color: _primaryMaroon,
                      ),
                      onPressed: toggleVisibility,
                    ),
                  ),
                ),
                if (helperText != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      helperText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                if (strengthIndicator != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 8,
                      top: 4,
                    ),
                    child: strengthIndicator,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _getStrengthText(),
              style: TextStyle(
                fontSize: 12,
                color: _getStrengthColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_passwordStrength}/4",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: MediaQuery.of(context).size.width *
                    0.7 *
                    (_passwordStrength / 4),
                decoration: BoxDecoration(
                  color: _getStrengthColor(),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpdatePasswordButton(ChangePasswordState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: ElevatedButton(
                onPressed: () {
                  if (state is ChangePasswordProgress) {
                    return;
                  }
                  if (oldPassword.text.trim().isEmpty) {
                    Utils.showSnackBar(
                        message: pleaseEnterOldPasswordKey, context: context);
                    return;
                  } else if (newPassword.text.trim().isEmpty) {
                    Utils.showSnackBar(
                        message: pleaseEnterNewPasswordKey, context: context);
                    return;
                  } else if (confirmPassword.text.trim().isEmpty) {
                    Utils.showSnackBar(
                        message: pleaseEnterConfirmPasswordKey,
                        context: context);
                    return;
                  } else if (confirmPassword.text.trim() !=
                      newPassword.text.trim()) {
                    Utils.showSnackBar(
                        message: passwordAreNotMatchKey, context: context);
                    return;
                  }

                  context.read<ChangePasswoedCubit>().changePassword(
                      oldPassword: oldPassword.text.trim(),
                      newPassword: newPassword.text.trim(),
                      confirmPassword: confirmPassword.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryMaroon,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: state is ChangePasswordProgress
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_reset),
                          const SizedBox(width: 12),
                          Text(
                            "Perbarui Kata Sandi",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: BlocConsumer<ChangePasswoedCubit, ChangePasswordState>(
          listener: (context, state) {
        if (state is ChangePasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      "Kata Sandi Berhasil Diperbarui",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.green.shade400,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
            ),
          );

          Future.delayed(const Duration(milliseconds: 2200), () {
            if (context.mounted) {
              Get.back();
            }
          });
        } else if (state is ChangePasswordFailure) {
          Utils.showSnackBar(message: state.errorMessage, context: context);
        }
      }, builder: (context, state) {
        return PopScope(
          canPop: state is! ChangePasswordProgress,
          child: Stack(
            children: [
              // Main content
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 70, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and description
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Transform.translate(
                              offset:
                                  Offset(0, 20 * (1 - _fadeAnimation.value)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Ubah Kata Sandi",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: _primaryMaroon,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Masukkan kata sandi lama Anda dan kata sandi baru untuk mengganti kata sandi.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Password Fields with staggered animations
                      _buildPasswordField(
                        controller: oldPassword,
                        hintKey: "Kata Sandi Lama",
                        hidePassword: _hideOldPassword,
                        toggleVisibility: () {
                          setState(() {
                            _hideOldPassword = !_hideOldPassword;
                          });
                        },
                      ),

                      _buildPasswordField(
                        controller: newPassword,
                        hintKey: "Kata Sandi Baru",
                        hidePassword: _hideNewPassword,
                        toggleVisibility: () {
                          setState(() {
                            _hideNewPassword = !_hideNewPassword;
                          });
                        },
                        helperText:
                            "Gunakan minimal 8 karakter dengan kombinasi huruf, angka, dan simbol",
                        strengthIndicator: _buildPasswordStrengthIndicator(),
                      ),

                      _buildPasswordField(
                        controller: confirmPassword,
                        hintKey: "Konfirmasi Kata Sandi",
                        hidePassword: _hideConfirmPassword,
                        toggleVisibility: () {
                          setState(() {
                            _hideConfirmPassword = !_hideConfirmPassword;
                          });
                        },
                      ),

                      // Password requirements
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _lightMaroon.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _lightMaroon.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Syarat Kata Sandi Kuat:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _primaryMaroon,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildRequirementRow(
                                      "Minimal 8 karakter",
                                      newPassword.text.length >= 8,
                                    ),
                                    _buildRequirementRow(
                                      "Memiliki huruf kapital",
                                      newPassword.text
                                          .contains(RegExp(r'[A-Z]')),
                                    ),
                                    _buildRequirementRow(
                                      "Memiliki angka",
                                      newPassword.text
                                          .contains(RegExp(r'[0-9]')),
                                    ),
                                    _buildRequirementRow(
                                      "Memiliki simbol (!@#\$%^&*)",
                                      newPassword.text.contains(
                                          RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Appbar with back button
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        color: _backgroundColor,
                        child: SafeArea(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_ios),
                                  color: _primaryMaroon,
                                  onPressed: () {
                                    if (state is ChangePasswordProgress) {
                                      return;
                                    }
                                    Get.back();
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Kembali",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _primaryMaroon,
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
              ),

              // Update button at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildUpdatePasswordButton(state),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRequirementRow(String text, bool fulfilled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            fulfilled ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: fulfilled ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: fulfilled ? Colors.grey.shade800 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
