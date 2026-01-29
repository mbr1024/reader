class AppConfig {
  static const String appName = '小说阅读器';
  static const String appVersion = '1.0.0';

  // API 配置 (10.0.2.2 是 Android 模拟器访问主机的特殊 IP)
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // 阅读器默认配置
  static const double defaultFontSize = 18.0;
  static const double minFontSize = 12.0;
  static const double maxFontSize = 32.0;
  static const double defaultLineHeight = 1.8;

  // 缓存配置
  static const int maxCachedChapters = 100;
  static const int preloadChapters = 3;
}
