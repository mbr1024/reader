import 'package:hive/hive.dart';

part 'bookshelf_item.g.dart';

/// 书架项数据模型
@HiveType(typeId: 0)
class BookshelfItem {
  @HiveField(0)
  final String bookId;
  
  @HiveField(1)
  final String sourceId;
  
  @HiveField(2)
  final String title;
  
  @HiveField(3)
  final String author;
  
  @HiveField(4)
  final String? cover;
  
  @HiveField(5)
  final String? category;
  
  @HiveField(6)
  final String? lastChapterId;
  
  @HiveField(7)
  final String? lastChapterTitle;
  
  @HiveField(8)
  final DateTime addedAt;
  
  @HiveField(9)
  final DateTime? lastReadAt;
  
  @HiveField(10)
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
