import 'package:eschool_saas_staff/cubits/appConfigurationCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/chatParentsUserChatHistoryCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/chatStaffsUserChatHistoryCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/chatStudentsUserChatHistoryCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/socketSettingsCubit.dart';
import 'package:eschool_saas_staff/cubits/homeScreenDataCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/data/models/bottomNavItem.dart';
import 'package:eschool_saas_staff/data/models/notificationDetails.dart';
import 'package:eschool_saas_staff/data/repositories/announcementRepository.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/academicsContainer/academicsContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/appUnderMaintenanceContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/forceUpdateDialogContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/homeContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/profileContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/teacherHomeContainer/teacherHomeContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/bottomNavItemContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/animatedBottomNavItemContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/notificationUtility.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static Widget getRouteInstance() => BlocProvider(
        create: (context) => HomeScreenDataCubit(),
        child: const HomeScreen(),
      );

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentSelectedBottomNavIndex = 0;

  //
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadTemporarilyStoredNotifications();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        NotificationUtility.setUpNotificationService();
        context
            .read<StaffAllowedPermissionsAndModulesCubit>()
            .getPermissionAndAllowedModules();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void loadTemporarilyStoredNotifications() {
    AnnouncementRepository.getTemporarilyStoredNotifications()
        .then((notifications) {
      //
      for (var notificationData in notifications) {
        AnnouncementRepository.addNotification(
            notificationDetails:
                NotificationDetails.fromJson(Map.from(notificationData)));
      }
      //
      if (notifications.isNotEmpty) {
        AnnouncementRepository.clearTemporarilyNotification();
      }

      //
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      loadTemporarilyStoredNotifications();
    }
  }

  late final List<BottomNavItem> _bottomNavItems = [
    BottomNavItem(
        iconPath: "home.svg",
        title: homeKey,
        selectedIconPath: "home_active.svg"),
    BottomNavItem(
        iconPath: "academics.svg",
        title: academicsKey,
        selectedIconPath: "academics_active.svg"),
    BottomNavItem(
        iconPath: "profile.svg",
        title: profileKey,
        selectedIconPath: "profile_active.svg"),
  ];

  void changeCurrentBottomNavIndex(int index) {
    if (_currentSelectedBottomNavIndex != index) {
      // Enhanced haptic feedback
      HapticFeedback.mediumImpact();

      // Trigger animation with spring-like effect
      setState(() {
        _currentSelectedBottomNavIndex = index;
      });

      // Add subtle screen transition animation
      if (mounted) {
        // Create a gentle spring effect when changing tabs
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            // Use a second setState to trigger another animation frame
            // This creates a more fluid transition between states
            setState(() {});
          }
        });
      }
    }
  }

  Widget _buildBottomNavigationContainer() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 90 + MediaQuery.of(context).padding.bottom * (0.5),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Glass-morphic background
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 10.0,
                  sigmaY: 10.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.9),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, -4),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // Improved Animated Background with better clipping
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: AnimatedNavBackground(
                selectedIndex: _currentSelectedBottomNavIndex,
                itemCount: _bottomNavItems.length,
              ),
            ),

            // Navigation Items Row with better integration
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:
                      List.generate(_bottomNavItems.length, (index) => index)
                          .map((index) => AnimatedBottomNavItemContainer(
                                index: index,
                                bottomNavItem: _bottomNavItems[index],
                                onTap: changeCurrentBottomNavIndex,
                                selectedBottomNavIndex:
                                    _currentSelectedBottomNavIndex,
                              ))
                          .toList(),
                ),
              ),
            ),

            // Subtle indicator line with improved animation
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCirc,
              bottom: MediaQuery.of(context).padding.bottom * (0.5) + 12,
              left: MediaQuery.of(context).size.width /
                      _bottomNavItems.length *
                      _currentSelectedBottomNavIndex +
                  (MediaQuery.of(context).size.width / _bottomNavItems.length -
                          30) /
                      2,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 30,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF7A1E23),
                  borderRadius: BorderRadius.circular(1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7A1E23).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: context.read<AppConfigurationCubit>().appUnderMaintenance()
          ? const AppUnderMaintenanceContainer()
          : BlocConsumer<StaffAllowedPermissionsAndModulesCubit,
              StaffAllowedPermissionsAndModulesState>(
              listener: (context, state) {
                if (state is StaffAllowedPermissionsAndModulesFetchSuccess) {
                  final chatModuleEnabled = context
                      .read<StaffAllowedPermissionsAndModulesCubit>()
                      .isModuleEnabled(moduleId: chatModuleId.toString());

                  if (chatModuleEnabled) {
                    final userId =
                        context.read<AuthCubit>().getUserDetails().id ?? 0;

                    context.read<SocketSettingCubit>().init(userId: userId);
                  } else {
                    setState(() {
                      _bottomNavItems.removeWhere((e) => e.title == chatKey);
                    });
                  }
                }
              },
              builder: (context, state) {
                final chatModuleEnabled = context
                    .read<StaffAllowedPermissionsAndModulesCubit>()
                    .isModuleEnabled(moduleId: chatModuleId.toString());

                return Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: IndexedStack(
                        index: _currentSelectedBottomNavIndex,
                        children: [
                          //two different containers for 2 different user types
                          if (context.read<AuthCubit>().isTeacher()) ...[
                            const TeacherHomeContainer(),
                          ] else ...[
                            HomeContainer(key: HomeContainer.widgetKey),
                          ],
                          const AcademicsContainer(),
                          const ProfileContainer(),
                        ],
                      ),
                    ),

                    if (state is StaffAllowedPermissionsAndModulesFetchSuccess)
                      _buildBottomNavigationContainer(),

                    //Check forece update here
                    context.read<AppConfigurationCubit>().forceUpdate()
                        ? FutureBuilder<bool>(
                            future: Utils.forceUpdate(
                              context
                                  .read<AppConfigurationCubit>()
                                  .getAppVersion(),
                            ),
                            builder: (context, snaphsot) {
                              if (snaphsot.hasData) {
                                return (snaphsot.data ?? false)
                                    ? const ForceUpdateDialogContainer()
                                    : const SizedBox();
                              }

                              return const SizedBox();
                            },
                          )
                        : const SizedBox(),
                  ],
                );
              },
            ),
    );
  }
}

