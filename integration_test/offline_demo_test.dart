import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:milliy_metr/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Offline Demo Mode End-to-End Test', (WidgetTester tester) async {
    // 1. Start the app (this naturally starts without the backend if we don't start the server)
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Wait for splash screen and potentially onboarding to finish
    // Since we are mocking, we can tap through onboarding if needed
    final getStartedButton = find.text('Boshlash'); // Adjust based on language
    if (getStartedButton.evaluate().isNotEmpty) {
      await tester.tap(getStartedButton);
      await tester.pumpAndSettle();
    }
    
    // Select persona if needed (Guest)
    final guestButton = find.text('Mehmon');
    if (guestButton.evaluate().isNotEmpty) {
      await tester.tap(guestButton);
      await tester.pumpAndSettle();
    }

    // Skip personalization
    final skipButton = find.text('O\'tkazib yuborish');
    if (skipButton.evaluate().isNotEmpty) {
      await tester.tap(skipButton);
      await tester.pumpAndSettle();
    }

    // 2. Home screen verification
    // Verify a category appears (e.g., Bricks or Cement depending on language)
    expect(find.byType(ListView), findsWidgets); // Should have lists (categories, featured)
    
    // Tap Catalog tab in BottomNavigationBar
    final catalogTab = find.byIcon(Icons.grid_view_rounded);
    if (catalogTab.evaluate().isNotEmpty) {
      await tester.tap(catalogTab);
      await tester.pumpAndSettle();
    }

    // 3. Catalog Verification
    // Tap on the first category to ensure it loads
    final firstCategory = find.byType(ListTile).first;
    if (firstCategory.evaluate().isNotEmpty) {
        await tester.tap(firstCategory);
        await tester.pumpAndSettle();
        
        // Verify products are displayed
        expect(find.byType(GridView), findsWidgets);
        
        // Tap first product
        final firstProduct = find.byType(GestureDetector).first; // Product cards usually have GestureDetector
        await tester.tap(firstProduct);
        await tester.pumpAndSettle();
        
        // Verify Product Details (Add to Cart button exists)
        expect(find.byIcon(Icons.shopping_cart_outlined), findsWidgets);
    }
    
    // Finish test successfully
    debugPrint('Offline Demo Mode test completed successfully.');
  });
}
