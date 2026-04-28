import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kartu statistik kehadiran yang menampilkan jumlah dan persentase siswa.
/// Digunakan di TeacherViewAttendanceSubjectScreen dan halaman kehadiran lainnya.
class AttendanceStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final int total;
  final Color color;
  final bool small;

  const AttendanceStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    required this.total,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
        total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: small ? 10 : 16,
        horizontal: small ? 8 : 16,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: small ? 14 : 18,
                ),
              ),
              Text(
                '$percentage%',
                style: GoogleFonts.poppins(
                  fontSize: small ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: small ? 6 : 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: small ? 11 : 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$count/$total',
            style: GoogleFonts.poppins(
              fontSize: small ? 14 : 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
