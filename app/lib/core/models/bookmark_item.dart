import 'package:hive/hive.dart';

/// 书签数据模型
class BookmarkItem {
  final String id;
  final String bookId;
  final String sourceId;
  final String bookTitle;
  final int chapterIndex;
  final String chapterTitle;
  final int position; // 章节内的位置（字符偏移）
  final String content; // 书签处的文字片段
  final String? note; // 用户备注
  final DateTime createdAt;

  BookmarkItem({
    required this.id,
    required this.bookId,
    required this.sourceId,
    required this.bookTitle,
    required this.chapterIndex,
    required this.chapterTitle,
    required this.position,
    required this.content,
    this.note,
    required this.createdAt,
  });

  BookmarkItem copyWith({
    String? note,
  }) {
    return BookmarkItem(
      id: id,
      bookId: bookId,
      sourceId: sourceId,
      bookTitle: bookTitle,
      chapterIndex: chapterIndex,
      chapterTitle: chapterTitle,
      position: position,
      content: content,
      note: note ?? this.note,
      createdAt: createdAt,
    );
  }
}

class BookmarkItemAdapter extends TypeAdapter<BookmarkItem> {
  @override
  final int typeId = 3; // 新的 typeId，避免与现有 adapter 冲突

  @override
  BookmarkItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookmarkItem(
      id: fields[0] as String,
      bookId: fields[1] as String,
      sourceId: fields[2] as String,
      bookTitle: fields[3] as String,
      chapterIndex: fields[4] as int,
      chapterTitle: fields[5] as String,
      position: fields[6] as int,
      content: fields[7] as String,
      note: fields[8] as String?,
      createdAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BookmarkItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.bookId)
      ..writeByte(2)..write(obj.sourceId)
      ..writeByte(3)..write(obj.bookTitle)
      ..writeByte(4)..write(obj.chapterIndex)
      ..writeByte(5)..write(obj.chapterTitle)
      ..writeByte(6)..write(obj.position)
      ..writeByte(7)..write(obj.content)
      ..writeByte(8)..write(obj.note)
      ..writeByte(9)..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
