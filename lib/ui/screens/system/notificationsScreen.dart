import 'package:eschool_saas_staff/cubits/announcement/localNotificationsCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/system/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/system/customModernAppBar.dart';
import 'package:eschool_saas_staff/ui/widgets/system/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/system/notificationItemContainer.dart';
import 'package:eschool_saas_staff/utils/system/labelKeys.dart';
import 'package:eschool_saas_staff/utils/system/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return BlocProvider(
      create: (context) => LocalNotificationsCubit(),
      child: const NotificationsScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<LocalNotificationsCubit>().getLocalNotifications();
      }
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomModernAppBar(
        title: Utils.getTranslatedLabel(notificationsKey),
        icon: Icons.notifications,
        fabAnimationController: _fabAnimationController,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: BlocBuilder<LocalNotificationsCubit, LocalNotificationsState>(
        builder: (context, state) {
          if (state is LocalNotificationsFetchSuccess) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 25,
              ),
              child: Column(
                children: state.notifications
                    .map((notificationDetails) => NotificationItemContainer(
                          notificationDetails: notificationDetails,
                        ))
                    .toList(),
              ),
            );
          }

          if (state is LocalNotificationsFetchFailure) {
            return Center(
              child: ErrorContainer(
                errorMessage: state.errorMessage,
                onTapRetry: () {
                  context
                      .read<LocalNotificationsCubit>()
                      .getLocalNotifications();
                },
              ),
            );
          }

          return Center(
            child: CustomCircularProgressIndicator(
              indicatorColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }
}
