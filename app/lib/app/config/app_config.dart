import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

class AppConfig {
  static const String appName = '小说阅读器';
  static const String appVersion = '1.0.0';

  // 服务器配置 - 通过 --dart-define 注入
  // 用法: flutter run --dart-define=API_URL=http://your-server:3000
  static const String _apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000',
  );

  // 开发时局域网 IP（可选，通过 --dart-define=LAN_IP=xxx 注入）
  static const String _lanIp = String.fromEnvironment(
    'LAN_IP',
    defaultValue: '192.168.1.100',
  );

  // 是否使用真机开发（局域网IP）
  static const bool _useRealDevice = bool.fromEnvironment(
    'USE_REAL_DEVICE',
    defaultValue: false,
  );

  /// 获取 API 基础地址
  static String get baseUrl {
    // 如果配置了 API_URL，直接使用
    if (_apiUrl != 'http://localhost:3000') {
      return _apiUrl;
    }

    // Release 模式必须配置 API_URL
    if (kReleaseMode) {
      return _apiUrl;
    }

    // Debug 模式根据平台选择开发地址
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      if (_useRealDevice) {
        return 'http://$_lanIp:3000';
      } else {
        return 'http://10.0.2.2:3000'; // Android 模拟器访问主机
      }
    } else {
      return 'http://localhost:3000';
    }
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
