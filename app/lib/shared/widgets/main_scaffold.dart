import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 主框架 - 简洁现代风格
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFF0F0F0),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book,
                  label: '书架',
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: '发现',
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: '我的',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _calculateSelectedIndex(context) == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index, context),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFF999999),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/bookshelf')) return 0;
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/bookshelf');
        break;
      case 1:
        context.go('/explore');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }
}
