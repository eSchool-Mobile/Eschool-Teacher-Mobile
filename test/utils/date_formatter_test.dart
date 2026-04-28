import 'package:flutter_test/flutter_test.dart';
import 'package:eschool_saas_staff/utils/system/dateFormatter.dart';

void main() {
  group('DateFormatter Tests', () {
    test('toApiFormat should convert DateTime to DD-MM-YYYY format', () {
      final date = DateTime(2025, 11, 18);
      final result = DateFormatter.toApiFormat(date);
      expect(result, equals('18-11-2025'));
    });

    test('toApiFormat should handle single digit months and days', () {
      final date = DateTime(2025, 1, 5);
      final result = DateFormatter.toApiFormat(date);
      expect(result, equals('05-01-2025'));
    });

    test('fromApiFormat should parse valid YYYY-MM-DD format', () {
      final result = DateFormatter.fromApiFormat('2025-11-18');
      expect(result, isNotNull);
      expect(result!.year, equals(2025));
      expect(result.month, equals(11));
      expect(result.day, equals(18));
    });

    test('fromApiFormat should return null for invalid format', () {
      final result = DateFormatter.fromApiFormat('18-11-2025');
      expect(result, isNull);
    });

    test('fromApiFormat should return null for null input', () {
      final result = DateFormatter.fromApiFormat(null);
      expect(result, isNull);
    });

    test('fromApiFormat should return null for empty string', () {
      final result = DateFormatter.fromApiFormat('');
      expect(result, isNull);
    });

    test('isValidApiDateFormat should validate correct format', () {
      expect(DateFormatter.isValidApiDateFormat('2025-11-18'), isTrue);
      expect(DateFormatter.isValidApiDateFormat('2025-01-05'), isTrue);
    });

    test('isValidApiDateFormat should reject incorrect formats', () {
      expect(DateFormatter.isValidApiDateFormat('18-11-2025'), isFalse);
      expect(DateFormatter.isValidApiDateFormat('2025/11/18'), isFalse);
      expect(DateFormatter.isValidApiDateFormat('invalid'), isFalse);
      expect(DateFormatter.isValidApiDateFormat(''), isFalse);
    });

    test('normalizeToApiFormat should convert DD-MM-YYYY to YYYY-MM-DD', () {
      final result = DateFormatter.normalizeToApiFormat('18-11-2025');
      expect(result, equals('2025-11-18'));
    });

    test('normalizeToApiFormat should convert DD/MM/YYYY to YYYY-MM-DD', () {
      final result = DateFormatter.normalizeToApiFormat('18/11/2025');
      expect(result, equals('2025-11-18'));
    });

    test('normalizeToApiFormat should return YYYY-MM-DD as is', () {
      final result = DateFormatter.normalizeToApiFormat('2025-11-18');
      expect(result, equals('2025-11-18'));
    });

    test('normalizeToApiFormat should return null for invalid input', () {
      expect(DateFormatter.normalizeToApiFormat(null), isNull);
      expect(DateFormatter.normalizeToApiFormat(''), isNull);
      expect(DateFormatter.normalizeToApiFormat('invalid'), isNull);
    });

    test('getCurrentApiDate should return current date in API format', () {
      final result = DateFormatter.getCurrentApiDate();
      expect(DateFormatter.isValidApiDateFormat(result), isTrue);
    });

    test('toDisplayFormat should convert DateTime to DD/MM/YYYY format', () {
      final date = DateTime(2025, 11, 18);
      final result = DateFormatter.toDisplayFormat(date);
      expect(result, equals('18/11/2025'));
    });

    test('toGetRequestFormat should convert DateTime to DD-MM-YYYY format', () {
      final date = DateTime(2025, 11, 18);
      final result = DateFormatter.toGetRequestFormat(date);
      expect(result, equals('18-11-2025'));
    });

    test('toGetRequestFormat should handle single digit months and days', () {
      final date = DateTime(2025, 1, 5);
      final result = DateFormatter.toGetRequestFormat(date);
      expect(result, equals('05-01-2025'));
    });

    test('isValidGetRequestDateFormat should validate DD-MM-YYYY format', () {
      expect(DateFormatter.isValidGetRequestDateFormat('18-11-2025'), isTrue);
      expect(DateFormatter.isValidGetRequestDateFormat('05-01-2025'), isTrue);
    });

    test('isValidGetRequestDateFormat should reject invalid formats', () {
      expect(DateFormatter.isValidGetRequestDateFormat('2025-11-18'), isFalse);
      expect(DateFormatter.isValidGetRequestDateFormat('18/11/2025'), isFalse);
      expect(DateFormatter.isValidGetRequestDateFormat('32-13-2025'),
          isFalse); // Invalid day/month
      expect(DateFormatter.isValidGetRequestDateFormat(''), isFalse);
    });

    test('round trip conversion should work correctly', () {
      final originalDate = DateTime(2025, 11, 18);
      final apiFormat = DateFormatter.toApiFormat(originalDate);
      final parsedDate = DateFormatter.fromApiFormat(apiFormat);

      expect(parsedDate, isNotNull);
      expect(parsedDate!.year, equals(originalDate.year));
      expect(parsedDate.month, equals(originalDate.month));
      expect(parsedDate.day, equals(originalDate.day));
    });

    test('API format and GET request format should be the same now', () {
      final date = DateTime(2025, 11, 18);
      final apiFormat = DateFormatter.toApiFormat(date);
      final getFormat = DateFormatter.toGetRequestFormat(date);

      expect(apiFormat, equals('18-11-2025'));
      expect(getFormat, equals('18-11-2025'));
      expect(apiFormat, equals(getFormat)); // Now they should be the same
    });
  });
}
