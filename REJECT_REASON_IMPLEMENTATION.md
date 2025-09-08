# Implementasi Fitur Reject Reason pada Sistem Cuti

## Ringkasan Perubahan

Telah diimplementasikan fitur baru pada sistem cuti dimana admin **wajib memberikan alasan penolakan** ketika menolak permohonan cuti. Fitur ini memastikan transparansi dan komunikasi yang lebih baik antara admin dan staff.

## Perubahan yang Dilakukan

### 1. Model LeaveRequest (`lib/data/models/leaveRequest.dart`)
- **Tambahan field**: `rejectReason` (String?) untuk menyimpan alasan penolakan
- **Update constructor**: Menambahkan parameter `rejectReason`
- **Update JSON parsing**: Menangani field `reject_reason` dari API response
- **Update copyWith method**: Mendukung update `rejectReason`

### 2. Repository (`lib/data/repositories/leaveRepository.dart`)
- **Update method**: `approveOrRejectLeaveRequest` sekarang menerima parameter opsional `rejectReason`
- **Validasi server-side**: Validasi bahwa `reject_reason` wajib diisi jika status = 2 (rejected)
- **API call enhancement**: Mengirim `reject_reason` ke backend saat menolak permohonan

### 3. Cubit Logic (`lib/cubits/leave/approveOrRejectLeaveRequestCubit.dart`)
- **Parameter tambahan**: Method `approveOrRejectLeaveRequest` sekarang menerima `rejectReason`
- **Validasi client-side**: Memastikan `rejectReason` tidak kosong saat menolak permohonan
- **Error handling**: Menampilkan error message jika reject reason tidak diisi

### 4. UI Dialog (`lib/ui/widgets/rejectReasonDialog.dart`)
- **Dialog baru**: `RejectReasonDialog` untuk input alasan penolakan
- **Validasi form**: Memastikan alasan minimal 10 karakter
- **UX/UI modern**: Animasi dan desain yang konsisten dengan tema aplikasi
- **Required field**: Field wajib diisi sebelum bisa submit

### 5. Screen Integration (`lib/ui/screens/leaveRequestsScreen.dart`)
- **Flow baru**: Saat admin menekan tombol "Tolak", dialog input reason ditampilkan terlebih dahulu
- **Parameter passing**: `rejectReason` diteruskan ke bottomsheet dan cubit
- **Display enhancement**: Menampilkan alasan penolakan pada detail cuti yang sudah ditolak
- **Visual indicator**: Section khusus dengan warna merah untuk alasan penolakan

## Fitur Utama

### ✅ Validasi Wajib
- Admin **tidak dapat** menyelesaikan proses penolakan tanpa mengisi alasan
- Validasi dilakukan di level client (UI) dan server (Repository)
- Minimal 10 karakter untuk alasan penolakan

### ✅ User Experience
- Dialog modern dengan animasi smooth
- Form validation real-time
- Loading state saat proses submission
- Cancel/Batal button untuk membatalkan aksi

### ✅ Transparansi
- Alasan penolakan ditampilkan di detail permohonan cuti
- Visual indicator yang jelas untuk status ditolak
- History alasan penolakan tersimpan permanen

### ✅ API Integration
- Parameter `reject_reason` dikirim ke backend
- Backward compatibility dengan API existing
- Error handling yang robust

## Cara Penggunaan

### Untuk Admin:
1. Buka detail permohonan cuti
2. Klik tombol "Tolak" 
3. Dialog akan muncul meminta alasan penolakan
4. Isi alasan penolakan (minimal 10 karakter)
5. Klik "Tolak Cuti" untuk konfirmasi
6. Permohonan akan ditolak dengan alasan tersimpan

### Untuk Staff:
1. Dapat melihat alasan penolakan pada detail cuti yang ditolak
2. Alasan ditampilkan dengan visual indicator merah
3. Informasi transparan mengapa cuti ditolak

## Teknical Notes

- **Status Code**: 0 = Pending, 1 = Approved, 2 = Rejected
- **Field Database**: `reject_reason` (nullable string)
- **Validasi**: Required jika status = 2 (rejected)
- **UI State Management**: Menggunakan BLoC pattern yang sudah ada
- **Backward Compatibility**: Existing functionality tetap berjalan normal

## Testing Checklist

- [ ] Approve cuti tanpa reject_reason ✅ (normal flow)
- [ ] Reject cuti tanpa mengisi reason ❌ (harus gagal)
- [ ] Reject cuti dengan reason valid ✅ (berhasil)
- [ ] Display reject reason pada UI ✅ (terlihat)
- [ ] Cancel dialog reject ✅ (batal proses)
- [ ] Form validation ✅ (minimal 10 karakter)

---

**Status**: ✅ **COMPLETED**  
**Date**: September 8, 2025  
**Developer**: GitHub Copilot Assistant
