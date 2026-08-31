import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../main.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  bool _isSidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 640;
    final bool isTablet = width >= 640 && width <= 1024;
    final bool isDesktop = width > 1024;
    
    final bool showDrawer = isMobile || isTablet;

    return Scaffold(
      appBar: showDrawer
          ? AppBar(
              title: const Text('Milliy Metr Admin'),
              actions: [_buildTopActions(context, isMobile: isMobile)],
            )
          : null,
      drawer: showDrawer ? _buildSidebar(context, isDrawer: true) : null,
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context, isDrawer: false),
          Expanded(
            child: Column(
              children: [
                if (isDesktop) _buildTopHeader(context),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, {required bool isDrawer}) {
    final width = _isSidebarExpanded ? 260.0 : 80.0;
    
    return Container(
      width: isDrawer ? 260.0 : width,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 24),
          if (_isSidebarExpanded || isDrawer)
            const Text(
              'Milliy Metr',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF7A00),
              ),
            )
          else
            const Icon(Icons.business, color: Color(0xFFFF7A00), size: 32),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildNavItem(context, 'dashboard'.tr(), Icons.dashboard, '/dashboard', isDrawer: isDrawer),
                _buildNavItem(context, 'categories'.tr(), Icons.category, '/categories', isDrawer: isDrawer),
                _buildNavItem(context, 'products'.tr(), Icons.inventory, '/products', isDrawer: isDrawer),
                _buildNavItem(context, 'orders'.tr(), Icons.list_alt, '/orders', isDrawer: isDrawer),
                _buildNavItem(context, 'banners'.tr(), Icons.image, '/banners', isDrawer: isDrawer),
                _buildNavItem(context, 'customers'.tr(), Icons.people, '/users', isDrawer: isDrawer),
                _buildNavItem(context, 'notifications'.tr(), Icons.notifications, '/notifications', isDrawer: isDrawer),
                _buildNavItem(context, 'administrators'.tr(), Icons.admin_panel_settings, '/admin_users', isDrawer: isDrawer),
              ],
            ),
          ),
          if (!isDrawer)
            IconButton(
              icon: Icon(_isSidebarExpanded ? Icons.chevron_left : Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _isSidebarExpanded = !_isSidebarExpanded;
                });
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, String route, {required bool isDrawer}) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final isSelected = currentRoute.startsWith(route);

    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFFFF7A00) : Theme.of(context).iconTheme.color),
      title: (_isSidebarExpanded || isDrawer)
          ? Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFF7A00) : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            )
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      selected: isSelected,
      selectedTileColor: const Color(0xFFFF7A00).withValues(alpha: 0.1),
      onTap: () {
        context.go(route);
        if (isDrawer) {
          Navigator.of(context).pop(); // Close drawer
        }
      },
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      height: 64,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, size: 12, color: Colors.green),
              const SizedBox(width: 8),
              Text('api_online'.tr(), style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          _buildTopActions(context, isMobile: false),
        ],
      ),
    );
  }

  Widget _buildTopActions(BuildContext context, {required bool isMobile}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<Locale>(
          value: context.locale,
          icon: const Icon(Icons.language),
          underline: const SizedBox(),
          onChanged: (Locale? newLocale) {
            if (newLocale != null) {
              context.setLocale(newLocale);
            }
          },
          items: [
            DropdownMenuItem(value: const Locale('uz'), child: isMobile ? const SizedBox.shrink() : const Text('O\'zbek')),
            DropdownMenuItem(value: const Locale('ru'), child: isMobile ? const SizedBox.shrink() : const Text('Русский')),
          ],
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.red),
          tooltip: 'logout'.tr(),
          onPressed: () {
            sharedPrefs.remove('admin_token');
            context.go('/login');
          },
        ),
        if (!isMobile) const SizedBox(width: 8),
      ],
    );
  }
}
