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
                  // Subtle texture pattern
                  child: CustomPaint(
                    painter: PatternPainter(
                      color: const Color(0xFF7A1E23).withOpacity(0.03),
                    ),
                  ),
                ),
              ),
            ),

            // Subtle Top Highlight
            Positioned(
              top: 0,
              left: 20,
              right: 20,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Navigation Items Row
            Positioned(
              top: 0,
              left: 0,
              right: 0,
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

            // Animated indicator line
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              bottom: MediaQuery.of(context).padding.bottom * (0.5) + 15,
              left: MediaQuery.of(context).size.width /
                      _bottomNavItems.length *
                      _currentSelectedBottomNavIndex +
                  (MediaQuery.of(context).size.width / _bottomNavItems.length -
                          40) /
                      2,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF7A1E23),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7A1E23).withOpacity(0.4),
                      blurRadius: 6,
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

// Add this custom painter class at the bottom of your file
class PatternPainter extends CustomPainter {
  final Color color;

  PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Create a modern pattern with subtle diagonal lines
    final spacing = 25.0;

    for (double i = -50; i < size.width + 50; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + 100, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
