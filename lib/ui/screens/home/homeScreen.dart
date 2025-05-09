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
// import 'package:eschool_saas_staff/ui/screens/home/widgets/chatContainer/chatContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/forceUpdateDialogContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/homeContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/profileContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/teacherHomeContainer/teacherHomeContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/animatedBottomNavigation.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/notificationUtility.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    setState(() {
      _currentSelectedBottomNavIndex = index;
    });
  }

  Widget _buildBottomNavigationContainer() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 140 + MediaQuery.of(context).padding.bottom * (0.5),
        color: Colors.transparent,
        child: AnimatedBottomNavigation(
          items: _bottomNavItems,
          selectedIndex: _currentSelectedBottomNavIndex,
          onItemSelected: changeCurrentBottomNavIndex,
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
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 120),
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
                            if (chatModuleEnabled) const ProfileContainer(),
                          ],
                        ),
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
