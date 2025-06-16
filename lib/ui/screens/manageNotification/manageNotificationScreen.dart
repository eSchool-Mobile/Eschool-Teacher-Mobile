import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/announcement/notificationsCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
// import 'package:eschool_saas_staff/data/models/notification.dart';
import 'package:eschool_saas_staff/data/models/notificationDetails.dart';
import 'package:eschool_saas_staff/ui/screens/manageNotification/widgets/adminNotificationDetailsContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customErrorWidget.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

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

class ManageNotificationScreenState extends State<ManageNotificationScreen>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController()
    ..addListener(scrollListener);

  late AnimationController _fabAnimationController;
  final Color _maroonPrimary = const Color(0xFF800020);
  final Color _maroonLight = const Color(0xFFAA6976);
  bool _isSearchActive = false;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    Future.delayed(Duration.zero, () {
      getNotifications();
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
    _searchController.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<NotificationsCubit>().hasMore()) {
        context.read<NotificationsCubit>().fetchMore();
      }
    }

    // Animate FAB based on scroll
    if (_scrollController.offset > 50) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  Widget _buildAddNotificationButton() {
    return context
            .read<StaffAllowedPermissionsAndModulesCubit>()
            .isPermissionGiven(permission: createNotificationPermissionKey)
        ? BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsFetchSuccess) {
                return AnimatedBuilder(
                  animation: _fabAnimationController,
                  builder: (context, child) {
                    // Scale FAB from the bottom
                    return ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 0.0)
                          .animate(CurvedAnimation(
                        parent: _fabAnimationController,
                        curve: Curves.easeInOut,
                      )),
                      child: child,
                    );
                  },
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.all(appContentHorizontalPadding),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.white,
                            Colors.white,
                          ],
                        ),
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: 90,
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _maroonPrimary,
                              _maroonLight,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: _maroonPrimary.withOpacity(0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            highlightColor: Colors.white.withOpacity(0.1),
                            splashColor: Colors.white.withOpacity(0.2),
                            onTap: () {
                              Get.toNamed(Routes.addNotificationScreen);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    Utils.getTranslatedLabel(
                                        addNotificationKey),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              return const SizedBox();
            },
          )
        : const SizedBox();
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isSearchActive ? 56 : 0,
      curve: Curves.easeInOut,
      child: _isSearchActive
          ? Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari notifikasi...',
                  prefixIcon: Icon(Icons.search, color: _maroonLight),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close, color: _maroonLight),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = "";
                        _isSearchActive = false;
                      });
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            )
          : SizedBox.shrink(),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 80),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kelola Notifikasi',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _maroonPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola semua notifikasi yang dikirim ke pengguna',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.1, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: MediaQuery.of(context).padding.top + 80,
        child: Stack(
          children: [
            // Fancy gradient background with animated particles
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _fabAnimationController,
                builder: (context, _) {
                  return ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF690013),
                          _maroonPrimary,
                          Color(0xFFA12948),
                          _maroonLight,
                        ],
                        stops: [0.0, 0.3, 0.6, 1.0],
                        transform: GradientRotation(
                            _fabAnimationController.value * 0.02),
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF800020),
                            Color(0xFF9A1E3C),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Decorative design elements
            Positioned.fill(
              child: CustomPaint(
                painter: AppBarDecorationPainter(
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),

            // Animated glowing effect
            AnimatedBuilder(
              animation: _fabAnimationController,
              builder: (context, _) {
                return Positioned(
                  top: -100 + (_fabAnimationController.value * 20),
                  right: -60 + (_fabAnimationController.value * 10),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.0),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Main app bar content with frosted glass effect
            Positioned(
              bottom: 10,
              left: 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Back button with ripple effect
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              highlightColor: Colors.white.withOpacity(0.1),
                              splashColor: Colors.white.withOpacity(0.2),
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                            .slideX(begin: -0.3, end: 0),

                        // Animated divider
                        Container(
                          height: 24,
                          width: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.4),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),

                        // Title with animated badge
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Main title
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Animated icon
                                    AnimatedBuilder(
                                      animation: _fabAnimationController,
                                      builder: (context, child) {
                                        return Transform.rotate(
                                          angle: _fabAnimationController.value *
                                              0.05,
                                          child: Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.white.withOpacity(0.9),
                                                  Colors.white.withOpacity(0.4),
                                                ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.notifications_active,
                                              color: _maroonPrimary,
                                              size: 20,
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    SizedBox(width: 12),

                                    // Title text with glowing effect
                                    ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white,
                                            Colors.white.withOpacity(0.9),
                                          ],
                                        ).createShader(bounds);
                                      },
                                      blendMode: BlendMode.srcIn,
                                      child: Text(
                                        'Kelola Notifikasi',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 1),
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Animated divider
                        Container(
                          height: 24,
                          width: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.4),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),

                        // Search button with interactive animation
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              highlightColor: Colors.white.withOpacity(0.1),
                              splashColor: Colors.white.withOpacity(0.2),
                              onTap: () {
                                setState(() {
                                  _isSearchActive = !_isSearchActive;
                                  if (!_isSearchActive) {
                                    _searchController.clear();
                                    _searchQuery = "";
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: _isSearchActive
                                      ? Border.all(
                                          color: Colors.white.withOpacity(0.4),
                                          width: 1.5,
                                        )
                                      : null,
                                ),
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 400),
                                  transitionBuilder: (Widget child,
                                      Animation<double> animation) {
                                    return RotationTransition(
                                      turns: Tween<double>(begin: 0.5, end: 1.0)
                                          .animate(animation),
                                      child: ScaleTransition(
                                        scale: animation,
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      ),
                                    );
                                  },
                                  child: _isSearchActive
                                      ? Icon(
                                          Icons.close_rounded,
                                          key: ValueKey<bool>(true),
                                          color: Colors.white,
                                          size: 22,
                                        )
                                      : Icon(
                                          Icons.search_rounded,
                                          key: ValueKey<bool>(false),
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                            .slideX(begin: 0.3, end: 0),
                      ],
                    ),
                  ),
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
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsFetchSuccess) {
                // Filter notifications based on search query if active
                final notifications = _searchQuery.isEmpty
                    ? state.notifications
                    : state.notifications
                        .where((notification) =>
                            (notification.title ?? "")
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ||
                            (notification.message ?? "")
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()))
                        .toList();

                return Align(
                  alignment: Alignment.topCenter,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      getNotifications();
                    },
                    color: _maroonPrimary,
                    displacement:
                        Utils.appContentTopScrollPadding(context: context) + 25,
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildSearchBar(),
                        Expanded(
                          child: notifications.isEmpty &&
                                  _searchQuery.isNotEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Notifikasi tidak ditemukan',
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(delay: 300.ms)
                              : ListView(
                                  controller: _scrollController,
                                  padding: EdgeInsets.only(
                                    bottom: 100,
                                    top: 0,
                                  ),
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          // Header Row
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: _maroonPrimary
                                                  .withOpacity(0.08),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                topRight: Radius.circular(16),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 40,
                                                  child: Text(
                                                    "#",
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                      color: _maroonPrimary,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    Utils.getTranslatedLabel(
                                                        nameKey),
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                      color: _maroonPrimary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Notification Items
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(16),
                                                bottomRight:
                                                    Radius.circular(16),
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: Column(
                                              children: _buildNotificationItems(
                                                  notifications, state),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (state is NotificationsFetchFailure) {
                return Center(
                  child: CustomErrorWidget(
                    message: state.errorMessage,
                    onRetry: () {
                      getNotifications();
                    },
                    primaryColor: _maroonPrimary,
                  ),
                );
              }

              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomCircularProgressIndicator(
                      indicatorColor: _maroonPrimary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Memuat notifikasi...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms);
            },
          ),
          _buildAddNotificationButton(),
          _buildAppBar(),
        ],
      ),
    );
  }

  List<Widget> _buildNotificationItems(List<NotificationDetails> notifications,
      NotificationsFetchSuccess state) {
    List<Widget> items = [];

    for (int index = 0; index < notifications.length; index++) {
      // Add notification item with animation
      items.add(
        Container(
          margin: EdgeInsets.only(
            bottom: index == notifications.length - 1 ? 0 : 1,
          ),
          child: AdminNotificationDetailsContainer(
            notificationDetails: notifications[index],
            index: index,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: (50 * index).ms).slideY(
              begin: 0.1,
              end: 0,
              curve: Curves.easeOutQuad,
              duration: 500.ms,
              delay: (50 * index).ms,
            ),
      );

      // Add 'load more' indicator or error if it's the last item
      if (context.read<NotificationsCubit>().hasMore() &&
          index == notifications.length - 1) {
        if (state.fetchMoreError) {
          items.add(
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: CustomTextButton(
                  buttonTextKey: retryKey,
                  onTapButton: () {
                    context.read<NotificationsCubit>().fetchMore();
                  },
                ),
              ),
            ),
          );
        } else {
          items.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _maroonPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(_maroonPrimary),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return items;
  }
}

// Custom painter for decorative elements
class AppBarDecorationPainter extends CustomPainter {
  final Color color;

  AppBarDecorationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.2), 30, paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), 20, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.15), 15, paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), 10, paint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.4), 8, paint);

    // Draw arc
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final arcRect = Rect.fromLTRB(size.width * 0.1, size.height * 0.2,
        size.width * 0.6, size.height * 0.6);
    canvas.drawArc(arcRect, 0.2, 1.5, false, arcPaint);

    // Draw another arc
    final arcRect2 = Rect.fromLTRB(size.width * 0.5, size.height * 0.4,
        size.width * 0.9, size.height * 0.8);
    canvas.drawArc(arcRect2, 3, 1.5, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
