/// 广告配置
/// 控制广告的开关、频率等参数
class AdConfig {
  static AdConfig? _instance;
  static AdConfig get instance => _instance ??= AdConfig._();

  AdConfig._();

  // ============ 广告总开关 ============
  bool _adsEnabled = true;
  bool get adsEnabled => _adsEnabled;
  set adsEnabled(bool value) => _adsEnabled = value;

  // ============ Banner 广告配置 ============
  bool bannerEnabled = true;

  // ============ 信息流广告配置 ============
  bool nativeEnabled = true;
  
  /// 书架页：每隔多少本书显示一个广告
  int bookshelfAdInterval = 6;
  
  /// 排行榜：每隔多少项显示一个广告
  int rankAdInterval = 5;
  
  /// 分类页：每隔多少项显示一个广告
  int categoryAdInterval = 8;

  // ============ 插页广告配置（备用，目前阅读器使用 Banner） ============
  bool interstitialEnabled = true;
  
  /// 插页广告关闭按钮延迟（秒）
  int interstitialCloseDelay = 3;
  
  // ============ 阅读器广告配置 ============
  /// 阅读器：每阅读多少章显示一次章节间广告
  int readerChapterInterval = 3;

  // ============ 辅助方法 ============

  /// 是否应该在指定索引位置显示广告
  bool shouldShowAdAtIndex(int index, int interval) {
    if (!_adsEnabled || !nativeEnabled) return false;
    if (index == 0) return false; // 第一个位置不显示广告
    return (index + 1) % interval == 0;
  }

  /// 是否应该在阅读指定章节数后显示插页广告
  bool shouldShowInterstitialAfterChapters(int chaptersRead) {
    if (!_adsEnabled || !interstitialEnabled) return false;
    if (chaptersRead == 0) return false;
    return chaptersRead % readerChapterInterval == 0;
  }
}
