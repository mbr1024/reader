import 'package:hive_flutter/hive_flutter.dart';
import '../constants/storage_keys.dart';
import '../models/bookshelf_item.dart';
import '../models/bookmark_item.dart';
import '../models/reading_progress.dart';
import '../models/reader_settings.dart';

/// 本地存储服务
/// 管理所有 Hive Box 的初始化和访问
class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  
  StorageService._();
  
  late Box<String> _authBox;
  late Box<BookshelfItem> _bookshelfBox;
  late Box<ReadingProgress> _progressBox;
  late Box<ReaderSettings> _settingsBox;
  late Box<String> _localBooksBox; // bookId -> filePath
  late Box<String> _localChaptersIndexBox; // bookId -> JSON章节标题列表
  late Box<String> _localChaptersContentBox; // bookId_idx -> 章节内容
  late Box<BookmarkItem> _bookmarkBox; // 书签
  late Box<String> _onlineChapterCacheBox; // sourceId_bookId_chapterId -> 章节内容JSON
  
  bool _initialized = false;
  
  /// 初始化存储服务
  Future<void> init() async {
    if (_initialized) return;
    
    // 注册 TypeAdapters (检查避免重复注册)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(BookshelfItemAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ReadingProgressAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ReaderSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(BookmarkItemAdapter());
    }
    
    // 打开 Boxes
    _authBox = await Hive.openBox<String>(StorageKeys.authBox);
    _bookshelfBox = await Hive.openBox<BookshelfItem>(StorageKeys.bookshelfBox);
    _progressBox = await Hive.openBox<ReadingProgress>(StorageKeys.progressBox);
    _settingsBox = await Hive.openBox<ReaderSettings>(StorageKeys.settingsBox);
    _localBooksBox = await Hive.openBox<String>(StorageKeys.localBooksBox);
    _localChaptersIndexBox = await Hive.openBox<String>(StorageKeys.localChaptersIndexBox);
    _localChaptersContentBox = await Hive.openBox<String>(StorageKeys.localChaptersContentBox);
    _bookmarkBox = await Hive.openBox<BookmarkItem>(StorageKeys.bookmarkBox);
    _onlineChapterCacheBox = await Hive.openBox<String>(StorageKeys.onlineChapterCacheBox);
    
    _initialized = true;
  }
  
  // ============ Auth 相关 ============
  
  String? get accessToken => _authBox.get(StorageKeys.accessToken);
  String? get refreshToken => _authBox.get(StorageKeys.refreshToken);
  String? get userId => _authBox.get(StorageKeys.userId);
  
  Future<void> saveAuth({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await _authBox.put(StorageKeys.accessToken, accessToken);
    await _authBox.put(StorageKeys.refreshToken, refreshToken);
    await _authBox.put(StorageKeys.userId, userId);
  }
  
  Future<void> clearAuth() async {
    await _authBox.clear();
  }
  
  bool get isLoggedIn => accessToken != null;
  
  // ============ 书架相关 ============
  
  /// 生成书架项的唯一 key（sourceId:bookId）
  String _bookshelfKey(String sourceId, String bookId) => '$sourceId:$bookId';
  
  List<BookshelfItem> getBookshelf() {
    return _bookshelfBox.values.toList();
  }
  
  BookshelfItem? getBookshelfItem(String bookId, {required String sourceId}) {
    return _bookshelfBox.get(_bookshelfKey(sourceId, bookId));
  }
  
  Future<void> addToBookshelf(BookshelfItem item) async {
    await _bookshelfBox.put(_bookshelfKey(item.sourceId, item.bookId), item);
  }
  
  Future<void> removeFromBookshelf(String bookId, {required String sourceId}) async {
    await _bookshelfBox.delete(_bookshelfKey(sourceId, bookId));
  }
  
  bool isInBookshelf(String bookId, {required String sourceId}) {
    return _bookshelfBox.containsKey(_bookshelfKey(sourceId, bookId));
  }
  
  Future<void> updateBookshelfItem(BookshelfItem item) async {
    await _bookshelfBox.put(_bookshelfKey(item.sourceId, item.bookId), item);
  }
  
  /// 清空书架（开发调试用）
  Future<void> clearBookshelf() async {
    await _bookshelfBox.clear();
  }
  
  // ============ 本地书籍文件路径 ============
  
  /// 保存本地书籍的文件路径
  Future<void> saveLocalBookPath(String bookId, String filePath) async {
    await _localBooksBox.put(bookId, filePath);
  }
  
  /// 获取本地书籍的文件路径
  String? getLocalBookPath(String bookId) {
    return _localBooksBox.get(bookId);
  }
  
  /// 删除本地书籍的文件路径
  Future<void> removeLocalBookPath(String bookId) async {
    await _localBooksBox.delete(bookId);
  }
  
  /// 获取所有本地书籍路径映射
  Map<String, String> getAllLocalBookPaths() {
    return Map.fromEntries(
      _localBooksBox.keys.map((key) => MapEntry(key.toString(), _localBooksBox.get(key)!)),
    );
  }

  // ============ 阅读进度相关 ============
  
  ReadingProgress? getProgress(String bookId) {
    return _progressBox.get(bookId);
  }
  
  Future<void> saveProgress(ReadingProgress progress) async {
    await _progressBox.put(progress.bookId, progress);
  }
  
  Future<void> clearProgress(String bookId) async {
    await _progressBox.delete(bookId);
  }
  
  // ============ 阅读设置相关 ============
  
  static const String _settingsKey = 'reader_settings';
  
  ReaderSettings getSettings() {
    return _settingsBox.get(_settingsKey) ?? ReaderSettings.defaults();
  }
  
  Future<void> saveSettings(ReaderSettings settings) async {
    await _settingsBox.put(_settingsKey, settings);
  }

  // ============ 本地书籍章节存储 ============

  /// 保存章节索引（标题列表的 JSON）
  Future<void> saveChapterIndex(String bookId, String jsonStr) async {
    await _localChaptersIndexBox.put(bookId, jsonStr);
  }

  /// 读取章节索引
  String? getChapterIndex(String bookId) {
    return _localChaptersIndexBox.get(bookId);
  }

  /// 保存单章内容
  Future<void> saveChapterContent(String bookId, int index, String content) async {
    await _localChaptersContentBox.put('${bookId}_$index', content);
  }

  /// 批量保存章节内容（减少 I/O 次数）
  Future<void> saveChapterContents(String bookId, List<String> contents) async {
    final entries = <String, String>{};
    for (int i = 0; i < contents.length; i++) {
      entries['${bookId}_$i'] = contents[i];
    }
    await _localChaptersContentBox.putAll(entries);
  }

  /// 读取单章内容（同步，极快）
  String? getChapterContent(String bookId, int index) {
    return _localChaptersContentBox.get('${bookId}_$index');
  }

  /// 删除某本书的全部章节数据
  Future<void> removeLocalBookData(String bookId) async {
    await _localChaptersIndexBox.delete(bookId);
    // 删除所有章节内容 - 使用 deleteAll 批量删除，避免多次 I/O
    final keysToDelete = _localChaptersContentBox.keys
        .where((key) => key.toString().startsWith('${bookId}_'))
        .toList();
    if (keysToDelete.isNotEmpty) {
      await _localChaptersContentBox.deleteAll(keysToDelete);
    }
    await _localBooksBox.delete(bookId);
  }

  // ============ 书签相关 ============

  /// 获取所有书签
  List<BookmarkItem> getAllBookmarks() {
    return _bookmarkBox.values.toList();
  }

  /// 获取某本书的所有书签
  List<BookmarkItem> getBookmarksByBookId(String bookId) {
    return _bookmarkBox.values
        .where((b) => b.bookId == bookId)
        .toList();
  }

  /// 添加书签
  Future<void> addBookmark(BookmarkItem item) async {
    await _bookmarkBox.put(item.id, item);
  }

  /// 更新书签（如更新备注）
  Future<void> updateBookmark(BookmarkItem item) async {
    await _bookmarkBox.put(item.id, item);
  }

  /// 删除书签
  Future<void> removeBookmark(String id) async {
    await _bookmarkBox.delete(id);
  }

  /// 清空所有书签
  Future<void> clearAllBookmarks() async {
    await _bookmarkBox.clear();
  }

  /// 删除某本书的所有书签
  Future<void> removeBookmarksByBookId(String bookId) async {
    final keysToDelete = _bookmarkBox.keys
        .where((key) {
          final item = _bookmarkBox.get(key);
          return item?.bookId == bookId;
        })
        .toList();
    if (keysToDelete.isNotEmpty) {
      await _bookmarkBox.deleteAll(keysToDelete);
    }
  }

  // ============ 在线章节缓存相关 ============
  
  /// 生成在线章节缓存的 key
  String _onlineCacheKey(String sourceId, String bookId, String chapterId) {
    return '${sourceId}_${bookId}_$chapterId';
  }
  
  /// 缓存在线章节内容
  Future<void> cacheOnlineChapter(
    String sourceId,
    String bookId,
    String chapterId,
    String contentJson,
  ) async {
    final key = _onlineCacheKey(sourceId, bookId, chapterId);
    await _onlineChapterCacheBox.put(key, contentJson);
  }
  
  /// 获取缓存的在线章节内容
  String? getCachedOnlineChapter(
    String sourceId,
    String bookId,
    String chapterId,
  ) {
    final key = _onlineCacheKey(sourceId, bookId, chapterId);
    return _onlineChapterCacheBox.get(key);
  }
  
  /// 检查在线章节是否已缓存
  bool hasOnlineChapterCache(
    String sourceId,
    String bookId,
    String chapterId,
  ) {
    final key = _onlineCacheKey(sourceId, bookId, chapterId);
    return _onlineChapterCacheBox.containsKey(key);
  }
  
  /// 删除某本书的所有在线章节缓存
  Future<void> clearOnlineChapterCache(String sourceId, String bookId) async {
    final prefix = '${sourceId}_${bookId}_';
    final keysToDelete = _onlineChapterCacheBox.keys
        .where((key) => key.toString().startsWith(prefix))
        .toList();
    if (keysToDelete.isNotEmpty) {
      await _onlineChapterCacheBox.deleteAll(keysToDelete);
    }
  }
  
  /// 清空所有在线章节缓存
  Future<void> clearAllOnlineChapterCache() async {
    await _onlineChapterCacheBox.clear();
  }
  
  /// 获取在线章节缓存大小（条目数）
  int get onlineChapterCacheCount => _onlineChapterCacheBox.length;
}
