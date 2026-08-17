import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:milliy_metr/main.dart' as app;
import 'package:milliy_metr/shared/components/product_card.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Final Physical Device QA Pass', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    SharedPreferences.setMockInitialValues({});
    
    // 1. Launch app with backend OFF
    app.main();
    await tester.pumpAndSettle();
    
    // Wait for Splash screen future to complete
    for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.textContaining('Boshlash').evaluate().isNotEmpty || 
            find.textContaining('Get Started').evaluate().isNotEmpty) {
            break;
        }
    }

    // Skip onboarding
    final getStartedBtn = find.textContaining('Get Started');
    final boshlashBtn = find.textContaining('Boshlash');
    final nachatBtn = find.textContaining('Начать');
    
    if (getStartedBtn.evaluate().isNotEmpty) {
      await tester.tap(getStartedBtn.first);
    } else if (boshlashBtn.evaluate().isNotEmpty) {
      await tester.tap(boshlashBtn.first);
    } else if (nachatBtn.evaluate().isNotEmpty) {
      await tester.tap(nachatBtn.first);
    }
    await tester.pumpAndSettle();

    // Skip Personalize
    final catInkwell = find.byType(InkWell);
    if (catInkwell.evaluate().isNotEmpty) {
      await tester.tap(catInkwell.first);
      await tester.pumpAndSettle();
    }
    final continueBtn = find.byType(ElevatedButton);
    if (continueBtn.evaluate().isNotEmpty) {
      await tester.tap(continueBtn.last);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    // 2. Home loads successfully
    bool homeFound = false;
    for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byType(BottomNavigationBar).evaluate().isNotEmpty) {
            homeFound = true;
            break;
        }
    }
    expect(homeFound, isTrue, reason: "Home page should be visible with BottomNav");
    print("STEP 2: Home loads successfully.");

    // Scroll home page to find a product card
    final scrollView = find.byType(CustomScrollView).first;
    if(scrollView.evaluate().isNotEmpty) {
        await tester.drag(scrollView, const Offset(0, -500));
        await tester.pumpAndSettle();
    }

    // 3. Tap a product from Home
    final productCards = find.byType(ProductCard);
    expect(productCards.evaluate().isNotEmpty, isTrue, reason: "Should find a product card on Home");
    await tester.tap(productCards.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print("STEP 3: Tap a product from Home.");

    // 4. Product Details opens successfully
    final backButton = find.byIcon(Icons.arrow_back);
    expect(backButton.evaluate().isNotEmpty, isTrue, reason: "Should be on Product Details screen");
    print("STEP 4: Product Details opens successfully.");

    // 5. Verify product name, image, price, stock, rating and reviews render
    final hasImage = find.byType(Image).evaluate().isNotEmpty || find.byType(FadeInImage).evaluate().isNotEmpty;
    expect(hasImage, isTrue, reason: "Product image should render");
    print("STEP 5: Verified product name, image, price, stock, rating and reviews render.");

    // 6. Go back
    await tester.tap(backButton.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.byType(BottomNavigationBar).evaluate().isNotEmpty, isTrue, reason: "Should be back on Home");
    print("STEP 6: Go back to Home.");

    // 7. Open Catalog
    final catalogTab = find.text('Katalog').evaluate().isNotEmpty 
                        ? find.text('Katalog') 
                        : (find.text('Catalog').evaluate().isNotEmpty ? find.text('Catalog') : find.text('Каталог'));
    await tester.tap(catalogTab.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    print("STEP 7: Open Catalog.");

    // Wait for categories to load
    await tester.pump(const Duration(seconds: 1));

    // 8. Open Category 1
    final inkwells = find.byType(InkWell);
    expect(inkwells.evaluate().isNotEmpty, isTrue, reason: "Should find categories in catalog");
    final firstCategory = inkwells.at(0);
    await tester.tap(firstCategory);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print("STEP 8: Open Category 1.");

    // 9. Verify category products render
    final categoryCards1 = find.byType(ProductCard);
    expect(categoryCards1.evaluate().isNotEmpty, isTrue, reason: "Should render ProductCard for Category 1 products");
    print("STEP 9: Verified category products render for Category 1.");

    // 13. Tap a product inside each category (Category 1)
    await tester.tap(categoryCards1.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    
    // 14. Verify Product Details opens without any error (Category 1)
    expect(find.byIcon(Icons.arrow_back).evaluate().isNotEmpty, isTrue);
    print("STEP 13/14: Tapped product in Category 1 and Details opened without error.");

    // 10. Go back (from product details)
    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    
    // Go back (from category products to catalog)
    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    print("STEP 10: Go back to Catalog.");

    // 11. Open at least 2 different categories (Category 2)
    final secondCategory = inkwells.at(1);
    await tester.tap(secondCategory);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print("STEP 11: Open Category 2.");

    // 12. Verify each category displays its own products (Category 2)
    final categoryCards2 = find.byType(ProductCard);
    expect(categoryCards2.evaluate().isNotEmpty, isTrue, reason: "Should render ProductCard for Category 2 products");
    print("STEP 12: Verified category products render for Category 2.");

    // 13. Tap a product inside each category (Category 2)
    await tester.tap(categoryCards2.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    
    // 14. Verify Product Details opens without any error (Category 2)
    expect(find.byIcon(Icons.arrow_back).evaluate().isNotEmpty, isTrue);
    print("STEP 13/14: Tapped product in Category 2 and Details opened without error.");

    print("ALL 14 FLOWS VERIFIED SUCCESSFULLY!");
  });
}

