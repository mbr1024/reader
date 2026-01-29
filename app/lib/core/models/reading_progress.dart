import 'package:hive/hive.dart';

part 'reading_progress.g.dart';

/// 阅读进度数据模型
@HiveType(typeId: 1)
class ReadingProgress {
  @HiveField(0)
  final String bookId;
  
  @HiveField(1)
  final String sourceId;
  
  @HiveField(2)
  final String chapterId;
  
  @HiveField(3)
  final String chapterTitle;
  
  @HiveField(4)
  final int chapterIndex;
  
  @HiveField(5)
  final double scrollPosition;
  
  @HiveField(6)
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
