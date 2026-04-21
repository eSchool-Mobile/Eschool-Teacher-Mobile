import 'package:flutter_test/flutter_test.dart';
import 'package:eschool_saas_staff/data/models/extracurricularAttendance.dart';

void main() {
  group('AttendanceData Tests', () {
    test('create should create valid AttendanceData', () {
      final data = AttendanceData.create(studentId: 123, type: 1);
      expect(data.studentId, equals(123));
      expect(data.type, equals(1));
    });

    test('create should throw error for invalid student ID', () {
      expect(
        () => AttendanceData.create(studentId: 0, type: 1),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => AttendanceData.create(studentId: -1, type: 1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('create should throw error for invalid type', () {
      expect(
        () => AttendanceData.create(studentId: 123, type: -1),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => AttendanceData.create(studentId: 123, type: 4),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
        'fromAttendance should create AttendanceData from ExtracurricularAttendance',
        () {
      final attendance = ExtracurricularAttendance(
        attendanceId: 1,
        studentId: 123,
        studentName: 'Test Student',
        status: AttendanceStatus.present,
        date: DateTime(2025, 11, 18),
      );

      final data = AttendanceData.fromAttendance(attendance);
      expect(data.studentId, equals(123));
      expect(data.type, equals(1));
    });

    test('isValid should validate AttendanceData', () {
      const validData = AttendanceData(studentId: 123, type: 1);
      expect(validData.isValid(), isTrue);

      const invalidStudentId = AttendanceData(studentId: 0, type: 1);
      expect(invalidStudentId.isValid(), isFalse);

      const invalidType = AttendanceData(studentId: 123, type: -1);
      expect(invalidType.isValid(), isFalse);
    });

    test('toJson should create correct JSON structure', () {
      const data = AttendanceData(studentId: 123, type: 1);
      final json = data.toJson();

      expect(json['student_id'], equals(123));
      expect(json['type'], equals(1));
      expect(json.containsKey('id'), isFalse); // Should NOT contain 'id' field
    });

    test('toString should include status label', () {
      const data = AttendanceData(studentId: 123, type: 1);
      final string = data.toString();

      expect(string, contains('studentId: 123'));
      expect(string, contains('type: 1'));
      expect(string, contains('status: Hadir'));
    });

    test('equality should work correctly', () {
      const data1 = AttendanceData(studentId: 123, type: 1);
      const data2 = AttendanceData(studentId: 123, type: 1);
      const data3 = AttendanceData(studentId: 456, type: 1);

      expect(data1, equals(data2));
      expect(data1, isNot(equals(data3)));
    });

    test('hashCode should be consistent', () {
      const data1 = AttendanceData(studentId: 123, type: 1);
      const data2 = AttendanceData(studentId: 123, type: 1);

      expect(data1.hashCode, equals(data2.hashCode));
    });
  });
}
