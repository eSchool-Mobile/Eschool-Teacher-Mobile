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

class ProfileContainer extends StatelessWidget {
  const ProfileContainer({super.key});

  String? getRoles(BuildContext context) {
    if (!context.read<AuthCubit>().isTeacher()) {
      return context.read<AuthCubit>().getUserDetails().getRoles();
    } else {
      return Utils.getTranslatedLabel(teacherKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, authstate) {
      return Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.only(
                  top: Utils.appContentTopScrollPadding(context: context) + 145,
                  end: appContentHorizontalPadding,
                  start: appContentHorizontalPadding,
                  bottom: 100),
              child: Column(
                children: [
                  MenusWithTitleContainer(menus: [
                    MenuTile(
                        iconImageName: "edit_profile.svg",
                        onTap: () {
                          Get.toNamed(Routes.editProfileScreen);
                        },
                        titleKey: editProfileKey),
                    MenuTile(
                        iconImageName: "change_password.svg",
                        onTap: () {
                          Get.toNamed(Routes.changePasswordScreen);
                        },
                        titleKey: changePasswordKey),
                  ], title: personalSettingsKey),
                  MenusWithTitleContainer(title: leaveKey, menus: [
                    CustomMenuTile(
                        iconImageName: "apply_leave.svg",
                        titleKey: applyLeaveKey,
                        onTap: () {
                          Get.toNamed(Routes.applyLeaveScreen);
                        }),
                    CustomMenuTile(
                        iconImageName: "my_leave.svg",
                        titleKey: myLeaveKey,
                        onTap: () {
                          Get.toNamed(Routes.leavesScreen,
                              arguments: LeavesScreen.buildArguments(
                                  showMyLeaves: true));
                        }),
                  ]),
                  MenusWithTitleContainer(title: payrollKey, menus: [
                    CustomMenuTile(
                        iconImageName: "payroll_slip.svg",
                        titleKey: myPayrollSlipsKey,
                        onTap: () {
                          Get.toNamed(Routes.myPayrollScreen);
                        }),
                    CustomMenuTile(
                        iconImageName: "allowances_and_deductions.svg",
                        titleKey: allowancesAndDeductionsKey,
                        onTap: () {
                          Get.toNamed(Routes.allowancesAndDeductionsScreen);
                        }),
                  ]),
                  MenusWithTitleContainer(menus: [
                    MenuTile(
                        iconImageName: "about_us.svg",
                        onTap: () {
                          Get.toNamed(Routes.aboutUsScreen);
                        },
                        titleKey: aboutUsKey),
                    MenuTile(
                        iconImageName: "contact_us.svg",
                        onTap: () {
                          Get.toNamed(Routes.contactUsScreen);
                        },
                        titleKey: contactUsKey),
                    MenuTile(
                        iconImageName: "privacy_policy.svg",
                        onTap: () {
                          Get.toNamed(Routes.privacyPolicyScreen);
                        },
                        titleKey: privacyPolicyKey),
                    MenuTile(
                        iconImageName: "terms_and_conditions.svg",
                        onTap: () {
                          Get.toNamed(Routes.termsAndConditionScreen);
                        },
                        titleKey: termsAndConditionKey),
                    // MenuTile(
                    //     iconImageName: "rate_us.svg",
                    //     onTap: () {
                    //       Utils.openLinkInBrowser(
                    //           url: context
                    //               .read<AppConfigurationCubit>()
                    //               .getAppLink(),
                    //           context: context);
                    //     },
                    //     titleKey: rateUsKey),
                    // MenuTile(
                    //     iconImageName: "share.svg",
                    //     onTap: () {
                    //       Utils.openLinkInBrowser(
                    //           url: context
                    //               .read<AppConfigurationCubit>()
                    //               .getAppLink(),
                    //           context: context);
                    //     },
                    //     titleKey: shareAppKey),
                  ], title: personalSettingsKey),
                  CustomRoundedButton(
                    widthPercentage: 1.0,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    borderColor: Theme.of(context).colorScheme.error,
                    buttonTitle: logoutKey,
                    titleColor: Theme.of(context).colorScheme.error,
                    showBorder: true,
                    onTap: () {
                      showDialog(
                              context: context,
                              builder: (_) => const LogoutConfirmationDialog())
                          .then((value) {
                        final logoutUser = (value as bool?) ?? false;
                        if (logoutUser) {
                          if (context.mounted) {
                            context.read<AuthCubit>().signOut();
                            Get.offNamed(Routes.loginScreen);
                          }
                        }
                      });
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                const CustomAppbar(
                  titleKey: profileKey,
                  showBackButton: false,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(appContentHorizontalPadding),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context).colorScheme.tertiary))),
                  height: Utils().getResponsiveHeight(context, 120),
                  child: Row(
                    children: [
                      ProfileImageContainer(
                        imageUrl:
                            context.read<AuthCubit>().getUserDetails().image ??
                                "",
                        heightAndWidth: 95,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextContainer(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textKey: context
                                    .read<AuthCubit>()
                                    .getUserDetails()
                                    .firstName ??
                                "-",
                            style: TextStyle(
                                fontSize: Utils.getScaledValue(context, 18),
                                fontWeight: FontWeight.w600),
                          ),
                          CustomTextContainer(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textKey:
                                "${Utils.getTranslatedLabel(roleKey)} : ${getRoles(context)}",
                            style: TextStyle(
                              height: 1.1,
                              fontSize: Utils.getScaledValue(context, 15),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          CustomTextContainer(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textKey:
                                "${context.read<AuthCubit>().getUserDetails().school?.name ?? "-"} (${context.read<AuthCubit>().getUserDetails().school?.code ?? "-"})",
                            style: TextStyle(
                              height: 1.1,
                              fontSize: Utils.getScaledValue(context, 15),
                            ),
                          )
                        ],
                      )),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      );
    });
  }
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
