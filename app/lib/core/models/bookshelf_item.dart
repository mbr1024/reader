import 'package:hive/hive.dart';

/// 书架项数据模型
class BookshelfItem {
  final String bookId;
  final String sourceId;
  final String title;
  final String author;
  final String? cover;
  final String? category;
  final String? lastChapterId;
  final String? lastChapterTitle;
  final DateTime addedAt;
  final DateTime? lastReadAt;
  final bool isTop;

  BookshelfItem({
    required this.bookId,
    required this.sourceId,
    required this.title,
    required this.author,
    this.cover,
    this.category,
    this.lastChapterId,
    this.lastChapterTitle,
    required this.addedAt,
    this.lastReadAt,
    this.isTop = false,
  });
  
  BookshelfItem copyWith({
    String? cover,
    String? lastChapterId,
    String? lastChapterTitle,
    DateTime? lastReadAt,
    bool? isTop,
  }) {
    return BookshelfItem(
      bookId: bookId,
      sourceId: sourceId,
      title: title,
      author: author,
      cover: cover ?? this.cover,
      category: category,
      lastChapterId: lastChapterId ?? this.lastChapterId,
      lastChapterTitle: lastChapterTitle ?? this.lastChapterTitle,
      addedAt: addedAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      isTop: isTop ?? this.isTop,
    );
  }
}

class BookshelfItemAdapter extends TypeAdapter<BookshelfItem> {
  @override
  final int typeId = 0;

  @override
  BookshelfItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookshelfItem(
      bookId: fields[0] as String,
      sourceId: fields[1] as String,
      title: fields[2] as String,
      author: fields[3] as String,
      cover: fields[4] as String?,
      category: fields[5] as String?,
      lastChapterId: fields[6] as String?,
      lastChapterTitle: fields[7] as String?,
      addedAt: fields[8] as DateTime,
      lastReadAt: fields[9] as DateTime?,
      isTop: fields[10] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, BookshelfItem obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)..write(obj.bookId)
      ..writeByte(1)..write(obj.sourceId)
      ..writeByte(2)..write(obj.title)
      ..writeByte(3)..write(obj.author)
      ..writeByte(4)..write(obj.cover)
      ..writeByte(5)..write(obj.category)
      ..writeByte(6)..write(obj.lastChapterId)
      ..writeByte(7)..write(obj.lastChapterTitle)
      ..writeByte(8)..write(obj.addedAt)
      ..writeByte(9)..write(obj.lastReadAt)
      ..writeByte(10)..write(obj.isTop);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookshelfItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
