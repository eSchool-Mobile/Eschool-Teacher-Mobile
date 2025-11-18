import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/extracurricularTimetable.dart';
import 'package:eschool_saas_staff/data/models/extracurricularTimetableEntry.dart';
import 'package:eschool_saas_staff/ui/screens/extracurricular/createExtracurricularTimetableScreen.dart';
import 'package:eschool_saas_staff/cubits/extracurricularTimetable/extracurricularTimetableCubit.dart';
import 'package:eschool_saas_staff/data/repositories/extracurricularTimetableRepository.dart';
import 'package:eschool_saas_staff/utils/utils.dart';

class ExtracurricularTimetableItem extends StatelessWidget {
  final ExtracurricularTimetable item;
  final String selectedDay;
  final VoidCallback? onRefresh;

  const ExtracurricularTimetableItem({
    Key? key,
    required this.item,
    required this.selectedDay,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final schedule = item.getScheduleForDay(selectedDay) ?? '-';
    final timeData = _parseScheduleTime(schedule);
    final Color primaryColor = const Color(0xFF6366F1);

    return Container(
      margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      height: 150,
      child: Row(
        children: [
          // Time section (20% width)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeText(timeData['startTime'] ?? '', context),
                Container(
                  height: 60,
                  width: 2,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                _buildTimeText(timeData['endTime'] ?? '', context),
              ],
            ),
          ),

          SizedBox(width: MediaQuery.of(context).size.width * 0.05),

          // Content section (75% width)
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and actions
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ekstrakurikuler',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              item.extracurricularName ?? 'Unnamed',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Action buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit_rounded,
                            color: Colors.blue,
                            onTap: () => _editTimetable(context),
                          ),
                          SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.delete_rounded,
                            color: Colors.red,
                            onTap: () => _showDeleteConfirmation(context),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Spacer(),

                  // Schedule info
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${timeData['startTime']} - ${timeData['endTime']}',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeText(String time, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        time.isEmpty
            ? '-'
            : Utils.formatTime(
                timeOfDay: TimeOfDay(
                  hour: Utils.getHourFromTimeDetails(time: time),
                  minute: Utils.getMinuteFromTimeDetails(time: time),
                ),
                context: context,
              ),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }

  void _editTimetable(BuildContext context) async {
    // Create ExtracurricularTimetableEntry from current item
    final schedule = item.getScheduleForDay(selectedDay) ?? '-';
    final timeData = _parseScheduleTime(schedule);

    final entry = ExtracurricularTimetableEntry(
      id: item.id,
      extracurricularId: item.id?.toString(),
      extracurricularName: item.extracurricularName,
      day: selectedDay,
      startTime: timeData['startTime'] ?? '',
      endTime: timeData['endTime'] ?? '',
    );

    final result = await Get.to(() => BlocProvider(
          create: (context) => ExtracurricularTimetableCubit(
            ExtracurricularTimetableRepository(),
          ),
          child: CreateExtracurricularTimetableScreen(
            existingEntry: entry,
          ),
        ));

    if (result == true && onRefresh != null) {
      onRefresh!();
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 12),
            Text(
              'Konfirmasi Hapus',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin menghapus jadwal ini?',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.extracurricularName ?? 'Unnamed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Hari: ${_getDayInIndonesian(selectedDay)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _resetTimetable(context, false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _resetTimetable(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Hapus Permanen'),
          ),
        ],
      ),
    );
  }

  void _resetTimetable(BuildContext context, bool permanent) {
    if (item.id != null) {
      context.read<ExtracurricularTimetableCubit>().resetTimetableEntry(
            item.id!,
            permanent: permanent,
          );

      if (onRefresh != null) {
        onRefresh!();
      }
    }
  }

  String _getDayInIndonesian(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 'Senin';
      case 'tuesday':
        return 'Selasa';
      case 'wednesday':
        return 'Rabu';
      case 'thursday':
        return 'Kamis';
      case 'friday':
        return 'Jumat';
      case 'saturday':
        return 'Sabtu';
      case 'sunday':
        return 'Minggu';
      default:
        return day;
    }
  }

  Map<String, String> _parseScheduleTime(String schedule) {
    if (schedule == '-' || schedule.isEmpty) {
      return {'startTime': '', 'endTime': ''};
    }

    // Try to parse different time formats
    // Format: "HH:MM - HH:MM" or "HH:MM-HH:MM"
    final timePattern = RegExp(r'(\d{1,2}:\d{2})\s*-\s*(\d{1,2}:\d{2})');
    final match = timePattern.firstMatch(schedule);

    if (match != null) {
      return {
        'startTime': match.group(1) ?? '',
        'endTime': match.group(2) ?? '',
      };
    }

    return {'startTime': '', 'endTime': ''};
  }
}
