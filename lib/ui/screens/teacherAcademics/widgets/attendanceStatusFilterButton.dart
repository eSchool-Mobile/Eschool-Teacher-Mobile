import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tombol filter status kehadiran yang kompak (Hadir, Tidak Hadir, Sakit, Izin, Alpa).
/// Digunakan di TeacherViewAttendanceSubjectScreen.
class AttendanceStatusFilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const AttendanceStatusFilterButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? color.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
              color: isSelected
                  ? color.withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? color : Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? color : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
