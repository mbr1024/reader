class AppConfig {
  static const String appName = '绯页';
  static const String appVersion = '1.0.0';

  // 服务器配置 - 通过 .env 文件注入
  // flutter run --dart-define-from-file=.env
  static const String _apiUrl = String.fromEnvironment('API_URL');

  /// 获取 API 基础地址
  static String get baseUrl {
    assert(_apiUrl.isNotEmpty, '请配置 API_URL 环境变量，使用 --dart-define-from-file=.env');
    return _apiUrl;
  }
  
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
