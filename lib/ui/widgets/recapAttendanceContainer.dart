import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/recapAttendenceItemContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eschool_saas_staff/utils/colorPalette.dart';

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

    if (availableMonths == 0) {
      return FadeIn(
        duration: Duration(milliseconds: 800),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColorPalette.warmBeige,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColorPalette.primaryMaroon.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 64,
                  color: AppColorPalette.primaryMaroon.withOpacity(0.5),
                ),
                SizedBox(height: 20),
                Text(
                  'Data Rekap Belum Tersedia',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColorPalette.primaryMaroon,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tahun $selectedYear',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColorPalette.secondaryMaroon,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        color: AppColorPalette.warmBeige.withOpacity(0.5),
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: List.generate(availableMonths, (monthIndex) {
            return FadeInUp(
              duration: Duration(milliseconds: 400 + (monthIndex * 100)),
              child: Container(
                margin: EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorPalette.primaryMaroon.withOpacity(0.08),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMonthHeader(monthIndex),
                    _buildClassList(monthIndex, context),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMonthHeader(int monthIndex) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColorPalette.primaryMaroon,
            AppColorPalette.secondaryMaroon,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getMonthName(monthIndex + 1),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$selectedYear',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassList(int monthIndex, BuildContext context) {
    // Ambil hanya satu kelas untuk setiap bulan (index pertama)
    final section = classSections.isNotEmpty ? classSections[0] : null;

    return Padding(
      padding: EdgeInsets.all(24),
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
                    color: AppColorPalette.primaryMaroon,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                'Aksi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColorPalette.primaryMaroon,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Divider(
            color: AppColorPalette.lightMaroon,
            thickness: 1,
            height: 32,
          ),
          if (section != null) _buildClassItem(section, monthIndex, context),
        ],
      ),
    );
  }

  Widget _buildClassItem(
      ClassSection section, int monthIndex, BuildContext context) {
    return SlideInRight(
      duration: Duration(milliseconds: 400),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: section.pkl == 1
              ? Colors.grey.shade100
              : AppColorPalette.warmBeige.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: section.pkl == 1
                ? Colors.grey.shade300
                : AppColorPalette.lightMaroon,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(
                    section.pkl == 1
                        ? Icons.business_center_rounded
                        : Icons.school_rounded,
                    color: section.pkl == 1
                        ? Colors.grey
                        : AppColorPalette.secondaryMaroon,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section.name ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: section.pkl == 1
                            ? Colors.grey.shade700
                            : AppColorPalette.primaryMaroon,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildActionButtons(section, monthIndex, context),
          ],
        ),
      ),
    );
  }

  // Update the existing _buildActionButtons method with new styling
  Widget _buildActionButtons(
      ClassSection section, int monthIndex, BuildContext context) {
    final bool isPKL = section.pkl == 1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon:
              isPKL ? Icons.business_center_rounded : Icons.visibility_rounded,
          label: 'Preview',
          onPressed: () => _previewRecap(context, section, monthIndex + 1),
          isPrimary: true,
          isPKL: isPKL,
        ),
        SizedBox(width: 8),
        _buildActionButton(
          icon: isPKL ? Icons.business_center_rounded : Icons.download_rounded,
          label: 'Unduh',
          onPressed: () => isPKL
              ? _showPKLNotification(context, section.name ?? 'Kelas ini')
              : onDownload(section, monthIndex + 1),
          isPrimary: false,
          isPKL: isPKL,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
    required bool isPKL,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isPKL
                ? Colors.grey.shade300
                : isPrimary
                    ? AppColorPalette.primaryMaroon
                    : AppColorPalette.secondaryMaroon,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isPKL
                    ? Colors.grey.withOpacity(0.2)
                    : AppColorPalette.primaryMaroon.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
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
