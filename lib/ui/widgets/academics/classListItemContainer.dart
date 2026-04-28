import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/data/models/academic/classSection.dart';
import 'package:eschool_saas_staff/utils/system/constants.dart';
import 'package:eschool_saas_staff/utils/system/labelKeys.dart';
import 'package:eschool_saas_staff/utils/system/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClassListItemContainer extends StatelessWidget {
  final ClassSection classSectionDetails;
  final int index;
  const ClassListItemContainer(
      {required this.classSectionDetails, super.key, required this.index});

  Widget _boldText(String text) {
    return Builder(
        builder: (context) => Text(
              text,
              style: TextStyle(
                fontSize: Utils.getScaledValue(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ));
  }

  Widget _normalTitleText(String text, BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Utils.getScaledValue(context, 14),
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.76),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "Class Section: ${classSectionDetails.name}, Teacher ID: ${context.read<AuthCubit>().getUserDetails().id}");
    return Container(
      margin: EdgeInsets.symmetric(vertical: appContentHorizontalPadding),
      padding: EdgeInsets.all(appContentHorizontalPadding),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _boldText(
              "${(index + 1)}. ${classSectionDetails.name ?? ""} ${classSectionDetails.classDetails?.semesterName != '' ? "\n" : ""}"),
          Text.rich(
            TextSpan(
              text: classSectionDetails.classDetails?.semesterName != ''
                  ? '(${classSectionDetails.classDetails!.semesterName})'
                  : '',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Divider(
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(
            height: 10,
          ),
          if (classSectionDetails.classTeachers?.isNotEmpty ?? false) ...[
            _normalTitleText(
                Utils.getTranslatedLabel(classTeacherKey), context),
            const SizedBox(
              height: 5,
            ),
            ...List.generate(
              classSectionDetails.classTeachers!.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: _boldText(classSectionDetails
                        .classTeachers![index].teacher?.fullName ??
                    "-"),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
          if (classSectionDetails.subjectTeachers
                  ?.where((element) =>
                      element.teacher?.id ==
                      context.read<AuthCubit>().getUserDetails().id)
                  .toList()
                  .isNotEmpty ??
              false) ...[
            _normalTitleText(
                Utils.getTranslatedLabel(yourSubjectsKey), context),
            const SizedBox(
              height: 5,
            ),
            ...List.generate(
              classSectionDetails.subjectTeachers!.length,
              (index) =>
                  //filter out the subjects which the current user does not take
                  classSectionDetails.subjectTeachers![index].teacher?.id !=
                          context.read<AuthCubit>().getUserDetails().id
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: _boldText(classSectionDetails
                                  .subjectTeachers![index].subject
                                  ?.getSybjectNameWithType() ??
                              "-"),
                        ),
            )
          ],
        ],
      ),
    );
  }
}
