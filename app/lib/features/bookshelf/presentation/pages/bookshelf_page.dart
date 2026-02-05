import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/bookshelf_item.dart';
import '../../../../core/data/mock_data.dart';

class BookshelfPage extends StatefulWidget {
  const BookshelfPage({super.key});

  @override
  State<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends State<BookshelfPage> {
  final _storage = StorageService.instance;
  List<BookshelfItem> _books = [];

  @override
  void initState() {
    super.initState();
    _initBookshelf();
  }

  Future<void> _initBookshelf() async {
    // 如果书架为空，添加默认数据
    if (_storage.getBookshelf().isEmpty) {
      for (final book in MockData.defaultBookshelf) {
        await _storage.addToBookshelf(BookshelfItem(
          bookId: book.id,
          sourceId: 'demo',
          title: book.title,
          author: book.author,
          cover: book.cover,
          category: book.category,
          addedAt: DateTime.now(),
        ));
      }
    }
    _loadBookshelf();
  }

  void _loadBookshelf() {
    setState(() {
      _books = _storage.getBookshelf();
      _books.sort((a, b) {
        if (a.isTop != b.isTop) return a.isTop ? -1 : 1;
        final aTime = a.lastReadAt ?? a.addedAt;
        final bTime = b.lastReadAt ?? b.addedAt;
        return bTime.compareTo(aTime);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _books.isEmpty ? _buildEmptyState() : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _loadBookshelf(),
      child: CustomScrollView(
        slivers: [
          // 顶部标题栏
          SliverToBoxAdapter(child: _buildHeader()),
          
          // 最近阅读
          if (_books.isNotEmpty)
            SliverToBoxAdapter(child: _buildRecentReading()),
          
          // 本地调试入口
          SliverToBoxAdapter(child: _buildLocalDebugEntry()),
          
          // 书架标题
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '我的书架',
                    style: AppTheme.lightTheme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.sort, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          
          // 书籍网格
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildBookItem(_books[index]),
                childCount: _books.length,
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 80, color: AppColors.textHint.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            '书架空空如也',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/explore'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('去书城逛逛', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
            '书架',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            color: AppColors.textPrimary,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 28),
            color: AppColors.textPrimary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReading() {
    final recent = _books.first;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surface, // 白色背景
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: _buildCover(recent.cover, recent.title, 55, 75), // 稍微缩小
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '继续阅读',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        recent.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recent.lastChapterTitle ?? '开始新的阅读',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => context.push('/book/${recent.sourceId}/${recent.bookId}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceVariant, // 浅红背景
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('阅读'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 本地调试入口卡片
  Widget _buildLocalDebugEntry() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/reader/local/local_novel/0'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.bug_report, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '📱 本地调试',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '我炼体的，一拳爆星很正常吧？',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '立即阅读',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookItem(BookshelfItem book) {
    return GestureDetector(
      onLongPress: () => _showBookOptions(book),
      onTap: () => context.push('/book/${book.sourceId}/${book.bookId}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border.withOpacity(0.5)), // 轻微边框
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: _buildCover(book.cover, book.title, double.infinity, double.infinity),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500, // 稍微减弱字重
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '读至: ${book.lastChapterTitle ?? "未开始"}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: AppColors.textHint), // 减小字号
          ),
        ],
      ),
    );
  }

  Widget _buildCover(String? url, String title, double width, double height) {
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('assets/')) {
        return Image.asset(
          url,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderCover(title, width, height),
        );
      }
      
      return CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: width,
          height: height,
          color: AppColors.surfaceVariant,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (_, __, ___) => _buildPlaceholderCover(title, width, height),
      );
    }
    return _buildPlaceholderCover(title, width, height);
  }

  Widget _buildPlaceholderCover(String title, double width, double height) {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceVariant,
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0] : '书',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ),
    );
  }

  Future<void> _showBookOptions(BookshelfItem book) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.vertical_align_top, color: AppColors.primary),
              title: Text(book.isTop ? '取消置顶' : '置顶书籍'),
              onTap: () async {
                final newBook = BookshelfItem(
                  bookId: book.bookId,
                  sourceId: book.sourceId,
                  title: book.title,
                  author: book.author,
                  cover: book.cover,
                  category: book.category,
                  addedAt: book.addedAt,
                  lastReadAt: book.lastReadAt,
                  lastChapterId: book.lastChapterId,
                  lastChapterTitle: book.lastChapterTitle,
                  isTop: !book.isTop,
                );
                await _storage.addToBookshelf(newBook);
                _loadBookshelf();
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('移除书架', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                await _storage.removeFromBookshelf(book.bookId);
                _loadBookshelf();
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
