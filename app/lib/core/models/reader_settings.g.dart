// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      fontSize: fields[0] as double,
      lineHeight: fields[1] as double,
      backgroundColorValue: fields[2] as int,
      keepScreenOn: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ReaderSettings obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.fontSize)
      ..writeByte(1)
      ..write(obj.lineHeight)
      ..writeByte(2)
      ..write(obj.backgroundColorValue)
      ..writeByte(3)
      ..write(obj.keepScreenOn);
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
