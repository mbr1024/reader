import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/utils/toast.dart';

/// "我的"页面 - 简洁现代风格
class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late bool _isLoggedIn;
  late int _bookCount;

  @override
  void initState() {
    super.initState();
    _refreshState();
  }

  void _refreshState() {
    final storage = StorageService.instance;
    _isLoggedIn = storage.isLoggedIn;
    _bookCount = storage.getBookshelf().length;
  }

  /// 跳转登录页，返回后刷新状态
  Future<void> _goLogin() async {
    await context.push('/login');
    if (mounted) {
      setState(() => _refreshState());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildUserSection(),
              const SizedBox(height: 32),
              _buildStatsSection(),
              const SizedBox(height: 32),
              _buildMenuSection(),
              const SizedBox(height: 24),
              if (_isLoggedIn) _buildLogoutButton(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Text('我的', style: TextStyle(
        fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
    );
  }

  Widget _buildUserSection() {
    if (_isLoggedIn) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.person, size: 28, color: Color(0xFF888888)),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('书友_9527', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                  SizedBox(height: 4),
                  Text('同步阅读进度中', style: TextStyle(fontSize: 13, color: Color(0xFF999999))),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: _goLogin,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(Icons.person_outline, size: 28, color: Color(0xFFAAAAAA)),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('登录 / 注册', style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                    SizedBox(height: 4),
                    Text('登录后同步阅读进度', style: TextStyle(fontSize: 13, color: Color(0xFF999999))),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFCCCCCC)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildStatItem('$_bookCount', '书架'),
          _buildStatDivider(),
          _buildStatItem('12', '读过'),
          _buildStatDivider(),
          _buildStatItem('5.2h', '时长'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 32, color: const Color(0xFFE8E8E8));
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMenuGroup([
            _MenuItem(
              icon: Icons.history_outlined, title: '阅读历史',
              onTap: () => context.push('/reading-history'),
            ),
            _MenuItem(
              icon: Icons.bookmark_outline, title: '我的书签',
              onTap: () => context.push('/bookmarks'),
            ),
            _MenuItem(
              icon: Icons.cloud_outlined, title: '云端同步',
              onTap: () => context.push('/sync'),
            ),
          ]),
          const SizedBox(height: 24),
          _buildMenuGroup([
            _MenuItem(
              icon: Icons.settings_outlined, title: '设置',
              onTap: () => context.push('/settings/detail'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: _buildMenuGroup([
        _MenuItem(
          icon: Icons.logout, title: '退出登录',
          isDestructive: true,
          onTap: () => _showLogoutDialog(),
        ),
      ]),
    );
  }

  Widget _buildMenuGroup(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;
          return Column(
            children: [
              _buildMenuItem(item),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Container(height: 1, color: const Color(0xFFEEEEEE)),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(item.icon, size: 20,
              color: item.isDestructive ? const Color(0xFFE53935) : const Color(0xFF666666)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(item.title, style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500,
                color: item.isDestructive ? const Color(0xFFE53935) : const Color(0xFF1A1A1A))),
            ),
            Icon(Icons.arrow_forward_ios, size: 14,
              color: item.isDestructive
                  ? const Color(0xFFE53935).withValues(alpha: 0.4)
                  : const Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('退出登录',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
        content: const Text('确定要退出登录吗？退出后本地数据将保留。',
          style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消', style: TextStyle(color: Color(0xFF999999))),
          ),
          TextButton(
            onPressed: () async {
              await StorageService.instance.clearAuth();
              if (mounted) {
                Navigator.pop(dialogContext);
                setState(() => _refreshState());
                Toast.show(context, '已退出登录');
              }
            },
            child: const Text('确定',
              style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDestructive;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isDestructive = false,
    required this.onTap,
  });
}
