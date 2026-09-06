import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/features/home/presentation/views/home_screen.dart';
import 'package:milliy_metr/features/catalog/presentation/views/catalog_screen.dart';
import 'package:milliy_metr/features/wishlist/presentation/views/wishlist_screen.dart';
import 'package:milliy_metr/features/checkout/presentation/views/cart_screen.dart';
import 'package:milliy_metr/features/profile/presentation/views/profile_screen.dart';
import 'package:milliy_metr/features/cart/presentation/providers/cart_notifier.dart';
import 'package:milliy_metr/core/providers/main_navigation_provider.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  final StatefulNavigationShell? navigationShell;

  const MainScreen({super.key, this.navigationShell});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  // The original screens list is only used if navigationShell is null (fallback)
  final List<Widget> _screens = [
    const HomeScreen(),
    const CatalogScreen(),
    const WishlistScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Watch cart state to display badge
    final cartState = ref.watch(cartNotifierProvider);
    int cartCount = 0;
    cartState.maybeWhen(
      loaded: (items) {
        cartCount = items.fold(0, (sum, item) => sum + item.quantity);
      },
      orElse: () {},
    );

    final int currentIndex =
        widget.navigationShell?.currentIndex ?? ref.watch(mainTabIndexProvider);

    final isDesktop = MediaQuery.sizeOf(context).width > 700;
    
    final body = widget.navigationShell != null
          ? widget.navigationShell!
          : IndexedStack(
              index: currentIndex,
              children: _screens,
            );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                ref.read(authProvider.notifier).clearError();
                if (widget.navigationShell != null) {
                  widget.navigationShell!.goBranch(
                    index,
                    initialLocation: index == widget.navigationShell!.currentIndex,
                  );
                } else {
                  ref.read(mainTabIndexProvider.notifier).state = index;
                }
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: context.colors.surface,
              indicatorColor: context.colors.primary.withValues(alpha: 0.15),
              indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              selectedIconTheme: IconThemeData(color: context.colors.primary),
              selectedLabelTextStyle: TextStyle(color: context.colors.primary, fontWeight: FontWeight.w600),
              unselectedLabelTextStyle: TextStyle(color: context.colors.textMedium),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: Text(context.l10n.home),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.grid_view_outlined),
                  selectedIcon: const Icon(Icons.grid_view),
                  label: Text(context.l10n.catalog),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.favorite_outline),
                  selectedIcon: const Icon(Icons.favorite),
                  label: Text(context.l10n.wishlist),
                ),
                NavigationRailDestination(
                  icon: Badge(
                    isLabelVisible: cartCount > 0,
                    label: Text(cartCount.toString()),
                    backgroundColor: context.colors.primary,
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: cartCount > 0,
                    label: Text(cartCount.toString()),
                    backgroundColor: context.colors.primary,
                    child: const Icon(Icons.shopping_cart),
                  ),
                  label: Text(context.l10n.cart),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: Text(context.l10n.profile),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      body: body,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Center(
              heightFactor: 1.0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: (index) {
                    ref.read(authProvider.notifier).clearError();
                    if (widget.navigationShell != null) {
                      widget.navigationShell!.goBranch(
                        index,
                        initialLocation: index == widget.navigationShell!.currentIndex,
                      );
                    } else {
                      ref.read(mainTabIndexProvider.notifier).state = index;
                    }
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  selectedItemColor: context.colors.primary,
                  unselectedItemColor: context.colors.textMedium,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  selectedLabelStyle:
                      const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(fontSize: 12),
                  elevation: 0,
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.home_outlined, key: Key('home_tab')),
                      activeIcon: const Icon(Icons.home),
                      label: context.l10n.home,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.grid_view_outlined, key: Key('catalog_tab')),
                      activeIcon: const Icon(Icons.grid_view),
                      label: context.l10n.catalog,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.favorite_outline, key: Key('wishlist_tab')),
                      activeIcon: const Icon(Icons.favorite),
                      label: context.l10n.wishlist,
                    ),
                    BottomNavigationBarItem(
                      icon: Badge(
                        isLabelVisible: cartCount > 0,
                        label: Text(cartCount.toString()),
                        backgroundColor: context.colors.primary,
                        child: const Icon(Icons.shopping_cart_outlined, key: Key('cart_tab')),
                      ),
                      activeIcon: Badge(
                        isLabelVisible: cartCount > 0,
                        label: Text(cartCount.toString()),
                        backgroundColor: context.colors.primary,
                        child: const Icon(Icons.shopping_cart),
                      ),
                      label: context.l10n.cart,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.person_outline, key: Key('profile_tab')),
                      activeIcon: const Icon(Icons.person),
                      label: context.l10n.profile,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
