import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';

/// 设置页面 - 二级页面
class SettingsDetailPage extends StatefulWidget {
  const SettingsDetailPage({super.key});

  @override
  State<SettingsDetailPage> createState() => _SettingsDetailPageState();
}

class _SettingsDetailPageState extends State<SettingsDetailPage> {
  bool _darkMode = false;
  bool _wifiOnly = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          
          // 阅读设置
          _buildSectionHeader('阅读设置'),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.text_fields,
              title: '字体大小',
              value: '18',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.format_line_spacing,
              title: '行间距',
              value: '1.8',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.palette_outlined,
              title: '阅读背景',
              value: '护眼黄',
              onTap: () {},
            ),
          ]),
          
          // 通用设置
          _buildSectionHeader('通用设置'),
          _buildSettingsCard([
            _buildSwitchItem(
              icon: Icons.dark_mode_outlined,
              title: '深色模式',
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
            _buildSwitchItem(
              icon: Icons.wifi,
              title: '仅 WiFi 下载',
              value: _wifiOnly,
              onChanged: (v) => setState(() => _wifiOnly = v),
            ),
            _buildSettingItem(
              icon: Icons.cleaning_services_outlined,
              title: '清除缓存',
              value: '128 MB',
              onTap: () {},
            ),
          ]),
          
          // 账户安全
          _buildSectionHeader('账户安全'),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.sync,
              title: '同步数据',
              value: '今天 10:30',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: '修改密码',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.logout,
              title: '退出登录',
              isDestructive: true,
              onTap: () => _showLogoutDialog(),
            ),
          ]),
          
          // 关于
          _buildSectionHeader('关于'),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.update,
              title: '版本更新',
              value: '1.0.0',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.description_outlined,
              title: '用户协议',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.privacy_tip_outlined,
              title: '隐私政策',
              onTap: () {},
            ),
          ]),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(height: 1, indent: 52, color: AppColors.divider),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? value,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDestructive ? AppColors.error : AppColors.textSecondary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: isDestructive ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ),
            if (value != null)
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDestructive ? AppColors.error.withOpacity(0.5) : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？退出后本地数据将保留。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
