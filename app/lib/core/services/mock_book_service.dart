import 'package:flutter/services.dart' show rootBundle;
import '../models/book_models.dart';

/// 本地 Mock 书籍服务
/// 解析 assets/books/三体.txt 文件，提供离线调试功能
class MockBookService {
  static const String _assetPath = 'assets/books/三体.txt';
  static const String _bookId = 'santi';
  static const String _sourceId = 'local';

  String? _cachedContent;
  List<_ChapterMeta>? _cachedChapters;

  /// 获取书籍详情
  BookDetail getBookDetail() {
    return BookDetail(
      id: _bookId,
      title: '三体',
      author: '刘慈欣',
      cover: 'assets/images/covers/image.png',
      description: '文化大革命如火如荼进行的同时，军方探寻外星文明的绝秘计划"红岸工程"取得了突破性进展。',
      category: '科幻',
      status: '完结',
      chapterCount: null, // 动态计算
      source: _sourceId,
    );
  }

  /// 加载并缓存文件内容
  Future<String> _loadContent() async {
    if (_cachedContent != null) {
      return _cachedContent!;
    }
    _cachedContent = await rootBundle.loadString(_assetPath);
    return _cachedContent!;
  }

  /// 解析章节元数据
  Future<List<_ChapterMeta>> _parseChapters() async {
    if (_cachedChapters != null) {
      return _cachedChapters!;
    }

    final content = await _loadContent();
    final lines = content.split('\n');
    final chapters = <_ChapterMeta>[];

    // 匹配章节标题的正则表达式
    // 支持 "第X章" 格式，可选前缀如 "第一部  第X章"
    final chapterRegex = RegExp(r'^(第[一二三四五六七八九十]+部\s+)?(第[0-9一二三四五六七八九十百千万]+章\s*.+|序)');

    int chapterIndex = 0;
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (chapterRegex.hasMatch(line)) {
        // 如果有上一章，设置其结束行
        if (chapters.isNotEmpty) {
          chapters.last.endLine = i - 1;
        }
        chapters.add(_ChapterMeta(
          id: chapterIndex.toString(),
          title: line,
          index: chapterIndex,
          startLine: i,
          endLine: lines.length - 1, // 临时设置，后续会更新
        ));
        chapterIndex++;
      }
    }

    _cachedChapters = chapters;
    return chapters;
  }

  /// 获取章节列表
  Future<List<ChapterInfo>> getChapterList() async {
    final chapters = await _parseChapters();
    return chapters.map((meta) {
      return ChapterInfo(
        id: meta.id,
        title: meta.title,
        index: meta.index,
        wordCount: null,
      );
    }).toList();
  }

  /// 获取章节内容
  Future<ChapterContent> getChapterContent(String chapterId) async {
    final content = await _loadContent();
    final lines = content.split('\n');
    final chapters = await _parseChapters();

    final index = int.tryParse(chapterId) ?? 0;
    if (index < 0 || index >= chapters.length) {
      return ChapterContent(
        title: '章节不存在',
        content: '无法找到章节内容',
      );
    }

    final chapter = chapters[index];
    final chapterLines = lines.sublist(chapter.startLine, chapter.endLine + 1);
    
    // 移除第一行（章节标题）以避免重复显示
    final contentLines = chapterLines.length > 1 
        ? chapterLines.sublist(1) 
        : chapterLines;

    return ChapterContent(
      title: chapter.title,
      content: contentLines.join('\n').trim(),
    );
  }

  /// 获取书籍 ID
  String get bookId => _bookId;

  /// 获取书源 ID
  String get sourceId => _sourceId;
}

/// 章节元数据（内部使用）
class _ChapterMeta {
  final String id;
  final String title;
  final int index;
  final int startLine;
  int endLine;

  _ChapterMeta({
    required this.id,
    required this.title,
    required this.index,
    required this.startLine,
    required this.endLine,
  });
}
