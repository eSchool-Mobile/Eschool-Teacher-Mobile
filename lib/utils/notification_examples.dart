// Contoh penggunaan berbagai tema notifikasi
// Import file ini di main.dart atau tempat lain yang diperlukan

import 'package:get/get.dart';
import 'package:eschool_saas_staff/utils/in_appbanner.dart';

// 1. Mengubah tema global (berlaku untuk semua notifikasi)
void setupNotificationTheme() {
  // Pilih salah satu tema:
  // - NotificationTheme.modern (default) - gradient dengan shadow
  // - NotificationTheme.classic - seperti sebelumnya
  // - NotificationTheme.minimal - border dengan background putih
  // - NotificationTheme.card - rounded corners besar dengan shadow

  setNotificationTheme(NotificationTheme.modern);
}

// 2. Contoh penggunaan notifikasi dengan tema berbeda
void exampleNotifications() {
  // Notifikasi dengan tema global
  showPushBanner(
    title: 'Pengumuman Baru',
    body: 'Ada pengumuman penting dari sekolah',
    type: PushType.info,
  );

  // Notifikasi dengan tema spesifik (override tema global)
  showPushBanner(
    title: 'Tugas Berhasil Dikumpulkan',
    body: 'Tugas matematika telah dikoreksi',
    type: PushType.success,
    theme: NotificationTheme.card, // Pakai tema card meskipun global tema lain
  );

  // Notifikasi error dengan tema minimal
  showPushBanner(
    title: 'Koneksi Gagal',
    body: 'Periksa koneksi internet Anda',
    type: PushType.error,
    theme: NotificationTheme.minimal,
    duration: const Duration(seconds: 6), // Durasi lebih lama
  );

  // Notifikasi warning dengan tema klasik
  showPushBanner(
    title: 'Pengingat',
    body: 'Deadline pengumpulan tugas besok',
    type: PushType.warning,
    theme: NotificationTheme.classic,
  );
}

// 3. Menggunakan notifikasi dengan action button
void notificationWithAction() {
  showPushBanner(
    title: 'Pesan Baru',
    body: 'Anda memiliki pesan dari guru',
    type: PushType.info,
    onTap: () {
      // Navigasi ke halaman pesan
      Get.toNamed('/messages');
    },
  );
}

// 4. Preview semua tema sekaligus (untuk testing)
void previewAllThemes() {
  final types = [
    PushType.info,
    PushType.success,
    PushType.warning,
    PushType.error
  ];
  final themes = [
    NotificationTheme.modern,
    NotificationTheme.classic,
    NotificationTheme.minimal,
    NotificationTheme.card
  ];

  int delay = 0;
  for (final theme in themes) {
    for (final type in types) {
      Future.delayed(Duration(seconds: delay), () {
        showPushBanner(
          title: '${theme.name} - ${type.name}',
          body: 'Contoh notifikasi dengan tema ${theme.name}',
          type: type,
          theme: theme,
          duration: const Duration(seconds: 3),
        );
      });
      delay += 1;
    }
  }
}
