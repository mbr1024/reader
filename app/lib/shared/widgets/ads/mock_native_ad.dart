import 'package:flutter/material.dart';
import '../../../core/ads/models/ad_item.dart';
import '../../../core/ads/ad_service.dart';

/// 模拟信息流广告组件（原生广告）
/// 样式与书籍卡片一致，用于列表/网格中插入
class MockNativeAd extends StatelessWidget {
  final AdItem? ad;
  final VoidCallback? onTap;
  
  /// 是否使用网格样式（书架页使用）
  final bool isGridStyle;

  const MockNativeAd({
    super.key,
    this.ad,
    this.onTap,
    this.isGridStyle = false,
  });

  // 信息流广告样式
  static const List<_NativeAdStyle> _styles = [
    // 游戏推广
    _NativeAdStyle(
      bgColors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
      iconBg: Color(0xFF3498DB),
      icon: Icons.sports_esports,
    ),
    // 电商优惠
    _NativeAdStyle(
      bgColors: [Color(0xFFE74C3C), Color(0xFFF39C12)],
      iconBg: Color(0xFFF39C12),
      icon: Icons.shopping_bag_outlined,
    ),
    // 教育学习
    _NativeAdStyle(
      bgColors: [Color(0xFF16A085), Color(0xFF1ABC9C)],
      iconBg: Color(0xFF1ABC9C),
      icon: Icons.auto_stories_outlined,
    ),
    // 生活服务
    _NativeAdStyle(
      bgColors: [Color(0xFFE67E22), Color(0xFFF1C40F)],
      iconBg: Color(0xFFF1C40F),
      icon: Icons.fastfood_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final adItem = ad ?? AdService.instance.getNativeAd();
    if (adItem == null) return const SizedBox.shrink();

    if (isGridStyle) {
      return _buildGridStyle(adItem);
    }
    return _buildListStyle(adItem);
  }

  /// 网格样式（书架页）- 模拟 App 推广卡片
  Widget _buildGridStyle(AdItem adItem) {
    final styleIndex = adItem.id.hashCode.abs() % _styles.length;
    final style = _styles[styleIndex];

    return GestureDetector(
      onTap: () {
        AdService.instance.trackClick(adItem);
        onTap?.call();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                // 模拟 App 图标样式
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: style.bgColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      style.icon,
                      color: Colors.white.withOpacity(0.9),
                      size: 36,
                    ),
                  ),
                ),
                // AD 标签 - 更低调
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text(
                      '广告',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            adItem.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            adItem.advertiser,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }

  /// 列表样式（排行榜页、发现页）
  Widget _buildListStyle(AdItem adItem) {
    final styleIndex = adItem.id.hashCode.abs() % _styles.length;
    final style = _styles[styleIndex];

    return GestureDetector(
      onTap: () {
        AdService.instance.trackClick(adItem);
        onTap?.call();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Row(
          children: [
            // 模拟 App 图标
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: style.bgColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                style.icon,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            // 广告信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    adItem.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    adItem.description ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          '广告',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        adItem.advertiser,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 下载/查看按钮
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: style.bgColors[0],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                adItem.actionText ?? '查看',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NativeAdStyle {
  final List<Color> bgColors;
  final Color iconBg;
  final IconData icon;

  const _NativeAdStyle({
    required this.bgColors,
    required this.iconBg,
    required this.icon,
  });
}
