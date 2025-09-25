import 'dart:convert';

import 'package:eschool_saas_staff/app/app.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/firebase_options.dart';
import 'package:eschool_saas_staff/utils/in_appbanner.dart';
import 'package:eschool_saas_staff/utils/logger.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

///[V.1.4.1] - Staff App Version
///
///

Future<void> main() async {
  timeago.setLocaleMessages('id', timeago.IdMessages());
  await initializeDateFormatting('id');
  Encoding.getByName('utf-8');

  await initializeApp();
  // Setup FCM notification listener
  await setupFCM();
}

// Setup FCM notification listener & permission
Future<void> setupFCM() async {
  print('[FCM-SETUP] Starting FCM setup...');

  // Init Firebase kalau belum (aman dari freeze karena dipanggil setelah runApp)
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    print('[FCM-SETUP] Firebase initialized');
  } else {
    print('[FCM-SETUP] Firebase already initialized');
  }

  // Izin notifikasi (Android 13+ & iOS)
  final settings = await FirebaseMessaging.instance.requestPermission();
  print('[FCM-SETUP] Permission status: ${settings.authorizationStatus}');

  // Get FCM token untuk debugging
  final token = await FirebaseMessaging.instance.getToken();
  print('[FCM-SETUP] FCM Token: $token');
  print('[FCM-SETUP] ===== COPY TOKEN INI KE BACKEND/POSTMAN UNTUK TEST =====');
  print('[FCM-SETUP] Token untuk backend: $token');
  print('[FCM-SETUP] ====================================================');

  // Subscribe ke topic untuk testing (opsional)
  await FirebaseMessaging.instance.subscribeToTopic('staff_notifications');
  await FirebaseMessaging.instance.subscribeToTopic('all_notifications');
  print(
      '[FCM-SETUP] Subscribed to topics: staff_notifications, all_notifications');

  // Foreground: tampilkan banner non-modal (tanpa context)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('[FCM-FOREGROUND] ===== RECEIVED FOREGROUND MESSAGE =====');
    logRemoteMessageAndroid(message, tag: 'FCM-FOREGROUND');

    final type = (message.data['type'] ?? '')
        .toString(); // 'announcement' | 'leave_approved' | 'exam_created' | ...
    final title = (message.notification?.title ?? 'Notifikasi').toString();
    final body = (message.notification?.body ?? '').toString();

    print('[FCM-FOREGROUND] Type: $type');
    print('[FCM-FOREGROUND] Title: $title');
    print('[FCM-FOREGROUND] Body: $body');
    print('[FCM-FOREGROUND] Full Data: ${message.data}');

    // mapping type -> style
    final PushType style = mapPushType(type,
        status: message.data[
            'status']); // dto.status bisa 1/2/3 atau "approved"/"pending"/"rejected"

    print('[FCM-FOREGROUND] Mapped Style: $style');
    print('[FCM-FOREGROUND] Calling showPushBanner...');

    // ✅ tampilkan banner non-modal (tanpa BuildContext)
    showPushBanner(title: title, body: body, type: style);

    print('[FCM-FOREGROUND] showPushBanner called successfully');

    // contoh: kalau perlu update state lokal berdasarkan type/id, lakukan di sini
  });

  // Klik notifikasi saat app dibuka dari background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('[FCM-OPENED] ===== APP OPENED FROM NOTIFICATION =====');
    logRemoteMessageAndroid(message, tag: 'FCM-OPENED');
    final type = (message.data['type'] ?? '').toString();
    print('[FCM-OPENED] Notification type: $type');

    if (type == 'announcement') {
      print('[FCM-OPENED] Navigating to notifications screen...');
      Get.toNamed(Routes.notificationsScreen);
    } else {
      print('[FCM-OPENED] No specific navigation for type: $type');
    }
  });

  // Handle background/terminated app notifications
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    print('[FCM-INITIAL] ===== APP OPENED FROM TERMINATED STATE =====');
    logRemoteMessageAndroid(initialMessage, tag: 'FCM-INITIAL');
    final type = (initialMessage.data['type'] ?? '').toString();

    if (type == 'announcement') {
      print('[FCM-INITIAL] Will navigate to notifications after app starts...');
      // Navigate after app is fully initialized
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.toNamed(Routes.notificationsScreen);
      });
    }
  }

  print('[FCM-SETUP] FCM setup completed successfully');
}

/// Test function untuk trigger notifikasi manual (debugging)
void testNotificationBanner() {
  print('[TEST-NOTIFICATION] Triggering test banner...');
  showPushBanner(
    title: 'Test Notification',
    body: 'This is a test notification banner',
    type: PushType.success,
  );
}

