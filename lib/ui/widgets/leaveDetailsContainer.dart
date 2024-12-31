import 'package:eschool_saas_staff/data/models/leaveDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
// import 'package:eschool_saas_staff/ui/widgets/textWithFadedBackgroundContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class LeaveDetailsContainer extends StatelessWidget {
  final LeaveDetails leaveDetails;
  const LeaveDetailsContainer({super.key, required this.leaveDetails});

  String translateRole(String role) {
    final Map<String, String> roleTranslations = {
      "Teacher": "Guru",
    };

    return roleTranslations[role] ?? role;
  }

  String translateLeaveType(String leaveType) {
    final Map<String, String> leaveTranslations = {
      "Full": "Sehari Penuh",
      "First Half": "Setengah Pertama",
      "Second Half": "Setengah Kedua",
    };
    String translated = leaveTranslations[leaveType] ?? leaveType ?? '';
    print("Translating $leaveType to $translated");
    return translated;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
        padding: EdgeInsets.symmetric(
            horizontal: appContentHorizontalPadding,
            vertical: appContentHorizontalPadding),
        width: double.maxFinite,
        // height: 140,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.5),
            color: Theme.of(context).scaffoldBackgroundColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomTextContainer(
                  textKey: translateLeaveType(leaveDetails.type ?? ""),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: Utils.getScaledValue(context, 15),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                CustomTextContainer(
                    textKey: leaveDetails.leaveDate ?? "",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: Utils.getScaledValue(context, 15),
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
            // const SizedBox(height: 10),
            const Divider(),
            Row(
              children: [
                ProfileImageContainer(
                  imageUrl: leaveDetails.leave?.user?.image ?? "",
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextContainer(
                        textKey: leaveDetails.leave?.user?.firstName ?? "",
                        style: TextStyle(
                            fontSize: Utils.getScaledValue(context, 17),
                            fontWeight: FontWeight.bold),
                      ),
                      CustomTextContainer(
                        textKey:
                            "${Utils.getTranslatedLabel(roleKey)} : ${translateRole(leaveDetails.leave?.user?.roles?.first.name ?? "")}",
                        style: TextStyle(
                          fontSize: Utils.getScaledValue(context, 15),
                          // fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
