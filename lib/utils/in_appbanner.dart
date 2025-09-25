import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tipe notifikasi untuk styling yang berbeda
enum PushType {
  info,
  success,
  warning,
  error,
}

/// Style tema notifikasi
enum NotificationTheme {
  modern, // Tema modern dengan gradient dan shadow
  classic, // Tema klasik seperti sekarang
  minimal, // Tema minimal dengan border
  card, // Tema card dengan rounded corners besar
}

/// Global theme setting - bisa diubah sesuai preferensi
NotificationTheme _currentTheme = NotificationTheme.modern;

/// Mengubah tema notifikasi global
void setNotificationTheme(NotificationTheme theme) {
  _currentTheme = theme;
}

/// Mendapatkan tema notifikasi saat ini
NotificationTheme getNotificationTheme() {
  return _currentTheme;
}

/// Menampilkan banner push notification tanpa memerlukan BuildContext
/// Menggunakan Get.snackbar dari GetX yang sudah ada di project
void showPushBanner({
  required String title,
  required String body,
  PushType type = PushType.info,
  NotificationTheme? theme, // Jika null, gunakan tema global
  Duration duration = const Duration(seconds: 4),
  VoidCallback? onTap,
}) {
  // Gunakan tema yang diberikan atau tema global
  final notificationTheme = theme ?? _currentTheme;

  // Mapping warna berdasarkan tipe
  final colorConfig = _getColorConfig(type);

  switch (notificationTheme) {
    case NotificationTheme.modern:
      _showModernNotification(title, body, colorConfig, duration, onTap);
      break;
    case NotificationTheme.classic:
      _showClassicNotification(title, body, colorConfig, duration, onTap);
      break;
    case NotificationTheme.minimal:
      _showMinimalNotification(title, body, colorConfig, duration, onTap);
      break;
    case NotificationTheme.card:
      _showCardNotification(title, body, colorConfig, duration, onTap);
      break;
  }
}

/// Notifikasi modern dengan gradient dan shadow
void _showModernNotification(String title, String body,
    _ColorConfig colorConfig, Duration duration, VoidCallback? onTap) {
  Get.snackbar(
    title,
    body,
    titleText: Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
    ),
    messageText: Text(
      body,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.95),
      ),
    ),
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.transparent, // Transparent untuk gradient
    colorText: Colors.white,
    borderRadius: 16,
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    icon: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        colorConfig.icon,
        color: Colors.white,
        size: 28,
      ),
    ),
    shouldIconPulse: true,
    duration: duration,
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
    forwardAnimationCurve: Curves.easeOutBack,
    reverseAnimationCurve: Curves.easeInBack,
    animationDuration: const Duration(milliseconds: 600),
    onTap: onTap != null ? (_) => onTap() : null,
    mainButton: onTap != null
        ? TextButton(
            onPressed: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Lihat',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          )
        : null,
    boxShadows: [
      BoxShadow(
        color: colorConfig.backgroundColor.withOpacity(0.4),
        blurRadius: 12,
        offset: const Offset(0, 4),
        spreadRadius: 2,
      ),
    ],
    backgroundGradient: LinearGradient(
      colors: [
        colorConfig.backgroundColor,
        colorConfig.backgroundColor.withOpacity(0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}

/// Notifikasi klasik (seperti sebelumnya)
void _showClassicNotification(String title, String body,
    _ColorConfig colorConfig, Duration duration, VoidCallback? onTap) {
  Get.snackbar(
    title,
    body,
    titleText: Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorConfig.textColor,
      ),
    ),
    messageText: Text(
      body,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorConfig.textColor.withOpacity(0.8),
      ),
    ),
    snackPosition: SnackPosition.TOP,
    backgroundColor: colorConfig.backgroundColor,
    colorText: colorConfig.textColor,
    borderRadius: 12,
    margin: const EdgeInsets.all(16),
    icon: Icon(
      colorConfig.icon,
      color: colorConfig.iconColor,
      size: 24,
    ),
    shouldIconPulse: true,
    duration: duration,
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
    forwardAnimationCurve: Curves.easeOutBack,
    reverseAnimationCurve: Curves.easeInBack,
    animationDuration: const Duration(milliseconds: 500),
    onTap: onTap != null ? (_) => onTap() : null,
    mainButton: onTap != null
        ? TextButton(
            onPressed: onTap,
            child: Text(
              'Lihat',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorConfig.actionColor,
              ),
            ),
          )
        : null,
  );
}

