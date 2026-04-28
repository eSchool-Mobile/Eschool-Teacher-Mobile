import 'package:eschool_saas_staff/ui/widgets/system/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/system/constants.dart';
import 'package:eschool_saas_staff/utils/system/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/teacherMyTimetableCubit.dart';

class WeekdaysContainer extends StatefulWidget {
  final String selectedDayKey;
  final Function(String newSelection) onSelectionChange;
  const WeekdaysContainer(
      {super.key,
      required this.selectedDayKey,
      required this.onSelectionChange});

  @override
  State<WeekdaysContainer> createState() => _WeekdaysContainerState();
}

class _WeekdaysContainerState extends State<WeekdaysContainer> {
  late String _selectedDayKey;

  @override
  void initState() {
    super.initState();
    _selectedDayKey = widget.selectedDayKey;
  }

  void _onSelectionChange(String abbreviatedDayKey) {
    Map<String, String> dayMapping = {
      'mon': 'Monday',
      'tue': 'Tuesday',
      'wed': 'Wednesday',
      'thu': 'Thursday',
      'fri': 'Friday',
      'sat': 'Saturday',
      'sun': 'Sunday',
    };

    String fullDayName =
        dayMapping[abbreviatedDayKey.toLowerCase()] ?? abbreviatedDayKey;
    debugPrint("Day selection changed to: $abbreviatedDayKey -> $fullDayName");

    setState(() {
      _selectedDayKey = abbreviatedDayKey;
    });

    context
        .read<TeacherMyTimetableCubit>()
        .getTeacherMyTimetable(isRefresh: true, dayKey: abbreviatedDayKey);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
            bottom: BorderSide(color: Theme.of(context).colorScheme.tertiary)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: Utils.weekDays.map((dayKey) {
            final isSelected = dayKey == _selectedDayKey;
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: 12.5),
              child: GestureDetector(
                onTap: () {
                  if (isSelected) {
                    return;
                  }
                  _onSelectionChange(dayKey);
                },
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surface,
                  child: CustomTextContainer(
                    textKey: dayKey,
                    style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.surface
                            : Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
