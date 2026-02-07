import 'dart:async';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';
import '../models/bookshelf_item.dart';
import 'storage_service.dart';

/// 书架同步服务
/// 已登录用户自动无感同步书架数据（排除本地书籍）
class BookshelfSyncService {
  static BookshelfSyncService? _instance;
  static BookshelfSyncService get instance => _instance ??= BookshelfSyncService._();

  BookshelfSyncService._();

  final _api = ApiClient.instance;
  final _storage = StorageService.instance;

  Timer? _syncTimer;
  bool _isSyncing = false;
  DateTime? _lastSyncAt;

  /// 初始化同步服务（在用户登录后调用）
  void startAutoSync() {
    if (!_storage.isLoggedIn) return;

    // 立即执行一次同步
    syncNow();

    // 每5分钟自动同步一次
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      syncNow();
    });
  }

  /// 停止自动同步（在用户登出后调用）
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// 立即执行同步
  Future<void> syncNow() async {
    if (!_storage.isLoggedIn || _isSyncing) return;

    _isSyncing = true;
    try {
      await _doSync();
      _lastSyncAt = DateTime.now();
    } catch (e) {
      debugPrint('书架同步失败: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// 执行同步逻辑
  Future<void> _doSync() async {
    // 获取本地书架（排除本地书籍）
    final localBooks = _storage.getBookshelf()
        .where((item) => item.sourceId != 'local')
        .toList();

    // 构建同步请求数据（符合服务端 DTO 格式）
    final syncData = {
      'deviceId': await _getDeviceId(),
      'syncType': 'bookshelf',
      'bookshelf': localBooks.map((item) => ({
        'bookId': item.bookId,
        'sourceId': item.sourceId,
        'sourceType': item.sourceId, // 使用 sourceId 作为 sourceType
        'title': item.title,
        'author': item.author,
        'cover': item.cover ?? '',
        'lastChapter': int.tryParse(item.lastChapterId ?? '0') ?? 0,
        'lastPosition': 0,
        'isTop': item.isTop,
        'lastReadAt': item.lastReadAt?.toIso8601String(),
      })).toList(),
    };

    try {
      final response = await _api.authPost('/sync', data: syncData);
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true && data['data'] != null) {
        // 合并服务端数据到本地
        await _mergeServerData(data['data']);
      }
    } catch (e) {
      // 401 等认证错误时不处理，让用户重新登录
      debugPrint('同步请求失败: $e');
    }
  }

  /// 合并服务端数据到本地
  Future<void> _mergeServerData(Map<String, dynamic> serverData) async {
    final serverBookshelf = serverData['bookshelf'] as List<dynamic>?;
    if (serverBookshelf == null) return;

    // 获取本地书架
    final localBooks = _storage.getBookshelf();
    final localBookIds = localBooks.map((b) => '${b.sourceId}:${b.bookId}').toSet();

    // 添加服务端有但本地没有的书籍（排除本地书籍）
    for (final item in serverBookshelf) {
      final book = item['book'] as Map<String, dynamic>?;
      if (book == null) continue;

      final sourceId = book['sourceType'] as String? ?? '';
      final bookId = book['sourceId'] as String? ?? '';

      // 跳过本地书籍
      if (sourceId == 'local') continue;

      final key = '$sourceId:$bookId';
      if (!localBookIds.contains(key)) {
        // 本地没有，添加
        final lastReadAtStr = item['lastReadAt'] as String?;
        DateTime? lastReadAt;
        if (lastReadAtStr != null) {
          lastReadAt = DateTime.tryParse(lastReadAtStr);
        }
        
        await _storage.addToBookshelf(BookshelfItem(
          bookId: bookId,
          sourceId: sourceId,
          title: book['title'] as String? ?? '',
          author: book['author'] as String? ?? '',
          cover: book['cover'] as String?,
          category: book['category'] as String?,
          addedAt: DateTime.now(),
          lastReadAt: lastReadAt,
          isTop: item['isTop'] as bool? ?? false,
        ));
      }
    }
  }

  /// 获取设备 ID
  Future<String> _getDeviceId() async {
    // 简单实现：使用 userId 作为设备标识
    // 实际项目中应该使用 device_info_plus 获取真实设备 ID
    return _storage.userId ?? 'unknown_device';
  }

  /// 添加书籍后触发同步
  void onBookAdded() {
    // 延迟 1 秒后同步，避免频繁请求
    Future.delayed(const Duration(seconds: 1), () => syncNow());
  }

  /// 移除书籍后触发同步
  void onBookRemoved() {
    Future.delayed(const Duration(seconds: 1), () => syncNow());
  }

  /// 更新阅读进度后触发同步
  void onProgressUpdated() {
    // 阅读进度更新频繁，延迟 5 秒后同步
    Future.delayed(const Duration(seconds: 5), () => syncNow());
  }

  DateTime? get lastSyncAt => _lastSyncAt;
  bool get isSyncing => _isSyncing;
}
