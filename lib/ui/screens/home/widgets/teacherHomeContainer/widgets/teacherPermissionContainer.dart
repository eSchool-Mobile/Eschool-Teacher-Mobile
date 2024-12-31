import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/homeScreenDataCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/contentTitleWithViewmoreButton.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/teacherHomeContainer/widgets/roundedBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
// import 'package:eschool_saas_staff/ui/widgets/leaveDetailsContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/permissionDetailsContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TeacherPermissionContainer extends StatelessWidget {
  const TeacherPermissionContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    final todaysPermission =
        context.read<HomeScreenDataCubit>().getTodayPermission();
    return RoundedBackgroundContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContentTitleWithViewMoreButton(
            contentTitleKey: permissionStudentKey,
            showViewMoreButton: true,
            viewMoreOnTap: () {
              Get.toNamed(Routes.generalPermissionScreen);
            },
          ),
          const SizedBox(
            height: 15,
          ),
          todaysPermission.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: appContentHorizontalPadding),
                  child: CustomTextContainer(
                    textKey: noStudentPermissionKey,
                    style: TextStyle(
                      fontSize:
                          Utils.getScaledValue(context, 11.5) / textScaleFactor,
                    ),
                  ),
                )
              : Column(
                  children: [
                    PermissionDetailsContainer(
                      permissionDetails: todaysPermission[0],
                      overflow: true,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    todaysPermission.length > 2
                        ? PermissionDetailsContainer(
                            permissionDetails: todaysPermission[1],
                            overflow: true,
                          )
                        : const SizedBox(),
                  ],
                ),
        ],
      ),
    );
  }
}
