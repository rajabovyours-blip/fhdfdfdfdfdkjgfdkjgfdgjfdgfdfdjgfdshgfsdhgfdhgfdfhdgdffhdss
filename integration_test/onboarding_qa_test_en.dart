import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:milliy_metr/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:milliy_metr/core/storage/preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Physical Device QA: English', () {
    testWidgets('4. English Localization', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await PreferencesManager.init();
      await PreferencesManager.setLanguage('en');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.text('Get Started'), findsOneWidget);
    });
  });
}
