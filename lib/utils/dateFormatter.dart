import 'package:intl/intl.dart';

/// Utility class untuk menangani format tanggal secara konsisten
/// Semua format tanggal untuk API menggunakan ISO YYYY-MM-DD
class DateFormatter {
  // Format ISO untuk API (YYYY-MM-DD)
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  // Format untuk display UI (DD/MM/YYYY)
  static final DateFormat _displayDateFormat = DateFormat('dd/MM/yyyy');

  // Format untuk display dengan nama bulan (DD MMM YYYY)
  static final DateFormat _displayDateFormatWithMonth =
      DateFormat('dd MMM yyyy', 'id_ID');

  /// Konversi DateTime ke format API untuk POST request (DD-MM-YYYY)
  /// Backend mengharapkan format d-m-Y untuk semua request (GET dan POST)
  static String toApiFormat(DateTime date) {
    try {
      final formatted =
          '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      print(
          '🔍 [DATE_FORMATTER] Converting ${date.toString()} to API format (POST): $formatted');
      return formatted;
    } catch (e) {
      print('❌ [DATE_FORMATTER] Error formatting date to API format: $e');
      // Fallback manual
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    }
  }

  /// Konversi DateTime ke format untuk GET request (DD-MM-YYYY)
  /// Backend mengharapkan format d-m-Y untuk query parameter
  static String toGetRequestFormat(DateTime date) {
    try {
      final formatted =
          '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      print(
          '🔍 [DATE_FORMATTER] Converting ${date.toString()} to GET request format: $formatted');
      return formatted;
    } catch (e) {
      print(
          '❌ [DATE_FORMATTER] Error formatting date to GET request format: $e');
      // Fallback manual
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    }
  }

  /// Parse string tanggal dari API (YYYY-MM-DD) ke DateTime
  /// Digunakan untuk parsing response dari backend
  static DateTime? fromApiFormat(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      print('⚠️ [DATE_FORMATTER] Date string is null or empty');
      return null;
    }

    try {
      final parsed = _apiDateFormat.parse(dateString);
      print(
          '🔍 [DATE_FORMATTER] Parsed API date "$dateString" to: ${parsed.toString()}');
      return parsed;
    } catch (e) {
      print('❌ [DATE_FORMATTER] Error parsing API date "$dateString": $e');

      // Fallback: coba parse manual untuk format YYYY-MM-DD
      try {
        final parts = dateString.split('-');
        if (parts.length == 3) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);

          final fallbackDate = DateTime(year, month, day);
          print(
              '🔍 [DATE_FORMATTER] Fallback parsing successful: ${fallbackDate.toString()}');
          return fallbackDate;
        }
      } catch (fallbackError) {
        print(
            '❌ [DATE_FORMATTER] Fallback parsing also failed: $fallbackError');
      }

      return null;
    }
  }

  /// Konversi DateTime ke format display untuk UI (DD/MM/YYYY)
  static String toDisplayFormat(DateTime date) {
    try {
      return _displayDateFormat.format(date);
    } catch (e) {
      print('❌ [DATE_FORMATTER] Error formatting date to display format: $e');
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  /// Konversi DateTime ke format display dengan nama bulan (DD MMM YYYY)
  static String toDisplayFormatWithMonth(DateTime date) {
    try {
      return _displayDateFormatWithMonth.format(date);
    } catch (e) {
      print('❌ [DATE_FORMATTER] Error formatting date with month: $e');
      return toDisplayFormat(date);
    }
  }

  /// Validasi apakah string tanggal valid dalam format API (YYYY-MM-DD)
  static bool isValidApiDateFormat(String dateString) {
    if (dateString.isEmpty) return false;

    try {
      _apiDateFormat.parse(dateString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validasi apakah string tanggal valid dalam format GET request (DD-MM-YYYY)
  static bool isValidGetRequestDateFormat(String dateString) {
    if (dateString.isEmpty) return false;

    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        // Validasi range tanggal
        if (day >= 1 &&
            day <= 31 &&
            month >= 1 &&
            month <= 12 &&
            year >= 1900) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get current date dalam format API
  static String getCurrentApiDate() {
    return toApiFormat(DateTime.now());
  }

  /// Get current date dalam format display
  static String getCurrentDisplayDate() {
    return toDisplayFormat(DateTime.now());
  }

  /// Konversi berbagai format tanggal ke format API
  /// Mendukung DD-MM-YYYY, DD/MM/YYYY, YYYY-MM-DD
  static String? normalizeToApiFormat(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    // Jika sudah format API, return as is
    if (isValidApiDateFormat(dateString)) {
      return dateString;
    }

    // Coba parse format DD-MM-YYYY atau DD/MM/YYYY
    try {
      DateTime? parsed;

      if (dateString.contains('-')) {
        final parts = dateString.split('-');
        if (parts.length == 3) {
          // Cek apakah DD-MM-YYYY atau YYYY-MM-DD
          if (parts[0].length == 4) {
            // YYYY-MM-DD format
            parsed = DateTime(
                int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          } else {
            // DD-MM-YYYY format
            parsed = DateTime(
                int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          }
        }
      } else if (dateString.contains('/')) {
        final parts = dateString.split('/');
        if (parts.length == 3) {
          // DD/MM/YYYY format
          parsed = DateTime(
              int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      }

      if (parsed != null) {
        return toApiFormat(parsed);
      }
    } catch (e) {
      print('❌ [DATE_FORMATTER] Error normalizing date "$dateString": $e');
    }

    return null;
  }
}
