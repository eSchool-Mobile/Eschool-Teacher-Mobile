import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class CustomRadioButton extends StatelessWidget {
  final StudentAttendanceStatus status;
  final StudentAttendanceStatus groupValue;
  final ValueChanged<StudentAttendanceStatus> onChanged;
  final Color color;
  final String text;

  const CustomRadioButton(
      {super.key,
      required this.status,
      required this.groupValue,
      required this.onChanged,
      required this.color,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(status);
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: groupValue == status ? color : Colors.grey,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: Utils.getScaledValue(context, 15),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
