# Panduan Implementasi Notifikasi eSchool Staff

## Overview
Sistem notifikasi telah diupdate untuk menggunakan `flutter_local_notifications` yang memberikan kontrol penuh terhadap tampilan notifikasi, termasuk saat aplikasi dalam foreground.

## Fitur Utama

### 1. Local Notifications
- Notifikasi ditampilkan menggunakan `flutter_local_notifications`
- Mendukung Android dan iOS
- Custom notification channel untuk Android
- Notifikasi dapat ditampilkan saat app dalam foreground

### 2. FCM Integration
- Background message handler untuk menerima notifikasi saat app tidak aktif
- Foreground message handler untuk menampilkan notifikasi lokal
- Automatic navigation berdasarkan type notifikasi
- Comprehensive logging untuk debugging

### 3. Notification Types Support
Staff app mendukung jenis notifikasi berikut:

#### Attendance
- `attendance_update`: Update absensi
- `attendance_marked`: Absensi telah dicatat

#### Exam
- `exam_created`: Ujian baru dibuat
- `exam_result_published`: Hasil ujian dipublikasi
- `exam_marks_updated`: Nilai ujian diupdate

#### Online Exam
- `online_exam_created`: Ujian online dibuat
- `online_exam_updated`: Ujian online diupdate
- `online_exam_cancelled`: Ujian online dibatalkan
- `online_exam_questions_ready`: Soal ujian online siap
- `online_exam_corrected`: Ujian online telah dikoreksi

#### Leave Management
- `leave_approved`: Cuti disetujui
- `leave_rejected`: Cuti ditolak
- `staff_leave_approved`: Cuti staff disetujui
- `staff_leave_rejected`: Cuti staff ditolak

#### Lesson & Topic
- `lesson_created`: Pelajaran baru dibuat
- `lesson_updated`: Pelajaran diupdate
- `topic_created`: Topik baru dibuat
- `topic_updated`: Topik diupdate

#### Announcement
- `announcement_created`: Pengumuman baru
- `announcement_updated`: Pengumuman diupdate

#### Student Management
- `student_promoted`: Siswa dipromosikan
- `student_transferred`: Siswa dipindahkan

## Navigation Mapping

| Notification Type | Navigation Route |
|------------------|------------------|
| `leave_*` | `Routes.leaveRequestScreen` |
| All other types | `Routes.notificationsScreen` |

## API Functions

### Core Functions
```dart
// Setup FCM dan local notifications
await setupFCM();

// Get FCM token
String? token = await getFCMToken();

// Subscribe to topics
await subscribeToTopics(['staff_notifications', 'leave_updates']);

// Unsubscribe from topics
await unsubscribeFromTopics(['old_topic']);
```

### Internal Functions
- `_initializeLocalNotifications()`: Initialize local notification plugin
- `_showLocalNotification(RemoteMessage)`: Show notification in foreground
- `_handleNotificationTap(RemoteMessage)`: Handle navigation on tap
- `_logMessageDetails(RemoteMessage, String)`: Debug logging

## Testing Notifications

### 1. Foreground Testing
- App harus dalam status aktif/foreground
- Kirim notifikasi dari backend atau Firebase Console
- Notifikasi akan muncul sebagai local notification
- Tap untuk test navigation

### 2. Background Testing
- App dalam background atau terminated
- Kirim notifikasi dari backend
- Notifikasi akan muncul sebagai system notification
- Tap untuk test navigation dan initial message handling

### 3. Debug Logging
Semua notifikasi akan menghasilkan log detail dengan format:
```
[FCM-FOREGROUND] ========= REMOTE MESSAGE =========
[FCM-FOREGROUND] messageId   : xxx
[FCM-FOREGROUND] title  : xxx
[FCM-FOREGROUND] body   : xxx
[FCM-FOREGROUND] ---- data (2) ----
[FCM-FOREGROUND] type = leave_approved
[FCM-FOREGROUND] user_id = 123
[FCM-FOREGROUND] ==================================
```

## Troubleshooting

### 1. Notifikasi Tidak Muncul
- Cek permission notifikasi di device settings
- Pastikan FCM token ter-register di backend
- Cek log untuk error messages
- Verifikasi notification channel setup

### 2. Navigation Tidak Berfungsi
- Pastikan `type` field ada dalam data payload
- Cek mapping type ke route di `_handleNotificationTap()`
- Verifikasi route sudah terdaftar di `Routes`

### 3. Duplicate Notifications
- Pastikan hanya `main.dart` yang handle FCM setup
- Disable setup di `homeScreen.dart` atau file lain
- Cek tidak ada multiple subscription ke FCM events

## Migration Notes

### Dari In-App Banner ke Local Notifications
- ❌ `showPushBanner()` - sudah tidak digunakan
- ✅ `_showLocalNotification()` - implementasi baru
- ❌ `PushType` enum - sudah tidak digunakan
- ✅ Native notification channel - lebih reliable

### Dependencies Added
- `flutter_local_notifications: ^17.1.0` (sudah ada)
- Platform imports (`dart:io` untuk Platform.isAndroid)

## Backend Integration

### Expected Payload Structure
```json
{
  "notification": {
    "title": "Cuti Disetujui",
    "body": "Permohonan cuti Anda telah disetujui"
  },
  "data": {
    "type": "leave_approved",
    "user_id": "123",
    "leave_id": "456"
  }
}
```

### FCM Token Registration
Gunakan `getFCMToken()` untuk mendapatkan token dan kirim ke backend untuk registrasi.

## Performance Notes
- Local notifications tidak membutuhkan BuildContext
- Background handler berjalan isolated, tidak bisa akses app state
- Notification channel hanya perlu dibuat sekali
- FCM token dapat berubah, monitor dengan `onTokenRefresh`