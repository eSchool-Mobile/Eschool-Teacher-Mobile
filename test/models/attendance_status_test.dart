import 'package:flutter_test/flutter_test.dart';
import 'package:eschool_saas_staff/data/models/extracurricular/extracurricularAttendance.dart';

void main() {
  group('AttendanceStatus Tests', () {
    test('fromInt should return correct status for valid values', () {
      expect(AttendanceStatus.fromInt(0), equals(AttendanceStatus.absent));
      expect(AttendanceStatus.fromInt(1), equals(AttendanceStatus.present));
      expect(AttendanceStatus.fromInt(2), equals(AttendanceStatus.sick));
      expect(AttendanceStatus.fromInt(3), equals(AttendanceStatus.permission));
    });

    test('fromInt should return present for invalid values', () {
      expect(AttendanceStatus.fromInt(-1), equals(AttendanceStatus.present));
      expect(AttendanceStatus.fromInt(4), equals(AttendanceStatus.present));
      expect(AttendanceStatus.fromInt(999), equals(AttendanceStatus.present));
    });

    test('fromIntNullable should return null for null input', () {
      expect(AttendanceStatus.fromIntNullable(null), isNull);
    });

    test('fromIntNullable should return correct status for valid values', () {
      expect(
          AttendanceStatus.fromIntNullable(0), equals(AttendanceStatus.absent));
      expect(AttendanceStatus.fromIntNullable(1),
          equals(AttendanceStatus.present));
    });

    test('fromJsonField should parse from different field names', () {
      expect(AttendanceStatus.fromJsonField({'status': 1}),
          equals(AttendanceStatus.present));
      expect(AttendanceStatus.fromJsonField({'attendance_status': 0}),
          equals(AttendanceStatus.absent));
      expect(AttendanceStatus.fromJsonField({'attendance_type': 2}),
          equals(AttendanceStatus.sick));
      expect(AttendanceStatus.fromJsonField({'type': 3}),
          equals(AttendanceStatus.permission));
    });

    test('fromJsonField should parse string values', () {
      expect(AttendanceStatus.fromJsonField({'status': '1'}),
          equals(AttendanceStatus.present));
      expect(AttendanceStatus.fromJsonField({'status': '0'}),
          equals(AttendanceStatus.absent));
    });

    test('fromJsonField should default to present for missing/invalid values',
        () {
      expect(
          AttendanceStatus.fromJsonField({}), equals(AttendanceStatus.present));
      expect(AttendanceStatus.fromJsonField({'status': 'invalid'}),
          equals(AttendanceStatus.present));
      expect(AttendanceStatus.fromJsonField({'other_field': 1}),
          equals(AttendanceStatus.present));
    });

    test('isValidStatusValue should validate status values', () {
      expect(AttendanceStatus.isValidStatusValue(0), isTrue);
      expect(AttendanceStatus.isValidStatusValue(1), isTrue);
      expect(AttendanceStatus.isValidStatusValue(2), isTrue);
      expect(AttendanceStatus.isValidStatusValue(3), isTrue);

      expect(AttendanceStatus.isValidStatusValue(-1), isFalse);
      expect(AttendanceStatus.isValidStatusValue(4), isFalse);
      expect(AttendanceStatus.isValidStatusValue(999), isFalse);
    });

    test('enum values should have correct properties', () {
      expect(AttendanceStatus.absent.value, equals(0));
      expect(AttendanceStatus.absent.label, equals('Tidak Hadir'));
      expect(AttendanceStatus.absent.englishLabel, equals('Alpa'));

      expect(AttendanceStatus.present.value, equals(1));
      expect(AttendanceStatus.present.label, equals('Hadir'));
      expect(AttendanceStatus.present.englishLabel, equals('Present'));

      expect(AttendanceStatus.sick.value, equals(2));
      expect(AttendanceStatus.sick.label, equals('Sakit'));
      expect(AttendanceStatus.sick.englishLabel, equals('Sick'));

      expect(AttendanceStatus.permission.value, equals(3));
      expect(AttendanceStatus.permission.label, equals('Izin'));
      expect(AttendanceStatus.permission.englishLabel, equals('Permission'));
    });
  });
}
