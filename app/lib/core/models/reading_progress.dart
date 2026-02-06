import 'package:hive/hive.dart';

/// 阅读进度数据模型
class ReadingProgress {
  final String bookId;
  final String sourceId;
  final String chapterId;
  final String chapterTitle;
  final int chapterIndex;
  final double scrollPosition;
  final DateTime updatedAt;

  ReadingProgress({
    required this.bookId,
    required this.sourceId,
    required this.chapterId,
    required this.chapterTitle,
    required this.chapterIndex,
    this.scrollPosition = 0.0,
    required this.updatedAt,
  });
  
  ReadingProgress copyWith({
    String? chapterId,
    String? chapterTitle,
    int? chapterIndex,
    double? scrollPosition,
    DateTime? updatedAt,
  }) {
    return ReadingProgress(
      bookId: bookId,
      sourceId: sourceId,
      chapterId: chapterId ?? this.chapterId,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ReadingProgressAdapter extends TypeAdapter<ReadingProgress> {
  @override
  final int typeId = 1;

  @override
  ReadingProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingProgress(
      bookId: fields[0] as String,
      sourceId: fields[1] as String,
      chapterId: fields[2] as String,
      chapterTitle: fields[3] as String,
      chapterIndex: fields[4] as int,
      scrollPosition: fields[5] as double? ?? 0.0,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingProgress obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)..write(obj.bookId)
      ..writeByte(1)..write(obj.sourceId)
      ..writeByte(2)..write(obj.chapterId)
      ..writeByte(3)..write(obj.chapterTitle)
      ..writeByte(4)..write(obj.chapterIndex)
      ..writeByte(5)..write(obj.scrollPosition)
      ..writeByte(6)..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
