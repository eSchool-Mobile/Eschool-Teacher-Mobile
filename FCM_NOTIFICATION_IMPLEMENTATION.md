# Implementasi Firebase Cloud Messaging (FCM) untuk eSchool Staff

## Overview
Implementasi ini menambahkan sistem notifikasi push menggunakan Firebase Cloud Messaging (FCM) yang terintegrasi dengan aplikasi eSchool Staff. Sistem ini mendukung notifikasi foreground, background, dan terminated state dengan banner yang user-friendly.

## File yang Dibuat/Dimodifikasi

### 1. `/lib/utils/in_appbanner.dart` (BARU)
Utility untuk menampilkan banner notifikasi dalam aplikasi tanpa memerlukan BuildContext.

**Fitur:**
- Enum `PushType` untuk berbagai jenis notifikasi (info, success, warning, error)
- Fungsi `showPushBanner()` menggunakan GetX snackbar
- Styling otomatis berdasarkan tipe notifikasi
- Support untuk aksi tap

### 2. `/lib/utils/logger.dart` (DIMODIFIKASI)
Ditambahkan fungsi `logRemoteMessageAndroid()` untuk debugging FCM.

**Fitur:**
- Log detail lengkap dari RemoteMessage
- Format JSON terstruktur untuk analisis
- Support untuk Android dan iOS notification payload
- Tag kustom untuk filtering log

### 3. `/lib/main.dart` (DIMODIFIKASI)
File utama aplikasi dengan setup FCM lengkap.

**Perubahan:**
- Ditambahkan imports untuk FCM dan utilities
- Background message handler `_firebaseMessagingBackgroundHandler()`
- Fungsi `setupFCM()` untuk inisialisasi
- Handler untuk berbagai state notifikasi
- Navigation logic berdasarkan tipe notifikasi

## Cara Kerja

### 1. Inisialisasi
```dart
Future<void> main() async {
  // Setup locale dan encoding
  timeago.setLocaleMessages('id', timeago.IdMessages());
  await initializeDateFormatting('id');
  
  // Inisialisasi aplikasi
  await initializeApp();
  
  // Setup FCM
  await setupFCM();
}
```

### 2. FCM Setup
- Mengecek apakah Firebase sudah diinisialisasi
- Set background message handler
- Request permission untuk notifikasi
- Setup listener untuk berbagai state

### 3. State Handling
- **Foreground**: Tampilkan banner menggunakan `showPushBanner()`
- **Background/Terminated**: Handle navigation saat notifikasi diklik
- **Initial**: Handle notifikasi yang membuka aplikasi

### 4. Type Mapping
Sistem mapping otomatis untuk styling banner:
```dart
final PushType style = switch (type.toLowerCase()) {
  'assignment' || 'assignment_created' || 'tugas' => PushType.info,
  'leave' || 'izin' => PushType.success,
  'leave_approved' || 'izin_disetujui' => PushType.success,
  'leave_rejected' || 'izin_ditolak' => PushType.error,
  'leave_pending' || 'izin_menunggu' => PushType.warning,
  'fee' || 'tagihan' || 'payment' => PushType.warning,
  'announcement' || 'pengumuman' => PushType.info,
  'attendance' || 'absensi' => PushType.info,
  'message' || 'pesan' => PushType.info,
  'error' || 'kesalahan' => PushType.error,
  _ => PushType.info,
};
```

### 5. Navigation Logic
Automatic navigation berdasarkan tipe notifikasi:
- `announcement/pengumuman` → NotificationsScreen
- `leave/izin`, `leave_approved/izin_disetujui`, `leave_rejected/izin_ditolak`, `leave_pending/izin_menunggu` → LeaveRequestScreen
- `message/pesan` → ChatContacts
- `assignment/tugas` → NotificationsScreen
- `attendance/absensi` → NotificationsScreen
- Default → NotificationsScreen

## Struktur Notifikasi yang Didukung

### Format Data Notifikasi
```json
{
  "notification": {
    "title": "Judul Notifikasi",
    "body": "Isi pesan notifikasi"
  },
  "data": {
    "type": "announcement|assignment|leave|message|attendance|fee",
    "id": "ID_ITEM_TERKAIT",
    "custom_data": "nilai_tambahan"
  }
}
```

### Tipe Notifikasi yang Didukung
1. **announcement/pengumuman** - Pengumuman umum
2. **assignment/tugas** - Penugasan dari guru
3. **leave/izin** - Permohonan izin staff (general)
4. **leave_approved/izin_disetujui** - Cuti/izin disetujui ✅
5. **leave_rejected/izin_ditolak** - Cuti/izin ditolak ❌
6. **leave_pending/izin_menunggu** - Cuti/izin menunggu approval ⏳
7. **message/pesan** - Pesan chat
8. **attendance/absensi** - Terkait kehadiran
9. **fee/tagihan** - Terkait pembayaran

## Debugging dan Monitoring

### Log Format
Semua notifikasi FCM akan di-log dengan format JSON:
```json
{
  "ts": "2024-01-01T10:00:00.000Z",
  "level": "INFO", 
  "scope": "FCM-FOREGROUND",
  "message": "Firebase Cloud Messaging received",
  "data": {
    "messageId": "xxx",
    "data": {...},
    "notification": {...}
  }
}
```

### Tag Logging
- `FCM-FOREGROUND` - Notifikasi saat app aktif
- `FCM-BACKGROUND` - Notifikasi saat app di background
- `FCM-OPENED` - Notifikasi yang diklik untuk membuka app
- `FCM-INITIAL` - Notifikasi yang membuka app dari terminated
- `FCM-TOKEN` - FCM registration token

## Testing

### Cara Test Implementasi
1. **Foreground**: Kirim notifikasi saat app aktif - banner harus muncul
2. **Background**: Kirim notifikasi saat app di background - klik untuk test navigation
3. **Terminated**: Kill app, kirim notifikasi, buka dari notification tray
4. **Types**: Test berbagai tipe notifikasi untuk memastikan styling dan navigation

### Tools untuk Testing
- Firebase Console → Cloud Messaging
- Postman dengan FCM API
- Firebase Admin SDK untuk testing otomatis

## Dependencies yang Digunung
- `firebase_core: ^2.24.2`
- `firebase_messaging: ^14.0.0`
- `get: ^4.6.6` (untuk navigation dan snackbar)
- `google_fonts: ^6.2.1` (untuk styling)
- `intl: ^0.20.2` (untuk locale)
- `timeago: ^3.7.0` (untuk timestamp)

## Kompatibilitas
- ✅ Android API 21+
- ✅ iOS 11+
- ✅ Web (dengan service worker)
- ✅ Background/Foreground/Terminated states
- ✅ Dark/Light theme

## Keamanan
- Permission request otomatis
- Validasi tipe notifikasi
- Safe navigation dengan fallback
- Error handling untuk malformed notifications

## Maintenance
- Monitor FCM token refresh
- Update navigation routes sesuai perubahan aplikasi
- Adjust styling sesuai design system
- Review dan update tipe notifikasi baru