import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:milliy_metr/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test', () {
    testWidgets('verify app boots and navigates', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
