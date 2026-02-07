/// 广告数据模型
class AdItem {
  final String id;
  final AdType type;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? actionText;
  final String? targetUrl;
  final String advertiser;

  const AdItem({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.imageUrl,
    this.actionText,
    this.targetUrl,
    required this.advertiser,
  });
}

/// 广告类型
enum AdType {
  banner,       // 横幅广告
  native,       // 信息流广告（原生广告）
  interstitial, // 插页广告
}
