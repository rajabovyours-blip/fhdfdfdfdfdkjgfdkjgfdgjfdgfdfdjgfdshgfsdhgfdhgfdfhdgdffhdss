import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/core/utils/app_formatters.dart';
import 'package:milliy_metr/features/cart/presentation/providers/cart_notifier.dart';
import 'package:milliy_metr/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:milliy_metr/features/checkout/domain/entities/cart_item_entity.dart';
import 'package:milliy_metr/features/checkout/presentation/widgets/cart_item_card.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

import 'package:milliy_metr/core/providers/auth_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(cartNotifierProvider.notifier).loadCart());
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          context.l10n.clearCartQuestion,
          style: TextStyle(color: context.colors.textHigh),
        ),
        content: Text(
          context.l10n.clearCartWarning,
          style: TextStyle(color: context.colors.textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.l10n.cancel,
              style: TextStyle(color: context.colors.textMedium),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(cartNotifierProvider.notifier).clearCart();
            },
            child: Text(
              context.l10n.clear,
              style: TextStyle(color: context.colors.danger),
            ),
          ),
        ],
      ),
    );
  }

  void _removeItemWithUndo(CartItemEntity item) {
    final notifier = ref.read(cartNotifierProvider.notifier);
    notifier.removeFromCart(item.id);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.itemRemovedFromCart),
        backgroundColor: context.colors.surfaceVariant,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: context.l10n.undo,
          textColor: context.colors.secondary,
          onPressed: () {
            notifier.addToCart(item.product, item.quantity);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartNotifierProvider);
    final notifier = ref.read(cartNotifierProvider.notifier);
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          context.l10n.cart,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: context.colors.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (notifier.itemCount > 0 && isAuthenticated)
            IconButton(
              icon: Icon(
                Icons.delete_sweep_outlined,
                color: context.colors.textMedium,
              ),
              onPressed: _showClearCartDialog,
              tooltip: context.l10n.clearCartTooltip,
            ),
        ],
      ),
      body: !isAuthenticated 
          ? _buildGuestState() 
          : state.maybeWhen(
              loading: () => _buildSkeleton(),
              error: (e) => _buildErrorState(e),
              loaded: (cartItems) {
          if (cartItems.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Cart Items
                    ...cartItems.map((item) {
                      return CartItemCard(
                        item: item,
                        onIncrement: () {
                          final maxQty = item.product.stock > 0 ? item.product.stock : 99;
                          if (item.quantity < maxQty) {
                            notifier.updateCartItem(item.id, item.quantity + 1);
                          }
                        },
                        onDecrement: () {
                          if (item.quantity <= 1) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: context.colors.surface,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: Text('Tasdiqlash', style: TextStyle(color: context.colors.textHigh)),
                                content: Text('Ushbu mahsulotni savatdan olib tashlamoqchimisiz?', style: TextStyle(color: context.colors.textMedium)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text(context.l10n.cancel, style: TextStyle(color: context.colors.textMedium)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _removeItemWithUndo(item);
                                    },
                                    child: Text(context.l10n.clear, style: TextStyle(color: context.colors.danger)),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            notifier.updateCartItem(item.id, item.quantity - 1);
                          }
                        },
                        onRemove: () => _removeItemWithUndo(item),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Order Summary
                    _buildOrderSummary(notifier),
                  ],
                ),
              ),

              // Sticky Checkout CTA
              _buildCheckoutSticky(notifier, cartItems),
            ],
          );
        },
        orElse: () => _buildSkeleton(),
      ),
    );
  }

  Widget _buildGuestState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                size: 64,
                color: context.colors.textMedium,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.guestModeTitle,
              style: TextStyle(
                color: context.colors.textHigh,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.guestCartDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textMedium,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  context.l10n.login,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.colors.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: context.colors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.cartEmpty,
              style: TextStyle(
                color: context.colors.textHigh,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.cartEmptyDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textMedium,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  context.l10n.viewProducts,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.colors.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.orderSummary,
            style: TextStyle(
              color: context.colors.textHigh,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: context.l10n.products,
            value: AppFormatters.currency(
              notifier.subtotal,
              Localizations.localeOf(context).languageCode,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: context.l10n.delivery,
            value: AppFormatters.currency(
              notifier.shippingFee,
              Localizations.localeOf(context).languageCode,
            ),
          ),
          if (notifier.discount > 0) ...[
            const SizedBox(height: 12),
            _SummaryRow(
              label: context.l10n.discount,
              value:
                  '-${AppFormatters.currency(notifier.discount, Localizations.localeOf(context).languageCode)}',
              valueColor: context.colors.success,
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: context.colors.outline, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.total,
                style: TextStyle(
                  color: context.colors.textHigh,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                AppFormatters.currency(
                  notifier.total,
                  Localizations.localeOf(context).languageCode,
                ),
                style: TextStyle(
                  color: context.colors.secondary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSticky(
    CartNotifier notifier,
    List<CartItemEntity> items,
  ) {
    final bool canCheckout =
        items.isNotEmpty && items.every((e) => e.quantity <= e.product.stock);

    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${context.l10n.total}:',
                    style: TextStyle(
                      color: context.colors.textMedium,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    AppFormatters.currency(
                      notifier.total,
                      Localizations.localeOf(context).languageCode,
                    ),
                    style: TextStyle(
                      color: context.colors.textHigh,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  key: const Key('checkout_button'),
                  onPressed: canCheckout
                      ? () {
                          // Pass selected items to checkout provider
                          final selectedItems =
                              items.where((e) => e.isSelected).toList();
                          ref
                              .read(checkoutProvider.notifier)
                              .initializeWithCartItems(selectedItems);
                          context.push(AppRoutes.checkout);
                        }
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.someItemsOutOfStock),
                              backgroundColor: context.colors.danger,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canCheckout
                        ? context.colors.primary
                        : context.colors.outline,
                    foregroundColor: canCheckout
                        ? context.colors.onPrimary
                        : context.colors.textMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    context.l10n.checkout,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: canCheckout
                          ? context.colors.onPrimary
                          : context.colors.textMedium,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Center(
      child: CircularProgressIndicator(color: context.colors.primary),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: context.colors.danger),
            const SizedBox(height: 16),
            Text(
              context.l10n.errorLoadingCart,
              style: TextStyle(
                color: context.colors.textHigh,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.checkInternetAndRetry,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textMedium),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  ref.read(cartNotifierProvider.notifier).loadCart(),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: context.colors.textMedium, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? context.colors.textHigh,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
