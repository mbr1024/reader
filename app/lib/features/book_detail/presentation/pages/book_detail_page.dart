import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../explore/providers/book_source_provider.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/bookshelf_item.dart';

class BookDetailPage extends ConsumerStatefulWidget {
  final String sourceId;
  final String bookId;

  const BookDetailPage({
    super.key,
    required this.sourceId,
    required this.bookId,
  });

  @override
  ConsumerState<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends ConsumerState<BookDetailPage> {
  final _storage = StorageService.instance;
  bool _isInBookshelf = false;

  @override
  void initState() {
    super.initState();
    _isInBookshelf = _storage.isInBookshelf(widget.bookId);
  }

  @override
  Widget build(BuildContext context) {
    final bookDetailAsync = ref.watch(bookDetailProvider((
      sourceId: widget.sourceId,
      bookId: widget.bookId,
    )));
    final chaptersAsync = ref.watch(chapterListProvider((
      sourceId: widget.sourceId,
      bookId: widget.bookId,
    )));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: bookDetailAsync.when(
        data: (book) => CustomScrollView(
          slivers: [
            // 自定义 AppBar
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (book.cover != null)
                      CachedNetworkImage(
                        imageUrl: book.cover!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      )
                    else
                      Container(color: AppColors.primary.withOpacity(0.1)),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.surface.withOpacity(0.9),
                            AppColors.surface,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 书籍信息卡片
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 作者和分类
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(book.author, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                        if (book.category != null) ...[
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              book.category!,
                              style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 简介
                    if (book.description != null)
                      Text(
                        book.description!,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.6,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 24),
                    // 按钮区
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final chapters = chaptersAsync.valueOrNull;
                              if (chapters != null && chapters.isNotEmpty) {
                                final progress = _storage.getProgress(widget.bookId);
                                final chapterId = progress?.chapterId ?? chapters.first.id;
                                context.push('/reader/${widget.sourceId}/${widget.bookId}/$chapterId');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            child: Text(
                              _storage.getProgress(widget.bookId) != null ? '继续阅读' : '开始阅读',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        _isInBookshelf
                            ? OutlinedButton.icon(
                                onPressed: _removeFromBookshelf,
                                icon: const Icon(Icons.check, size: 20),
                                label: const Text('已在书架'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  foregroundColor: AppColors.textSecondary,
                                  side: const BorderSide(color: AppColors.border),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                ),
                              )
                            : OutlinedButton.icon(
                                onPressed: () => _addToBookshelf(book),
                                icon: const Icon(Icons.add, size: 20),
                                label: const Text('加入书架'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 章节列表标题
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      '目录',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    chaptersAsync.when(
                      data: (chapters) => Text(
                        '共 ${chapters.length} 章',
                        style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            // 章节列表
            chaptersAsync.when(
              data: (chapters) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final chapter = chapters[index];
                    return Container(
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        title: Text(
                          chapter.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                        ),
                        trailing: chapter.wordCount != null
                            ? Text(
                                '${(chapter.wordCount! / 1000).toStringAsFixed(1)}k',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              )
                            : const Icon(Icons.navigate_next, size: 16, color: AppColors.textHint),
                        onTap: () {
                          context.push('/reader/${widget.sourceId}/${widget.bookId}/${chapter.id}');
                        },
                      ),
                    );
                  },
                  childCount: chapters.length,
                ),
              ),
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('加载章节失败: $e', style: const TextStyle(color: AppColors.error)),
                  ),
                ),
              ),
            ),
            
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('加载失败: $e', style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(bookDetailProvider((
                  sourceId: widget.sourceId,
                  bookId: widget.bookId,
                ))),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('重试', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addToBookshelf(dynamic book) async {
    final item = BookshelfItem(
      bookId: widget.bookId,
      sourceId: widget.sourceId,
      title: book.title,
      author: book.author,
      cover: book.cover,
      category: book.category,
      addedAt: DateTime.now(),
    );
    await _storage.addToBookshelf(item);
    setState(() => _isInBookshelf = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已加入书架')),
      );
    }
  }

  Future<void> _removeFromBookshelf() async {
    await _storage.removeFromBookshelf(widget.bookId);
    setState(() => _isInBookshelf = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已从书架移除')),
      );
    }
  }
}
