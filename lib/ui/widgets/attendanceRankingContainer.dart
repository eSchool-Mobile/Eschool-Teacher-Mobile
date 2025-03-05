import 'package:eschool_saas_staff/data/models/attendanceRanking.dart';
import 'package:eschool_saas_staff/ui/widgets/attendenceRankingItemContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherClassSectionScreen.dart';

class AttendanceRankingContainer extends StatefulWidget {
  final AttendanceRanking attendanceRankings;
  final bool showAllStudents;

  const AttendanceRankingContainer({
    super.key,
    required this.attendanceRankings,
    required this.showAllStudents,
  });

  @override
  State<AttendanceRankingContainer> createState() =>
      _AttendanceRankingContainerState();
}

class _AttendanceRankingContainerState
    extends State<AttendanceRankingContainer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Pattern
        Positioned.fill(
          child: AnimatedOpacity(
            duration: Duration(seconds: 1),
            opacity: 0.1,
            child: CustomPaint(
              painter: BackgroundPainter(
                color: AppColorPalette.primaryMaroon,
              ),
            ),
          ),
        ),

        // Main Content
        Container(
          margin: EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeaderSection(),
              _buildLeaderboard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColorPalette.primaryMaroon,
            AppColorPalette.secondaryMaroon,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: AppColorPalette.primaryMaroon.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Icon
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.school,
              size: 100,
              color: Colors.white.withOpacity(0.1),
            ),
          ),

          // Content
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.emoji_events_rounded,
                            color: Colors.amber, size: 24),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Peringkat Kehadiran",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "Berdasarkan tingkat kehadiran siswa",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  _buildFilterButton(),
                ],
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 8),
                    _buildTopThreeItem(
                        widget.showAllStudents
                            ? ((widget.attendanceRankings.allStudents?.length ??
                                        0) >
                                    1
                                ? widget.attendanceRankings.allStudents![1]
                                : null)
                            : _getTopStudent(2),
                        2),
                    _buildTopThreeItem(
                        widget.showAllStudents
                            ? ((widget.attendanceRankings.allStudents
                                        ?.isNotEmpty ??
                                    false)
                                ? widget.attendanceRankings.allStudents![0]
                                : null)
                            : _getTopStudent(1),
                        1),
                    _buildTopThreeItem(
                        widget.showAllStudents
                            ? ((widget.attendanceRankings.allStudents?.length ??
                                        0) >
                                    2
                                ? widget.attendanceRankings.allStudents![2]
                                : null)
                            : _getTopStudent(3),
                        3),
                    SizedBox(width: 8),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  dynamic _getTopStudent(int position) {
    return widget.attendanceRankings.groupedByClassLevel
        ?.expand((e) => e.topStudents ?? [])
        .where((student) => student.rank == position)
        .firstOrNull;
  }

  Widget _buildFilterButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_list, color: Colors.white, size: 20),
          SizedBox(width: 5),
          Text(
            widget.showAllStudents ? "Semua Siswa" : "Top Ranking",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThreeSection() {
    final topThree = widget.showAllStudents
        ? widget.attendanceRankings.allStudents?.take(3).toList() ?? []
        : widget.attendanceRankings.groupedByClassLevel
                ?.expand((e) => e.topStudents ?? [])
                .take(3)
                .toList() ??
            [];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTopThreeItem(topThree.length > 1 ? topThree[1] : null, 2),
        _buildTopThreeItem(topThree.isNotEmpty ? topThree[0] : null, 1),
        _buildTopThreeItem(topThree.length > 2 ? topThree[2] : null, 3),
      ],
    );
  }

  Widget _buildTopThreeItem(dynamic student, int position) {
    final scale = position == 1 ? 1.1 : 1.0;
    final verticalPadding = position == 1 ? 0.0 : 20.0;

    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: verticalPadding),
      child: Transform.scale(
        scale: scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _getPositionColors(position),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(_getPositionIcon(position),
                    color: Colors.white, size: 22),
              ),
            ),
            SizedBox(height: 6),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 80),
              child: Tooltip(
                message: student?.studentName ?? '-',
                child: Text(
                  student?.studentName ?? '-',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: position == 1 ? 13 : 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Text(
              '${student?.point ?? 0} poin',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getPositionColors(int position) {
    switch (position) {
      case 1:
        return [
          Color(0xFFFFD700), // Bright Gold
          Color(0xFFDAA520), // Golden Rod
        ];
      case 2:
        return [
          Color(0xFF90CDF4), // Light Sky Blue
          Color(0xFF63B3ED), // Sky Blue
        ];
      case 3:
        return [
          Color(0xFF9AE6B4), // Light Green
          Color(0xFF68D391), // Medium Green
        ];
      default:
        return [
          Color(0xFFE2E8F0),
          Color(0xFFCBD5E1),
        ];
    }
  }

  IconData _getPositionIcon(int position) {
    switch (position) {
      case 1:
        return Icons.workspace_premium;
      case 2:
        return Icons.trending_up;
      case 3:
        return Icons.military_tech;
      default:
        return Icons.star;
    }
  }

  Widget _buildLeaderboard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: widget.showAllStudents
            ? _buildAllStudentsList()
            : _buildTopStudentsList(),
      ),
    );
  }

  List<Widget> _buildAllStudentsList() {
    return (widget.attendanceRankings.allStudents ?? []).map((student) {
      return AttendanceRankingItemContainer(
        topStudents: TopStudents(
          rank: widget.attendanceRankings.allStudents!.indexOf(student) + 1,
          className: student.className,
          studentName: student.studentName,
          studentId: student.studentId,
          jumlahJpSum: student.jumlahJpSum,
          point: student.point,
        ),
        index: widget.attendanceRankings.allStudents!.indexOf(student),
      );
    }).toList();
  }

  List<Widget> _buildTopStudentsList() {
    return (widget.attendanceRankings.groupedByClassLevel ?? [])
        .expand((classLevel) => (classLevel.topStudents ?? []))
        .map((student) => AttendanceRankingItemContainer(
              topStudents: student,
              index: student.rank ?? 0,
            ))
        .toList();
  }
}
