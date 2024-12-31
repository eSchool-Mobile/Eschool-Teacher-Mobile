import 'package:eschool_saas_staff/data/models/attendanceRanking.dart';
import 'package:eschool_saas_staff/ui/widgets/attendenceRankingItemContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class AttendanceRankingContainer extends StatefulWidget {
  final AttendanceRanking attendanceRankings;
  final bool showAllStudents;

  const AttendanceRankingContainer({
    super.key,
    required this.attendanceRankings,
    required this.showAllStudents,
  });

  @override
  State<AttendanceRankingContainer> createState() =>
      _AttendanceRankingContainerState();
}

class _AttendanceRankingContainerState
    extends State<AttendanceRankingContainer> {
  @override
  Widget build(BuildContext context) {
    // int currentIndex = 0;
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
                    width: boxConstraints.maxWidth * (0.01),
                  ),
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.22),
                    child: CustomTextContainer(
                      textKey: "Rank",
                      style: titleStyle,
                    ),
                  ),
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.4),
                    child: CustomTextContainer(
                      textKey: "Nama",
                      style: titleStyle,
                    ),
                  ),
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.22),
                    child: CustomTextContainer(
                        textKey: "Kelas", style: titleStyle),
                  ),
                  SizedBox(
                    // width: boxConstraints.maxWidth * (0.),
                    child: CustomTextContainer(
                      textKey: "Poin",
                      style: titleStyle,
                    ),
                  ),
                ],
              );
            }),
          ),
          // Fix the List.generate part
          // Display data based on showAllStudents flag
          if (widget.showAllStudents)
            ...(widget.attendanceRankings.allStudents ?? []).map((student) {
              return AttendanceRankingItemContainer(
                topStudents: TopStudents(
                  rank:
                      widget.attendanceRankings.allStudents!.indexOf(student) +
                          1,
                  className: student.className,
                  studentName: student.studentName,
                  studentId: student.studentId,
                  jumlahJpSum: student.jumlahJpSum,
                  point: student.point,
                ),
                index: widget.attendanceRankings.allStudents!.indexOf(student),
              );
            }).toList()
          else
            ...(widget.attendanceRankings.groupedByClassLevel ?? [])
                .expand((classLevel) => (classLevel.topStudents ?? []))
                .map((student) => AttendanceRankingItemContainer(
                      topStudents: student,
                      index: student.rank ?? 0,
                    ))
                .toList(),
        ],
      ),
    );
  }
}
