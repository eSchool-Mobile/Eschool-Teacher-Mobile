# EKSTRAKURIKULER ATTENDANCE API SPECIFICATION

## 1. REQUEST STRUCTURE (POST /api/staff/extracurricular/attendance/store/{sessionId})

### Request Body:
```json
{
  "ekstrakurikuler_id": 31,
  "date": "2025-11-18",  // Format: YYYY-MM-DD
  "attendance_data": [
    {
      "student_id": 1,     // BUKAN "id", tapi "student_id"
      "type": 1            // 0=Absent, 1=Present, 2=Sick, 3=Permission
    },
    {
      "student_id": 4,
      "type": 3
    },
    {
      "student_id": 8,
      "type": 0
    }
  ]
}
```

### Response:
```json
{
  "error": false,
  "message": "Absensi berhasil disimpan",
  "code": 200,
  "data": {
    "saved_count": 3,
    "attendance_id": 123
  }
}
```

## 2. RESPONSE STRUCTURE (GET /api/staff/extracurricular/attendance/{id})

### Current Response (PROBLEMATIC):
```json
{
  "error": false,
  "message": "Data Fetched Successfully",
  "data": null,
  "rows": [
    {
      "no": 1,
      "id": 1,                    // attendance_id, NOT student_id
      "eskul_name": "Bola Basket",
      "student_name": "BAGAS SYAWALUDIN",
      "status": 1,
      "date": "2025-11-18"
    },
    {
      "no": 3,
      "id": 8,                    // attendance_id, NOT student_id  
      "eskul_name": "Bola Basket",
      "student_name": "YUSUF PANGESTU PRADIPTA YUSUF",
      "status": 0,
      "date": null                // PROBLEMATIC: null date
    }
  ]
}
```

### REQUIRED Response Structure:
```json
{
  "error": false,
  "message": "Data Fetched Successfully", 
  "data": {
    "ekstrakurikuler_id": 31,
    "ekstrakurikuler_name": "Bola Basket",
    "date": "2025-11-18",
    "members": [
      {
        "attendance_id": 1,
        "student_id": 101,          // REQUIRED: actual student ID
        "student_name": "BAGAS SYAWALUDIN",
        "student_nisn": "1234567890",
        "class_name": "XII IPA 1",
        "status": 1,                // 0=Absent, 1=Present, 2=Sick, 3=Permission
        "date": "2025-11-18"        // NEVER null
      },
      {
        "attendance_id": 2,
        "student_id": 104,
        "student_name": "MUHAMMAD DANU JAYA SAPUTRA", 
        "student_nisn": "1234567891",
        "class_name": "XII IPA 2",
        "status": 3,
        "date": "2025-11-18"
      },
      {
        "attendance_id": 3,
        "student_id": 108,
        "student_name": "YUSUF PANGESTU PRADIPTA YUSUF",
        "student_nisn": "1234567892", 
        "class_name": "XII IPA 1",
        "status": 0,
        "date": "2025-11-18"        // FIXED: no more null
      }
    ]
  }
}
```

## 3. STATUS MAPPING

```
0 = Absent (Tidak Hadir/Alpa)
1 = Present (Hadir) 
2 = Sick (Sakit)
3 = Permission (Izin)
```

## 4. DATE FORMAT STANDARD

- **API Request/Response**: `YYYY-MM-DD` (ISO format)
- **Display**: `DD/MM/YYYY` or localized format
- **Internal Processing**: DateTime objects
