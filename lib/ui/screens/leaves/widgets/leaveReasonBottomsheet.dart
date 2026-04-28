import 'package:eschool_saas_staff/ui/widgets/system/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/system/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/system/constants.dart';
import 'package:eschool_saas_staff/utils/system/labelKeys.dart';
import 'package:flutter/material.dart';

class LeaveReasonBottomsheet extends StatelessWidget {
  final String reason;
  const LeaveReasonBottomsheet({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
        titleLabelKey: leaveReasonKey,
        child: Container(
          padding: EdgeInsets.all(appContentHorizontalPadding),
          child: CustomTextContainer(textKey: reason),
        ));
  }
}
