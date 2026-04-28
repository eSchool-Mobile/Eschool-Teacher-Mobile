// Contoh penggunaan notifikasi eSchool Staff
// Import file ini di main.dart atau tempat lain yang diperlukan

import 'package:get/get.dart';
import 'package:eschool_saas_staff/utils/system/in_appbanner.dart';

/// Contoh notifikasi untuk berbagai skenario di aplikasi staff
class NotificationExamples {
  /// 1. Notifikasi info umum
  static void showInfoNotification() {
    showPushBanner(
      title: 'Pengumuman Baru',
      body:
          'Ada pengumuman penting dari Kepala Sekolah mengenai jadwal libur semester',
      type: PushType.info,
    );
  }

  /// 2. Notifikasi sukses (cuti disetujui)
  static void showSuccessNotification() {
    showPushBanner(
      title: 'Cuti Disetujui ✓',
      body: 'Permohonan cuti Anda telah disetujui oleh Kepala Sekolah',
      type: PushType.success,
      onTap: () {
        // Navigasi ke halaman detail cuti
        Get.toNamed('/leave-details');
      },
    );
  }

  /// 3. Notifikasi warning (deadline)
  static void showWarningNotification() {
    showPushBanner(
      title: 'Batas Waktu Hampir Berakhir',
      body: 'Pengumpulan nilai ujian semester berakhir dalam 24 jam',
      type: PushType.warning,
      duration: const Duration(seconds: 6), // Durasi lebih lama untuk warning
    );
  }

  /// 4. Notifikasi error (cuti ditolak)
  static void showErrorNotification() {
    showPushBanner(
      title: 'Permohonan Ditolak',
      body: 'Permohonan cuti ditolak. Silakan hubungi bagian administrasi',
      type: PushType.error,
      onTap: () {
        // Navigasi ke kontak admin
        Get.toNamed('/contact-admin');
      },
    );
  }

  /// 5. Notifikasi tugas baru
  static void showNewAssignmentNotification() {
    showPushBanner(
      title: 'Tugas Baru Tersedia',
      body: 'Tugas matematika telah ditambahkan untuk kelas XII-A',
      type: PushType.info,
      onTap: () {
        Get.toNamed('/assignments');
      },
    );
  }

  /// 6. Notifikasi absensi
  static void showAttendanceNotification() {
    showPushBanner(
      title: 'Absensi Berhasil Direkam',
      body: 'Absensi kelas XI-B telah berhasil disimpan',
      type: PushType.success,
    );
  }

  /// 7. Notifikasi ujian
  static void showExamNotification() {
    showPushBanner(
      title: 'Ujian Matematika',
      body: 'Ujian matematika kelas XII akan dimulai dalam 30 menit',
      type: PushType.warning,
      onTap: () {
        Get.toNamed('/exam-schedule');
      },
    );
  }

  /// 8. Preview semua jenis notifikasi (untuk testing)
  static void previewAllNotifications() {
    final notifications = [
      {
        'title': 'Info Notification',
        'body': 'Contoh notifikasi informasi umum',
        'type': PushType.info,
      },
      {
        'title': 'Success Notification',
        'body': 'Contoh notifikasi berhasil',
        'type': PushType.success,
      },
      {
        'title': 'Warning Notification',
        'body': 'Contoh notifikasi peringatan',
        'type': PushType.warning,
      },
      {
        'title': 'Error Notification',
        'body': 'Contoh notifikasi error',
        'type': PushType.error,
      },
    ];

    int delay = 0;
    for (final notification in notifications) {
      Future.delayed(Duration(seconds: delay), () {
        showPushBanner(
          title: notification['title'] as String,
          body: notification['body'] as String,
          type: notification['type'] as PushType,
          duration: const Duration(seconds: 3),
        );
      });
      delay += 2; // Delay 2 detik antar notifikasi
    }
  }
}
