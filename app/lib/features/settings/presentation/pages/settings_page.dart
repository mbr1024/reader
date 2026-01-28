import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 用户信息卡片
          _buildUserCard(context),
          const SizedBox(height: 16),

          // 阅读设置
          _buildSectionTitle('阅读设置'),
          _buildSettingItem(
            icon: Icons.text_fields,
            title: '字体大小',
            subtitle: '18',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.format_line_spacing,
            title: '行间距',
            subtitle: '1.8',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.palette_outlined,
            title: '阅读背景',
            subtitle: '护眼绿',
            onTap: () {},
          ),
          const Divider(height: 32),

          // 通用设置
          _buildSectionTitle('通用设置'),
          _buildSwitchItem(
            icon: Icons.dark_mode_outlined,
            title: '深色模式',
            value: false,
            onChanged: (value) {},
          ),
          _buildSwitchItem(
            icon: Icons.wifi_off_outlined,
            title: '仅 WiFi 下载',
            value: true,
            onChanged: (value) {},
          ),
          _buildSettingItem(
            icon: Icons.cleaning_services_outlined,
            title: '清除缓存',
            subtitle: '128 MB',
            onTap: () {},
          ),
          const Divider(height: 32),

          // 账户
          _buildSectionTitle('账户'),
          _buildSettingItem(
            icon: Icons.sync,
            title: '同步数据',
            subtitle: '上次同步: 今天 10:30',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.logout,
            title: '退出登录',
            onTap: () {
              _showLogoutDialog(context);
            },
            isDestructive: true,
          ),
          const Divider(height: 32),

          // 关于
          _buildSectionTitle('关于'),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: '版本',
            subtitle: '1.0.0',
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

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '读者',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '点击登录同步阅读记录',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？退出后本地数据将保留。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
