import 'package:eschool_saas_staff/ui/widgets/system/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/system/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuTile extends StatelessWidget {
  final String titleKey;
  final String iconImageName;
  final Function onTap;
  final double? iconPadding;
  const MenuTile(
      {super.key,
      required this.iconImageName,
      required this.onTap,
      required this.titleKey,
      this.iconPadding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: () {
          onTap.call();
        },
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.all(iconPadding ?? 15),
              child: SvgPicture.asset(
                Utils.getImagePath(iconImageName),
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary, BlendMode.srcIn),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: CustomTextContainer(
                textKey: titleKey,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: Utils.getScaledValue(context, 16.5),
                    fontWeight: FontWeight.w500),
              ),
            ),
            CircleAvatar(
              radius: 15.0,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Directionality.of(context).name == TextDirection.rtl.name
                    ? CupertinoIcons.arrow_left
                    : CupertinoIcons.arrow_right,
                size: 17.5,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          ],
        ),
      ),
    );
  }
}
