import 'package:eschool_saas_staff/data/models/staff/attendanceStudent.dart';
// import 'package:eschool_saas_staff/data/models/studentAttendance.dart';
// import 'package:eschool_saas_staff/data/models/studentDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
// import 'package:eschool_saas_staff/ui/widgets/studentAttendenceItemContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/studentSubjectAttendenceItemContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class StudentSubjectAttendanceContainer extends StatefulWidget {
  final List<AttendanceStudent> studentAttendances;
  final bool isForAddAttendance;
  final Function(
      List<({StudentAttendanceStatus status, int studentId})>
          attendanceStatuses)? onStatusChanged;
  const StudentSubjectAttendanceContainer(
      {super.key,
      required this.isForAddAttendance,
      required this.studentAttendances,
      this.onStatusChanged});

  @override
  State<StudentSubjectAttendanceContainer> createState() =>
      _StudentAttendanceContainerState();
}

class _StudentAttendanceContainerState
    extends State<StudentSubjectAttendanceContainer> {
  late List<StudentAttendanceStatus> allAttendanceStatuses =
      widget.studentAttendances.map((e) {
    if (e.isPresent()) {
      return StudentAttendanceStatus.present;
    } else if (e.isAbsent()) {
      return StudentAttendanceStatus.absent;
    } else if (e.isSick()) {
      return StudentAttendanceStatus.sick;
    } else if (e.isPermission()) {
      return StudentAttendanceStatus.permission;
    } else if (e.isAlpa()) {
      return StudentAttendanceStatus.alpa;
    } else {
      return StudentAttendanceStatus.absent; // Default jika tidak ada match
    }
  }).toList();

  @override
  void initState() {
    if (widget.onStatusChanged != null) {
      //passing initially filled values
      widget.onStatusChanged!(
        List.generate(
          widget.studentAttendances.length,
          (index) {
            return (
              status: allAttendanceStatuses[index],
              studentId: widget.studentAttendances[index].studentId ?? 0
            );
          },
        ),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(widget.studentAttendances[0].toString());
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
              const titleStyle =
                  TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600);
              return Row(
                children: [
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.1),
                    child: const CustomTextContainer(
                      textKey: 'No',
                      style: titleStyle,
                    ),
                  ),
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.57),
                    child: const CustomTextContainer(
                      textKey: nameKey,
                      style: titleStyle,
                    ),
                  ),
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.2),
                    child: const CustomTextContainer(
                      textKey: statusKey,
                      style: titleStyle,
                    ),
                  ),
                ],
              );
            }),
          ),
          ...List.generate(widget.studentAttendances.length, (index) {
            return StudentSubjectAttendanceItemContainer(
              studentDetails: widget.studentAttendances[index],
              showStatusPicker: widget.isForAddAttendance,
              isPresent: widget.studentAttendances[index].isPresent(),
              isSick: widget.studentAttendances[index].isSick(),
              isPermission: widget.studentAttendances[index].isPermission(),
              isAlpa: widget.studentAttendances[index].isAlpa(),
              index: index,
              onChangeAttendance: (StudentAttendanceStatus status) {
                allAttendanceStatuses[index] = status;
                if (widget.onStatusChanged != null) {
                  widget.onStatusChanged!(
                    List.generate(
                      widget.studentAttendances.length,
                      (index) {
                        return (
                          status: allAttendanceStatuses[index],
                          studentId:
                              widget.studentAttendances[index].studentId ?? 0
                        );
                      },
                    ),
                  );
                }
              },
            );
          }),
        ],
      ),
    );
  }
}
