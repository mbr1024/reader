import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/ads/models/ad_item.dart';
import '../../../core/ads/ad_service.dart';

/// 模拟 Banner 广告组件
/// 模拟真实广告样式，使用更自然的配色
class MockBannerAd extends StatelessWidget {
  final AdItem? ad;
  final VoidCallback? onTap;
  final double height;

  const MockBannerAd({
    super.key,
    this.ad,
    this.onTap,
    this.height = 80,
  });

  // 模拟真实广告的配色方案（更自然的颜色）
  static const List<_AdStyle> _adStyles = [
    // 游戏类 - 深色系
    _AdStyle(
      bgColor: Color(0xFF1A1A2E),
      accentColor: Color(0xFFE94560),
      textColor: Colors.white,
      buttonBg: Color(0xFFE94560),
      buttonText: Colors.white,
    ),
    // 电商类 - 暖色系
    _AdStyle(
      bgColor: Color(0xFFFFF8F0),
      accentColor: Color(0xFFFF6B35),
      textColor: Color(0xFF2D2D2D),
      buttonBg: Color(0xFFFF6B35),
      buttonText: Colors.white,
    ),
    // 金融类 - 蓝色稳重
    _AdStyle(
      bgColor: Color(0xFFF0F4F8),
      accentColor: Color(0xFF1E88E5),
      textColor: Color(0xFF1A1A1A),
      buttonBg: Color(0xFF1E88E5),
      buttonText: Colors.white,
    ),
    // 教育类 - 清新绿
    _AdStyle(
      bgColor: Color(0xFFF5FBF6),
      accentColor: Color(0xFF2E7D32),
      textColor: Color(0xFF2D2D2D),
      buttonBg: Color(0xFF43A047),
      buttonText: Colors.white,
    ),
    // 生活服务 - 橙黄
    _AdStyle(
      bgColor: Color(0xFFFFFBE6),
      accentColor: Color(0xFFFF9800),
      textColor: Color(0xFF2D2D2D),
      buttonBg: Color(0xFFFF9800),
      buttonText: Colors.white,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final adItem = ad ?? AdService.instance.getBannerAd();
    if (adItem == null) return const SizedBox.shrink();

    // 根据广告 ID 确定样式（保持一致性）
    final styleIndex = adItem.id.hashCode.abs() % _adStyles.length;
    final style = _adStyles[styleIndex];

    return GestureDetector(
      onTap: () {
        AdService.instance.trackClick(adItem);
        onTap?.call();
      },
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: style.bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: style.accentColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // 内容
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  // 左侧图标区域
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: style.accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getAdIcon(adItem.advertiser),
                      color: style.accentColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 中间文字
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          adItem.title,
                          style: TextStyle(
                            color: style.textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (adItem.description != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            adItem.description!,
                            style: TextStyle(
                              color: style.textColor.withOpacity(0.6),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 行动按钮
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: style.buttonBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      adItem.actionText ?? '查看',
                      style: TextStyle(
                        color: style.buttonText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 广告标签
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: style.textColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  '广告',
                  style: TextStyle(
                    color: style.textColor.withOpacity(0.4),
                    fontSize: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAdIcon(String advertiser) {
    if (advertiser.contains('游戏')) return Icons.sports_esports_outlined;
    if (advertiser.contains('会员') || advertiser.contains('VIP')) return Icons.workspace_premium_outlined;
    if (advertiser.contains('教育')) return Icons.school_outlined;
    if (advertiser.contains('金融') || advertiser.contains('理财')) return Icons.account_balance_outlined;
    if (advertiser.contains('生活') || advertiser.contains('外卖')) return Icons.local_offer_outlined;
    if (advertiser.contains('活动')) return Icons.card_giftcard_outlined;
    return Icons.campaign_outlined;
  }
}

class _AdStyle {
  final Color bgColor;
  final Color accentColor;
  final Color textColor;
  final Color buttonBg;
  final Color buttonText;

  const _AdStyle({
    required this.bgColor,
    required this.accentColor,
    required this.textColor,
    required this.buttonBg,
    required this.buttonText,
  });
}
