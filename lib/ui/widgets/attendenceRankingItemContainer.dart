import 'package:eschool_saas_staff/data/models/attendanceRanking.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class AttendanceRankingItemContainer extends StatefulWidget {
  final TopStudents topStudents;
  final int index;
  // final Function(ClassSection) onDownload;

  const AttendanceRankingItemContainer({
    super.key,
    required this.topStudents,
    required this.index,
  });

  @override
  State<AttendanceRankingItemContainer> createState() =>
      _AttendanceRankingItemContainerState();
}

class _AttendanceRankingItemContainerState
    extends State<AttendanceRankingItemContainer> {
  @override
  Widget build(BuildContext context) {
    final border = BorderSide(color: Theme.of(context).colorScheme.tertiary);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: Utils().getResponsiveHeight(context, 80),
      padding: EdgeInsets.symmetric(
          horizontal: appContentHorizontalPadding, vertical: 10),
      decoration: BoxDecoration(
          border: Border(left: border, bottom: border, right: border)),
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return Row(
          children: [
            SizedBox(
              width: boxConstraints.maxWidth * (0.025),
            ),
            SizedBox(
              width: boxConstraints.maxWidth * (0.12),
              child: CustomTextContainer(
                textKey: widget.topStudents.rank?.toString() ?? "-",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: Utils.getScaledValue(context, 15),
                    fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(
              width: boxConstraints.maxWidth * (0.425),
              child: Container(
                padding: EdgeInsets.all(10),
                child: CustomTextContainer(
                  textKey: widget.topStudents.studentName?.toString() ?? "-",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: Utils.getScaledValue(context, 15),
                      fontWeight: FontWeight.w400),
                  maxLines: 5,
                ),
              ),
            ),
            SizedBox(
              width: boxConstraints.maxWidth * (0.25),
              child: CustomTextContainer(
                textAlign: TextAlign.center,
                textKey: widget.topStudents.className?.toString() ?? "-",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: Utils.getScaledValue(context, 15),
                    fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(
              width: boxConstraints.maxWidth * (0.18),
              child: CustomTextContainer(
                textAlign: TextAlign.center,
                textKey: (widget.topStudents.point != null &&
                        double.parse(widget.topStudents.point!) == 0.0)
                    ? "0"
                    : widget.topStudents.point?.toString() ?? "-",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: Utils.getScaledValue(context, 15),
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      }),
    );
  }
}
