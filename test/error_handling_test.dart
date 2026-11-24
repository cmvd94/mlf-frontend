import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlf_frontend/core/network/api_client.dart';
import 'package:mlf_frontend/core/errors/exceptions.dart';
import 'package:mlf_frontend/core/utils/error_boundary.dart';
import 'package:mlf_frontend/main.dart';

void main() {
  group('Error Handling & Crash Proofing Tests', () {
    testWidgets('AppErrorBoundary displays fallback UI when builder throws and recovers on retry', (tester) async {
      bool shouldThrow = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AppErrorBoundary(
                  sectionName: 'Test Section',
                  builder: (context) {
                    if (shouldThrow) {
                      throw Exception('Simulated widget crash');
                    }
                    return const Text('Widget Rendered Successfully');
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify boundary caught the error and rendered default fallback UI
      expect(find.text('Something went wrong in Test Section'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Reset and trigger retry
      shouldThrow = false;
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(find.text('Widget Rendered Successfully'), findsOneWidget);
    });

    testWidgets('StartupErrorScreen renders error details and retry buttons without overflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StartupErrorScreen(error: 'Fatal DB lock exception'),
        ),
      );

      expect(find.text('Application Startup Issue'), findsOneWidget);
      expect(find.text('Fatal DB lock exception'), findsOneWidget);
      expect(find.text('View Logs'), findsOneWidget);
      expect(find.text('Retry Launch'), findsOneWidget);
    });

    test('ApiClient handles invalid or malformed URI gracefully without crash', () async {
      final client = ApiClient();
      expect(
        () => client.get('::bad_endpoint::'),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