/// Notifikasi minimal dengan border
void _showMinimalNotification(String title, String body,
    _ColorConfig colorConfig, Duration duration, VoidCallback? onTap) {
  Get.snackbar(
    title,
    body,
    titleText: Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: colorConfig.backgroundColor,
      ),
    ),
    messageText: Text(
      body,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Colors.grey[700]!,
      ),
    ),
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.white,
    colorText: colorConfig.backgroundColor,
    borderRadius: 8,
    margin: const EdgeInsets.all(16),
    borderColor: colorConfig.backgroundColor,
    borderWidth: 2,
    icon: Icon(
      colorConfig.icon,
      color: colorConfig.backgroundColor,
      size: 24,
    ),
    shouldIconPulse: false,
    duration: duration,
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
    forwardAnimationCurve: Curves.easeOut,
    reverseAnimationCurve: Curves.easeIn,
    animationDuration: const Duration(milliseconds: 400),
    onTap: onTap != null ? (_) => onTap() : null,
    mainButton: onTap != null
        ? TextButton(
            onPressed: onTap,
            child: Text(
              'Lihat',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorConfig.backgroundColor,
              ),
            ),
          )
        : null,
  );
}

/// Notifikasi card dengan rounded corners besar
void _showCardNotification(String title, String body, _ColorConfig colorConfig,
    Duration duration, VoidCallback? onTap) {
  Get.snackbar(
    title,
    body,
    titleText: Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: colorConfig.textColor,
      ),
    ),
    messageText: Text(
      body,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorConfig.textColor.withOpacity(0.9),
      ),
    ),
    snackPosition: SnackPosition.TOP,
    backgroundColor: colorConfig.backgroundColor,
    colorText: colorConfig.textColor,
    borderRadius: 24,
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    icon: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorConfig.iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        colorConfig.icon,
        color: colorConfig.iconColor,
        size: 32,
      ),
    ),
    shouldIconPulse: true,
    duration: duration,
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
    forwardAnimationCurve: Curves.elasticOut,
    reverseAnimationCurve: Curves.easeInBack,
    animationDuration: const Duration(milliseconds: 700),
    onTap: onTap != null ? (_) => onTap() : null,
    mainButton: onTap != null
        ? TextButton(
            onPressed: onTap,
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorConfig.actionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Lihat Detail',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorConfig.actionColor,
                ),
              ),
            ),
          )
        : null,
    boxShadows: [
      BoxShadow(
        color: colorConfig.backgroundColor.withOpacity(0.3),
        blurRadius: 20,
        offset: const Offset(0, 8),
        spreadRadius: 4,
      ),
    ],
  );
}

/// Konfigurasi warna untuk setiap tipe notifikasi
class _ColorConfig {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color actionColor;
  final IconData icon;

  const _ColorConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.actionColor,
    required this.icon,
  });
}

_ColorConfig _getColorConfig(PushType type) {
  switch (type) {
    case PushType.info:
      return const _ColorConfig(
        backgroundColor: Color(0xFF2196F3),
        textColor: Colors.white,
        iconColor: Colors.white,
        actionColor: Colors.white,
        icon: Icons.info_outline,
      );
    case PushType.success:
      return const _ColorConfig(
        backgroundColor: Color(0xFF4CAF50),
        textColor: Colors.white,
        iconColor: Colors.white,
        actionColor: Colors.white,
        icon: Icons.check_circle_outline,
      );
    case PushType.warning:
      return const _ColorConfig(
        backgroundColor: Color(0xFFFF9800),
        textColor: Colors.white,
        iconColor: Colors.white,
        actionColor: Colors.white,
        icon: Icons.warning_amber_outlined,
      );
    case PushType.error:
      return const _ColorConfig(
        backgroundColor: Color(0xFFF44336),
        textColor: Colors.white,
        iconColor: Colors.white,
        actionColor: Colors.white,
        icon: Icons.error_outline,
      );
  }
}
