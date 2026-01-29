import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/services/storage_service.dart';

/// "我的"页面 - 大厂风格个人中心
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;
    final bookCount = storage.getBookshelf().length;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 用户信息卡片
              _buildUserCard(context, storage.isLoggedIn),
              
              // 阅读统计
              _buildStatsSection(bookCount),
              
              // 功能入口
              _buildFunctionSection(context),
              
              // 更多服务
              _buildServiceSection(context),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, bool isLoggedIn) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Row(
        children: [
          // 头像
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 2),
              image: const DecorationImage(
                image: AssetImage('assets/images/logo.png'), // 假设有个logo或者默认头像
                fit: BoxFit.cover,
              ),
            ),
            child: const Icon(Icons.person, size: 40, color: AppColors.textHint), // Fallback
          ),
          const SizedBox(width: 20),
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? '书友_9527' : '点击登录',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E4), // 浅红背景
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '普通用户',
                    style: TextStyle(fontSize: 11, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          // 箭头
          if (!isLoggedIn)
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textHint,
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(int bookCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 20),
      // 移除阴影，使用更轻的背景或透明
      decoration: BoxDecoration(
        color: AppColors.surface,
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
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Roboto', // 更好看的数字字体
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 24,
      color: AppColors.divider,
    );
  }

  Widget _buildFunctionSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        // 移除阴影
      ),
      child: Column(
        children: [
          _buildFunctionItem(
            icon: Icons.history,
            iconColor: const Color(0xFF1677FF),
            title: '阅读历史',
            subtitle: '查看阅读记录',
            onTap: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(left: 60),
            child: Divider(height: 1),
          ),
          _buildFunctionItem(
            icon: Icons.bookmark_outline,
            iconColor: const Color(0xFF13C2C2),
            title: '我的书签',
            subtitle: '管理所有书签',
            onTap: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(left: 60),
            child: Divider(height: 1),
          ),
          _buildFunctionItem(
            icon: Icons.download_outlined,
            iconColor: const Color(0xFFFAAD14),
            title: '离线下载',
            subtitle: '已下载 0 章',
            onTap: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(left: 60),
            child: Divider(height: 1),
          ),
          _buildFunctionItem(
            icon: Icons.cloud_sync_outlined,
            iconColor: const Color(0xFF722ED1),
            title: '云端同步',
            subtitle: '多设备同步进度',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        // 移除阴影
      ),
      child: Column(
        children: [
          _buildServiceItem(
            icon: Icons.settings_outlined,
            title: '设置',
            onTap: () => context.push('/settings/detail'),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 60),
            child: Divider(height: 1),
          ),
          _buildServiceItem(
            icon: Icons.help_outline,
            title: '帮助与反馈',
            onTap: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(left: 60),
            child: Divider(height: 1),
          ),
          _buildServiceItem(
            icon: Icons.info_outline,
            title: '关于',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.textSecondary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
