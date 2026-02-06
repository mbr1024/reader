import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

class AppConfig {
  static const String appName = '小说阅读器';
  static const String appVersion = '1.0.0';

  // 服务器配置
  static const String _productionServer = 'http://115.191.16.227:3000'; // 火山引擎服务器
  static const String _lanIp = '10.125.247.242'; // 开发时电脑局域网IP
  static const bool _useRealDevice = true; // 开发时真机使用局域网IP

  // 是否在 Debug 模式下也使用生产服务器
  static const bool _useProductionInDebug = true;

  /// 获取 API 基础地址
  /// Release 模式使用生产服务器，Debug 模式可配置
  static String get baseUrl {
    // Release 模式直接使用生产服务器
    if (kReleaseMode) {
      return _productionServer;
    }

    // Debug 模式下也使用生产服务器
    if (_useProductionInDebug) {
      return _productionServer;
    }

    // Debug 模式根据平台选择开发地址（备用）
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      if (_useRealDevice) {
        return 'http://$_lanIp:3000';
      } else {
        return 'http://10.0.2.2:3000';
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
