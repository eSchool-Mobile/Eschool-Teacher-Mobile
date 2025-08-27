import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionTile.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class FilterSelectionBottomsheet<T> extends StatelessWidget {
  final List<T> values;
  final Function(T? value) onSelection;
  final T selectedValue;
  final String titleKey;
  final bool showFilterByLabel;
  final String Function(T)? displayFunction;
  const FilterSelectionBottomsheet(
      {super.key,
      required this.onSelection,
      required this.selectedValue,
      required this.titleKey,
      required this.values,
      this.showFilterByLabel = true,
      this.displayFunction});

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
      titleLabelKey:
          "${showFilterByLabel ? '${Utils.getTranslatedLabel(filterByKey)} : ' : ''}${Utils.getTranslatedLabel(titleKey)}",
      child: Column(
        children: [
          const SizedBox(
            height: 25,
          ),
          // Create list with Divider between each item
          ...values.asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value;

            return Column(
              children: [
                FilterSelectionTile(
                  onTap: () {
                    if (value != null) {
                      onSelection.call(value);
                    }
                  },
                  isSelected: value == selectedValue,
                  title: displayFunction != null
                      ? Utils().cleanClassName(displayFunction!(value))
                      : Utils().cleanClassName(value.toString()),
                ),
                // Add Divider if not the last item
                if (index < values.length)
                  Divider(
                    // color: Colors.grey, // Customize as needed
                    thickness: 0.5, // Adjust the thickness
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
