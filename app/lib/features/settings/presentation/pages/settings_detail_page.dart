import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/reader_settings.dart';

/// 设置页面 - 二级页面
class SettingsDetailPage extends StatefulWidget {
  const SettingsDetailPage({super.key});

  @override
  State<SettingsDetailPage> createState() => _SettingsDetailPageState();
}

class _SettingsDetailPageState extends State<SettingsDetailPage> {
  bool _darkMode = false;
  
  // 阅读设置
  late double _fontSize;
  late double _lineHeight;
  late int _bgColorValue;

  final _storage = StorageService.instance;

  static const _bgOptions = [
    {'color': 0xFFFFFFFF, 'name': '白色'},
    {'color': 0xFFF5F0E1, 'name': '护眼'},
    {'color': 0xFFCCE8CF, 'name': '绿色'},
    {'color': 0xFF1C1C1E, 'name': '夜间'},
  ];

  @override
  void initState() {
    super.initState();
    final settings = _storage.getSettings();
    _fontSize = settings.fontSize;
    _lineHeight = settings.lineHeight;
    _bgColorValue = settings.backgroundColorValue;
  }

  void _saveSettings() {
    _storage.saveSettings(ReaderSettings(
      fontSize: _fontSize,
      lineHeight: _lineHeight,
      backgroundColorValue: _bgColorValue,
    ));
  }

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
          
          // 设置
          _buildSectionHeader('阅读与显示'),
          _buildSettingsCard([
            _buildSliderItem(
              icon: Icons.text_fields,
              title: '字体大小',
              value: _fontSize,
              min: 16,
              max: 32,
              divisions: 16,
              displayValue: '${_fontSize.toInt()}',
              onChanged: (v) {
                setState(() => _fontSize = v);
                _saveSettings();
              },
            ),
            _buildSliderItem(
              icon: Icons.format_line_spacing,
              title: '行间距',
              value: _lineHeight,
              min: 1.5,
              max: 3.0,
              divisions: 6,
              displayValue: _lineHeight.toStringAsFixed(1),
              onChanged: (v) {
                setState(() => _lineHeight = v);
                _saveSettings();
              },
            ),
            _buildBgColorItem(),
            _buildSwitchItem(
              icon: Icons.dark_mode_outlined,
              title: '深色模式',
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
            _buildSettingItem(
              icon: Icons.cleaning_services_outlined,
              title: '清除缓存',
              value: '128 MB',
              onTap: () => _showClearCacheDialog(),
            ),
          ]),

          // 关于与帮助
          _buildSectionHeader('关于与帮助'),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.info_outline,
              title: '关于绯页',
              value: 'v1.0.0',
              onTap: () => _showAboutDialog(),
            ),
            _buildSettingItem(
              icon: Icons.help_outline,
              title: '帮助与反馈',
              onTap: () => _showFeedbackDialog(),
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
      child: Text(title, style: const TextStyle(
        fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
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
            Icon(icon, size: 22,
              color: isDestructive ? AppColors.error : AppColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: TextStyle(
              fontSize: 15, color: isDestructive ? AppColors.error : AppColors.textPrimary))),
            if (value != null)
              Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios, size: 14,
              color: isDestructive ? AppColors.error.withValues(alpha: 0.5) : AppColors.textMuted),
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
          Expanded(child: Text(title, style: const TextStyle(
            fontSize: 15, color: AppColors.textPrimary))),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }

  /// 带滑块的设置项
  Widget _buildSliderItem({
    required IconData icon,
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: AppColors.textSecondary),
              const SizedBox(width: 14),
              Expanded(child: Text(title, style: const TextStyle(
                fontSize: 15, color: AppColors.textPrimary))),
              Text(displayValue, style: const TextStyle(
                fontSize: 14, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  /// 阅读背景选择
  Widget _buildBgColorItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette_outlined, size: 22, color: AppColors.textSecondary),
              const SizedBox(width: 14),
              const Text('阅读背景', style: TextStyle(
                fontSize: 15, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Row(
              children: _bgOptions.map((opt) {
                final color = Color(opt['color'] as int);
                final name = opt['name'] as String;
                final selected = _bgColorValue == opt['color'];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _bgColorValue = opt['color'] as int);
                      _saveSettings();
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected ? AppColors.primary : AppColors.border,
                              width: selected ? 2 : 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(name, style: TextStyle(
                          fontSize: 11,
                          color: selected ? AppColors.primary : AppColors.textMuted,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存数据吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('取消', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清除')));
            },
            child: const Text('确定', style: TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('帮助与反馈', style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('遇到问题或有建议？请告诉我们：',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '请输入您的反馈...',
                hintStyle: const TextStyle(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('取消', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('感谢您的反馈！'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF333333),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ));
            },
            child: const Text('提交', style: TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('关于', style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('绯页 v1.0.0', style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            SizedBox(height: 8),
            Text('一款简洁优雅的小说阅读应用',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('确定', style: TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
