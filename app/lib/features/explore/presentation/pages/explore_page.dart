import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/models/book_models.dart';
import '../../providers/book_source_provider.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String keyword) {
    if (keyword.trim().isEmpty) return;
    ref.read(searchKeywordProvider.notifier).state = keyword.trim();
  }

  @override
  Widget build(BuildContext context) {
    final sourcesAsync = ref.watch(bookSourcesProvider);
    final selectedSource = ref.watch(selectedSourceProvider);
    final searchResults = ref.watch(searchResultsProvider);
    final keyword = ref.watch(searchKeywordProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('发现'),
        actions: [
          IconButton(
            icon: const Icon(Icons.source_outlined),
            tooltip: '书源管理',
            onPressed: () {
              _showSourceSelector(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索书名、作者',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchKeywordProvider.notifier).state = '';
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
              onSubmitted: _onSearch,
              textInputAction: TextInputAction.search,
            ),
          ),

          sourcesAsync.when(
            data: (sources) => SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _SourceChip(
                    label: '全部',
                    isSelected: selectedSource == null,
                    onSelected: () {
                      ref.read(selectedSourceProvider.notifier).state = null;
                      if (keyword.isNotEmpty) {
                        ref.invalidate(searchResultsProvider);
                      }
                    },
                  ),
                  ...sources.map((source) => _SourceChip(
                    label: source.name,
                    isSelected: selectedSource == source.id,
                    onSelected: () {
                      ref.read(selectedSourceProvider.notifier).state = source.id;
                      if (keyword.isNotEmpty) {
                        ref.invalidate(searchResultsProvider);
                      }
                    },
                  )),
                ],
              ),
            ),
            loading: () => const SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => SizedBox(
              height: 40,
              child: Center(child: Text('加载书源失败', style: TextStyle(color: Colors.red[400]))),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: _buildContent(keyword, searchResults),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String keyword, AsyncValue<List<BookSearchResult>> searchResults) {
    if (keyword.isEmpty) {
      return _buildEmptyState();
    }

    return searchResults.when(
      data: (books) {
        if (books.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('未找到相关书籍', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return _BookListItem(
              book: book,
              onTap: () => _openBookDetail(book),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text('搜索失败: $e', style: TextStyle(color: Colors.red[400])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(searchResultsProvider),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('输入关键词搜索书籍', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _showSourceSelector(BuildContext context) {
    final sourcesAsync = ref.read(bookSourcesProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('书源管理', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            sourcesAsync.when(
              data: (sources) => Column(
                children: sources.map((source) => ListTile(
                  leading: Icon(
                    source.type == 'builtin' ? Icons.bookmark : Icons.cloud_download,
                  ),
                  title: Text(source.name),
                  subtitle: Text(source.type == 'builtin' ? '内置书源' : '导入书源'),
                  trailing: source.type == 'imported'
                      ? IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            ref.read(bookSourceApiProvider).removeImportedSource(source.id);
                            ref.invalidate(bookSourcesProvider);
                            Navigator.pop(context);
                          },
                        )
                      : null,
                )).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('加载失败: $e'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _openBookDetail(BookSearchResult book) {
    context.push('/book/${book.source}/${book.id}');
  }
}

class _SourceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _SourceChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _BookListItem extends StatelessWidget {
  final BookSearchResult book;
  final VoidCallback onTap;

  const _BookListItem({
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: book.cover != null
                    ? CachedNetworkImage(
                        imageUrl: book.cover!,
                        width: 70,
                        height: 95,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildCoverPlaceholder(context),
                        errorWidget: (context, url, error) => _buildCoverPlaceholder(context),
                      )
                    : _buildCoverPlaceholder(context),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (book.description != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        book.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (book.category != null)
                          _buildTag(context, book.category!),
                        const SizedBox(width: 8),
                        _buildTag(context, book.source, isSource: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverPlaceholder(BuildContext context) {
    return Container(
      width: 70,
      height: 95,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Icon(
          Icons.book,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text, {bool isSource = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSource
            ? Theme.of(context).colorScheme.secondaryContainer
            : Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: isSource
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
