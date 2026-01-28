import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../explore/providers/book_source_provider.dart';

class BookDetailPage extends ConsumerWidget {
  final String sourceId;
  final String bookId;

  const BookDetailPage({
    super.key,
    required this.sourceId,
    required this.bookId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookDetailAsync = ref.watch(bookDetailProvider((sourceId: sourceId, bookId: bookId)));
    final chaptersAsync = ref.watch(chapterListProvider((sourceId: sourceId, bookId: bookId)));

    return Scaffold(
      body: bookDetailAsync.when(
        data: (book) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  book.title,
                  style: const TextStyle(fontSize: 16),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (book.cover != null)
                      CachedNetworkImage(
                        imageUrl: book.cover!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      )
                    else
                      Container(color: Theme.of(context).colorScheme.primaryContainer),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(book.author, style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(width: 16),
                        if (book.category != null) ...[
                          Icon(Icons.category_outlined, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(book.category!, style: TextStyle(color: Colors.grey[600])),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (book.description != null)
                      Text(
                        book.description!,
                        style: TextStyle(color: Colors.grey[700], height: 1.5),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final chapters = chaptersAsync.valueOrNull;
                              if (chapters != null && chapters.isNotEmpty) {
                                context.push('/reader/$sourceId/$bookId/${chapters.first.id}');
                              }
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('开始阅读'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已加入书架')),
                            );
                          },
                          icon: const Icon(Icons.bookmark_add_outlined),
                          label: const Text('加入书架'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      '目录',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    chaptersAsync.when(
                      data: (chapters) => Text(
                        '共 ${chapters.length} 章',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            chaptersAsync.when(
              data: (chapters) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final chapter = chapters[index];
                    return ListTile(
                      title: Text(
                        chapter.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: chapter.wordCount != null
                          ? Text(
                              '${(chapter.wordCount! / 1000).toStringAsFixed(1)}k字',
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            )
                          : null,
                      onTap: () {
                        context.push('/reader/$sourceId/$bookId/${chapter.id}');
                      },
                    );
                  },
                  childCount: chapters.length,
                ),
              ),
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('加载章节失败: $e', style: TextStyle(color: Colors.red[400])),
                  ),
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text('加载失败: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(bookDetailProvider((sourceId: sourceId, bookId: bookId))),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
