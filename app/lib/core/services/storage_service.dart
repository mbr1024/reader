import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/storage_keys.dart';
import '../models/bookshelf_item.dart';
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
    
    // 打开 Boxes
    _authBox = await Hive.openBox<String>(StorageKeys.authBox);
    _bookshelfBox = await Hive.openBox<BookshelfItem>(StorageKeys.bookshelfBox);
    _progressBox = await Hive.openBox<ReadingProgress>(StorageKeys.progressBox);
    _settingsBox = await Hive.openBox<ReaderSettings>(StorageKeys.settingsBox);
    _localBooksBox = await Hive.openBox<String>(StorageKeys.localBooksBox);
    _localChaptersIndexBox = await Hive.openBox<String>(StorageKeys.localChaptersIndexBox);
    _localChaptersContentBox = await Hive.openBox<String>(StorageKeys.localChaptersContentBox);
    
    _initialized = true;

    // 修复/迁移旧的封面数据 (Fix for renamed assets)
    // 如果封面路径不符合新的 "number.webp" 格式，则重新随机分配
    try {
      final oldFormatRegex = RegExp(r'assets/images/covers/\d+\.webp$');
      for (var item in _bookshelfBox.values) {
        if (item.cover != null && !oldFormatRegex.hasMatch(item.cover!)) {
          final newCoverId = (item.bookId.hashCode % 38) + 1;
          final newItem = item.copyWith(
            cover: 'assets/images/covers/$newCoverId.webp',
          );
          await _bookshelfBox.put(item.bookId, newItem);
        }
      }
    } catch (e) {
      debugPrint('Error migrating covers: $e');
    }
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
  
  List<BookshelfItem> getBookshelf() {
    return _bookshelfBox.values.toList();
  }
  
  BookshelfItem? getBookshelfItem(String bookId) {
    return _bookshelfBox.get(bookId);
  }
  
  Future<void> addToBookshelf(BookshelfItem item) async {
    await _bookshelfBox.put(item.bookId, item);
  }
  
  Future<void> removeFromBookshelf(String bookId) async {
    await _bookshelfBox.delete(bookId);
  }
  
  bool isInBookshelf(String bookId) {
    return _bookshelfBox.containsKey(bookId);
  }
  
  Future<void> updateBookshelfItem(BookshelfItem item) async {
    await _bookshelfBox.put(item.bookId, item);
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

  /// 读取单章内容（同步，极快）
  String? getChapterContent(String bookId, int index) {
    return _localChaptersContentBox.get('${bookId}_$index');
  }

  /// 删除某本书的全部章节数据
  Future<void> removeLocalBookData(String bookId) async {
    await _localChaptersIndexBox.delete(bookId);
    // 删除所有章节内容
    final keysToDelete = _localChaptersContentBox.keys
        .where((key) => key.toString().startsWith('${bookId}_'))
        .toList();
    for (final key in keysToDelete) {
      await _localChaptersContentBox.delete(key);
    }
    await _localBooksBox.delete(bookId);
  }
}
