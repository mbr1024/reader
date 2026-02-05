import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/book_models.dart';
import '../../../core/services/book_source_api.dart';
import '../../../core/services/mock_book_service.dart';

final bookSourceApiProvider = Provider<BookSourceApi>((ref) {
  return BookSourceApi();
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
    final api = ref.watch(bookSourceApiProvider);
    return api.getBookDetail(params.sourceId, params.bookId);
  },
);

final chapterListProvider = FutureProvider.family<List<ChapterInfo>, ({String sourceId, String bookId})>(
  (ref, params) async {
    final api = ref.watch(bookSourceApiProvider);
    return api.getChapterList(params.sourceId, params.bookId);
  },
);

final chapterContentProvider = FutureProvider.family<ChapterContent, ({String sourceId, String bookId, String chapterId})>(
  (ref, params) async {
    final api = ref.watch(bookSourceApiProvider);
    return api.getChapterContent(params.sourceId, params.bookId, params.chapterId);
  },
);

// ============ 本地 Mock 书籍 Provider ============

final mockBookServiceProvider = Provider<MockBookService>((ref) {
  return MockBookService();
});

final localBookDetailProvider = Provider<BookDetail>((ref) {
  final service = ref.watch(mockBookServiceProvider);
  return service.getBookDetail();
});

final localChapterListProvider = FutureProvider<List<ChapterInfo>>((ref) async {
  final service = ref.watch(mockBookServiceProvider);
  return service.getChapterList();
});

final localChapterContentProvider = FutureProvider.family<ChapterContent, String>(
  (ref, chapterId) async {
    final service = ref.watch(mockBookServiceProvider);
    return service.getChapterContent(chapterId);
  },
);
