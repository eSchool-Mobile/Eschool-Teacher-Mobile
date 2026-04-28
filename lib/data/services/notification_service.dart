import 'package:eschool_saas_staff/app/routes.dart';

import 'package:eschool_saas_staff/utils/system/constants.dart';
import 'package:eschool_saas_staff/utils/system/in_appbanner.dart';
import 'package:eschool_saas_staff/utils/system/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../firebase_options.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();

  static NotificationService get instance => _instance;

  NotificationService._internal();

  /// Initialize Firebase and FCM
  Future<void> init() async {
    AppLogger.info('NotificationService', 'Starting FCM setup...');

    // Init Firebase if needed
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      AppLogger.info('NotificationService', 'Firebase initialized');
    } else {
      AppLogger.info('NotificationService', 'Firebase already initialized');
    }

    // Request permissions
    final settings = await FirebaseMessaging.instance.requestPermission();
    AppLogger.info('NotificationService',
        'Permission status: ${settings.authorizationStatus}');

    // Debug Token
    await _logFCMToken();

    // Subscribe to topics
    await subscribeToTopics([staffNotificationsTopic, allNotificationsTopic]);

    // Setup listeners
    _setupListeners();

    // Handle background launch
    _checkInitialMessage();

    AppLogger.info('NotificationService', 'FCM setup completed successfully');
  }

  Future<void> _logFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      AppLogger.info('NotificationService', 'FCM Token: $token');
      // Uncomment to print for easy copy-paste in dev
      // debugPrint('[FCM-TOKEN] $token');
    } catch (e) {
      AppLogger.error('NotificationService', 'Error getting token', error: e);
    }
  }

  void _setupListeners() {
    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info('NotificationService', 'Received foreground message');
      logRemoteMessageAndroid(message, tag: 'FCM-FOREGROUND');

      final type = (message.data['type'] ?? '').toString();
      final title = (message.notification?.title ?? 'Notifikasi').toString();
      final body = (message.notification?.body ?? '').toString();
      final status = message.data['status'];

      final PushType style = _mapPushType(type, status: status);

      // Show banner
      showPushBanner(title: title, body: body, type: style);
    });

    // App Opened from Notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('NotificationService', 'App opened from notification');
      logRemoteMessageAndroid(message, tag: 'FCM-OPENED');
      _handleNavigation(message);
    });
  }

  Future<void> _checkInitialMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      AppLogger.info(
          'NotificationService', 'App launched from terminated state');
      logRemoteMessageAndroid(initialMessage, tag: 'FCM-INITIAL');

      // Navigate after init
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNavigation(initialMessage);
      });
    }
  }

  void _handleNavigation(RemoteMessage message) {
    var type = (message.data['type'] ?? '').toString();
    // Normalize type string
    type = type.trim().toLowerCase().replaceAll('-', '_');

    // Additional data sometimes needed for navigation
    // Additional data sometimes needed for navigation
    // final id = message.data['id']; // Used for future deep linking

    switch (type) {
      // Announcement
      case 'announcement':
      case 'announcement_created':
      case 'announcement_updated':
        Get.toNamed(Routes.notificationsScreen);
        break;

      // Assignment / Tugas
      case 'assignment':
      case 'assignment_created':
      case 'assignment_updated':
      case 'tugas':
        // Arahkan ke list tugas.
        Get.toNamed(Routes.teacherManageAssignmentScreen);
        break;

      // Submission / Pengumpulan Tugas
      case 'submission':
      case 'assignment_submission':
      case 'student_submitted':
        // Arahkan ke list tugas karena TeacherManageAssignmentSubmissionScreen butuh Assignment object
        Get.toNamed(Routes.teacherManageAssignmentScreen);
        break;

      // Attendance / Absensi
      case 'attendance':
      case 'attendance_update':
      case 'attendance_marked':
        // Arahkan ke view attendance (defaults to current day/first class)
        Get.toNamed(Routes.teacherViewAttendanceScreen);
        break;

      // Exam (Luring/Offline)
      case 'exam':
      case 'exam_created':
      case 'exam_result_published':
      case 'exam_marks_updated':
        Get.toNamed(Routes.teacherExamResultScreen);
        break;

      // Online Exam
      case 'online_exam':
      case 'online_exam_created':
      case 'online_exam_updated':
      case 'online_exam_questions_ready':
      case 'online_exam_cancelled':
        Get.toNamed(Routes.onlineExamScreen);
        break;

      // Leave / Cuti / Izin (Staff)
      case 'leave':
      case 'leave_approved':
      case 'leave_rejected':
      case 'leave_status':
      case 'staff_leave_approved':
      case 'staff_leave_rejected':
        // Arahkan ke screen list cuti STAF (showMyLeaves: true)
        Get.toNamed(Routes.leavesScreen, arguments: {'showMyLeaves': true});
        break;

      // Student Leaves (Permohonan Izin Siswa) for Teachers
      case 'student_leave':
      case 'student_leave_request':
        Get.toNamed(Routes.leaveRequestScreen);
        break;

      // Payroll / Gaji
      case 'payroll':
      case 'salary_slip':
        Get.toNamed(Routes.myPayrollScreen);
        break;

      default:
        AppLogger.info(
            'NotificationService', 'No specific navigation for type: $type');
        // Fallback: ke notifikasi screen agar user bisa baca detailnya
        Get.toNamed(Routes.notificationsScreen);
    }
  }

  /// Helper to subscribe to topics
  Future<void> subscribeToTopics(List<String> topics) async {
    for (final topic in topics) {
      try {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
        AppLogger.info('NotificationService', 'Subscribed to topic: $topic');
      } catch (e) {
        AppLogger.error('NotificationService', 'Error subscribing to $topic',
            error: e);
      }
    }
  }

  /// Helper to unsubscribe from topics
  Future<void> unsubscribeFromTopics(List<String> topics) async {
    for (final topic in topics) {
      try {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
        AppLogger.info(
            'NotificationService', 'Unsubscribed from topic: $topic');
      } catch (e) {
        AppLogger.error(
            'NotificationService', 'Error unsubscribing from $topic',
            error: e);
      }
    }
  }

  int? _normalizeLeaveStatus(dynamic status) {
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

  PushType _mapPushType(String? rawType, {dynamic status}) {
    final key = (rawType ?? '').trim().toLowerCase().replaceAll('-', '_');

    return switch (key) {
      'assignment_created' || 'assignment_updated' || 'tugas' => PushType.info,
      'attendance_update' => PushType.info,
      'attendance_marked' => PushType.success,
      'exam_created' => PushType.info,
      'exam_result_published' => PushType.success,
      'exam_marks_updated' => PushType.info,
      'online_exam_created' => PushType.success,
      'online_exam_updated' => PushType.info,
      'online_exam_cancelled' => PushType.error,
      'online_exam_questions_ready' => PushType.success,
      'online_exam_corrected' => PushType.success,
      'leave_approved' => PushType.success,
      'leave_rejected' => PushType.error,
      'staff_leave_approved' => PushType.success,
      'staff_leave_rejected' => PushType.error,
      'leave_status' => switch (_normalizeLeaveStatus(status)) {
          1 => PushType.success,
          2 => PushType.warning,
          3 => PushType.error,
          _ => PushType.info,
        },
      'lesson_created' || 'lesson_updated' => PushType.info,
      'topic_created' || 'topic_updated' => PushType.info,
      'announcement_created' || 'announcement_updated' => PushType.info,
      'student_promoted' => PushType.success,
      'student_transferred' => PushType.warning,
      _ => PushType.success,
    };
  }
}
