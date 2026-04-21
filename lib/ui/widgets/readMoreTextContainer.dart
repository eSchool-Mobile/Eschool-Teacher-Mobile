import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class ReadMoreTextContainer extends StatelessWidget {
  final String text;
  final int? trimLines;
  final TextStyle? textStyle;
  final TextStyle? showMoreTextStyle;
  final TextStyle? showLessTextStyle;
  const ReadMoreTextContainer(
      {super.key,
      required this.text,
      this.textStyle,
      this.trimLines,
      this.showLessTextStyle,
      this.showMoreTextStyle});

  @override
  Widget build(BuildContext context) {
    final TextStyle showMoreAndReadLessTextStyle = TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        fontSize: Utils.getScaledValue(context, 11),
        fontWeight: FontWeight.bold);
    return ReadMoreText(
      text,
      trimLines: trimLines ?? 3,
      trimMode: TrimMode.Line,
      trimCollapsedText: 'lebih banyak',
      trimExpandedText: '  lebih sedikit',
      style: textStyle ??
          TextStyle(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.75)),
      lessStyle: showLessTextStyle ?? showMoreAndReadLessTextStyle,
      moreStyle: showMoreTextStyle ?? showMoreAndReadLessTextStyle,
    );
  }
}
