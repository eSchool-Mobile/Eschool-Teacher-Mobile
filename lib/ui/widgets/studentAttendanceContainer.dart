import 'package:eschool_saas_staff/data/models/studentAttendance.dart';
import 'package:eschool_saas_staff/data/models/studentDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/studentAttendanceItemContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class StudentAttendanceContainer extends StatefulWidget {
  final List<StudentAttendance> studentAttendances;
  final bool isForAddAttendance;
  final bool isReadOnly;
  final Function(
      List<({StudentAttendanceStatus status, int studentId})>
          attendanceStatuses)? onStatusChanged;

  const StudentAttendanceContainer({
    super.key,
    required this.isForAddAttendance,
    required this.studentAttendances,
    this.onStatusChanged,
    this.isReadOnly = false,
  });

  @override
  State<StudentAttendanceContainer> createState() =>
      _StudentAttendanceContainerState();
}

class _StudentAttendanceContainerState
    extends State<StudentAttendanceContainer> {
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
      return StudentAttendanceStatus.absent;
    }
  }).toList();

  @override
  void initState() {
    if (widget.onStatusChanged != null) {
      widget.onStatusChanged!(
        List.generate(
          widget.studentAttendances.length,
          (index) => (
            status: allAttendanceStatuses[index],
            studentId: widget.studentAttendances[index].studentDetails?.student
                    ?.userId ?? 0
          ),
        ),
      );
    }
    super.initState();
  }

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
            height: 45,
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
                    width: boxConstraints.maxWidth * (0.25),
                    child: CustomTextContainer(
                      textKey: rollNoKey,
                      style: titleStyle,
                    ),
                  ),
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.48),
                    child: CustomTextContainer(
                      textKey: nameKey,
                      style: titleStyle,
                    ),
                  ),
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.25),
                    child: CustomTextContainer(
                      textKey: statusKey,
                      style: titleStyle,
                    ),
                  ),
                ],
              );
            }),
          ),
          ...List.generate(widget.studentAttendances.length, (index) {
            return AbsorbPointer(
              absorbing: widget.isReadOnly,
              child: StudentAttendanceItemContainer(
                studentDetails:
                    widget.studentAttendances[index].studentDetails ?? StudentDetails.fromJson({}),
                showStatusPicker: widget.isForAddAttendance,
                isPresent: widget.studentAttendances[index].isPresent(),
                isSick: widget.studentAttendances[index].isSick(),
                isPermission: widget.studentAttendances[index].isPermission(),
                isAlpa: widget.studentAttendances[index].isAlpa(),
                onChangeAttendance: (StudentAttendanceStatus status) {
                  if (!widget.isReadOnly) {
                    allAttendanceStatuses[index] = status;
                    if (widget.onStatusChanged != null) {
                      widget.onStatusChanged!(
                        List.generate(
                          widget.studentAttendances.length,
                          (index) => (
                            status: allAttendanceStatuses[index],
                            studentId: widget.studentAttendances[index]
                                    .studentDetails?.student?.userId ?? 0
                          ),
                        ),
                      );
                    }
                  }
                },
                index: index,
              ),
            );
          }),
        ],
      ),
    );
  }
}
