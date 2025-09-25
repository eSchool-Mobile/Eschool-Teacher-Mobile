# 📱 **SEMUA SKENARIO GURU MENDAPATKAN NOTIFIKASI**

## 🎯 **1. CUTI/IZIN (PALING PENTING)**
### ✅ **Disetujui Admin:**
- **Type:** `leave_approved` / `izin_disetujui`
- **Banner:** 🟢 HIJAU (Success)
- **Title:** "Cuti Disetujui"
- **Body:** "Permohonan cuti Anda telah disetujui"
- **Navigate:** Ke halaman Leave Request

### ❌ **Ditolak Admin:**
- **Type:** `leave_rejected` / `izin_ditolak`
- **Banner:** 🔴 MERAH (Error)
- **Title:** "Cuti Ditolak"
- **Body:** "Permohonan cuti Anda telah ditolak"
- **Navigate:** Ke halaman Leave Request

### ⏳ **Status Menunggu:**
- **Type:** `leave_pending` / `izin_menunggu`
- **Banner:** 🟡 KUNING (Warning)
- **Title:** "Cuti Menunggu Approval"
- **Body:** "Permohonan cuti Anda sedang diproses"
- **Navigate:** Ke halaman Leave Request

---

## 📚 **2. TUGAS/ASSIGNMENT**
### 🆕 **Tugas Dibuat:**
- **Type:** `assignment_created` / `tugas`
- **Banner:** 🔵 BIRU (Info)
- **Title:** "Tugas Baru Dibuat"
- **Body:** "Tugas [nama_tugas] telah dibuat untuk kelas Anda"
- **Navigate:** Ke halaman Notifications

---

## 📢 **3. PENGUMUMAN/ANNOUNCEMENT**
### 📣 **Pengumuman Umum:**
- **Type:** `announcement` / `pengumuman`
- **Banner:** 🔵 BIRU (Info)
- **Title:** "Pengumuman Sekolah"
- **Body:** "Ada pengumuman penting dari sekolah"
- **Navigate:** Ke halaman Notifications

---

## 👥 **4. ABSENSI/ATTENDANCE**
### 📊 **Laporan Absensi:**
- **Type:** `attendance` / `absensi`
- **Banner:** 🔵 BIRU (Info)
- **Title:** "Laporan Absensi Siswa"
- **Body:** "Laporan absensi kelas [nama_kelas] telah tersedia"
- **Navigate:** Ke halaman Notifications

---

## 💬 **5. PESAN/MESSAGE**
### 💌 **Pesan Baru:**
- **Type:** `message` / `pesan`
- **Banner:** 🔵 BIRU (Info)
- **Title:** "Pesan Baru"
- **Body:** "Anda memiliki pesan baru dari [pengirim]"
- **Navigate:** Ke halaman Chat Contacts

---

## 💰 **6. TAGIHAN/FEE**
### 💳 **Pembayaran:**
- **Type:** `fee` / `tagihan` / `payment`
- **Banner:** 🟡 KUNING (Warning)
- **Title:** "Tagihan Sekolah"
- **Body:** "Ada tagihan yang perlu dibayar"
- **Navigate:** Ke halaman Notifications

---

## ⚠️ **7. ERROR/KESALAHAN**
### 🚨 **Error Sistem:**
- **Type:** `error` / `kesalahan`
- **Banner:** 🔴 MERAH (Error)
- **Title:** "Error Sistem"
- **Body:** "Terjadi kesalahan dalam sistem"
- **Navigate:** Ke halaman Notifications

---

## 🎨 **TAMPILAN BANNER BERDASARKAN TYPE:**

| Type | Banner Color | Icon | Navigation |
|------|-------------|------|------------|
| `leave_approved` | 🟢 Green | ✅ Check | Leave Screen |
| `leave_rejected` | 🔴 Red | ❌ Error | Leave Screen |
| `leave_pending` | 🟡 Yellow | ⏳ Clock | Leave Screen |
| `assignment` | 🔵 Blue | 📚 Book | Notifications |
| `announcement` | 🔵 Blue | 📢 Speaker | Notifications |
| `attendance` | 🔵 Blue | 📊 Chart | Notifications |
| `message` | 🔵 Blue | 💬 Chat | Chat Screen |
| `fee` | 🟡 Yellow | 💰 Money | Notifications |
| `error` | 🔴 Red | ⚠️ Warning | Notifications |

---

## 🔄 **FLOW NOTIFIKASI:**

```
Trigger Event → Backend API → Database → FCM API → Device → Banner + Sound + Vibration
```

**Contoh Real Case:**
1. **Admin tolak cuti** → Guru dapat notif 🔴 "Cuti Ditolak"
2. **Tugas baru dibuat** → Guru dapat notif 🔵 "Tugas Baru Dibuat"  
3. **Pengumuman sekolah** → Guru dapat notif 🔵 "Pengumuman Sekolah"
4. **Pesan dari admin** → Guru dapat notif 🔵 "Pesan Baru"

---

## 📋 **IMPLEMENTASI BACKEND YANG DIPERLUKAN:**

Untuk setiap event di atas, backend harus mengirim FCM dengan format:

```json
{
  "message": {
    "token": "fcm_token_guru",
    "notification": {
      "title": "Judul Notifikasi",
      "body": "Isi pesan"
    },
    "data": {
      "type": "leave_rejected", // sesuai type di atas
      "id": "123",
      "click_action": "FLUTTER_NOTIFICATION_CLICK"
    }
  }
}
```

**Guru akan mendapatkan notifikasi untuk SEMUA aktivitas penting sekolah!** 🎉