// AnimatedNavBackground widget for the bottom navigation
class AnimatedNavBackground extends StatefulWidget {
  final int selectedIndex;
  final int itemCount;

  const AnimatedNavBackground({
    Key? key,
    required this.selectedIndex,
    required this.itemCount,
  }) : super(key: key);

  @override
  State<AnimatedNavBackground> createState() => _AnimatedNavBackgroundState();
}

class _AnimatedNavBackgroundState extends State<AnimatedNavBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _oldIndex = 0;

  @override
  void initState() {
    super.initState();
    _oldIndex = widget.selectedIndex;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 850),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuint,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedNavBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _oldIndex = oldWidget.selectedIndex;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: ModernNavBackgroundPainter(
            selectedIndex: widget.selectedIndex,
            oldIndex: _oldIndex,
            itemCount: widget.itemCount,
            animationValue: _animation.value,
            isDarkMode: isDarkMode,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

// Custom painter for the navigation background
class ModernNavBackgroundPainter extends CustomPainter {
  final int selectedIndex;
  final int oldIndex;
  final int itemCount;
  final double animationValue;
  final bool isDarkMode;

  ModernNavBackgroundPainter({
    required this.selectedIndex,
    required this.oldIndex,
    required this.itemCount,
    required this.animationValue,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final itemWidth = width / itemCount;

    // Calculate the positions for animation
    final oldPosition = itemWidth * oldIndex + itemWidth / 2;
    final newPosition = itemWidth * selectedIndex + itemWidth / 2;
    final currentPosition =
        ui.lerpDouble(oldPosition, newPosition, animationValue)!;

    // Create primary color - maroon with slight transparency
    final primaryColor = const Color(0xFF7A1E23).withOpacity(0.9);
    final accentColor = isDarkMode
        ? const Color(0xFF521518).withOpacity(0.8)
        : const Color(0xFFECD0D2).withOpacity(0.8);
    final highlightColor = isDarkMode
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.3);

    // Background base with subtle gradient
    final backgroundRect = Rect.fromLTWH(0, 0, width, height);
    final backgroundGradient = LinearGradient(
      colors: [
        isDarkMode
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.3),
        isDarkMode
            ? Colors.black.withOpacity(0.1)
            : Colors.white.withOpacity(0.1),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final backgroundPaint = Paint()
      ..shader = backgroundGradient.createShader(backgroundRect);

    // Draw the flowing liquid background
    final basePath = Path();
    basePath.moveTo(0, height);

    // Calculate wave height based on animation
    final maxHeight = height * 0.65;
    final waveHeight = maxHeight * _elasticOut(animationValue);

    // Left side of the wave - smoother curve
    basePath.quadraticBezierTo(currentPosition - itemWidth * 0.8, height,
        currentPosition - itemWidth * 0.3, height - waveHeight * 0.7);

    // Center peak of the wave - smoother transition
    basePath.quadraticBezierTo(
        currentPosition,
        height - waveHeight - 5 * sin(animationValue * 3.14),
        currentPosition + itemWidth * 0.3,
        height - waveHeight * 0.7);

    // Right side of the wave - smoother curve
    basePath.quadraticBezierTo(
        currentPosition + itemWidth * 0.8, height, width, height);

    basePath.lineTo(width, height);
    basePath.lineTo(0, height);
    basePath.close();

    // Create wave gradient that's more subtle
    final waveGradient = LinearGradient(
      colors: [
        accentColor,
        primaryColor,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final wavePaint = Paint()
      ..shader = waveGradient.createShader(backgroundRect);

    // Draw shadow for depth effect
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final shadowPath = Path.from(basePath);
    final shiftedShadowPath = shadowPath.shift(const Offset(0, 4));
    canvas.drawPath(shiftedShadowPath, shadowPaint);

    // Draw the main wave
    canvas.drawPath(basePath, wavePaint);

    // Add glow effect around active item
    final glowPaint = Paint()
      ..color = isDarkMode
          ? primaryColor.withOpacity(0.2)
          : Colors.white.withOpacity(0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawCircle(Offset(currentPosition, height - waveHeight * 0.8),
        itemWidth * 0.25 * animationValue, glowPaint);

    // Add particles effect for more dynamic feel
    final particlePaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 3.14 * 2;
      final particleDistance =
          12 * animationValue * (0.5 + 0.5 * sin(animationValue * 5 + i));
      final particleSize = 1.0 + (i % 3) * 0.7 * animationValue;

      final x = currentPosition + cos(angle) * particleDistance;
      final y = height - waveHeight * 0.8 - sin(angle) * particleDistance;

      canvas.drawCircle(Offset(x, y), particleSize, particlePaint);
    }
  }

  // Custom elastic out curve function for nicer animation
  double _elasticOut(double t) {
    return sin(-13 * (t + 1) * 3.14 / 2) * pow(2, -10 * t) + 1;
  }

  @override
  bool shouldRepaint(ModernNavBackgroundPainter oldDelegate) =>
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.animationValue != animationValue;
}
