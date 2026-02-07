import 'dart:math';
import 'models/ad_item.dart';
import 'ad_config.dart';

/// 广告服务
/// 管理广告的加载和获取（目前使用模拟数据）
class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();

  AdService._();

  final _config = AdConfig.instance;
  final _random = Random();

  // ============ 模拟广告数据 ============

  static const _mockBannerAds = [
    AdItem(
      id: 'banner_1',
      type: AdType.banner,
      title: '限时特惠 VIP 会员',
      description: '首月仅需 6 元，畅读百万好书',
      actionText: '立即开通',
      advertiser: '书城会员',
    ),
    AdItem(
      id: 'banner_2',
      type: AdType.banner,
      title: '新书首发 《星辰大海》',
      description: '百万字完结，口碑爆棚',
      actionText: '免费试读',
      advertiser: '书城推荐',
    ),
    AdItem(
      id: 'banner_3',
      type: AdType.banner,
      title: '每日签到领书币',
      description: '连续签到 7 天，额外奖励翻倍',
      actionText: '去签到',
      advertiser: '书城活动',
    ),
  ];

  static const _mockNativeAds = [
    AdItem(
      id: 'native_1',
      type: AdType.native,
      title: '爆款手游推荐',
      description: '策略卡牌，百万玩家在线',
      actionText: '下载',
      advertiser: '游戏广告',
    ),
    AdItem(
      id: 'native_2',
      type: AdType.native,
      title: '学习英语神器',
      description: 'AI 智能对话，每天 10 分钟',
      actionText: '免费体验',
      advertiser: '教育广告',
    ),
    AdItem(
      id: 'native_3',
      type: AdType.native,
      title: '理财新选择',
      description: '稳健收益，安全可靠',
      actionText: '了解更多',
      advertiser: '金融广告',
    ),
    AdItem(
      id: 'native_4',
      type: AdType.native,
      title: '美食外卖优惠',
      description: '新用户立减 20 元',
      actionText: '领取',
      advertiser: '生活服务',
    ),
  ];

  static const _mockInterstitialAds = [
    AdItem(
      id: 'interstitial_1',
      type: AdType.interstitial,
      title: '开通 VIP 免广告',
      description: '畅享无干扰阅读体验\n海量正版好书随心看',
      actionText: '立即开通',
      advertiser: 'VIP 会员',
    ),
    AdItem(
      id: 'interstitial_2',
      type: AdType.interstitial,
      title: '热门游戏推荐',
      description: '全新冒险即将开启\n千万玩家等你来战',
      actionText: '立即下载',
      advertiser: '游戏推广',
    ),
  ];

  // ============ 获取广告 ============

  /// 获取 Banner 广告
  AdItem? getBannerAd() {
    if (!_config.adsEnabled || !_config.bannerEnabled) return null;
    return _mockBannerAds[_random.nextInt(_mockBannerAds.length)];
  }

  /// 获取信息流广告
  AdItem? getNativeAd() {
    if (!_config.adsEnabled || !_config.nativeEnabled) return null;
    return _mockNativeAds[_random.nextInt(_mockNativeAds.length)];
  }

  /// 获取插页广告
  AdItem? getInterstitialAd() {
    if (!_config.adsEnabled || !_config.interstitialEnabled) return null;
    return _mockInterstitialAds[_random.nextInt(_mockInterstitialAds.length)];
  }

  /// 获取指定类型的广告
  AdItem? getAd(AdType type) {
    switch (type) {
      case AdType.banner:
        return getBannerAd();
      case AdType.native:
        return getNativeAd();
      case AdType.interstitial:
        return getInterstitialAd();
    }
  }

  // ============ 广告事件（预留） ============

  /// 记录广告展示
  void trackImpression(AdItem ad) {
    // TODO: 后续接入真实广告 SDK 时实现
    // print('Ad impression: ${ad.id}');
  }

  /// 记录广告点击
  void trackClick(AdItem ad) {
    // TODO: 后续接入真实广告 SDK 时实现
    // print('Ad click: ${ad.id}');
  }
}
