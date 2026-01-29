import 'package:hive/hive.dart';

part 'reader_settings.g.dart';

/// 阅读设置数据模型
@HiveType(typeId: 2)
class ReaderSettings {
  @HiveField(0)
  final double fontSize;
  
  @HiveField(1)
  final double lineHeight;
  
  @HiveField(2)
  final int backgroundColorValue; // 存储颜色的 int 值
  
  @HiveField(3)
  final bool keepScreenOn;

  ReaderSettings({
    required this.fontSize,
    required this.lineHeight,
    required this.backgroundColorValue,
    this.keepScreenOn = false,
  });
  
  /// 默认设置
  factory ReaderSettings.defaults() {
    return ReaderSettings(
      fontSize: 18.0,
      lineHeight: 1.8,
      backgroundColorValue: 0xFFF5F0E1, // 护眼色
      keepScreenOn: false,
    );
  }
  
  ReaderSettings copyWith({
    double? fontSize,
    double? lineHeight,
    int? backgroundColorValue,
    bool? keepScreenOn,
  }) {
    return ReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      backgroundColorValue: backgroundColorValue ?? this.backgroundColorValue,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    );
  }
}
