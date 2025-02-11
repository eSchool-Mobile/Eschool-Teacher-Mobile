import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/recapAttendenceItemContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';

class RecapAttendanceContainer extends StatelessWidget {
  final List<ClassSection> classSections;
  final Function(ClassSection, int) onDownload;
  final int selectedYear;
  final String? email;
  final int? schoolId; // Tambahkan parameter schoolId

  const RecapAttendanceContainer({
    Key? key,
    required this.classSections,
    required this.onDownload,
    required this.selectedYear,
    this.email,
    this.schoolId, // Tambahkan ini
  }) : super(key: key);

  // Update the _previewRecap method
  void _previewRecap(
      BuildContext context, ClassSection section, int month) async {
    // Check if class is in PKL
    if (section.pkl == 1) {
      _showPKLNotification(context, section.name ?? 'Kelas ini');
      return;
    }

    if (schoolId == null) {
      print('School ID is null');
      return;
    }

    final url = Uri.parse('https://eschool.ac.id/recap-download'
        '?school_id=$schoolId' // Gunakan schoolId yang diterima dari parameter
        '&class_id=${section.classDetails?.id}'
        '&class_section_id=${section.id}'
        '&month=$month'
        '&year=$selectedYear'
        '&email=${Uri.encodeComponent(email ?? "")}'
        '&gm=naowndoianwodinaiwondaoiwnd'
        '&download=false');

    print('Preview URL: $url'); // Debug log

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.inAppWebView);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching preview URL: $e');
    }
  }

  // Add this new method to show PKL notification
  void _showPKLNotification(BuildContext context, String className) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange[700],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Kelas Sedang PKL',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            '$className sedang melaksanakan PKL (Praktik Kerja Lapangan). '
            'Rekap absensi tidak tersedia selama periode PKL.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Tutup',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final availableMonths = selectedYear < now.year
        ? 12
        : selectedYear > now.year
            ? 0
            : now.month;

    // Calm red color palette
    final primaryColor = Color(0xFFF5CAC3);
    final secondaryColor = Color(0xFFEAB0A9);
    final accentColor = Color(0xFFD3756B);
    final textColor = Color(0xFF84423A);
    final backgroundColor = Color(0xFFFFF5F5);

    if (availableMonths == 0) {
      return FadeIn(
        duration: Duration(milliseconds: 800),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: textColor.withOpacity(0.5),
              ),
              SizedBox(height: 16),
              Text(
                'Data rekap belum tersedia\nuntuk tahun $selectedYear',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        color: backgroundColor,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: List.generate(availableMonths, (monthIndex) {
            return FadeInUp(
              duration: Duration(milliseconds: 400 + (monthIndex * 100)),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 15,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, secondaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.calendar_today_rounded,
                              color: textColor,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getMonthName(monthIndex + 1),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                '$selectedYear',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textColor.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Kelas',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              Text(
                                'Unduh',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          Divider(
                              color: primaryColor.withOpacity(0.3),
                              thickness: 1,
                              height: 32),
                          ...classSections
                              .map((section) => Padding(
                                    padding: EdgeInsets.only(bottom: 16),
                                    child: FadeIn(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              section.name ?? '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color:
                                                    textColor.withOpacity(0.9),
                                              ),
                                            ),
                                          ),
                                          _buildActionButtons(
                                              section, monthIndex, context),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // Update the _buildActionButtons method
  Widget _buildActionButtons(
      ClassSection section, int monthIndex, BuildContext context) {
    final bool isPKL = section.pkl == 1;
    final primaryColor = isPKL ? Colors.grey : Color(0xFFEAB0A9);
    final secondaryColor = isPKL ? Colors.grey : Color(0xFFD3756B);

    return Row(
      children: [
        Tooltip(
          message:
              isPKL ? '${section.name} sedang PKL' : 'Preview rekap absensi',
          child: ElevatedButton.icon(
            onPressed: () => _previewRecap(context, section, monthIndex + 1),
            icon: Icon(
                isPKL
                    ? Icons.business_center_rounded
                    : Icons.visibility_rounded,
                size: 20),
            label: Text('Preview'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        SizedBox(width: 8),
        Tooltip(
          message: isPKL ? '${section.name} sedang PKL' : 'Unduh rekap absensi',
          child: ElevatedButton.icon(
            onPressed: () => isPKL
                ? _showPKLNotification(context, section.name ?? 'Kelas ini')
                : onDownload(section, monthIndex + 1),
            icon: Icon(
                isPKL ? Icons.business_center_rounded : Icons.download_rounded,
                size: 20),
            label: Text('Unduh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month - 1];
  }
}
