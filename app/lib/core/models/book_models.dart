class BookSource {
  final String id;
  final String name;
  final String type;

  BookSource({
    required this.id,
    required this.name,
    required this.type,
  });

  factory BookSource.fromJson(Map<String, dynamic> json) {
    return BookSource(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
    );
  }
}

class BookSearchResult {
  final String id;
  final String title;
  final String author;
  final String? cover;
  final String? description;
  final String? category;
  final String? status;
  final String source;

  BookSearchResult({
    required this.id,
    required this.title,
    required this.author,
    this.cover,
    this.description,
    this.category,
    this.status,
    required this.source,
  });

  factory BookSearchResult.fromJson(Map<String, dynamic> json) {
    return BookSearchResult(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      cover: json['cover'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      status: json['status'] as String?,
      source: json['source'] as String,
    );
  }
}

class BookDetail {
  final String id;
  final String title;
  final String author;
  final String? cover;
  final String? description;
  final String? category;
  final String? status;
  final int? chapterCount;
  final String source;

  BookDetail({
    required this.id,
    required this.title,
    required this.author,
    this.cover,
    this.description,
    this.category,
    this.status,
    this.chapterCount,
    required this.source,
  });

  factory BookDetail.fromJson(Map<String, dynamic> json) {
    return BookDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      cover: json['cover'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      status: json['status'] as String?,
      chapterCount: json['chapterCount'] as int?,
      source: json['source'] as String,
    );
  }
}

class ChapterInfo {
  final String id;
  final String title;
  final int index;
  final int? wordCount;

  ChapterInfo({
    required this.id,
    required this.title,
    required this.index,
    this.wordCount,
  });

  factory ChapterInfo.fromJson(Map<String, dynamic> json) {
    return ChapterInfo(
      id: json['id'] as String,
      title: json['title'] as String,
      index: json['index'] as int,
      wordCount: json['wordCount'] as int?,
    );
  }
}

class ChapterContent {
  final String title;
  final String content;

  ChapterContent({
    required this.title,
    required this.content,
  });

  factory ChapterContent.fromJson(Map<String, dynamic> json) {
    return ChapterContent(
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }
}

/// 推荐书籍（用于首页展示）
class RecommendBook {
  final String id;
  final String title;
  final String author;
  final String? cover;
  final String? category;
  final String? description;
  final int? chapterCount;
  final String? status;
  final String source;

  const RecommendBook({
    required this.id,
    required this.title,
    required this.author,
    this.cover,
    this.category,
    this.description,
    this.chapterCount,
    this.status,
    required this.source,
  });

  factory RecommendBook.fromJson(Map<String, dynamic> json) {
    return RecommendBook(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      cover: json['cover'] as String?,
      category: json['category'] as String?,
      description: json['description'] as String?,
      chapterCount: json['chapterCount'] as int?,
      status: json['status'] as String?,
      source: json['source'] as String,
    );
  }
}

/// 推荐数据（包含 banner、热门、新书、热搜等）
class RecommendationsData {
  final List<RecommendBook> banners;
  final List<RecommendBook> hotBooks;
  final List<RecommendBook> newBooks;
  final List<String> hotSearch;
  final List<RecommendBook> defaultBookshelf;

  const RecommendationsData({
    required this.banners,
    required this.hotBooks,
    required this.newBooks,
    required this.hotSearch,
    required this.defaultBookshelf,
  });

  factory RecommendationsData.fromJson(Map<String, dynamic> json) {
    return RecommendationsData(
      banners: (json['banners'] as List<dynamic>?)
          ?.where((e) => e != null)
          .map((e) => RecommendBook.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      hotBooks: (json['hotBooks'] as List<dynamic>?)
          ?.where((e) => e != null)
          .map((e) => RecommendBook.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      newBooks: (json['newBooks'] as List<dynamic>?)
          ?.where((e) => e != null)
          .map((e) => RecommendBook.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      hotSearch: (json['hotSearch'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      defaultBookshelf: (json['defaultBookshelf'] as List<dynamic>?)
          ?.where((e) => e != null)
          .map((e) => RecommendBook.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // 空数据
  static const empty = RecommendationsData(
    banners: [],
    hotBooks: [],
    newBooks: [],
    hotSearch: [],
    defaultBookshelf: [],
  );
}
