import 'dart:math';
import 'package:animate_do/animate_do.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/appConfigurationCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customErrorWidget.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();

  static Widget getRouteInstance() => const SplashScreen();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  final List<IconData> _schoolIcons = [
    Icons.school,
    Icons.book,
    Icons.calculate,
    Icons.edit,
    Icons.science,
    Icons.computer,
    Icons.sports_basketball,
    Icons.music_note,
  ];

  @override
  void initState() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    Future.delayed(const Duration(seconds: 0), () {
      if (mounted) {
        context.read<AppConfigurationCubit>().fetchAppConfiguration();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void navigateToNextScreen() async {
    if (context.read<AuthCubit>().state is Unauthenticated) {
      Get.offNamed(Routes.loginScreen);
    } else {
      Get.offNamed(Routes.homeScreen);
    }
  }

  Widget _buildRotatingIcons() {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(_schoolIcons.length, (index) {
        final double angle = (2 * 3.14 * index) / _schoolIcons.length;
        return AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.identity()
                ..translate(
                  120 * cos(angle + _rotationController.value * 2 * 3.14),
                  120 * sin(angle + _rotationController.value * 2 * 3.14),
                ),
              child: FadeInUp(
                duration: Duration(milliseconds: 800 + (index * 100)),
                child: Icon(
                  _schoolIcons[index],
                  size: 35,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AppConfigurationCubit, AppConfigurationState>(
        listener: (context, state) {
          if (state is AppConfigurationFetchSuccess) {
            navigateToNextScreen();
          }
        },
        builder: (context, state) {
          if (state is AppConfigurationFetchFailure) {
            return Center(
              child: CustomErrorWidget(
                message: state.errorMessage,
                onRetry: () {
                  context.read<AppConfigurationCubit>().fetchAppConfiguration();
                },
              ),
            );
          }
          return Container(
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
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildRotatingIcons(),
                  FadeInDown(
                    duration: Duration(milliseconds: 1000),
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        Utils.getImagePath("splash.jpg"),
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
