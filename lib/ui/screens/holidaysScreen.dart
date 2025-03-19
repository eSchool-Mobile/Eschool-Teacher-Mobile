import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/holidayContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HolidaysScreen extends StatefulWidget {
  final List<Holiday> holidays;
  const HolidaysScreen({super.key, required this.holidays});

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return HolidaysScreen(
      holidays: arguments['holidays'] as List<Holiday>,
    );
  }

  static Map<String, dynamic> buildArguments(
      {required List<Holiday> holidays}) {
    return {"holidays": List<Holiday>.from(holidays)};
  }

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _searchQuery = '';
  bool _isSearching = false;
  List<Holiday> _filteredHolidays = [];
  final TextEditingController _searchController = TextEditingController();
  final maroonColor = Color(0xFF800020);

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _controller.forward();
    _filteredHolidays = widget.holidays;
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterHolidays() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredHolidays = widget.holidays;
      });
      return;
    }

    setState(() {
      _filteredHolidays = widget.holidays.where((holiday) {
        return (holiday.title
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            (holiday.description
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    });
  }

  Map<String, List<Holiday>> _groupHolidaysByMonth(List<Holiday> holidays) {
    final Map<String, List<Holiday>> grouped = {};

    // Sort holidays by date first
    final sortedHolidays = holidays.toList()
      ..sort((a, b) {
        final dateA = DateTime.parse(a.date ?? "");
        final dateB = DateTime.parse(b.date ?? "");
        return dateA.compareTo(dateB);
      });

    for (var holiday in sortedHolidays) {
      final dateTime = DateTime.parse(holiday.date ?? "");
      final monthYear = "${months[dateTime.month - 1]} ${dateTime.year}";

      if (!grouped.containsKey(monthYear)) {
        grouped[monthYear] = [];
      }

      grouped[monthYear]!.add(holiday);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedHolidays = _groupHolidaysByMonth(_filteredHolidays);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[50]!,
                  Colors.white,
                ],
              ),
            ),
          ),

          // Background decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: maroonColor.withOpacity(0.06),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Stats summary
              

                // Holiday List
                Expanded(
                  child: _filteredHolidays.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                FontAwesomeIcons.calendarXmark,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? "Belum ada jadwal liburan"
                                    : "Tidak ditemukan hasil pencarian",
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 300.ms)
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                              appContentHorizontalPadding,
                              8,
                              appContentHorizontalPadding,
                              30),
                          itemCount: groupedHolidays.length,
                          itemBuilder: (context, index) {
                            final monthYear =
                                groupedHolidays.keys.elementAt(index);
                            final holidays = groupedHolidays[monthYear]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 16, bottom: 12, left: 6),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: maroonColor,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        child: Text(
                                          monthYear,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          height: 20,
                                          thickness: 1,
                                          indent: 14,
                                          endIndent: 8,
                                          color: Colors.grey[200],
                                        ),
                                      ),
                                      Text(
                                        '${holidays.length} hari',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...List.generate(
                                  holidays.length,
                                  (i) => HolidayContainer(
                                    holiday: holidays[i],
                                    width: MediaQuery.of(context).size.width,
                                    margin: const EdgeInsetsDirectional.only(
                                        bottom: 16),
                                  )
                                      .animate(delay: (50 * i).ms)
                                      .fadeIn(duration: 400.ms)
                                      .slideY(
                                          begin: 0.1,
                                          end: 0,
                                          duration: 400.ms,
                                          curve: Curves.easeOutQuad),
                                ),
                              ],
                            )
                                .animate(delay: (100 * index).ms)
                                .fadeIn(duration: 400.ms);
                          },
                        ),
                ),
              ],
            ),
          ),

          // AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    Expanded(
                      child: CustomAppbar(titleKey: holidaysKey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
