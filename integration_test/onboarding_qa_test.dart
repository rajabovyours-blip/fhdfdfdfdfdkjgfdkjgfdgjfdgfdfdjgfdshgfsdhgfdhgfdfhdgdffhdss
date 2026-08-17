import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:milliy_metr/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:milliy_metr/core/storage/preferences.dart';
import 'package:milliy_metr/features/personalization/presentation/views/personalization_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Physical Device QA: Onboarding & Personalization', () {
    
    testWidgets('1. Uzbek Guest Flow', (tester) async {
      // Clear actual preferences to simulate fresh installation
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await PreferencesManager.init();
      await PreferencesManager.setLanguage('uz'); // Force UZ language

      app.main();

      // Wait for splash and onboarding
      await tester.pumpAndSettle(const Duration(seconds: 10));
      
      // Expect UZ "Boshlash"
      expect(find.text('Boshlash'), findsOneWidget);
      expect(find.text('Get Started'), findsNothing);

      // Tap Boshlash
      await tester.tap(find.text('Boshlash'));
      await tester.pump(const Duration(seconds: 2));

      // Personalization Screen
      expect(find.byType(PersonalizationScreen), findsOneWidget);

      // Wait for categories to load
      await tester.pump(const Duration(seconds: 3));

      // Verify category counts (we scroll to find them or just check the grid exists)
      final grid = find.byType(GridView);
      expect(grid, findsOneWidget);


      // Note: we might not have keys on category cards. Let's find by InkWell inside PersonalizationScreen
      final inkWells = find.descendant(
        of: find.byType(GridView),
        matching: find.byType(InkWell),
      );
      
      expect(inkWells.evaluate().length, greaterThan(2)); // We should see at least a few on screen

      // Tap the first one
      await tester.tap(inkWells.at(0));
      await tester.pump(const Duration(milliseconds: 500));
      
      // Tap the second one
      await tester.tap(inkWells.at(1));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify still on Personalization screen (didn't crash or navigate)
      expect(find.byType(PersonalizationScreen), findsOneWidget);

      // Tap Continue (Davom etish)
      final continueBtn = find.text('Davom etish');
      expect(continueBtn, findsOneWidget);
      await tester.tap(continueBtn);
      await tester.pump(const Duration(seconds: 3));

      // Verify Home Screen is reached (no login)
      expect(find.byKey(const Key('catalog_tab')), findsOneWidget);
      expect(find.byKey(const Key('login_phone_field')), findsNothing);
    });

    testWidgets('2. Persistence (No Onboarding on Relaunch)', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      await prefs.setStringList('preferred_categories', ['some_id']);
      await prefs.setString('language', 'uz');
      
      app.main();
      await tester.pump(const Duration(seconds: 10));

      // Should be on Home directly
      expect(find.text('Boshlash'), findsNothing);
      expect(find.byType(PersonalizationScreen), findsNothing);
      expect(find.byKey(const Key('catalog_tab')), findsOneWidget);
    });

  });
}
