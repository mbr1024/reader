import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:epubx/epubx.dart' as epub;
import '../models/book_models.dart';
import 'storage_service.dart';

/// 本地书籍服务
///
/// 核心设计：导入时预处理，读取时零延迟
/// - 导入：后台解析文件 → 所有章节写入 Hive
/// - 读取：直接从 Hive 取，和在线书籍完全一样快
/// - 不再运行时读原始文件，不再用 Isolate
class LocalBookService {
  static final LocalBookService _instance = LocalBookService._();
  static LocalBookService get instance => _instance;
  LocalBookService._();

  StorageService get _storage => StorageService.instance;

  // ============ 导入 ============

  /// 导入书籍，返回进度回调
  Future<ImportResult> importBook(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('文件不存在: $filePath');
    }

    final fileName = file.uri.pathSegments.last;
    final ext = fileName.split('.').last.toLowerCase();

    switch (ext) {
      case 'txt':
        return _importTxt(filePath, fileName);
      case 'epub':
        return _importEpub(filePath, fileName);
      default:
        throw Exception('不支持的文件格式: .$ext（支持 TXT、EPUB）');
    }
  }

  /// 导入 TXT：后台解析 → 写 Hive
  Future<ImportResult> _importTxt(String filePath, String fileName) async {
    final title = fileName.replaceAll(
        RegExp(r'\.txt$', caseSensitive: false), '');
    final bookId = _generateBookId(title);

    // 在 compute 中解析（纯同步，无 async）
    final parsed = await compute(_parseTxtFile, filePath);

    // 写入 Hive（主线程，Hive 写入很快）
    await _saveToHive(bookId, parsed.titles, parsed.contents);
    await _storage.saveLocalBookPath(bookId, filePath);

    return ImportResult(
      bookId: bookId,
      title: title,
      author: '',
      chapterCount: parsed.titles.length,
      format: 'txt',
    );
  }

  /// 导入 EPUB：后台解析 → 写 Hive
  /// 先尝试严格模式 readBook，失败则回退到宽松模式 openBook
  Future<ImportResult> _importEpub(String filePath, String fileName) async {
    final tempTitle = fileName.replaceAll(
        RegExp(r'\.epub$', caseSensitive: false), '');
    final bytes = await File(filePath).readAsBytes();
    final bookId = _generateBookId(tempTitle);

    _ParsedChapters parsed;
    String title = tempTitle;
    String author = '';

    try {
      // 严格模式：一次性读取全部内容
      final epubBook = await epub.EpubReader.readBook(bytes);
      title = epubBook.Title ?? tempTitle;
      author = epubBook.Author ?? '';
      parsed = _extractEpubChapters(epubBook);
    } catch (e) {
      // 宽松模式：EPUB 格式不规范时，逐章安全读取
      debugPrint('EPUB 严格解析失败，尝试宽松模式: $e');
      final bookRef = await epub.EpubReader.openBook(bytes);
      title = bookRef.Title ?? tempTitle;
      author = bookRef.Author ?? '';
      parsed = await _extractEpubChaptersLenient(bookRef);
    }

    await _saveToHive(bookId, parsed.titles, parsed.contents);
    await _storage.saveLocalBookPath(bookId, filePath);

    return ImportResult(
      bookId: bookId,
      title: title,
      author: author,
      chapterCount: parsed.titles.length,
      format: 'epub',
    );
  }

  /// 将章节数据写入 Hive
  Future<void> _saveToHive(
    String bookId,
    List<String> titles,
    List<String> contents,
  ) async {
    // 写章节索引（标题列表 JSON）
    await _storage.saveChapterIndex(bookId, jsonEncode(titles));

    // 逐章写内容
    for (int i = 0; i < contents.length; i++) {
      await _storage.saveChapterContent(bookId, i, contents[i]);
    }
  }

  // ============ 读取（直接从 Hive，零延迟） ============

  /// 检查 Hive 中是否有章节数据
  bool _hasHiveData(String bookId) {
    return _storage.getChapterIndex(bookId) != null;
  }

  /// 获取章节列表
  Future<List<ChapterInfo>> getChapterList(String bookId) async {
    final indexJson = _storage.getChapterIndex(bookId);
    if (indexJson == null) return [];

    final titles = (jsonDecode(indexJson) as List).cast<String>();
    return titles.asMap().entries.map((entry) {
      return ChapterInfo(
        id: entry.key.toString(),
        title: entry.value,
        index: entry.key,
      );
    }).toList();
  }

  /// 获取章节内容
  Future<ChapterContent> getChapterContent(String bookId, String chapterId) async {
    final chapterIdx = int.tryParse(chapterId) ?? 0;

    // 取标题
    final indexJson = _storage.getChapterIndex(bookId);
    final titles = indexJson != null
        ? (jsonDecode(indexJson) as List).cast<String>()
        : <String>[];
    final title = chapterIdx < titles.length ? titles[chapterIdx] : '未知章节';

    // 取内容（同步读 Hive，极快）
    final content = _storage.getChapterContent(bookId, chapterIdx);
    if (content == null) {
      return ChapterContent(title: title, content: '章节内容未找到，请尝试重新导入');
    }

    return ChapterContent(title: title, content: content);
  }

  /// 获取书籍详情
  Future<BookDetail> getBookDetail(String bookId) async {
    final indexJson = _storage.getChapterIndex(bookId);
    final chapterCount = indexJson != null
        ? (jsonDecode(indexJson) as List).length
        : 0;

    // 从书架获取标题/作者信息
    final bookshelfItem = _storage.getBookshelfItem(bookId);

    return BookDetail(
      id: bookId,
      title: bookshelfItem?.title ?? '未知书籍',
      author: bookshelfItem?.author ?? '',
      cover: null,
      description: '本地导入书籍',
      category: '本地',
      status: '',
      chapterCount: chapterCount,
      source: 'local',
    );
  }

  // ============ 缓存管理 ============

  /// 检查书籍是否已导入（Hive 中有数据）
  bool isImported(String bookId) {
    return _storage.getChapterIndex(bookId) != null;
  }

  /// 清除单本书的所有数据
  Future<void> clearBook(String bookId) async {
    await _storage.removeLocalBookData(bookId);
  }

  // 兼容旧接口
  void clearCache(String bookId) {
    // Hive 数据不需要手动清内存缓存
  }

  void clearAllCache() {
    // no-op
  }

  // ============ TXT 解析（compute 回调，纯同步） ============

  /// 每段最大字符数（普通文档自动分段用）
  static const int _maxCharsPerSegment = 5000;

  /// 在 isolate 中执行的 TXT 解析
  static _ParsedChapters _parseTxtFile(String filePath) {
    final regex = RegExp(
      r'^(第[一二三四五六七八九十百千万零\d]+[章节回卷部]\s*.+|序[章言]?\s*.*|楔子|引子|番外.*)$',
    );

    final bytes = File(filePath).readAsBytesSync();
    final content = utf8.decode(bytes, allowMalformed: true);
    final lines = content.split('\n');

    final titles = <String>[];
    final contents = <String>[];
    final buffer = StringBuffer();
    String currentTitle = '';
    int matchedChapters = 0;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty && regex.hasMatch(trimmed)) {
        // 保存上一章
        if (currentTitle.isNotEmpty || buffer.isNotEmpty) {
          titles.add(currentTitle.isEmpty ? '开头' : currentTitle);
          contents.add(buffer.toString().trim());
          buffer.clear();
        }
        currentTitle = trimmed;
        matchedChapters++;
      } else {
        buffer.writeln(line);
      }
    }

    // 最后一章
    if (currentTitle.isNotEmpty || buffer.isNotEmpty) {
      titles.add(currentTitle.isEmpty ? '正文' : currentTitle);
      contents.add(buffer.toString().trim());
    }

    // 清理空的开头
    if (titles.isNotEmpty && titles[0] == '开头' && contents[0].isEmpty) {
      titles.removeAt(0);
      contents.removeAt(0);
    }

    // 如果没匹配到章节标题，或只有1段且超过阈值 → 按字数自动分段
    // 适用于普通文档、日志、代码等非小说文件
    if (matchedChapters == 0 || (titles.length == 1 && contents[0].length > _maxCharsPerSegment * 2)) {
      return _splitBySize(content.trim());
    }

    // 对匹配到章节的情况，检查是否有单章过大的，也拆分
    final finalTitles = <String>[];
    final finalContents = <String>[];
    for (int i = 0; i < titles.length; i++) {
      if (contents[i].length > _maxCharsPerSegment * 3) {
        // 单章太大，拆分成子段
        final sub = _splitBySize(contents[i], baseTitle: titles[i]);
        finalTitles.addAll(sub.titles);
        finalContents.addAll(sub.contents);
      } else {
        finalTitles.add(titles[i]);
        finalContents.add(contents[i]);
      }
    }

    if (finalTitles.isEmpty) {
      return _splitBySize(content.trim());
    }

    return _ParsedChapters(titles: finalTitles, contents: finalContents);
  }

  /// 按字数自动分段（在段落边界处切分，不会切断段落）
  static _ParsedChapters _splitBySize(String text, {String baseTitle = ''}) {
    final titles = <String>[];
    final contents = <String>[];
    final paragraphs = text.split('\n');

    final buffer = StringBuffer();
    int charCount = 0;
    int segmentIndex = 1;

    for (final para in paragraphs) {
      buffer.writeln(para);
      charCount += para.length + 1;

      if (charCount >= _maxCharsPerSegment) {
        final prefix = baseTitle.isNotEmpty ? '$baseTitle · ' : '';
        titles.add('${prefix}第$segmentIndex段');
        contents.add(buffer.toString().trim());
        buffer.clear();
        charCount = 0;
        segmentIndex++;
      }
    }

    // 剩余内容
    if (buffer.isNotEmpty) {
      final remaining = buffer.toString().trim();
      if (remaining.isNotEmpty) {
        if (titles.isEmpty) {
          // 整个文件不到一段
          titles.add(baseTitle.isNotEmpty ? baseTitle : '正文');
          contents.add(remaining);
        } else {
          final prefix = baseTitle.isNotEmpty ? '$baseTitle · ' : '';
          titles.add('${prefix}第$segmentIndex段');
          contents.add(remaining);
        }
      }
    }

    if (titles.isEmpty) {
      titles.add(baseTitle.isNotEmpty ? baseTitle : '正文');
      contents.add(text);
    }

    return _ParsedChapters(titles: titles, contents: contents);
  }

  // ============ EPUB 解析 ============

  /// 从 EPUB 提取章节（同步方法）
  _ParsedChapters _extractEpubChapters(epub.EpubBook epubBook) {
    final titles = <String>[];
    final contents = <String>[];

    // 优先用 TOC
    final toc = epubBook.Chapters;
    if (toc != null && toc.isNotEmpty) {
      for (final chapter in toc) {
        final text = _stripHtml(chapter.HtmlContent ?? '');
        if (text.trim().isNotEmpty) {
          titles.add(chapter.Title ?? '未命名章节');
          contents.add(text.trim());
        }

        if (chapter.SubChapters != null) {
          for (final sub in chapter.SubChapters!) {
            final subText = _stripHtml(sub.HtmlContent ?? '');
            if (subText.trim().isNotEmpty) {
              titles.add(sub.Title ?? '未命名');
              contents.add(subText.trim());
            }
          }
        }
      }
    }

    // 无 TOC，从 HTML content 提取
    if (titles.isEmpty && epubBook.Content?.Html != null) {
      int idx = 0;
      for (final entry in epubBook.Content!.Html!.entries) {
        final text = _stripHtml(entry.value.Content ?? '');
        if (text.trim().isNotEmpty) {
          titles.add('第${idx + 1}章');
          contents.add(text.trim());
          idx++;
        }
      }
    }

    if (titles.isEmpty) {
      titles.add('正文');
      contents.add('无法解析 EPUB 内容');
    }

    return _ParsedChapters(titles: titles, contents: contents);
  }

  /// 宽松模式：从 EpubBookRef 逐章安全读取，跳过有问题的文件
  Future<_ParsedChapters> _extractEpubChaptersLenient(epub.EpubBookRef bookRef) async {
    final titles = <String>[];
    final contents = <String>[];

    // 尝试从 TOC 读取
    try {
      final chapterRefs = await bookRef.getChapters();
      for (final chRef in chapterRefs) {
        try {
          final html = await chRef.epubTextContentFileRef?.ReadContentAsync() ?? '';
          final text = _stripHtml(html);
          if (text.trim().isNotEmpty) {
            titles.add(chRef.Title ?? '未命名章节');
            contents.add(text.trim());
          }
        } catch (_) {
          // 跳过无法读取的章节
        }

        // 子章节
        if (chRef.SubChapters != null) {
          for (final sub in chRef.SubChapters!) {
            try {
              final html = await sub.epubTextContentFileRef?.ReadContentAsync() ?? '';
              final text = _stripHtml(html);
              if (text.trim().isNotEmpty) {
                titles.add(sub.Title ?? '未命名');
                contents.add(text.trim());
              }
            } catch (_) {
              // 跳过
            }
          }
        }
      }
    } catch (_) {
      // TOC 也读不了
    }

    // 如果 TOC 没读到内容，尝试从 HTML content 逐个读
    if (titles.isEmpty) {
      try {
        final contentRef = bookRef.Content;
        if (contentRef?.Html != null) {
          int idx = 0;
          for (final entry in contentRef!.Html!.entries) {
            try {
              final html = await entry.value.ReadContentAsync();
              final text = _stripHtml(html);
              if (text.trim().isNotEmpty) {
                titles.add('第${idx + 1}章');
                contents.add(text.trim());
                idx++;
              }
            } catch (_) {
              // 跳过
            }
          }
        }
      } catch (_) {
        // 完全无法读取
      }
    }

    if (titles.isEmpty) {
      titles.add('正文');
      contents.add('EPUB 文件格式异常，无法解析内容');
    }

    return _ParsedChapters(titles: titles, contents: contents);
  }

  /// 去除 HTML 标签
  static String _stripHtml(String html) {
    var text = html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'</(p|div|h[1-6]|li|tr)>'), '\n')
        .replaceAll(RegExp(r'<(p|div|h[1-6]|li|tr)[^>]*>'), '')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&mdash;', '—')
        .replaceAll('&hellip;', '…');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return text.trim();
  }

  // ============ 工具 ============

  String _generateBookId(String title) {
    return 'local_${title.hashCode.abs()}';
  }
}

// ============ 数据类型 ============

/// 导入结果
class ImportResult {
  final String bookId;
  final String title;
  final String author;
  final int chapterCount;
  final String format;

  ImportResult({
    required this.bookId,
    required this.title,
    required this.author,
    required this.chapterCount,
    required this.format,
  });
}

/// 解析后的章节数据（用于 compute 返回）
class _ParsedChapters {
  final List<String> titles;
  final List<String> contents;

  _ParsedChapters({required this.titles, required this.contents});
}
