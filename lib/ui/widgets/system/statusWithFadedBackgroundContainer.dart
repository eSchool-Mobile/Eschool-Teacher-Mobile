import 'package:eschool_saas_staff/ui/widgets/system/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/system/utils.dart';
import 'package:flutter/material.dart';

class StatusWithFadedBackgroundContainer extends StatelessWidget {
  final String titleKey;
  final Color backgroundColor;
  final Color textColor;
  const StatusWithFadedBackgroundContainer(
      {super.key,
      required this.backgroundColor,
      required this.textColor,
      required this.titleKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Utils().getResponsiveHeight(context, 100),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0), color: backgroundColor),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: CustomTextContainer(
        textKey: titleKey,
        maxLines: 2,
        style: TextStyle(
            color: textColor, fontSize: Utils.getScaledValue(context, 13.5)),
        textAlign: TextAlign.center,
        overflow: TextOverflow.visible,
      ),
    );
  }
}
