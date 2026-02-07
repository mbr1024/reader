import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/book_models.dart';
import '../../../core/services/book_source_api.dart';
import '../../../core/services/local_book_service.dart';

final bookSourceApiProvider = Provider<BookSourceApi>((ref) {
  return BookSourceApi();
});

/// 推荐数据 Provider（banner、热门、新书、热搜等）
final recommendationsProvider = FutureProvider<RecommendationsData>((ref) async {
  final api = ref.watch(bookSourceApiProvider);
  try {
    return await api.getRecommendations();
  } catch (e) {
    // 如果获取失败，返回空数据
    return RecommendationsData.empty;
  }
});

final bookSourcesProvider = FutureProvider<List<BookSource>>((ref) async {
  final api = ref.watch(bookSourceApiProvider);
  return api.getSources();
});

final selectedSourceProvider = StateProvider<String?>((ref) => null);

final searchKeywordProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<BookSearchResult>>((ref) async {
  final api = ref.watch(bookSourceApiProvider);
  final keyword = ref.watch(searchKeywordProvider);
  final sourceId = ref.watch(selectedSourceProvider);

  if (keyword.isEmpty) {
    return [];
  }

  return api.search(keyword, sourceId: sourceId);
});

final bookDetailProvider = FutureProvider.family<BookDetail, ({String sourceId, String bookId})>(
  (ref, params) async {
    if (params.sourceId == 'local') {
      // 本地导入书籍
      final localService = LocalBookService.instance;
      return localService.getBookDetail(params.bookId);
    }
    final api = ref.watch(bookSourceApiProvider);
    return api.getBookDetail(params.sourceId, params.bookId);
  },
);

final chapterListProvider = FutureProvider.family<List<ChapterInfo>, ({String sourceId, String bookId})>(
  (ref, params) async {
    if (params.sourceId == 'local') {
      final localService = LocalBookService.instance;
      return localService.getChapterList(params.bookId);
    }
    final api = ref.watch(bookSourceApiProvider);
    return api.getChapterList(params.sourceId, params.bookId);
  },
);

final chapterContentProvider = FutureProvider.family<ChapterContent, ({String sourceId, String bookId, String chapterId})>(
  (ref, params) async {
    if (params.sourceId == 'local') {
      final localService = LocalBookService.instance;
      return localService.getChapterContent(params.bookId, params.chapterId);
    }
    final api = ref.watch(bookSourceApiProvider);
    return api.getChapterContent(params.sourceId, params.bookId, params.chapterId);
  },
);
