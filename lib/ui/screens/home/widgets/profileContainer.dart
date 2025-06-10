import 'dart:math';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/appLocalizationCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/menuTile.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/menusWithTitleContainer.dart';
import 'package:eschool_saas_staff/ui/screens/leaves/leavesScreen.dart';
import 'package:eschool_saas_staff/ui/screens/login/widgets/schoolListScreen.dart';
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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:animate_do/animate_do.dart';
import 'package:eschool_saas_staff/utils/colorPalette.dart';
import 'dart:ui';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  // Maroon color palette for app bar
  final Color maroonPrimary = const Color(0xFF800020); // Deep maroon
  final Color maroonLight = const Color(0xFFAA6976); // Light maroon
  final Color maroonDark =
      const Color.fromARGB(255, 124, 9, 31); // Darker variant

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _animation =
        Tween<double>(begin: 0, end: 2 * pi).animate(_animationController);

    // Set system UI overlay style for status bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
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
                  top: Utils.appContentTopScrollPadding(context: context) +
                      180, // Increased top padding to accommodate new app bar
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
                      const SizedBox(height: 8),

                      // // Welcome message
                      // _buildWelcomeSection(context),

                      // const SizedBox(height: 32),

                      _buildMenuSection(
                        context: context,
                        title: "Pengaturan Personal",
                        icon: Icons.person_outline,
                        iconColor: Color(0xFF8B0000).withOpacity(0.9),
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
                        iconColor: Color(0xFF8B0000).withOpacity(0.9),
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
                        iconColor: Color(0xFF8B0000).withOpacity(0.9),
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
                        iconColor: Color(0xFF8B0000).withOpacity(0.9),
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

                      _buildMenuSection(
                        context: context,
                        title: "Sekolah",
                        icon: Icons.school_outlined,
                        iconColor: Color(0xFF8B0000).withOpacity(0.9),
                        index: 4,
                        menus: [
                          _buildMenuItem(
                            context: context,
                            icon: Icons.swap_horiz,
                            title: "Pindah Sekolah",
                            index: 10,
                            onTap: () async {
                              final authCubit = context.read<AuthCubit>();
                              final userDetails = authCubit.getUserDetails();
                              print('=== DEBUG PINDAH SEKOLAH ===');
                              print('UserDetails: ${userDetails.toJson()}');

                              final schoolsData =
                                  await authCubit.getSchoolsData();
                              print(
                                  'Schools data from AuthCubit: $schoolsData');
                              print(
                                  'Schools data type: ${schoolsData.runtimeType}');
                              print(
                                  'Schools data length: ${schoolsData.length}');

                              final userData = {
                                'data': {
                                  'first_name': userDetails.firstName,
                                  'last_name': userDetails.lastName,
                                  'email': userDetails.email,
                                  'mobile': userDetails.mobile,
                                  'image': userDetails.image,
                                  'id': userDetails.id,
                                  'schools': schoolsData,
                                },
                              };
                              print('Final userData created: $userData');
                              Get.to(
                                  () => SchoolListScreen(userData: userData));
                            },
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

            // Enhanced Curved App Bar
            _buildDramaticCurvedAppBar(context: context),
          ],
        );
      },
    );
  }

  // Widget _buildWelcomeSection(BuildContext context) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [
  //           Colors.white,
  //           AppColorPalette.warmBeige.withOpacity(0.4),
  //         ],
  //       ),
  //       borderRadius: BorderRadius.circular(24),
  //       boxShadow: [
  //         BoxShadow(
  //           color: AppColorPalette.primaryMaroon.withOpacity(0.05),
  //           blurRadius: 15,
  //           offset: const Offset(0, 8),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(10),
  //               decoration: BoxDecoration(
  //                 color: AppColorPalette.primaryMaroon.withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: Icon(
  //                 Icons.waving_hand_rounded,
  //                 color: Color(0xFF8B0000).withOpacity(0.9),
  //                 size: 22,
  //               ),
  //             ),
  //             const SizedBox(width: 14),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     "Selamat datang,",
  //                     style: GoogleFonts.poppins(
  //                       fontSize: 15,
  //                       fontWeight: FontWeight.w500,
  //                       color:
  //                           Colors.black.withOpacity(0.7), // Changed to black
  //                     ),
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Text(
  //                     context.read<AuthCubit>().getUserDetails().firstName ??
  //                         "Pengguna",
  //                     style: GoogleFonts.poppins(
  //                       fontSize: 24,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.black, // Changed to black
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
                          color: Colors.black, // Changed to black
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
                              ? Colors.black
                              : Colors.black
                                  .withOpacity(0.8), // Changed to black
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

  Widget _buildDramaticCurvedAppBar({required BuildContext context}) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 200 +
            MediaQuery.of(context)
                .padding
                .top, // Increased height to accommodate profile info
        width: MediaQuery.of(context).size.width,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            // Background with dramatically curved bottom
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

            // Static decorative elements
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

            // App bar title
            Positioned(
              top: MediaQuery.of(context).padding.top + 15,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Profil",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Profile card
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Container(
                height: 100,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                child: _buildProfileInfo(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context) {
    return Row(
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
            radius: 35,
            backgroundImage:
                (context.read<AuthCubit>().getUserDetails().image ?? "")
                        .isNotEmpty
                    ? CachedNetworkImageProvider(
                        context.read<AuthCubit>().getUserDetails().image ?? "",
                      )
                    : null,
            child:
                (context.read<AuthCubit>().getUserDetails().image ?? "").isEmpty
                    ? Icon(
                        Icons.person,
                        color: maroonPrimary,
                        size: 40,
                      )
                    : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.read<AuthCubit>().getUserDetails().firstName ??
                    "Pengguna",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: maroonPrimary,
                  height: 1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: maroonPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.school_outlined,
                      size: 14,
                      color: maroonPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.read<AuthCubit>().getUserDetails().school?.name ??
                          "-",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: maroonPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.email_outlined,
                      size: 14,
                      color: maroonPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.read<AuthCubit>().getUserDetails().email ?? "-",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: FadeInUp(
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                AppColorPalette.warmBeige.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColorPalette.primaryMaroon.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Illustration
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(bottom: 20),
                child: Lottie.network(
                  'https://assets3.lottiefiles.com/packages/lf20_ryltkdmr.json',
                  // Fallback if network fails
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.logout_rounded,
                    size: 60,
                    color: AppColorPalette.primaryMaroon,
                  ),
                ),
              ),

              // Title
              Text(
                "Konfirmasi Keluar",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColorPalette.primaryMaroon,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Message
              Text(
                "Apakah Anda yakin ingin keluar dari aplikasi?",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: false),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Batal",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Confirm button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColorPalette.primaryMaroon,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Keluar",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for dramatically curved gradient background
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
    path.lineTo(0, size.height - 60);

    // First dramatic curve
    final firstControlPoint = Offset(size.width * 0.25, size.height + 30);
    final firstEndPoint = Offset(size.width * 0.5, size.height - 40);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    // Second dramatic curve
    final secondControlPoint = Offset(size.width * 0.75, size.height - 110);
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
    path.cubicTo(size.width * 0.65, size.height * -0.2, size.width * 0.85,
        size.height * 0.4, size.width, size.height * 0.3);

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
