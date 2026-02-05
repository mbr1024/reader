import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static const String appName = '小说阅读器';
  static const String appVersion = '1.0.0';

  // API 配置 - 根据平台自动选择正确的地址
  // 真机调试时请确保手机和电脑在同一局域网，并修改为电脑的局域网IP
  static const String _lanIp = '10.125.247.242'; // 电脑局域网IP
  static const bool _useRealDevice = true; // 设为 true 时真机使用局域网IP

  static String get baseUrl {
    if (kIsWeb) {
      // Web 环境使用 localhost
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      if (_useRealDevice) {
        // Android 真机使用电脑的局域网 IP
        return 'http://$_lanIp:3000';
      } else {
        // Android 模拟器使用 10.0.2.2 访问主机
        return 'http://10.0.2.2:3000';
      }
    } else {
      // iOS/桌面平台使用 localhost
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
