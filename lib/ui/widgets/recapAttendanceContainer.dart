import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/recapAttendenceItemContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class RecapAttendanceContainer extends StatefulWidget {
  final List<ClassSection> classSections;
  final Function(ClassSection) onDownload;

  const RecapAttendanceContainer({
    super.key,
    required this.classSections,
    required this.onDownload,
  });

  @override
  State<RecapAttendanceContainer> createState() =>
      _SubjectAttendanceContainerState();
}

class _SubjectAttendanceContainerState extends State<RecapAttendanceContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(appContentHorizontalPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: Utils().getResponsiveHeight(context, 45),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(5.0),
                    topLeft: Radius.circular(5.0)),
                color: Theme.of(context).colorScheme.tertiary),
            padding: EdgeInsets.symmetric(
                horizontal: appContentHorizontalPadding, vertical: 10),
            child: LayoutBuilder(builder: (context, boxConstraints) {
              TextStyle titleStyle = TextStyle(
                  fontSize: Utils.getScaledValue(context, 15),
                  fontWeight: FontWeight.w600);
              return Row(
                children: [
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.03),
                  ),
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.35),
                    child: CustomTextContainer(
                      textKey: "Kelas",
                      style: titleStyle,
                    ),
                  ),
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.45),
                    child: CustomTextContainer(
                        textKey: "Bulan", style: titleStyle),
                  ),
                  SizedBox(
                    // width: boxConstraints.maxWidth * (0.),
                    child: CustomTextContainer(
                      textKey: "File",
                      style: titleStyle,
                    ),
                  ),
                ],
              );
            }),
          ),
          ...List.generate(widget.classSections.length, (index) {
            final classSection = widget.classSections[index];
            return RecapAttendanceItemContainer(
              classSection: classSection,
              index: index,
              onDownload: widget.onDownload,
            );
          }),
        ],
      ),
    );
  }
}
