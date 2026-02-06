import 'package:hive/hive.dart';

/// 阅读设置数据模型
class ReaderSettings {
  final double fontSize;
  final double lineHeight;
  final int backgroundColorValue;
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
      lineHeight: 2.0,
      backgroundColorValue: 0xFFF5F0E1,
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

class ReaderSettingsAdapter extends TypeAdapter<ReaderSettings> {
  @override
  final int typeId = 2;

  @override
  ReaderSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReaderSettings(
      fontSize: fields[0] as double? ?? 18.0,
      lineHeight: fields[1] as double? ?? 2.0,
      backgroundColorValue: fields[2] as int? ?? 0xFFF5F0E1,
      keepScreenOn: fields[3] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, ReaderSettings obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)..write(obj.fontSize)
      ..writeByte(1)..write(obj.lineHeight)
      ..writeByte(2)..write(obj.backgroundColorValue)
      ..writeByte(3)..write(obj.keepScreenOn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReaderSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
