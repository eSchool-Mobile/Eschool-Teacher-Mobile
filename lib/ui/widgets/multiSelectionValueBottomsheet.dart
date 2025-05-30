import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionTile.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class MultiSelectionValueBottomsheet<T> extends StatefulWidget {
  final List<T> selectedValues;
  final List<T> values;
  final String titleKey;
  const MultiSelectionValueBottomsheet(
      {super.key,
      required this.selectedValues,
      required this.values,
      required this.titleKey});

  @override
  State<MultiSelectionValueBottomsheet> createState() =>
      _MultiSelectionValueBottomsheetState();
}

class _MultiSelectionValueBottomsheetState<T> extends State<MultiSelectionValueBottomsheet<T>> {
  late final List<T> _selectedValues = List.from(widget.selectedValues);

  // Fungsi untuk memilih semua nilai
  void _selectAll() {
    _selectedValues.clear();
    _selectedValues.addAll(widget.values);
    setState(() {});
  }

  // Fungsi untuk menghapus semua pilihan
  void _deselectAll() {
    _selectedValues.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool allSelected = widget.values.length == _selectedValues.length &&
        widget.values.every((item) => _selectedValues.contains(item));

    return CustomBottomsheet(
      titleLabelKey: Utils.getTranslatedLabel(widget.titleKey),
      child: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          // Tombol "Semua" untuk memilih/hapus semua item
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  if (allSelected) {
                    _deselectAll();
                  } else {
                    _selectAll();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 15.0),
                  child: Row(
                    children: [
                      Icon(
                        allSelected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 15),
                      Text(
                        'Semua',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '(${_selectedValues.length}/${widget.values.length})',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          // Separator
          Divider(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            thickness: 1,
          ),
          const SizedBox(
            height: 10,
          ),
          ...widget.values.map((value) => FilterSelectionTile(
              onTap: () {
                if (_selectedValues.contains(value)) {
                  _selectedValues.remove(value);
                } else {
                  _selectedValues.add(value);
                }
                setState(() {});
              },
              isSelected: _selectedValues.contains(value),
              title: value.toString())),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
            child: CustomRoundedButton(
              widthPercentage: 1.0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              buttonTitle: submitKey,
              showBorder: false,
              onTap: () {
                Get.back(result: _selectedValues);
              },
            ),
          ),
        ],
      ),
    );
  }
}
