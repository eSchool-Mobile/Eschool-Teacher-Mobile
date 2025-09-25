import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Test utility untuk FCM notifications
/// File ini hanya untuk development/testing purposes
class NotificationTestUtils {
  /// Simulate local notification untuk testing
  static Future<void> testLocalNotification() async {
    if (!kDebugMode) return;

    // Simulate RemoteMessage untuk testing
    final Map<String, dynamic> testData = {
      'messageId': 'test_${DateTime.now().millisecondsSinceEpoch}',
      'notification': {
        'title': 'Test Notification',
        'body': 'Ini adalah test notifikasi lokal',
      },
      'data': {
        'type': 'leave_approved',
        'user_id': '123',
        'leave_id': '456',
      },
    };

    // Log test message
    debugPrint('[TEST] Simulating local notification...');
    debugPrint('[TEST] Title: ${testData['notification']['title']}');
    debugPrint('[TEST] Body: ${testData['notification']['body']}');
    debugPrint('[TEST] Type: ${testData['data']['type']}');
    debugPrint('[TEST] Full payload: ${json.encode(testData)}');
  }

  /// Test different notification types
  static List<Map<String, dynamic>> getTestNotificationScenarios() {
    return [
      {
        'title': 'Cuti Disetujui',
        'body': 'Permohonan cuti Anda dari tanggal 25-09-2025 telah disetujui',
        'type': 'leave_approved',
        'expectedRoute': 'Routes.leaveRequestScreen'
      },
      {
        'title': 'Cuti Ditolak',
        'body':
            'Permohonan cuti Anda ditolak dengan alasan: Jadwal mengajar padat',
        'type': 'leave_rejected',
        'expectedRoute': 'Routes.leaveRequestScreen'
      },
      {
        'title': 'Ujian Baru',
        'body':
            'Ujian Matematika kelas 10A telah dibuat untuk tanggal 30-09-2025',
        'type': 'exam_created',
        'expectedRoute': 'Routes.notificationsScreen'
      },
      {
        'title': 'Pengumuman',
        'body': 'Pengumuman: Rapat guru akan dilaksanakan besok pagi',
        'type': 'announcement_created',
        'expectedRoute': 'Routes.notificationsScreen'
      },
      {
        'title': 'Absensi Update',
        'body': 'Absensi kelas 10B telah diupdate untuk hari ini',
        'type': 'attendance_update',
        'expectedRoute': 'Routes.notificationsScreen'
      },
    ];
  }

  /// Generate test FCM payload
  static Map<String, dynamic> generateTestFCMPayload(String type) {
    final scenarios = getTestNotificationScenarios();
    final scenario = scenarios.firstWhere(
      (s) => s['type'] == type,
      orElse: () => scenarios.first,
    );

    return {
      'messageId': 'test_${type}_${DateTime.now().millisecondsSinceEpoch}',
      'notification': {
        'title': scenario['title'],
        'body': scenario['body'],
      },
      'data': {
        'type': type,
        'user_id': '123',
        'timestamp': DateTime.now().toIso8601String(),
      },
    };
  }

  /// Print FCM token untuk testing
  static Future<void> printCurrentFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('=== FCM TOKEN FOR TESTING ===');
      debugPrint('Token: $token');
      debugPrint('============================');

      // Copy to clipboard friendly format
      debugPrint('Backend Registration Format:');
      debugPrint(json.encode({
        'user_id': 'STAFF_USER_ID',
        'device_type': 'android', // or 'ios'
        'fcm_token': token,
        'app_type': 'staff'
      }));
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  /// Test notification navigation
  static void testNotificationNavigation(String type) {
    debugPrint('=== TESTING NAVIGATION FOR TYPE: $type ===');

    // Log expected navigation
    final expectedRoute = _getExpectedRoute(type);
    debugPrint('Expected navigation: $expectedRoute');
    debugPrint('Type: $type');

    // Note: Actual navigation test perlu dilakukan dengan UI testing
    // atau dengan membuat wrapper function di main.dart
  }

  static String _getExpectedRoute(String type) {
    switch (type.toLowerCase()) {
      case 'leave_approved':
      case 'leave_rejected':
      case 'staff_leave_approved':
      case 'staff_leave_rejected':
        return 'Routes.leaveRequestScreen';
      default:
        return 'Routes.notificationsScreen';
    }
  }

  /// Test semua skenario notifikasi
  static void runAllTests() {
    debugPrint('=== RUNNING ALL NOTIFICATION TESTS ===');

    final scenarios = getTestNotificationScenarios();
    for (final scenario in scenarios) {
      debugPrint('Testing: ${scenario['type']}');
      debugPrint('  Title: ${scenario['title']}');
      debugPrint('  Expected Route: ${scenario['expectedRoute']}');
      testNotificationNavigation(scenario['type']);
      debugPrint('---');
    }

    debugPrint('=== ALL TESTS COMPLETED ===');
  }
}

/// Cara penggunaan:
/// 1. Import file ini di screen yang ingin test
/// 2. Panggil fungsi test yang dibutuhkan
/// 
/// Contoh:
/// ```dart
/// // Di initState() atau onPressed button
/// NotificationTestUtils.printCurrentFCMToken();
/// NotificationTestUtils.runAllTests();
/// ```