import 'package:eschool_saas_staff/data/models/attendanceRanking.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AttendanceRankingItemContainer extends StatefulWidget {
  final TopStudents topStudents;
  final int index;
  final bool showAllStudents;
  // final Function(ClassSection) onDownload;

  const AttendanceRankingItemContainer({
    super.key,
    required this.topStudents,
    required this.index,
    this.showAllStudents = false,
  });

  @override
  State<AttendanceRankingItemContainer> createState() =>
      _AttendanceRankingItemContainerState();
}

class _AttendanceRankingItemContainerState
    extends State<AttendanceRankingItemContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.index.isEven ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildRankIndicator(),
          SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Tooltip(
                  message: widget.topStudents.studentName ?? '',
                  child: Text(
                    widget.topStudents.studentName ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.school, size: 12, color: Colors.grey),
                    SizedBox(width: 4),
                    Expanded(
                      child: Tooltip(
                        message: widget.topStudents.className ?? '',
                        child: Text(
                          widget.topStudents.className ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          _buildPointsBadge(),
        ],
      ),
    );
  }

  Widget _buildRankIndicator() {
    final rank = widget.topStudents.rank ?? 0;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: rank <= 3 ? _getRankColor(rank) : Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            color: rank <= 3 ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPointsBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${widget.topStudents.point ?? 0}',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Color(0xFFFFD700);
      case 2:
        return Color(0xFFC0C0C0);
      case 3:
        return Color(0xFFCD7F32);
      default:
        return Colors.grey;
    }
  }

  // Update _buildFilterButton()
  Widget _buildFilterButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_list, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            widget.showAllStudents ? "Semua" : "Top",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
