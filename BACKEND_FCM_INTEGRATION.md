# Cara Backend Mengirim Notifikasi FCM untuk Cuti Ditolak

## 1. API Internal (Database API)
Backend menggunakan API internal untuk menyimpan notifikasi ke database:

```php
// Endpoint: POST /api/staff/notification
// Data yang dikirim:
{
  "title": "Cuti Ditolak",
  "message": "Permohonan cuti Anda telah ditolak",
  "type": "leave_rejected", // <-- TYPE FCM
  "user_id": [123], // ID guru yang cutinya ditolak
  "roles": null,
  "file": null
}
```

## 2. FCM API (Firebase Cloud Messaging)
Setelah menyimpan ke database, backend harus mengirim ke FCM:

```php
// Menggunakan Firebase Admin SDK atau REST API
// Endpoint FCM: https://fcm.googleapis.com/v1/projects/{project-id}/messages:send

// Payload FCM:
{
  "message": {
    "token": "fcm_token_guru", // FCM token dari device guru
    "notification": {
      "title": "Cuti Ditolak",
      "body": "Permohonan cuti Anda telah ditolak oleh admin"
    },
    "data": {
      "type": "leave_rejected", // <-- TYPE YANG DIGUNAKAN APP
      "leave_id": "123",
      "click_action": "FLUTTER_NOTIFICATION_CLICK"
    },
    "android": {
      "priority": "high",
      "notification": {
        "channel_id": "cuti_channel",
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      }
    },
    "apns": {
      "payload": {
        "aps": {
          "content-available": 1,
          "sound": "default"
        }
      }
    }
  }
}
```

## 3. Flow Lengkap:

```
Admin Tolak Cuti → Simpan ke DB → Kirim FCM → App Terima → Banner Merah
```

## 4. Type yang Didukung:

| Status Cuti | Type FCM | Styling App |
|-------------|----------|-------------|
| Disetujui | `leave_approved` | 🟢 Hijau |
| Ditolak | `leave_rejected` | 🔴 Merah |
| Menunggu | `leave_pending` | 🟡 Kuning |

## 5. Testing dengan Postman:

```bash
# Kirim FCM langsung untuk testing
POST https://fcm.googleapis.com/v1/projects/eschool-mobile-fe51a/messages:send
Authorization: Bearer {server_key}
Content-Type: application/json

{
  "message": {
    "token": "fcm_token_device_guru",
    "notification": {
      "title": "Cuti Ditolak",
      "body": "Permohonan cuti Anda ditolak admin"
    },
    "data": {
      "type": "leave_rejected",
      "leave_id": "123"
    }
  }
}
```