import 'dart:math';

import 'package:eschool_saas_staff/data/models/leaveRequest.dart';
import 'package:eschool_saas_staff/ui/screens/leaveRequestsScreen.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/statusWithFadedBackgroundContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class AppliedLeaveContainer extends StatelessWidget {
  final int index;
  final LeaveRequest leaveRequest;
  const AppliedLeaveContainer(
      {super.key, required this.index, required this.leaveRequest});

  @override
  Widget build(BuildContext context) {
    Color leaveStatusColor = Theme.of(context)
        .extension<CustomColors>()!
        .totalStudentOverviewBackgroundColor!;
    if (LeaveRequestStatus.approved ==
        getLeaveRequestStatusEnumFromValue(leaveRequest.status ?? 0)) {
      leaveStatusColor = Theme.of(context)
          .extension<CustomColors>()!
          .totalStaffOverviewBackgroundColor!;
    } else if (LeaveRequestStatus.pending ==
        getLeaveRequestStatusEnumFromValue(leaveRequest.status ?? 0)) {
      leaveStatusColor = Theme.of(context).colorScheme.primary;
    }
    return GestureDetector(
      onTap: () {
        Utils.showBottomSheet(
            child: AppliedLeaveDetailsBottomsheet(leaveRequest: leaveRequest),
            context: context);
      },
      child: Container(
        height: Utils().getResponsiveHeight(context, 70),
        padding: EdgeInsets.symmetric(
            vertical: appContentHorizontalPadding,
            horizontal: appContentHorizontalPadding),
        decoration: BoxDecoration(
            border: Border(
                bottom:
                    BorderSide(color: Theme.of(context).colorScheme.tertiary))),
        child: LayoutBuilder(builder: (context, boxConstraints) {
          return Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.1),
                    child: CustomTextContainer(
                      textKey: (index + 1).toString(),
                      style: TextStyle(
                          fontSize: Utils.getScaledValue(context, 14)),
                    ),
                  ),
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.47),
                    child: CustomTextContainer(
                      textKey: Utils.formatDateLeave(
                        DateTime.parse(leaveRequest.fromDate ?? ""),
                      ),
                      style: TextStyle(
                        fontSize: Utils.getScaledValue(context, 13),
                      ),
                      maxLines: 2,
                    ),
                  ),
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.43),
                    child: Row(
                      children: [
                        StatusWithFadedBackgroundContainer(
                            backgroundColor: leaveStatusColor.withValues(alpha: 0.1),
                            textColor: leaveStatusColor,
                            titleKey: getLeaveRequestStatusKey(
                                getLeaveRequestStatusEnumFromValue(
                                    leaveRequest.status ?? 0))),
                        const Spacer(),
                        Transform.rotate(
                          angle: (pi * 270) / 180,
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class AppliedLeaveDetailsBottomsheet extends StatelessWidget {
  final LeaveRequest leaveRequest;
  const AppliedLeaveDetailsBottomsheet({super.key, required this.leaveRequest});

  String translateLeaveType(String? type) {
    if (type == null) return "";

    switch (type) {
      case "Full":
        return "Sehari Penuh"; // Terjemahan ke bahasa Indonesia
      case "First Half":
        return "Paruh Pertama";
      case "Second Half":
        return "Paruh Kedua";
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
        titleLabelKey: leaveDetailsKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextContainer(
                    textKey: leaveReasonKey,
                    style: TextStyle(
                        fontSize: Utils.getScaledValue(context, 15),
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.76)),
                  ),
                  CustomTextContainer(
                    textKey: leaveRequest.reason ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: Utils.getScaledValue(context, 17)),
                  ),
                ],
              ),
            ),
            (leaveRequest.attachments?.isNotEmpty ?? false)
                ? Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: appContentHorizontalPadding),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10.0,
                        ),
                        CustomTextButton(
                          buttonTextKey: viewAttachmentsKey,
                          onTapButton: () {
                            Utils.showBottomSheet(
                                child: LeaveAttachmentsBottomsheet(
                                    files: leaveRequest.attachments!),
                                context: context);
                          },
                          textStyle: TextStyle(
                            fontSize: Utils.getScaledValue(context, 15),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      ],
                    ),
                  )
                : const SizedBox(),
            ...leaveRequest.leaveDetail
                    ?.map((leaveDetail) => ListTile(
                          subtitle: CustomTextContainer(
                            textKey: translateLeaveType(leaveDetail.type),
                            style: TextStyle(
                                fontSize: Utils.getScaledValue(context, 15)),
                          ),
                          title: CustomTextContainer(
                            textKey:
                                Utils.formatDate(DateTime.parse(leaveDetail.date!)),
                            style: TextStyle(
                                fontSize: Utils.getScaledValue(context, 15)),
                          ),
                        ))
                    .toList() ??
                [],
            const SizedBox(
              height: 25.0,
            ),
          ],
        ));
  }
}
