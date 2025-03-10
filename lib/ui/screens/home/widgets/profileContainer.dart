import 'dart:math';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/appLocalizationCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/menuTile.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/menusWithTitleContainer.dart';
import 'package:eschool_saas_staff/ui/screens/leaves/leavesScreen.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customMenuTile.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionTile.dart';
import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
import 'package:eschool_saas_staff/utils/appLanguages.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:animate_do/animate_do.dart';
import 'package:eschool_saas_staff/utils/colorPalette.dart';
import 'dart:ui';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class AppColorPalette {
  static const Color primaryMaroon = Color(0xFF8B1F41);
  static const Color secondaryMaroon = Color(0xFFA84B5C);
  static const Color lightMaroon = Color(0xFFE7C8CD);
  static const Color accentPink = Color(0xFFF4D0D9);
  static const Color warmBeige = Color(0xFFF5E6E8);
}

class ProfileContainer extends StatefulWidget {
  const ProfileContainer({super.key});

  @override
  State<ProfileContainer> createState() => _ProfileContainerState();
}

class _ProfileContainerState extends State<ProfileContainer>
    with SingleTickerProviderStateMixin {
  int _hoveredMenuIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _animation =
        Tween<double>(begin: 0, end: 2 * pi).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authstate) {
        return Stack(
          children: [
            // Animated Background Pattern
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height),
                  painter: BackgroundPatternPainter(
                    animation: _animation,
                    primaryColor:
                        AppColorPalette.primaryMaroon.withOpacity(0.03),
                    accentColor:
                        AppColorPalette.secondaryMaroon.withOpacity(0.02),
                  ),
                );
              },
            ),

            // Main Content
            AnimationLimiter(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsetsDirectional.only(
                  top: Utils.appContentTopScrollPadding(context: context) + 120,
                  end: appContentHorizontalPadding,
                  start: appContentHorizontalPadding,
                  bottom: 100,
                ),
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 600),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 30.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: <Widget>[
                      const SizedBox(height: 16),

                      // Welcome message
                      _buildWelcomeSection(context),

                      const SizedBox(height: 32),

                      _buildMenuSection(
                        context: context,
                        title: "Pengaturan Personal",
                        icon: Icons.person_outline,
                        iconColor: AppColorPalette.primaryMaroon,
                        index: 0,
                        menus: [
                          _buildMenuItem(
                            context: context,
                            icon: Icons.edit,
                            title: "Edit Profil",
                            index: 0,
                            onTap: () => Get.toNamed(Routes.editProfileScreen),
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.lock_outline,
                            title: "Ubah Kata Sandi",
                            index: 1,
                            onTap: () =>
                                Get.toNamed(Routes.changePasswordScreen),
                          ),
                        ],
                      ),

                      _buildMenuSection(
                        context: context,
                        title: "Cuti",
                        icon: Icons.event_available,
                        iconColor: AppColorPalette.secondaryMaroon,
                        index: 1,
                        menus: [
                          _buildMenuItem(
                            context: context,
                            icon: Icons.add_circle_outline,
                            title: "Ajukan Cuti",
                            index: 2,
                            onTap: () => Get.toNamed(Routes.applyLeaveScreen),
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.history,
                            title: "Riwayat Cuti Saya",
                            index: 3,
                            onTap: () => Get.toNamed(Routes.leavesScreen,
                                arguments: LeavesScreen.buildArguments(
                                    showMyLeaves: true)),
                          ),
                        ],
                      ),

                      _buildMenuSection(
                        context: context,
                        title: "Penggajian",
                        icon: Icons.account_balance_wallet,
                        iconColor: AppColorPalette.secondaryMaroon,
                        index: 2,
                        menus: [
                          _buildMenuItem(
                            context: context,
                            icon: Icons.receipt_long,
                            title: "Slip Gaji Saya",
                            index: 4,
                            onTap: () => Get.toNamed(Routes.myPayrollScreen),
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.monetization_on_outlined,
                            title: "Tunjangan & Potongan",
                            index: 5,
                            onTap: () => Get.toNamed(
                                Routes.allowancesAndDeductionsScreen),
                          ),
                        ],
                      ),

                      _buildMenuSection(
                        context: context,
                        title: "Informasi",
                        icon: Icons.info_outline,
                        iconColor: AppColorPalette.secondaryMaroon,
                        index: 3,
                        menus: [
                          _buildMenuItem(
                            context: context,
                            icon: Icons.business,
                            title: "Tentang Kami",
                            index: 6,
                            onTap: () => Get.toNamed(Routes.aboutUsScreen),
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.contact_mail,
                            title: "Hubungi Kami",
                            index: 7,
                            onTap: () => Get.toNamed(Routes.contactUsScreen),
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.privacy_tip_outlined,
                            title: "Kebijakan Privasi",
                            index: 8,
                            onTap: () =>
                                Get.toNamed(Routes.privacyPolicyScreen),
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.gavel_outlined,
                            title: "Syarat & Ketentuan",
                            index: 9,
                            onTap: () =>
                                Get.toNamed(Routes.termsAndConditionScreen),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      _buildLogoutButton(context),
                    ],
                  ),
                ),
              ),
            ),

            // Enhanced Glassmorphic AppBar
            _buildEnhancedAppBar(context: context),
          ],
        );
      },
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColorPalette.warmBeige.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColorPalette.primaryMaroon.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColorPalette.primaryMaroon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.waving_hand_rounded,
                  color: AppColorPalette.secondaryMaroon,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selamat datang,",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColorPalette.primaryMaroon.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.read<AuthCubit>().getUserDetails().firstName ??
                          "Pengguna",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColorPalette.primaryMaroon,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // const SizedBox(height: 16),
          // Row(
          //   children: [
          //     Expanded(
          //       child: _buildQuickStatCard(
          //         context,
          //         "Kehadiran Bulan Ini",
          //         "87%",
          //         Icons.calendar_today,
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: _buildQuickStatCard(
          //         context,
          //         "Cuti Tersedia",
          //         "12 hari",
          //         Icons.event_available,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(
      BuildContext context, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColorPalette.primaryMaroon.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: AppColorPalette.secondaryMaroon,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColorPalette.primaryMaroon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAppBar({required BuildContext context}) {
    return Align(
      alignment: Alignment.topCenter,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.9),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomAppbar(
                  titleKey: profileKey,
                  showBackButton: false,
                ),
                _buildProfileHeader(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getRoles(BuildContext context) {
    final roles = context.read<AuthCubit>().getUserDetails().roles ?? [];
    return roles.join(", ");
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColorPalette.warmBeige.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Hero(
                  tag: 'profile_image',
                  child: Stack(
                    children: [
                      // Glowing effect
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColorPalette.primaryMaroon.withOpacity(0.5),
                              AppColorPalette.primaryMaroon.withOpacity(0),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),

                      // Actual image
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColorPalette.primaryMaroon,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColorPalette.primaryMaroon
                                  .withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ProfileImageContainer(
                          imageUrl: context
                                  .read<AuthCubit>()
                                  .getUserDetails()
                                  .image ??
                              "",
                          heightAndWidth: 80,
                        ),
                      ),

                      // Status indicator
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          height: 18,
                          width: 18,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColorPalette.primaryMaroon
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.badge_outlined,
                              size: 14,
                              color: AppColorPalette.primaryMaroon,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${getRoles(context)}",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColorPalette.primaryMaroon,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColorPalette.primaryMaroon
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.school_outlined,
                              size: 14,
                              color: AppColorPalette.primaryMaroon,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context
                                      .read<AuthCubit>()
                                      .getUserDetails()
                                      .school
                                      ?.name ??
                                  "-",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColorPalette.primaryMaroon,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColorPalette.primaryMaroon
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.email_outlined,
                              size: 14,
                              color: AppColorPalette.primaryMaroon,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context
                                      .read<AuthCubit>()
                                      .getUserDetails()
                                      .email ??
                                  "-",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColorPalette.primaryMaroon,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required int index,
    required List<Widget> menus,
  }) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 400),
      child: SlideAnimation(
        verticalOffset: 40,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: iconColor.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              iconColor.withOpacity(0.2),
                              iconColor.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: iconColor.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: iconColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        iconColor.withOpacity(0.05),
                        iconColor.withOpacity(0.2),
                        iconColor.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
                ...menus,
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index,
    required VoidCallback onTap,
  }) {
    final isHovered = _hoveredMenuIndex == index;

    return StatefulBuilder(builder: (context, setState) {
      return MouseRegion(
        onEnter: (_) => this.setState(() => _hoveredMenuIndex = index),
        onExit: (_) => this.setState(() => _hoveredMenuIndex = -1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: isHovered
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColorPalette.primaryMaroon.withOpacity(0.05),
                      AppColorPalette.secondaryMaroon.withOpacity(0.1),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            border: isHovered
                ? Border.all(
                    color: AppColorPalette.primaryMaroon.withOpacity(0.1),
                    width: 1,
                  )
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              splashColor: AppColorPalette.primaryMaroon.withOpacity(0.1),
              highlightColor: Colors.transparent,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isHovered
                            ? AppColorPalette.primaryMaroon.withOpacity(0.1)
                            : AppColorPalette.warmBeige.withOpacity(0.5),
                        shape: BoxShape.circle,
                        boxShadow: isHovered
                            ? [
                                BoxShadow(
                                  color: AppColorPalette.primaryMaroon
                                      .withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        icon,
                        color: isHovered
                            ? AppColorPalette.primaryMaroon
                            : AppColorPalette.secondaryMaroon,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight:
                              isHovered ? FontWeight.w600 : FontWeight.w500,
                          color: isHovered
                              ? AppColorPalette.primaryMaroon
                              : AppColorPalette.secondaryMaroon,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      transform: Matrix4.translationValues(
                          isHovered ? 8.0 : 0.0, 0.0, 0.0),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: isHovered
                            ? AppColorPalette.primaryMaroon
                            : AppColorPalette.secondaryMaroon.withOpacity(0.5),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const LogoutConfirmationDialog(),
          ).then((value) {
            final logoutUser = (value as bool?) ?? false;
            if (logoutUser && context.mounted) {
              context.read<AuthCubit>().signOut();
              Get.offNamed(Routes.loginScreen);
            }
          });
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColorPalette.primaryMaroon,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              "Keluar",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  final Animation<double> animation;
  final Color primaryColor;
  final Color accentColor;

  BackgroundPatternPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Draw dots pattern
    final dotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    for (var x = 0; x < width; x += 30) {
      for (var y = 0; y < height; y += 30) {
        final offset = sin(x * 0.05 + y * 0.05 + animation.value) * 3;
        final radius = 1 + sin(x * 0.04 + y * 0.04 + animation.value) * 0.5;
        canvas.drawCircle(
          Offset(x + offset, y + offset),
          radius,
          dotPaint,
        );
      }
    }

    // Draw animated wave
    final wavePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var startY = 0; startY < height; startY += 200) {
      final path = Path();
      var startX = 0.0;
      path.moveTo(startX, startY.toDouble());

      for (var x = 0; x < width; x += 10) {
        final y = startY + sin(x * 0.02 + animation.value) * 20;
        path.lineTo(x.toDouble(), y);
      }

      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) => true;
}

class AppLanguagesBottomsheet extends StatelessWidget {
  const AppLanguagesBottomsheet({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
        titleLabelKey: changeLanguageKey,
        child: BlocBuilder<AppLocalizationCubit, AppLocalizationState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.all(appContentHorizontalPadding),
              child: Column(
                children: appLanguages
                    .map((language) => FilterSelectionTile(
                        onTap: () {
                          context
                              .read<AppLocalizationCubit>()
                              .changeLanguage(language.languageCode);
                        },
                        isSelected: state.language.languageCode ==
                            language.languageCode,
                        title: language.languageName))
                    .toList(),
              ),
            );
          },
        ));
  }
}

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const CustomTextContainer(textKey: sureToLogoutKey),
      actions: [
        CustomTextButton(
            buttonTextKey: noKey,
            textStyle: TextStyle(
              fontSize: Utils.getScaledValue(context, 15),
            ),
            onTapButton: () {
              Get.back(result: false);
            }),
        CustomTextButton(
            textStyle: TextStyle(
              color: Colors.red,
              fontSize: Utils.getScaledValue(context, 15),
            ),
            buttonTextKey: yesKey,
            onTapButton: () {
              Get.back(result: true);
            }),
      ],
    );
  }
}
