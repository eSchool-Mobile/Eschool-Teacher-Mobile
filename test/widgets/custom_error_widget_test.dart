import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eschool_saas_staff/ui/widgets/customErrorWidget.dart';

void main() {
  group('CustomErrorWidget Tests', () {
    testWidgets('CustomErrorWidget displays error message correctly',
        (tester) async {
      const testMessage = 'Test error message';
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomErrorWidget(
              message: testMessage,
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );

      // Verify error message is displayed
      expect(find.text(testMessage), findsOneWidget);

      // Verify default title is displayed
      expect(find.text('Oops! Terjadi Kesalahan'), findsOneWidget);

      // Verify retry button is displayed
      expect(find.text('Coba Lagi'), findsOneWidget);

      // Test retry button functionality
      await tester.tap(find.text('Coba Lagi'));
      expect(retryPressed, isTrue);
    });

    testWidgets('CustomErrorWidget displays custom title correctly',
        (tester) async {
      const customTitle = 'Custom Error Title';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomErrorWidget(
              message: 'Test message',
              title: customTitle,
            ),
          ),
        ),
      );

      expect(find.text(customTitle), findsOneWidget);
    });

    testWidgets('CustomErrorWidget hides retry button when onRetry is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomErrorWidget(
              message: 'Test message',
              // onRetry is null
            ),
          ),
        ),
      );

      // Retry button should not be displayed
      expect(find.text('Coba Lagi'), findsNothing);
    });
  });
}
