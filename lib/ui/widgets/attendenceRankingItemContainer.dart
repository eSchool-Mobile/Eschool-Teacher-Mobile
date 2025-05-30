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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: widget.index.isEven ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRankIndicator(),
          SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatStudentName(widget.topStudents.studentName ?? ''),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  softWrap: true,
                  // Removed ellipsis and maxLines to show full name
                ),
                SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.school, size: 12, color: Colors.grey),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.topStudents.className ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        softWrap: true,
                        // Removed ellipsis and maxLines to show full class name
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
    final colors = _getGradientColors(rank);
    IconData rankIcon;

    switch (rank) {
      case 1:
        rankIcon = Icons.warning_rounded;
        break;
      case 2:
        rankIcon = Icons.priority_high_rounded;
        break;
      case 3:
        rankIcon = Icons.error_outline_rounded;
        break;
      default:
        rankIcon = Icons.dangerous;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            rankIcon,
            color: Colors.white.withOpacity(0.3),
            size: 24,
          ),
          Text(
            '$rank',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsBadge() {
    final rank = widget.topStudents.rank ?? 0;
    final colors = _getGradientColors(rank);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                rank <= 3 ? _getRankIcon(rank) : Icons.dangerous,
                size: 16,
                color: Colors.white,
              ),
              SizedBox(width: 4),
              Text(
                '${widget.topStudents.point ?? 0}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Jumlah Alpha: ${widget.topStudents.alpha_count ?? 0}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Color(0xFFFFD700); // Bright Gold
      case 2:
        return Color(0xFF90CDF4); // Light Sky Blue
      case 3:
        return Color(0xFF9AE6B4); // Light Green
      default:
        return Color(0xFFE2E8F0); // Neutral Gray
    }
  }

  List<Color> _getGradientColors(int rank) {
    switch (rank) {
      case 1:
        return [
          Colors.red.shade800, // Merah tua (peringatan)
          Colors.red.shade600,
        ];
      case 2:
        return [
          Colors.deepOrange.shade800, // Oranye tua (waspada)
          Colors.deepOrange.shade600,
        ];
      case 3:
        return [
          Colors.orange.shade800, // Oranye terang (waspada)
          Colors.orange.shade600,
        ];
      default:
        return [
          Color(0xFF64748B), // Light Slate
          Color(0xFF475569), // Dark Slate
        ];
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.warning_rounded; // Ikon peringatan
      case 2:
        return Icons.priority_high_rounded; // Ikon tanda seru
      case 3:
        return Icons.error_outline_rounded; // Ikon error outline
      default:
        return Icons.dangerous;
    }
  }

  // Memformat nama siswa dengan menghilangkan tanda "-" di akhir
  String _formatStudentName(String name) {
    if (name.endsWith('-')) {
      return name.substring(0, name.length - 1).trim();
    }
    return name;
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
