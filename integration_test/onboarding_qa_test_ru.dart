import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:milliy_metr/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:milliy_metr/core/storage/preferences.dart';
import 'package:milliy_metr/features/personalization/presentation/views/personalization_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Physical Device QA: Russian', () {
    testWidgets('3. Russian Localization', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await PreferencesManager.init();
      await PreferencesManager.setLanguage('ru');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.text('Начать'), findsOneWidget);
      await tester.tap(find.text('Начать'));
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(PersonalizationScreen), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));

      // Select one
      final inkWells = find.descendant(of: find.byType(GridView), matching: find.byType(InkWell));
      await tester.tap(inkWells.first);
      await tester.pump(const Duration(milliseconds: 500));

      // Continue
      expect(find.text('Продолжить'), findsOneWidget);
    });
    
    testWidgets('4. English Localization', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesManager.init();
      await PreferencesManager.setLanguage('en'); // Force EN language

      app.main();
      await tester.pump(const Duration(seconds: 3));

      expect(find.text('Get Started'), findsOneWidget);
    });

  });
}
