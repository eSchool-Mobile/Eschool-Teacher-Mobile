import 'package:eschool_saas_staff/ui/widgets/system/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/system/utils.dart';
import 'package:flutter/material.dart';

class DateWithFadedBackgroundContainer extends StatelessWidget {
  final String titleKey;
  final Color backgroundColor;
  final Color textColor;
  const DateWithFadedBackgroundContainer(
      {super.key,
      required this.backgroundColor,
      required this.textColor,
      required this.titleKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Utils().getResponsiveHeight(context, 115),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0), color: backgroundColor),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: CustomTextContainer(
        textKey: titleKey,
        maxLines: 2,
        style: TextStyle(
            color: textColor, fontSize: Utils.getScaledValue(context, 15.0)),
        textAlign: TextAlign.center,
        overflow: TextOverflow.visible,
      ),
    );
  }
}
