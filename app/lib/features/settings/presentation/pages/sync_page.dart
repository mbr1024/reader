import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/services/storage_service.dart';

/// 云端同步页面
class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  bool _isSyncing = false;
  bool _autoSync = true;
  bool _syncOnWifiOnly = true;
  DateTime? _lastSyncTime;
  Map<String, int> _syncStats = {};

  @override
  void initState() {
    super.initState();
    _loadSyncInfo();
  }

  void _loadSyncInfo() {
    final storage = StorageService.instance;
    setState(() {
      _lastSyncTime = DateTime.now().subtract(const Duration(hours: 2));
      _syncStats = {
        'bookshelf': storage.getBookshelf().length,
        'bookmarks': 5,
        'histories': 12,
      };
    });
  }

  Future<void> _performSync() async {
    if (!StorageService.instance.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请先登录后使用云端同步'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            label: '去登录',
            onPressed: () {
              // 跳转登录页面
            },
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    // 模拟同步过程
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSyncing = false;
      _lastSyncTime = DateTime.now();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('同步完成'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  String _formatLastSync() {
    if (_lastSyncTime == null) return '从未同步';

    final diff = DateTime.now().difference(_lastSyncTime!);
    if (diff.inMinutes < 1) return '刚刚同步';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = StorageService.instance.isLoggedIn;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('云端同步'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 同步状态卡片
            _buildSyncStatusCard(isLoggedIn),
            
            const SizedBox(height: 16),
            
            // 同步数据统计
            _buildSyncDataSection(),
            
            const SizedBox(height: 16),
            
            // 同步设置
            _buildSyncSettingsSection(),
            
            const SizedBox(height: 24),
            
            // 同步说明
            _buildSyncDescription(),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusCard(bool isLoggedIn) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLoggedIn
              ? [AppColors.primary, AppColors.primary.withOpacity(0.8)]
              : [AppColors.textMuted, AppColors.textHint],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isLoggedIn ? AppColors.primary : AppColors.textMuted).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isLoggedIn ? Icons.cloud_done : Icons.cloud_off,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            isLoggedIn ? '已连接云端' : '未登录',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isLoggedIn ? '上次同步: ${_formatLastSync()}' : '登录后即可同步数据',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSyncing ? null : _performSync,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: isLoggedIn ? AppColors.primary : AppColors.textMuted,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isLoggedIn ? '立即同步' : '登录账号'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncDataSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '同步数据',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDataItem(
                icon: Icons.library_books,
                label: '书架',
                count: _syncStats['bookshelf'] ?? 0,
              ),
              _buildDataDivider(),
              _buildDataItem(
                icon: Icons.bookmark,
                label: '书签',
                count: _syncStats['bookmarks'] ?? 0,
              ),
              _buildDataDivider(),
              _buildDataItem(
                icon: Icons.history,
                label: '历史',
                count: _syncStats['histories'] ?? 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildDataDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.divider,
    );
  }

  Widget _buildSyncSettingsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('自动同步'),
            subtitle: const Text('打开应用时自动同步数据'),
            value: _autoSync,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _autoSync = value;
              });
            },
          ),
          const Divider(height: 1, indent: 16),
          SwitchListTile(
            title: const Text('仅 WiFi 同步'),
            subtitle: const Text('仅在 WiFi 环境下同步数据'),
            value: _syncOnWifiOnly,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _syncOnWifiOnly = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSyncDescription() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                '同步说明',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• 云端同步可在多设备间同步您的书架、阅读进度和书签\n'
            '• 数据采用加密传输，保障您的隐私安全\n'
            '• 同步冲突时会保留最近修改的数据\n'
            '• 建议定期同步以防数据丢失',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
