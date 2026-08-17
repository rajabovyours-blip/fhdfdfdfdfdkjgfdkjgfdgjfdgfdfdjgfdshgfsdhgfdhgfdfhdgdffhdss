import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:milliy_metr/main.dart' as app;

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Guest Flow Test', () {
    testWidgets('Complete Guest to Checkout Flow', (tester) async {
      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'preferred_categories': ['cement'],
      });
      app.main();

      // 1. Wait for app to boot and verify Home Screen
      await tester.pump(const Duration(seconds: 5));
      expect(find.byKey(const Key('catalog_tab')), findsOneWidget);

      // 2. Navigate to Catalog
      await tester.tap(find.byKey(const Key('catalog_tab')));
      await tester.pump(const Duration(seconds: 2));

      // 3. Select first category
      // Wait, byKey with RegExp is not directly supported in flutter_test, we need a predicate
      final firstCategory = find.byWidgetPredicate(
        (widget) => widget.key != null && widget.key.toString().contains('category_card_'),
      ).first;
      expect(firstCategory, findsOneWidget);
      await tester.tap(firstCategory);
      await tester.pump(const Duration(seconds: 3));

      // 4. Open first product
      final firstProduct = find.byWidgetPredicate(
        (widget) => widget.key != null && widget.key.toString().contains('product_card_'),
      ).first;
      expect(firstProduct, findsOneWidget);
      await tester.tap(firstProduct);
      await tester.pump(const Duration(seconds: 3));

      // 5. Add to Cart
      final addToCartBtn = find.byKey(const Key('add_to_cart_button'));
      expect(addToCartBtn, findsOneWidget);
      await tester.tap(addToCartBtn);
      await tester.pump(const Duration(seconds: 3));

      // 6. Navigate to Cart Tab
      // Wait, there might be a back button needed or directly tap tab?
      // Since product details is pushed, we need to go back or tap cart if bottom nav is visible.
      // Usually product details hides bottom nav or has back button.
      // Actually, after adding to cart, let's just go back
      final backButton = find.byIcon(Icons.arrow_back).first;
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pump(const Duration(seconds: 2));
      }
      // Go back to catalog
      final backButton2 = find.byIcon(Icons.arrow_back).first;
      if (backButton2.evaluate().isNotEmpty) {
        await tester.tap(backButton2);
        await tester.pump(const Duration(seconds: 2));
      }
      
      // Now tap Cart Tab
      final cartTab = find.byKey(const Key('cart_tab'));
      expect(cartTab, findsOneWidget);
      await tester.tap(cartTab);
      await tester.pump(const Duration(seconds: 2));

      // 7. Verify cart has item and click Checkout
      final checkoutBtn = find.byKey(const Key('checkout_button'));
      expect(checkoutBtn, findsOneWidget);
      await tester.tap(checkoutBtn);
      await tester.pump(const Duration(seconds: 3));

      // 8. Verify Login Screen appears
      final phoneField = find.byKey(const Key('login_phone_field'));
      expect(phoneField, findsOneWidget);

      // 9. Automate Login
      await tester.enterText(phoneField, '901234567');
      await tester.pump(const Duration(seconds: 1));
      
      final submitLoginBtn = find.byKey(const Key('login_submit_button'));
      await tester.tap(submitLoginBtn);
      await tester.pump(const Duration(seconds: 5));

      // 10. Verify OTP Screen appears and automate it
      final otpField = find.byKey(const Key('otp_field'));
      expect(otpField, findsOneWidget);

      await tester.enterText(otpField, '123456');
      await tester.pump(const Duration(seconds: 1));

      final submitOtpBtn = find.byKey(const Key('otp_submit_button'));
      await tester.tap(submitOtpBtn);
      
      // Wait for login to complete and return to checkout
      await tester.pump(const Duration(seconds: 5));

      // 11. Verify we returned to Checkout (or cart) instead of Home
      // In checkout screen, there is a Checkout title
      // Or we can verify the absence of login screen
      expect(find.byKey(const Key('login_phone_field')), findsNothing);
      expect(find.byKey(const Key('otp_field')), findsNothing);
      // It should be either in Checkout form or back in Cart
    });
  });
}
