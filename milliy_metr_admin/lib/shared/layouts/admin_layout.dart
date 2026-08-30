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
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text('Milliy Metr Admin'),
              actions: [_buildTopActions(context)],
            )
          : null,
      drawer: isMobile ? _buildSidebar(context, isMobile: true) : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(context, isMobile: false),
          Expanded(
            child: Column(
              children: [
                if (!isMobile) _buildTopHeader(context),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, {required bool isMobile}) {
    final width = _isSidebarExpanded ? 260.0 : 80.0;
    
    return Container(
      width: isMobile ? 260.0 : width,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 24),
          if (_isSidebarExpanded || isMobile)
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
                _buildNavItem(context, 'Dashboard', Icons.dashboard, '/dashboard', isMobile: isMobile),
                _buildNavItem(context, 'Kategoriyalar', Icons.category, '/categories', isMobile: isMobile),
                _buildNavItem(context, 'Mahsulotlar', Icons.inventory, '/products', isMobile: isMobile),
                _buildNavItem(context, 'Buyurtmalar', Icons.list_alt, '/orders', isMobile: isMobile),
                _buildNavItem(context, 'Bannerlar', Icons.image, '/banners', isMobile: isMobile),
                _buildNavItem(context, 'Mijozlar', Icons.people, '/users', isMobile: isMobile),
                _buildNavItem(context, 'Bildirishnomalar', Icons.notifications, '/notifications', isMobile: isMobile),
                _buildNavItem(context, 'Administratorlar', Icons.admin_panel_settings, '/admin_users', isMobile: isMobile),
              ],
            ),
          ),
          if (!isMobile)
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

  Widget _buildNavItem(BuildContext context, String title, IconData icon, String route, {required bool isMobile}) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final isSelected = currentRoute.startsWith(route);

    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFFFF7A00) : Theme.of(context).iconTheme.color),
      title: (_isSidebarExpanded || isMobile)
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
        if (isMobile) {
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
              Text('API: Online', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          _buildTopActions(context),
        ],
      ),
    );
  }

  Widget _buildTopActions(BuildContext context) {
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
          items: const [
            DropdownMenuItem(value: Locale('uz'), child: Text('O\'zbek')),
            DropdownMenuItem(value: Locale('ru'), child: Text('Русский')),
          ],
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.red),
          tooltip: 'Chiqish',
          onPressed: () {
            sharedPrefs.remove('admin_token');
            context.go('/login');
          },
        ),
      ],
    );
  }
}
