import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/storage_service.dart';

/// "我的"页面 - 简洁现代风格
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;
    final bookCount = storage.getBookshelf().length;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // 顶部标题
              _buildHeader(),
              
              const SizedBox(height: 32),
              
              // 用户信息
              _buildUserSection(context, storage.isLoggedIn),
              
              const SizedBox(height: 32),
              
              // 阅读统计
              _buildStatsSection(bookCount),
              
              const SizedBox(height: 32),
              
              // 功能列表
              _buildMenuSection(context),
              
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
      child: Text(
        '我的',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _buildUserSection(BuildContext context, bool isLoggedIn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          if (!isLoggedIn) {
            context.push('/login');
          }
        },
        child: Row(
          children: [
            // 头像
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                isLoggedIn ? Icons.person : Icons.person_outline,
                size: 28,
                color: const Color(0xFF888888),
              ),
            ),
            const SizedBox(width: 16),
            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoggedIn ? '书友_9527' : '点击登录',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLoggedIn ? '同步阅读进度中' : '登录后同步阅读进度',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFFCCCCCC),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(int bookCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildStatItem('$bookCount', '书架'),
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 32,
      color: const Color(0xFFE8E8E8),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 第一组菜单
          _buildMenuGroup([
            _MenuItem(
              icon: Icons.history_outlined,
              title: '阅读历史',
              onTap: () => context.push('/reading-history'),
            ),
            _MenuItem(
              icon: Icons.bookmark_outline,
              title: '我的书签',
              onTap: () => context.push('/bookmarks'),
            ),
            _MenuItem(
              icon: Icons.download_outlined,
              title: '离线下载',
              subtitle: '已下载 0 章',
              onTap: () => context.push('/downloads'),
            ),
            _MenuItem(
              icon: Icons.cloud_outlined,
              title: '云端同步',
              onTap: () => context.push('/sync'),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // 第二组菜单
          _buildMenuGroup([
            _MenuItem(
              icon: Icons.settings_outlined,
              title: '设置',
              onTap: () => context.push('/settings/detail'),
            ),
            _MenuItem(
              icon: Icons.help_outline,
              title: '帮助与反馈',
              onTap: () => _showFeedbackDialog(context),
            ),
            _MenuItem(
              icon: Icons.info_outline,
              title: '关于',
              onTap: () => _showAboutDialog(context),
            ),
          ]),
        ],
      ),
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
                  child: Container(
                    height: 1,
                    color: const Color(0xFFEEEEEE),
                  ),
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
            Icon(
              item.icon,
              size: 20,
              color: const Color(0xFF666666),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFFCCCCCC),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '关于',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '小说阅读器 v1.0.0',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '一款简洁优雅的小说阅读应用',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '确定',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '帮助与反馈',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '遇到问题或有建议？请告诉我们：',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '请输入您的反馈...',
                hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '取消',
              style: TextStyle(color: Color(0xFF999999)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('感谢您的反馈！'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF333333),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            child: const Text(
              '提交',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600,
              ),
            ),
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
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
