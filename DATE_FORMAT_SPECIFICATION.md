# DATE FORMAT SPECIFICATION - EKSTRAKURIKULER ATTENDANCE

## 🚨 CRITICAL: Backend Menggunakan Format Tanggal Yang Berbeda

Backend eSchool menggunakan **format tanggal yang berbeda** untuk GET dan POST request:

### 📥 GET Request (Query Parameters)
- **Format**: `DD-MM-YYYY` (d-m-Y)
- **Contoh**: `18-11-2025`
- **Digunakan untuk**: 
  - Load attendance data
  - Query attendance history
  - Filter berdasarkan tanggal

### 📤 POST Request (Request Body)
- **Format**: `DD-MM-YYYY` (d-m-Y format)
- **Contoh**: `18-11-2025`
- **Struktur**: Object dengan student_id sebagai key
- **Digunakan untuk**:
  - Save attendance data
  - Create/update operations

## 🔧 Implementasi di Flutter

### DateFormatter Methods

```dart
// Untuk semua request (GET dan POST) - sekarang menggunakan format yang sama
DateFormatter.toApiFormat(DateTime.now()) // "18-11-2025"

// Untuk parsing response dari API (masih YYYY-MM-DD)
DateFormatter.fromApiFormat("2025-11-18") // DateTime object

// Validasi format DD-MM-YYYY
DateFormatter.isValidGetRequestDateFormat("18-11-2025") // true
```

### Screen Usage

```dart
// Load attendance data (GET)
void _loadAttendanceData() {
  context.read<ExtracurricularAttendanceCubit>().getAttendanceData(
    attendanceId: _selectedExtracurricularId!,
    extracurricularId: _selectedExtracurricularId,
    date: _formatDateForGetRequest(_selectedDate), // DD-MM-YYYY
  );
}

// Save attendance data (POST)
void _saveAttendance() {
  context.read<ExtracurricularAttendanceCubit>().saveAttendance(
    sessionId: 1,
    extracurricularId: _selectedExtracurricularId!,
    date: _formatDateForApi(_selectedDate), // YYYY-MM-DD
    attendanceData: attendanceData,
  );
}
```

## 🔍 Error Yang Diperbaiki

### ❌ Error Sebelumnya:
```
Invalid date format. Use d-m-Y | Error Code: 103
```

**Penyebab**: Mengirim format `YYYY-MM-DD` untuk GET request, padahal backend mengharapkan `DD-MM-YYYY`.

### ✅ Solusi:
1. **GET Request**: Gunakan `DateFormatter.toGetRequestFormat()` → `18-11-2025`
2. **POST Request**: Gunakan `DateFormatter.toApiFormat()` → `2025-11-18`

## 📊 Request/Response Examples

### GET Request (Load Attendance)
```
URL: /api/staff/extracurricular/attendance/31
Query: {
  "ekstrakurikuler_id": "31",
  "date": "18-11-2025"  // DD-MM-YYYY format
}
```

### POST Request (Save Attendance)
```json
{
  "ekstrakurikuler_id": 31,
  "date": "18-11-2025",  // DD-MM-YYYY format
  "attendance_data": {
    "123": {
      "id": 123,
      "type": 1
    },
    "456": {
      "id": 456,
      "type": 0
    }
  }
}
```

## 🧪 Unit Tests

Tests memastikan kedua format bekerja dengan benar:

```dart
test('GET request format should be different from API format', () {
  final date = DateTime(2025, 11, 18);
  final apiFormat = DateFormatter.toApiFormat(date);      // "2025-11-18"
  final getFormat = DateFormatter.toGetRequestFormat(date); // "18-11-2025"
  
  expect(apiFormat, isNot(equals(getFormat)));
});
```

## ⚠️ PENTING: Jangan Sampai Tertukar!

- **GET Request**: Selalu gunakan `DD-MM-YYYY`
- **POST Request**: Selalu gunakan `YYYY-MM-DD`
- **Validation**: Gunakan method validation yang sesuai
- **Testing**: Pastikan unit test cover kedua format

Inkonsistensi format akan menyebabkan Carbon parsing error di backend!
