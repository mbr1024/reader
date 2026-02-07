import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
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

  /// 导入 EPUB：使用 Isolate.run 在后台线程解析，避免阻塞 UI
  Future<ImportResult> _importEpub(String filePath, String fileName) async {
    final tempTitle = fileName.replaceAll(
        RegExp(r'\.epub$', caseSensitive: false), '');
    final bytes = await File(filePath).readAsBytes();
    final bookId = _generateBookId(tempTitle);

    // 在独立 Isolate 中解析 EPUB（支持异步操作）
    final result = await Isolate.run(() async {
      return await _parseEpubInIsolate(bytes, tempTitle);
    });

    await _saveToHive(bookId, result.titles, result.contents);
    await _storage.saveLocalBookPath(bookId, filePath);

    return ImportResult(
      bookId: bookId,
      title: result.bookTitle,
      author: result.bookAuthor,
      chapterCount: result.titles.length,
      format: 'epub',
    );
  }

  /// 在 Isolate 中解析 EPUB（静态异步方法）
  static Future<_EpubIsolateResult> _parseEpubInIsolate(List<int> bytes, String tempTitle) async {
    try {
      // 严格模式：一次性读取全部内容
      final epubBook = await epub.EpubReader.readBook(bytes);
      final title = epubBook.Title ?? tempTitle;
      final author = epubBook.Author ?? '';
      final parsed = _extractEpubChaptersStatic(epubBook);
      return _EpubIsolateResult(
        bookTitle: title,
        bookAuthor: author,
        titles: parsed.titles,
        contents: parsed.contents,
      );
    } catch (e) {
      // 宽松模式
      try {
        final bookRef = await epub.EpubReader.openBook(bytes);
        final title = bookRef.Title ?? tempTitle;
        final author = bookRef.Author ?? '';
        final parsed = await _extractEpubChaptersLenientStatic(bookRef);
        return _EpubIsolateResult(
          bookTitle: title,
          bookAuthor: author,
          titles: parsed.titles,
          contents: parsed.contents,
        );
      } catch (_) {
        return _EpubIsolateResult(
          bookTitle: tempTitle,
          bookAuthor: '',
          titles: ['正文'],
          contents: ['EPUB 解析失败'],
        );
      }
    }
  }

  /// 静态版本的 EPUB 章节提取（用于 Isolate）
  static _ParsedChapters _extractEpubChaptersStatic(epub.EpubBook epubBook) {
    final titles = <String>[];
    final contents = <String>[];
    final processedFiles = <String>{};

    // 优先用 TOC
    final toc = epubBook.Chapters;
    if (toc != null && toc.isNotEmpty) {
      _extractChaptersRecursiveStatic(toc, titles, contents, processedFiles);
    }

    // 无 TOC 或 TOC 为空，从 HTML content 提取
    if (titles.isEmpty && epubBook.Content?.Html != null) {
      int idx = 0;
      for (final entry in epubBook.Content!.Html!.entries) {
        final fileName = entry.key;
        if (processedFiles.contains(fileName)) continue;

        final text = _stripHtml(entry.value.Content ?? '');
        if (text.trim().isNotEmpty) {
          final extractedTitle = _extractTitleFromContentStatic(text);
          final chapterTitle = extractedTitle ?? '第${idx + 1}章';
          titles.add(chapterTitle);
          contents.add(_removeLeadingTitle(text.trim(), chapterTitle));
          processedFiles.add(fileName);
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

  /// 静态版本的递归提取章节
  static void _extractChaptersRecursiveStatic(
    List<epub.EpubChapter> chapters,
    List<String> titles,
    List<String> contents,
    Set<String> processedFiles,
  ) {
    for (final chapter in chapters) {
      final fileName = chapter.ContentFileName ?? '';
      if (fileName.isNotEmpty && processedFiles.contains(fileName)) {
        if (chapter.SubChapters != null && chapter.SubChapters!.isNotEmpty) {
          _extractChaptersRecursiveStatic(chapter.SubChapters!, titles, contents, processedFiles);
        }
        continue;
      }

      final text = _stripHtml(chapter.HtmlContent ?? '');
      if (text.trim().isNotEmpty) {
        final chapterTitle = chapter.Title ?? '未命名章节';
        titles.add(chapterTitle);
        contents.add(_removeLeadingTitle(text.trim(), chapterTitle));
        if (fileName.isNotEmpty) {
          processedFiles.add(fileName);
        }
      }

      if (chapter.SubChapters != null && chapter.SubChapters!.isNotEmpty) {
        _extractChaptersRecursiveStatic(chapter.SubChapters!, titles, contents, processedFiles);
      }
    }
  }

  /// 静态版本的宽松模式章节提取
  static Future<_ParsedChapters> _extractEpubChaptersLenientStatic(epub.EpubBookRef bookRef) async {
    final titles = <String>[];
    final contents = <String>[];
    final processedFiles = <String>{};

    try {
      final chapterRefs = await bookRef.getChapters();
      await _extractChaptersLenientRecursiveStatic(chapterRefs, titles, contents, processedFiles);
    } catch (_) {}

    if (titles.isEmpty) {
      try {
        final contentRef = bookRef.Content;
        if (contentRef?.Html != null) {
          int idx = 0;
          for (final entry in contentRef!.Html!.entries) {
            if (processedFiles.contains(entry.key)) continue;
            try {
              final html = await entry.value.ReadContentAsync();
              final text = _stripHtml(html);
              if (text.trim().isNotEmpty) {
                final extractedTitle = _extractTitleFromContentStatic(text);
                final chapterTitle = extractedTitle ?? '第${idx + 1}章';
                titles.add(chapterTitle);
                contents.add(_removeLeadingTitle(text.trim(), chapterTitle));
                processedFiles.add(entry.key);
                idx++;
              }
            } catch (_) {}
          }
        }
      } catch (_) {}
    }

    if (titles.isEmpty) {
      titles.add('正文');
      contents.add('无法解析 EPUB 内容');
    }

    return _ParsedChapters(titles: titles, contents: contents);
  }

  /// 静态版本的递归读取章节（宽松模式）
  static Future<void> _extractChaptersLenientRecursiveStatic(
    List<epub.EpubChapterRef> chapterRefs,
    List<String> titles,
    List<String> contents,
    Set<String> processedFiles,
  ) async {
    for (final chRef in chapterRefs) {
      final fileName = chRef.ContentFileName ?? '';
      if (fileName.isNotEmpty && processedFiles.contains(fileName)) {
        if (chRef.SubChapters != null && chRef.SubChapters!.isNotEmpty) {
          await _extractChaptersLenientRecursiveStatic(chRef.SubChapters!, titles, contents, processedFiles);
        }
        continue;
      }

      try {
        final html = await chRef.epubTextContentFileRef?.ReadContentAsync() ?? '';
        final text = _stripHtml(html);
        if (text.trim().isNotEmpty) {
          final chapterTitle = chRef.Title ?? '未命名章节';
          titles.add(chapterTitle);
          contents.add(_removeLeadingTitle(text.trim(), chapterTitle));
          if (fileName.isNotEmpty) {
            processedFiles.add(fileName);
          }
        }
      } catch (_) {}

      if (chRef.SubChapters != null && chRef.SubChapters!.isNotEmpty) {
        await _extractChaptersLenientRecursiveStatic(chRef.SubChapters!, titles, contents, processedFiles);
      }
    }
  }

  /// 静态版本的标题提取
  static String? _extractTitleFromContentStatic(String content) {
    final lines = content.split('\n');
    for (final line in lines.take(5)) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty && trimmed.length <= 50 && !trimmed.startsWith('　')) {
        if (RegExp(r'^(第[零一二三四五六七八九十百千万\d]+[章节回卷]|Chapter|Section|Part|\d+[.、])', caseSensitive: false)
            .hasMatch(trimmed)) {
          return trimmed;
        }
      }
    }
    return null;
  }

  /// 将章节数据写入 Hive
  Future<void> _saveToHive(
    String bookId,
    List<String> titles,
    List<String> contents,
  ) async {
    // 写章节索引（标题列表 JSON）
    await _storage.saveChapterIndex(bookId, jsonEncode(titles));

    // 批量写入章节内容（减少 I/O 次数，避免阻塞）
    await _storage.saveChapterContents(bookId, contents);
  }

  // ============ 读取（直接从 Hive，零延迟） ============

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
    final bookshelfItem = _storage.getBookshelfItem(bookId, sourceId: 'local');

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

  /// 章节最大长度（超过则拆分）
  static const int _maxChapterLength = 15000;

  /// TXT 目录规则列表（参考 Legado）
  /// 按优先级排序，优先使用匹配数最多的规则
  static final List<_TxtTocRule> _txtTocRules = [
    // 规则1: 标准章节格式（第X章/节/卷/集/部/篇/回）- 最常见
    _TxtTocRule(
      name: '标准章节',
      pattern: r'^[ 　\t]{0,4}(?:序章|楔子|正文(?!完|结)|终章|后记|尾声|番外|第\s{0,4}[\d〇零一二两三四五六七八九十百千万壹贰叁肆伍陆柒捌玖拾佰仟]+?\s{0,4}(?:章|节(?!课)|卷|集(?![合和])|部(?![分赛游])|篇(?!张)|回(?![合来事去]))).{0,30}$',
      priority: 100,
    ),
    // 规则2: Chapter/Section/Part 英文格式
    _TxtTocRule(
      name: '英文章节',
      pattern: r'^[ 　\t]{0,4}(?:[Cc]hapter|[Ss]ection|[Pp]art|ＰＡＲＴ|[Ee]pisode|[Nn][Oo]\.?)\s{0,4}\d{1,4}.{0,30}$',
      priority: 90,
    ),
    // 规则3: 数字+分隔符+标题（1、标题 / 1.标题 / 1:标题）
    _TxtTocRule(
      name: '数字分隔符',
      pattern: r'^[ 　\t]{0,4}\d{1,5}[:：,.，、_—\-]\s*.{1,30}$',
      priority: 80,
    ),
    // 规则4: 中文数字+分隔符+标题（一、标题 / 二十四章 标题）
    _TxtTocRule(
      name: '中文数字分隔符',
      pattern: r'^[ 　\t]{0,4}(?:序章|楔子|正文(?!完|结)|终章|后记|尾声|番外|[零一二两三四五六七八九十百千万壹贰叁肆伍陆柒捌玖拾佰仟]{1,8}章?)[ 、_—\-].{1,30}$',
      priority: 75,
    ),
    // 规则5: 卷/章+序号+标题（卷一 xxx / 章三十 xxx）
    _TxtTocRule(
      name: '卷章序号',
      pattern: r'^[ \t　]{0,4}(?:[卷章][\d零一二两三四五六七八九十百千万壹贰叁肆伍陆柒捌玖拾佰仟]{1,8})[ 　]{0,4}.{0,30}$',
      priority: 70,
    ),
    // 规则6: 特殊符号格式（晋江风格 ☆、标题 / ★标题）
    _TxtTocRule(
      name: '晋江风格',
      pattern: r'^[ 　\t]{0,4}[☆★✦✧⭐].{1,30}$',
      priority: 65,
    ),
    // 规则7: 方括号格式（【第一章】/ 【序】）
    _TxtTocRule(
      name: '方括号格式',
      pattern: r'^[ 　\t]{0,4}【(?:第[\d零一二两三四五六七八九十百千万]+[章节回卷]|序章?|楔子|番外|后记|终章).{0,20}】.{0,20}$',
      priority: 60,
    ),
    // 规则8: 正文+标题/序号
    _TxtTocRule(
      name: '正文标题',
      pattern: r'^[ 　\t]{0,4}正文[ 　]{1,4}.{0,20}$',
      priority: 55,
    ),
    // 规则9: 书名+括号序号（标题(1) / 标题（12））
    _TxtTocRule(
      name: '书名括号序号',
      pattern: r'^[一-龥]{1,20}[ 　\t]{0,4}[(（][\d〇零一二两三四五六七八九十百千万壹贰叁肆伍陆柒捌玖拾佰仟]{1,8}[)）][ 　\t]{0,4}$',
      priority: 50,
    ),
    // 规则10: 分节阅读格式
    _TxtTocRule(
      name: '分节阅读',
      pattern: r'^[ 　\t]{0,4}(?:.{0,15}分[页节章段]阅读[-_ ]?|第\s{0,4}[\d零一二两三四五六七八九十百千万]{1,6}\s{0,4}[页节]).{0,30}$',
      priority: 45,
    ),
  ];

  /// 检测文件编码
  static String _detectAndDecode(List<int> bytes) {
    // 检查 UTF-8 BOM
    if (bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
      return utf8.decode(bytes.sublist(3), allowMalformed: true);
    }

    // 检查 UTF-16 LE BOM
    if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
      return _decodeUtf16Le(bytes.sublist(2));
    }

    // 检查 UTF-16 BE BOM
    if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
      return _decodeUtf16Be(bytes.sublist(2));
    }

    // 尝试 UTF-8 解码
    try {
      final decoded = utf8.decode(bytes);
      // 检查是否有明显的乱码特征
      if (!_hasGarbageCharacters(decoded)) {
        return decoded;
      }
    } catch (_) {}

    // 尝试 GBK/GB2312 解码
    try {
      final decoded = _decodeGbk(bytes);
      if (decoded.isNotEmpty && !_hasGarbageCharacters(decoded)) {
        return decoded;
      }
    } catch (_) {}

    // 最后回退到 UTF-8 允许错误
    return utf8.decode(bytes, allowMalformed: true);
  }

  /// 检查是否有乱码特征
  static bool _hasGarbageCharacters(String text) {
    // 检查前 1000 个字符中是否有大量替换字符或控制字符
    final sample = text.length > 1000 ? text.substring(0, 1000) : text;
    int badChars = 0;
    for (final char in sample.codeUnits) {
      // 替换字符、非法 Unicode 区域
      if (char == 0xFFFD || (char >= 0x80 && char < 0xA0)) {
        badChars++;
      }
    }
    return badChars > sample.length * 0.1; // 超过 10% 就认为是乱码
  }

  /// GBK 解码（简化实现，覆盖常见中文字符）
  static String _decodeGbk(List<int> bytes) {
    final buffer = StringBuffer();
    int i = 0;
    while (i < bytes.length) {
      final b1 = bytes[i];
      if (b1 < 0x80) {
        // ASCII
        buffer.writeCharCode(b1);
        i++;
      } else if (i + 1 < bytes.length) {
        // 双字节 GBK - 简化处理：使用 Latin1 解码然后尝试转换
        final b2 = bytes[i + 1];
        try {
          buffer.write(latin1.decode([b1, b2]));
        } catch (_) {
          buffer.writeCharCode(0xFFFD); // 替换字符
        }
        i += 2;
      } else {
        buffer.writeCharCode(0xFFFD);
        i++;
      }
    }
    return buffer.toString();
  }

  /// UTF-16 LE 解码
  static String _decodeUtf16Le(List<int> bytes) {
    final buffer = StringBuffer();
    for (int i = 0; i + 1 < bytes.length; i += 2) {
      buffer.writeCharCode(bytes[i] | (bytes[i + 1] << 8));
    }
    return buffer.toString();
  }

  /// UTF-16 BE 解码
  static String _decodeUtf16Be(List<int> bytes) {
    final buffer = StringBuffer();
    for (int i = 0; i + 1 < bytes.length; i += 2) {
      buffer.writeCharCode((bytes[i] << 8) | bytes[i + 1]);
    }
    return buffer.toString();
  }

  /// 选择最佳的目录规则
  static RegExp? _selectBestTocRule(String sampleContent) {
    int maxMatches = 0;
    _TxtTocRule? bestRule;

    for (final rule in _txtTocRules) {
      try {
        final regex = RegExp(rule.pattern, multiLine: true);
        final matches = regex.allMatches(sampleContent);
        int validMatches = 0;
        int lastEnd = 0;

        // 检查匹配间隔是否合理（避免误匹配）
        for (final match in matches) {
          // 间隔太小（小于 100 字符）可能是误匹配
          if (match.start - lastEnd >= 100 || lastEnd == 0) {
            validMatches++;
          }
          lastEnd = match.end;
        }

        // 选择有效匹配数最多的规则
        if (validMatches > maxMatches) {
          maxMatches = validMatches;
          bestRule = rule;
        }
      } catch (_) {
        // 正则表达式错误，跳过
      }
    }

    // 至少需要 2 个有效匹配才认为规则有效
    if (maxMatches >= 2 && bestRule != null) {
      return RegExp(bestRule.pattern, multiLine: true);
    }

    return null;
  }

  /// 在 isolate 中执行的 TXT 解析
  static _ParsedChapters _parseTxtFile(String filePath) {
    final bytes = File(filePath).readAsBytesSync();
    final content = _detectAndDecode(bytes);
    final lines = content.split('\n');

    // 使用前 512KB 内容选择最佳规则
    final sampleLength = content.length > 512000 ? 512000 : content.length;
    final sampleContent = content.substring(0, sampleLength);
    final regex = _selectBestTocRule(sampleContent);

    // 如果没有找到合适的规则，使用按大小分段
    if (regex == null) {
      return _splitBySize(content.trim());
    }

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

    // 如果匹配到的章节太少，可能是误匹配，使用按大小分段
    if (matchedChapters < 2 || (titles.length == 1 && contents[0].length > _maxCharsPerSegment * 2)) {
      return _splitBySize(content.trim());
    }

    // 对匹配到章节的情况，检查是否有单章过大的，也拆分
    final finalTitles = <String>[];
    final finalContents = <String>[];
    for (int i = 0; i < titles.length; i++) {
      if (contents[i].length > _maxChapterLength) {
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
        titles.add('$prefix第$segmentIndex段');
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
          titles.add('$prefix第$segmentIndex段');
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

  /// 移除内容开头与标题重复的部分
  /// 处理标题在内容中出现多次的情况（EPUB 常见问题）
  static String _removeLeadingTitle(String content, String title) {
    if (title.isEmpty || content.isEmpty) return content;
    
    // 规范化标题（去除首尾空白、统一空格）
    final normalizedTitle = _normalizeForComparison(title);
    if (normalizedTitle.isEmpty) return content;
    
    // 按行分割
    final lines = content.split('\n');
    int removeCount = 0;
    bool foundTitleLine = false;
    
    // 检查开头几行是否与标题相同或相似
    for (int i = 0; i < lines.length && i < 10; i++) {
      final line = lines[i].trim();
      final normalizedLine = _normalizeForComparison(line);
      
      // 空行：如果之前已找到标题行，继续跳过；否则也跳过
      if (normalizedLine.isEmpty) {
        if (foundTitleLine) {
          removeCount = i + 1;
        }
        continue;
      }
      
      // 检查是否为标题行
      if (_isMatchingTitle(normalizedLine, normalizedTitle)) {
        removeCount = i + 1;
        foundTitleLine = true;
        continue;
      }
      
      // 遇到非标题内容，停止检查
      break;
    }
    
    // 移除匹配的行
    if (removeCount > 0) {
      return lines.skip(removeCount).join('\n').trim();
    }
    
    return content;
  }

  /// 规范化字符串用于比较
  static String _normalizeForComparison(String text) {
    return text
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[　\u3000]'), ' ')  // 全角空格
        .replaceAll(RegExp(r'[【】「」『』《》〈〉（）()\[\]]'), '')  // 去除各种括号
        .toLowerCase();
  }

  /// 检查两行是否为匹配的标题
  static bool _isMatchingTitle(String lineNormalized, String titleNormalized) {
    // 完全相同
    if (lineNormalized == titleNormalized) return true;
    
    // 一个包含另一个
    if (lineNormalized.contains(titleNormalized) || 
        titleNormalized.contains(lineNormalized)) {
      return true;
    }
    
    // 去除章节前缀后比较
    final chapterPattern = RegExp(
      r'^(第[零一二三四五六七八九十百千万\d]+[章节回卷篇部集]|\d+[.、:：\s]|chapter\s*\d+|section\s*\d+|part\s*\d+)\s*',
      caseSensitive: false,
    );
    
    final coreA = lineNormalized.replaceFirst(chapterPattern, '').trim();
    final coreB = titleNormalized.replaceFirst(chapterPattern, '').trim();
    
    // 核心内容相同
    if (coreA.isNotEmpty && coreB.isNotEmpty && coreA == coreB) {
      return true;
    }
    
    // 检查是否只是章节编号（如 "第一章" 单独一行）
    if (lineNormalized.length < 15 && 
        RegExp(r'^(第[零一二三四五六七八九十百千万\d]+[章节回卷篇部集]|chapter\s*\d+|section\s*\d+|part\s*\d+)$', caseSensitive: false)
            .hasMatch(lineNormalized)) {
      // 标题也以相同章节编号开头
      if (titleNormalized.startsWith(lineNormalized) || 
          titleNormalized.contains(lineNormalized)) {
        return true;
      }
    }
    
    return false;
  }

  /// 去除 HTML 标签，完善的 HTML 实体解码
  /// 支持图片占位符显示
  static String _stripHtml(String html) {
    var text = html;

    // 处理图片标签 - 提取 alt 文本作为占位符
    text = text.replaceAllMapped(
      RegExp(r'<img[^>]*alt\s*=\s*"([^"]*)"[^>]*>', caseSensitive: false),
      (m) => '\n[图片: ${m.group(1)}]\n',
    );
    text = text.replaceAllMapped(
      RegExp(r"<img[^>]*alt\s*=\s*'([^']*)'[^>]*>", caseSensitive: false),
      (m) => '\n[图片: ${m.group(1)}]\n',
    );

    // 没有 alt 的图片标签 - 显示通用占位符
    text = text.replaceAllMapped(
      RegExp(r'<img[^>]*src\s*=\s*"([^"]*)"[^>]*>', caseSensitive: false),
      (m) {
        final src = m.group(1) ?? '';
        final fileName = src.split('/').last.split('?').first;
        return '\n[图片: $fileName]\n';
      },
    );
    text = text.replaceAllMapped(
      RegExp(r"<img[^>]*src\s*=\s*'([^']*)'[^>]*>", caseSensitive: false),
      (m) {
        final src = m.group(1) ?? '';
        final fileName = src.split('/').last.split('?').first;
        return '\n[图片: $fileName]\n';
      },
    );

    // 处理剩余的 img 标签
    text = text.replaceAll(RegExp(r'<img[^>]*>'), '\n[图片]\n');

    // 处理 SVG 标签
    text = text.replaceAll(RegExp(r'<svg[^>]*>.*?</svg>', caseSensitive: false, dotAll: true), '\n[图形]\n');

    // 处理换行标签
    text = text.replaceAll(RegExp(r'<br\s*/?>'), '\n');

    // 块级元素结束标签添加换行
    text = text.replaceAll(RegExp(r'</(p|div|h[1-6]|li|tr|blockquote|article|section|header|footer)>'), '\n\n');

    // 移除所有其他 HTML 标签
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');

    // 常见 HTML 实体解码
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&ensp;', ' ')
        .replaceAll('&emsp;', '　')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        // 破折号和省略号
        .replaceAll('&mdash;', '—')
        .replaceAll('&ndash;', '–')
        .replaceAll('&hellip;', '…')
        // 引号
        .replaceAll('&lsquo;', ''')
        .replaceAll('&rsquo;', ''')
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&laquo;', '«')
        .replaceAll('&raquo;', '»')
        // 特殊符号
        .replaceAll('&copy;', '©')
        .replaceAll('&reg;', '®')
        .replaceAll('&trade;', '™')
        .replaceAll('&times;', '×')
        .replaceAll('&divide;', '÷')
        .replaceAll('&plusmn;', '±')
        .replaceAll('&deg;', '°')
        .replaceAll('&cent;', '¢')
        .replaceAll('&pound;', '£')
        .replaceAll('&yen;', '¥')
        .replaceAll('&euro;', '€');

    // 处理十进制数字实体 &#NNNN;
    text = text.replaceAllMapped(
      RegExp(r'&#(\d+);'),
      (m) {
        try {
          final code = int.parse(m.group(1)!);
          if (code > 0 && code <= 0x10FFFF) {
            return String.fromCharCode(code);
          }
        } catch (_) {}
        return '';
      },
    );

    // 处理十六进制数字实体 &#xNNNN;
    text = text.replaceAllMapped(
      RegExp(r'&#[xX]([0-9a-fA-F]+);'),
      (m) {
        try {
          final code = int.parse(m.group(1)!, radix: 16);
          if (code > 0 && code <= 0x10FFFF) {
            return String.fromCharCode(code);
          }
        } catch (_) {}
        return '';
      },
    );

    // 清理多余换行和空白
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    text = text.replaceAll(RegExp(r'[ \t]+\n'), '\n');
    text = text.replaceAll(RegExp(r'\n[ \t]+'), '\n');

    return text.trim();
  }

  // ============ 工具 ============

  String _generateBookId(String title) {
    return 'local_${title.hashCode.abs()}';
  }
}

// ============ 数据类型 ============

/// TXT 目录规则
class _TxtTocRule {
  final String name;
  final String pattern;
  final int priority;

  const _TxtTocRule({
    required this.name,
    required this.pattern,
    required this.priority,
  });
}

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

/// EPUB Isolate 解析结果
class _EpubIsolateResult {
  final String bookTitle;
  final String bookAuthor;
  final List<String> titles;
  final List<String> contents;

  _EpubIsolateResult({
    required this.bookTitle,
    required this.bookAuthor,
    required this.titles,
    required this.contents,
  });
}
