import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/announcement/notificationsCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/ui/screens/manageNotification/widgets/adminNotificationDetailsContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ManageNotificationScreen extends StatefulWidget {
  const ManageNotificationScreen({super.key});

  static Widget getRouteInstance() {
    return BlocProvider(
      create: (context) => NotificationsCubit(),
      child: ManageNotificationScreen(
        key: screenKey,
      ),
    );
  }

  static GlobalKey<ManageNotificationScreenState> screenKey =
      GlobalKey<ManageNotificationScreenState>();

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<ManageNotificationScreen> createState() =>
      ManageNotificationScreenState();
}

class ManageNotificationScreenState extends State<ManageNotificationScreen> with TickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController()
    ..addListener(scrollListener);
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );

    Future.delayed(Duration.zero, () {
      getNotifications();
      _fabAnimationController.forward();
    });
  }

  void getNotifications() {
    context.read<NotificationsCubit>().getNotifications();
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<NotificationsCubit>().hasMore()) {
        context.read<NotificationsCubit>().fetchMore();
      }
    }
  }

  Widget _buildAddNotificationFAB() {
    return context
            .read<StaffAllowedPermissionsAndModulesCubit>()
            .isPermissionGiven(permission: createNotificationPermissionKey)
        ? BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsFetchSuccess) {
                return ScaleTransition(
                  scale: _fabAnimation,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Get.toNamed(Routes.addNotificationScreen);
                    },
                    icon: const Icon(Icons.add),
                    label: Text(Utils.getTranslatedLabel(context, addNotificationKey)),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 4.0,
                  ),
                );
              }
              return const SizedBox();
            },
          )
        : const SizedBox();
  }

  Widget _buildNotificationCard(notification, int index, bool isLoading) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) {
                      // View notification details
                    },
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    icon: Icons.visibility,
                    label: Utils.getTranslatedLabel(context, viewKey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              ),
              child: Card(
                elevation: 2.0,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  title: Text(
                    notification.title ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: notification.description != null && notification.description!.isNotEmpty
                      ? Text(
                          notification.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        notification.createdAt ?? "",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Handle notification tap
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              Utils.getTranslatedLabel(context, "noNotificationsFoundKey"),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Utils.getTranslatedLabel(context, "createNewNotificationKey"),
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
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
      floatingActionButton: _buildAddNotificationFAB(),
      body: Stack(
        children: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsFetchSuccess) {
                return state.notifications.isEmpty
                    ? _buildEmptyState()
                    : Align(
                        alignment: Alignment.topCenter,
                        child: RefreshIndicator(
                          onRefresh: () async {
                            getNotifications();
                          },
                          displacement:
                              Utils.appContentTopScrollPadding(context: context) + 25,
                          child: AnimationLimiter(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.only(
                                bottom: 100,
                                top: Utils.appContentTopScrollPadding(context: context) + 25,
                                left: 16,
                                right: 16,
                              ),
                              itemCount: state.notifications.length + (context.read<NotificationsCubit>().hasMore() ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == state.notifications.length) {
                                  if (state.fetchMoreError) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: CustomTextButton(
                                          buttonTextKey: retryKey,
                                          onTapButton: () {
                                            context.read<NotificationsCubit>().fetchMore();
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    child: Center(
                                      child: CustomCircularProgressIndicator(
                                        indicatorColor: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  );
                                }
                                return _buildNotificationCard(
                                  state.notifications[index],
                                  index,
                                  false,
                                );
                              },
                            ),
                          ),
                        ),
                      );
              }

              if (state is NotificationsFetchFailure) {
                return Center(
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      getNotifications();
                    },
                  ),
                );
              }

              // Loading state
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomCircularProgressIndicator(
                      indicatorColor: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0.0, end: 1.0),