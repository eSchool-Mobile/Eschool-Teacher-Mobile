import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class RecapAttendanceItemContainer extends StatefulWidget {
  final ClassSection classSection;
  final int index;
  final Function(ClassSection) onDownload;

  const RecapAttendanceItemContainer({
    super.key,
    required this.classSection,
    required this.index,
    required this.onDownload,
  });

  @override
  State<RecapAttendanceItemContainer> createState() =>
      _StudentSubjectAttendanceItemContainerState();
}

class _StudentSubjectAttendanceItemContainerState
    extends State<RecapAttendanceItemContainer> {
  final DateTime _selectedDateTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final border = BorderSide(color: Theme.of(context).colorScheme.tertiary);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: Utils().getResponsiveHeight(context, 75),
      padding: EdgeInsets.symmetric(
          horizontal: appContentHorizontalPadding, vertical: 10),
      decoration: BoxDecoration(
          border: Border(left: border, bottom: border, right: border)),
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return Row(
          children: [
            SizedBox(
              width: boxConstraints.maxWidth * (0.01),
            ),
            SizedBox(
              width: boxConstraints.maxWidth * (0.33),
              child: CustomTextContainer(
                textKey: widget.classSection.name.toString(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: Utils.getScaledValue(context, 15),
                    fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(
              width: boxConstraints.maxWidth * (0.4),
              child: CustomTextContainer(
                textKey: Utils.getMonthFullName(_selectedDateTime.month),
                style: TextStyle(
                    fontSize: Utils.getScaledValue(context, 15),
                    fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(
              child: CustomTextButton(
                buttonTextKey: 'Unduh',
                icon: Icon(
                  Icons.file_download,
                  color: Theme.of(context).colorScheme.primary,
                  size: 25,
                ),
                textStyle: TextStyle(
                  fontSize: Utils.getScaledValue(context, 12),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTapButton: () {
                  widget.onDownload(widget.classSection);
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
