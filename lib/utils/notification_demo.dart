import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'in_appbanner.dart';

/// Demo screen untuk mentest desain clean notification banner
class NotificationDemoScreen extends StatelessWidget {
  const NotificationDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        title: Text(
          'Clean Notification Demo',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF64748B)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Test Clean Notifications',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Desain bersih, elegan, dan nyaman dipandang\nTanpa blur, tetap solid dengan warna lembut',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Demo Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildDemoCard(
                  title: 'Info',
                  description: 'Informasi umum',
                  color: const Color(0xFF3B82F6),
                  icon: Icons.info_outline_rounded,
                  onTap: () => _showInfoDemo(),
                ),
                _buildDemoCard(
                  title: 'Success',
                  description: 'Berhasil',
                  color: const Color(0xFF10B981),
                  icon: Icons.check_circle_outline_rounded,
                  onTap: () => _showSuccessDemo(),
                ),
                _buildDemoCard(
                  title: 'Warning',
                  description: 'Peringatan',
                  color: const Color(0xFFF59E0B),
                  icon: Icons.warning_amber_outlined,
                  onTap: () => _showWarningDemo(),
                ),
                _buildDemoCard(
                  title: 'Error',
                  description: 'Kesalahan',
                  color: const Color(0xFFEF4444),
                  icon: Icons.error_outline_rounded,
                  onTap: () => _showErrorDemo(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // School scenarios section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        color: const Color(0xFF3B82F6),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Skenario Sekolah',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildScenarioButton(
                    'Cuti Disetujui ✓',
                    'Permohonan cuti Anda telah disetujui oleh Kepala Sekolah untuk tanggal 26-27 September 2025',
                    PushType.success,
                    Icons.event_available_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildScenarioButton(
                    'Tugas Baru Ditambahkan',
                    'Tugas Matematika baru telah ditambahkan untuk kelas XII-A. Deadline: 30 September 2025',
                    PushType.info,
                    Icons.assignment_outlined,
                  ),
                  const SizedBox(height: 10),
                  _buildScenarioButton(
                    'Batas Waktu Segera Berakhir',
                    'Pengumpulan nilai ujian semester akan berakhir dalam 2 hari. Harap segera dilengkapi',
                    PushType.warning,
                    Icons.schedule_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildScenarioButton(
                    'Permohonan Ditolak',
                    'Maaf, permohonan cuti ditolak. Silakan hubungi bagian administrasi untuk informasi lebih lanjut',
                    PushType.error,
                    Icons.cancel_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard({
    required String title,
    required String description,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioButton(
      String title, String message, PushType type, IconData icon) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => showPushBanner(
          title: title,
          body: message,
          type: type,
          onTap: () => Get.snackbar(
            'Aksi Dipicu',
            'Anda mengetuk: $title',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF1E293B),
            colorText: Colors.white,
            borderRadius: 8,
            margin: const EdgeInsets.all(16),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFAFBFC),
          foregroundColor: const Color(0xFF475569),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: const Color(0xFF64748B),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.play_arrow_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDemo() {
    showPushBanner(
      title: 'Pengumuman Penting',
      body:
          'Ada pengumuman baru dari Kepala Sekolah mengenai jadwal libur semester dan persiapan ujian akhir tahun',
      type: PushType.info,
      onTap: () => Get.snackbar(
        'Info Diklik',
        'Membuka halaman pengumuman...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF3B82F6),
        colorText: Colors.white,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessDemo() {
    showPushBanner(
      title: 'Berhasil Disetujui ✓',
      body:
          'Permohonan cuti Anda untuk tanggal 26-27 September 2025 telah disetujui oleh Kepala Sekolah',
      type: PushType.success,
      onTap: () => Get.snackbar(
        'Sukses Diklik',
        'Membuka detail permohonan...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showWarningDemo() {
    showPushBanner(
      title: 'Segera Berakhir!',
      body:
          'Batas waktu pengumpulan nilai ujian semester akan berakhir dalam 24 jam. Harap segera dilengkapi',
      type: PushType.warning,
      onTap: () => Get.snackbar(
        'Warning Diklik',
        'Membuka halaman pengumpulan nilai...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF59E0B),
        colorText: Colors.white,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorDemo() {
    showPushBanner(
      title: 'Permohonan Ditolak',
      body:
          'Maaf, permohonan cuti Anda ditolak karena jadwal bentrok dengan acara sekolah. Silakan hubungi admin',
      type: PushType.error,
      onTap: () => Get.snackbar(
        'Error Diklik',
        'Membuka informasi kontak...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