/// Function untuk mendapatkan dan log FCM token (untuk debugging backend)
Future<String?> getFCMTokenForBackend() async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    print('[FCM-TOKEN] ===== FCM TOKEN FOR BACKEND =====');
    print('[FCM-TOKEN] Token: $token');
    print('[FCM-TOKEN] ================================');
    return token;
  } catch (e) {
    print('[FCM-TOKEN] Error getting token: $e');
    return null;
  }
}

/// Test function untuk simulasi FCM message
void testFCMMessage() {
  print('[TEST-FCM] Simulating FCM message...');

  // Simulasi data seperti yang dikirim FCM
  final testType = 'leave_approved';
  final testTitle = 'Cuti Disetujui';
  final testBody = 'Permohonan cuti Anda telah disetujui';

  // Mapping type -> style (sama seperti di onMessage handler)
  final PushType style = mapPushType(testType, status: 1);

  print('[TEST-FCM] Type: $testType');
  print('[TEST-FCM] Title: $testTitle');
  print('[TEST-FCM] Body: $testBody');
  print('[TEST-FCM] Mapped Style: $style');

  // Trigger banner
  showPushBanner(title: testTitle, body: testBody, type: style);
}

int? _normalizeLeaveStatus(dynamic status) {
  // dukung int atau string
  if (status == null) return null;
  if (status is int) return status;

  final s = status.toString().trim().toLowerCase();
  switch (s) {
    case '1':
    case 'approved':
    case 'disetujui':
      return 1;
    case '2':
    case 'pending':
    case 'tertunda':
      return 2;
    case '3':
    case 'rejected':
    case 'ditolak':
      return 3;
    default:
      return null;
  }
}

PushType mapPushType(String? rawType, {dynamic status}) {
  // normalisasi: null → "", trim, lowercase, '-' -> '_'
  final key = (rawType ?? '').trim().toLowerCase().replaceAll('-', '_');

  return switch (key) {
    // Assignment / Tugas (tidak ada di staff app, tapi untuk consistency)
    'assignment_created' || 'assignment_updated' || 'tugas' => PushType.info,

    // Attendance
    'attendance_update' => PushType.info,
    'attendance_marked' => PushType.success,

    // Exam (luring)
    'exam_created' => PushType.info,
    'exam_result_published' => PushType.success,
    'exam_marks_updated' => PushType.info,
    // Online Exam
    'online_exam_created' => PushType.success,
    'online_exam_updated' => PushType.info,
    'online_exam_cancelled' => PushType.error,
    'online_exam_questions_ready' => PushType.success,
    'online_exam_corrected' => PushType.success,

    // Leave (perizinan) - Staff specific
    'leave_approved' => PushType.success,
    'leave_rejected' => PushType.error,
    'staff_leave_approved' => PushType.success,
    'staff_leave_rejected' => PushType.error,
    'leave_status' => switch (_normalizeLeaveStatus(status)) {
        1 => PushType.success, // disetujui
        2 => PushType.warning, // tertunda
        3 => PushType.error, // ditolak
        _ => PushType.info, // fallback aman (jangan warning)
      },

    // Lesson - Staff specific
    'lesson_created' || 'lesson_updated' => PushType.info,

    // Lesson Topic - Staff specific
    'topic_created' || 'topic_updated' => PushType.info,

    // Announcement
    'announcement_created' || 'announcement_updated' => PushType.info,

    // Promote / Transfer Student - Staff related
    'student_promoted' => PushType.success,
    'student_transferred' => PushType.warning,

    // Default
    _ => PushType.success,
  };
}

// Fungsi untuk menampilkan dialog pengumuman (opsional, untuk staff app)
void showAnnouncementDialog(String? title, String? body) {
  // Pastikan context global tersedia, atau gunakan Get.dialog jika pakai GetX
  Get.dialog(
    AlertDialog(
      title: Text(title ?? 'Pengumuman'),
      content: Text(body ?? ''),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Tutup'),
        ),
      ],
    ),
    barrierDismissible: true,
  );
}

/// Get FCM token for registration
Future<String?> getFCMToken() async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print('[FCM-TOKEN] Current token: $token');
    }
    return token;
  } catch (e) {
    print('[FCM-TOKEN] Error getting token: $e');
    return null;
  }
}

/// Subscribe to specific notification topics
Future<void> subscribeToTopics(List<String> topics) async {
  try {
    for (final topic in topics) {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      print('[FCM-TOPIC] Subscribed to: $topic');
    }
  } catch (e) {
    print('[FCM-TOPIC] Error subscribing: $e');
  }
}

/// Unsubscribe from specific notification topics
Future<void> unsubscribeFromTopics(List<String> topics) async {
  try {
    for (final topic in topics) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      print('[FCM-TOPIC] Unsubscribed from: $topic');
    }
  } catch (e) {
    print('[FCM-TOPIC] Error unsubscribing: $e');
  }
}
