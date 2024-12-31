import 'package:eschool_saas_staff/data/models/studentDetails.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/customRadioButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class StudentAttendanceItemContainer extends StatefulWidget {
  final bool showStatusPicker;
  final bool isPresent;
  final bool isSick;
  final bool isPermission;
  final bool isAlpa;
  final StudentDetails studentDetails;
  final Function(StudentAttendanceStatus status)? onChangeAttendance;
  final int index;
  const StudentAttendanceItemContainer({
    super.key,
    required this.studentDetails,
    this.showStatusPicker = false,
    required this.isPresent,
    required this.isSick,
    required this.isPermission,
    required this.isAlpa,
    required this.index,
    this.onChangeAttendance,
  });

  @override
  State<StudentAttendanceItemContainer> createState() =>
      _StudentAttendanceItemContainerState();
}

class _StudentAttendanceItemContainerState
    extends State<StudentAttendanceItemContainer> {
  late StudentAttendanceStatus selectedValue = widget.isPresent
      ? StudentAttendanceStatus.present
      : widget.isSick
          ? StudentAttendanceStatus.sick
          : widget.isPermission
              ? StudentAttendanceStatus.permission
              : widget.isAlpa
                  ? StudentAttendanceStatus.alpa
                  : StudentAttendanceStatus.present;

  _buildStatusPicker(BuildContext context) {
    return Wrap(
      spacing: 7.0,
      children: [
        // Hanya tampilkan S, I, A
        CustomRadioButton(
          status: StudentAttendanceStatus.sick,
          groupValue: selectedValue,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                // Reset ke present jika tap ulang opsi yang sama
                selectedValue = selectedValue == StudentAttendanceStatus.sick
                    ? StudentAttendanceStatus.present
                    : value;
              });
              if (widget.onChangeAttendance != null) {
                widget.onChangeAttendance!(selectedValue);
              }
            }
          },
          color:
              Theme.of(context).extension<CustomColors>()!.sickBackgroundColor!,
          text: 'S',
        ),
        CustomRadioButton(
          status: StudentAttendanceStatus.permission,
          groupValue: selectedValue,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedValue =
                    selectedValue == StudentAttendanceStatus.permission
                        ? StudentAttendanceStatus.present
                        : value;
              });
              if (widget.onChangeAttendance != null) {
                widget.onChangeAttendance!(selectedValue);
              }
            }
          },
          color: Theme.of(context)
              .extension<CustomColors>()!
              .permissionBackgroundColor!,
          text: 'I',
        ),
        CustomRadioButton(
          status: StudentAttendanceStatus.alpa,
          groupValue: selectedValue,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                // Reset ke present jika tap ulang opsi yang sama
                selectedValue = selectedValue == StudentAttendanceStatus.alpa
                    ? StudentAttendanceStatus.present
                    : value;
              });
              if (widget.onChangeAttendance != null) {
                widget.onChangeAttendance!(selectedValue);
              }
            }
          },
          color: Theme.of(context)
              .extension<CustomColors>()!
              .totalStudentOverviewBackgroundColor!,
          text: 'A',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final border = BorderSide(color: Theme.of(context).colorScheme.tertiary);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: Utils().getResponsiveHeight(context, 85),
      padding: EdgeInsets.symmetric(
          horizontal: appContentHorizontalPadding, vertical: 10),
      decoration: BoxDecoration(
          border: Border(left: border, bottom: border, right: border)),
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return Row(
          children: [
            SizedBox(
              width: boxConstraints.maxWidth * (0.02),
            ),
            SizedBox(
              width: boxConstraints.maxWidth * (0.08),
              child: CustomTextContainer(
                textKey: (widget.index + 1).toString(),
                style: TextStyle(fontSize: Utils.getScaledValue(context, 13)),
              ),
            ),
            SizedBox(
              width: boxConstraints.maxWidth * (0.54),
              child: Container(
                // color: Colors.red,
                padding: EdgeInsets.all(10),
                child: CustomTextContainer(
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  textKey: (widget.studentDetails.fullName ?? ""),
                  style: TextStyle(
                      fontSize: Utils.getScaledValue(context, 15),
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(
              width: boxConstraints.maxWidth * (0.35),
              child: widget.showStatusPicker
                  ? _buildStatusPicker(context)
                  : Container(
                      height: 50,
                      width: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: widget.isPresent
                              ? Theme.of(context)
                                  .extension<CustomColors>()!
                                  .totalStaffOverviewBackgroundColor!
                                  .withOpacity(0.1)
                              : widget.isSick
                                  ? Theme.of(context)
                                      .extension<CustomColors>()!
                                      .sickBackgroundColor!
                                      .withOpacity(0.1)
                                  : widget.isPermission
                                      ? Theme.of(context)
                                          .extension<CustomColors>()!
                                          .permissionBackgroundColor!
                                          .withOpacity(0.1)
                                      : widget.isAlpa
                                          ? Theme.of(context)
                                              .extension<CustomColors>()!
                                              .totalStudentOverviewBackgroundColor!
                                              .withOpacity(0.1)
                                          : Theme.of(context)
                                              .extension<CustomColors>()!
                                              .totalStudentOverviewBackgroundColor!
                                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5)),
                      child: CustomTextContainer(
                        textKey: widget.isPresent
                            ? "Hadir"
                            : widget.isSick
                                ? "Sakit"
                                : widget.isPermission
                                    ? "Izin"
                                    : widget.isAlpa
                                        ? "Alpa"
                                        : "-",
                        style: TextStyle(
                          fontSize: Utils.getScaledValue(context, 15),
                          fontWeight: FontWeight.w600,
                          color: widget.isPresent
                              ? Theme.of(context)
                                  .extension<CustomColors>()!
                                  .totalStaffOverviewBackgroundColor
                              : widget.isSick
                                  ? Theme.of(context)
                                      .extension<CustomColors>()!
                                      .sickBackgroundColor!
                                  : widget.isPermission
                                      ? Theme.of(context)
                                          .extension<CustomColors>()!
                                          .permissionBackgroundColor!
                                      : widget.isAlpa
                                          ? Theme.of(context)
                                              .extension<CustomColors>()!
                                              .totalStudentOverviewBackgroundColor!
                                          : Theme.of(context)
                                              .extension<CustomColors>()!
                                              .totalStudentOverviewBackgroundColor!,
                        ),
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }
}
