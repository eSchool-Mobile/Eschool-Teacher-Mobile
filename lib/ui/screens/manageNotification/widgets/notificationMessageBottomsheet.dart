import 'package:eschool_saas_staff/ui/widgets/system/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/system/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/system/constants.dart';
import 'package:eschool_saas_staff/utils/system/labelKeys.dart';
import 'package:flutter/material.dart';

class NotificationMessageBottomsheet extends StatelessWidget {
  final String text;
  const NotificationMessageBottomsheet({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
        titleLabelKey: messageKey,
        child: Padding(
          padding: EdgeInsets.all(appContentHorizontalPadding),
          child: CustomTextContainer(textKey: text),
        ));
  }
}
