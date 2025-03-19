import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/readMoreTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/textWithFadedBackgroundContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HolidayContainer extends StatefulWidget {
  final Holiday holiday;
  final double width;
  final EdgeInsetsDirectional? margin;
  final Function()? onTap;

  const HolidayContainer({
    super.key,
    required this.width,
    this.margin,
    required this.holiday,
    this.onTap,
  });

  @override
  State<HolidayContainer> createState() => _HolidayContainerState();
}

class _HolidayContainerState extends State<HolidayContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final holidayDateTime = DateTime.parse(widget.holiday.date ?? "");
    final maroonColor = Color(0xFF800020);
    final maroonLight = Color(0xFFAA6976);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          widget.onTap?.call() ??
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    HolidayDetailsBottomsheet(holiday: widget.holiday),
              );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: widget.margin,
          width: widget.width,
          constraints: const BoxConstraints(minHeight: 145),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16.0),
            // Menghapus shadow sesuai permintaan
            border: Border.all(
              color: _isHovered ? maroonLight : Colors.grey.shade200,
              width: 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          maroonColor,
                          maroonLight,
                        ],
                      ),
                    ),
                    child: Stack(
                        children: [
                        Positioned(
                          top: -5,
                          right: -5,
                          child: Icon(
                          FontAwesomeIcons.calendar,
                          size: 30,
                          color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                            child: CustomTextContainer(
                              textKey: holidayDateTime.day.toString(),
                              style: TextStyle(
                              fontSize: Utils.getScaledValue(context, 34),
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            ),
                            Center(
                            child: CustomTextContainer(
                              textKey: months[holidayDateTime.month - 1],
                              style: TextStyle(
                              height: 1.2,
                              fontSize: Utils.getScaledValue(context, 18),
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            ),
                            SizedBox(height: 6),
                            Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                              '${holidayDateTime.year}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                              ),
                            ),
                            ),
                          ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: CustomTextContainer(
                                  textKey: widget.holiday.title ?? "",
                                  style: TextStyle(
                                    fontSize: Utils.getScaledValue(context, 20),
                                    fontWeight: FontWeight.w600,
                                    color: maroonColor,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Icon(
                                  FontAwesomeIcons.circleInfo,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: CustomTextContainer(
                                  textKey: widget.holiday.description ?? "",
                                  style: TextStyle(
                                    height: 1.3,
                                    fontSize: Utils.getScaledValue(context, 15),
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Lihat Detail',
                                style: TextStyle(
                                  color: maroonColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 10,
                                color: maroonColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate(target: _isHovered ? 1 : 0).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.01, 1.01),
            duration: 300.ms),
      ),
    );
  }
}

class HolidayDetailsBottomsheet extends StatelessWidget {
  final Holiday holiday;
  const HolidayDetailsBottomsheet({super.key, required this.holiday});

  @override
  Widget build(BuildContext context) {
    final maroonColor = Color(0xFF800020);
    final holidayDateTime = DateTime.parse(holiday.date ?? "");

    return CustomBottomsheet(
      titleLabelKey: holidayKey,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [maroonColor, Color(0xFFAA6976)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        holidayDateTime.day.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        months[holidayDateTime.month - 1],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '${holidayDateTime.year}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Utils.formatDate(DateTime.parse(holiday.date!)),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        holiday.title ?? "",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: maroonColor,
                          letterSpacing: 0.3,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Divider(height: 1, thickness: 1, color: Colors.grey[200]),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  FontAwesomeIcons.circleInfo,
                  size: 16,
                  color: maroonColor,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Detail Liburan:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: CustomTextContainer(
                textKey: holiday.description ?? "",
                style: TextStyle(
                  height: 1.4,
                  fontSize: 15,
                  color: Colors.grey[800],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).moveY(
          begin: 20, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),
    );
  }
}
