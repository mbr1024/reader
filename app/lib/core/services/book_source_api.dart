import 'dart:convert';
import '../network/api_client.dart';
import '../models/book_models.dart';
import './storage_service.dart';

class BookSourceApi {
  final ApiClient _client = ApiClient.instance;
  final StorageService _storage = StorageService.instance;

  /// 获取推荐数据（banner、热门、新书、热搜等）
  Future<RecommendationsData> getRecommendations() async {
    final response = await _client.get('/book-source/recommendations');
    return RecommendationsData.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<BookSource>> getSources() async {
    final response = await _client.get('/book-source/sources');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((e) => BookSource.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<BookSearchResult>> search(String keyword, {String? sourceId}) async {
    final queryParams = <String, dynamic>{'keyword': keyword};
    if (sourceId != null) {
      queryParams['source'] = sourceId;
    }
    final response = await _client.get('/book-source/search', queryParameters: queryParams);
    final data = response.data as Map<String, dynamic>;
    final List<dynamic> books = data['books'] as List<dynamic>;
    return books.map((e) => BookSearchResult.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BookDetail> getBookDetail(String sourceId, String bookId) async {
    final response = await _client.get('/book-source/book/$sourceId/$bookId');
    return BookDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<ChapterInfo>> getChapterList(String sourceId, String bookId) async {
    final response = await _client.get('/book-source/book/$sourceId/$bookId/chapters');
    final data = response.data as Map<String, dynamic>;
    final List<dynamic> chapters = data['chapters'] as List<dynamic>;
    return chapters.map((e) => ChapterInfo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ChapterContent> getChapterContent(
    String sourceId,
    String bookId,
    String chapterId,
  ) async {
    // 尝试从本地缓存读取
    final cachedJson = _storage.getCachedOnlineChapter(sourceId, bookId, chapterId);
    if (cachedJson != null) {
      try {
        final data = jsonDecode(cachedJson) as Map<String, dynamic>;
        return ChapterContent.fromJson(data);
      } catch (_) {
        // 缓存数据损坏，继续从网络获取
      }
    }
    
    // 从网络获取
    final response = await _client.get('/book-source/book/$sourceId/$bookId/chapter/$chapterId');
    final data = response.data as Map<String, dynamic>;
    
    // 缓存到本地
    _storage.cacheOnlineChapter(sourceId, bookId, chapterId, jsonEncode(data));
    
    return ChapterContent.fromJson(data);
  }

  Future<void> importLegadoSource(String source) async {
    await _client.post('/book-source/import', data: {'source': source});
  }

  Future<List<BookSource>> getImportedSources() async {
    final response = await _client.get('/book-source/imported');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((e) => BookSource.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> removeImportedSource(String id) async {
    await _client.delete('/book-source/imported/$id');
  }
}
