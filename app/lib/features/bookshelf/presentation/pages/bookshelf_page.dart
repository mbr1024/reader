import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/bookshelf_item.dart';
import '../../../../core/data/mock_data.dart';

/// 书架页 - 简洁现代风格
class BookshelfPage extends StatefulWidget {
  const BookshelfPage({super.key});

  @override
  State<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends State<BookshelfPage> {
  final _storage = StorageService.instance;
  List<BookshelfItem> _books = [];
  String _sortBy = 'recent'; // recent, added, title, author
  bool _isGridView = true;

  // 本地调试书籍 - 三体
  static final _localTestBook = BookshelfItem(
    bookId: 'santi',
    sourceId: 'local',
    title: '三体',
    author: '刘慈欣',
    cover: 'assets/images/covers/image.png',
    category: '科幻',
    addedAt: DateTime.now(),
    lastChapterTitle: '本地调试',
  );

  @override
  void initState() {
    super.initState();
    _initBookshelf();
  }

  Future<void> _initBookshelf() async {
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
      _sortBooks();
    });
  }

  void _sortBooks() {
    switch (_sortBy) {
      case 'recent':
        _books.sort((a, b) {
          if (a.isTop != b.isTop) return a.isTop ? -1 : 1;
          final aTime = a.lastReadAt ?? a.addedAt;
          final bTime = b.lastReadAt ?? b.addedAt;
          return bTime.compareTo(aTime);
        });
        break;
      case 'added':
        _books.sort((a, b) {
          if (a.isTop != b.isTop) return a.isTop ? -1 : 1;
          return b.addedAt.compareTo(a.addedAt);
        });
        break;
      case 'title':
        _books.sort((a, b) {
          if (a.isTop != b.isTop) return a.isTop ? -1 : 1;
          return a.title.compareTo(b.title);
        });
        break;
      case 'author':
        _books.sort((a, b) {
          if (a.isTop != b.isTop) return a.isTop ? -1 : 1;
          return (a.author ?? '').compareTo(b.author ?? '');
        });
        break;
    }
  }

  // 获取包含本地测试书籍的完整列表
  List<BookshelfItem> get _allBooks => [_localTestBook, ..._books];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _books.isEmpty ? _buildEmptyState() : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      color: const Color(0xFF1A1A1A),
      onRefresh: () async => _loadBookshelf(),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          
          // 顶部标题栏
          SliverToBoxAdapter(child: _buildHeader()),
          
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          
          // 最近阅读
          if (_books.isNotEmpty)
            SliverToBoxAdapter(child: _buildRecentReading()),
          
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          
          // 书架标题
          SliverToBoxAdapter(child: _buildShelfTitle()),
          
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          
          // 书籍网格（包含本地测试书籍）
          if (_isGridView)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.58,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildBookItem(_allBooks[index]),
                  childCount: _allBooks.length,
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildBookListItem(_allBooks[index]),
                childCount: _allBooks.length,
              ),
            ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(child: _buildHeader()),
        SliverFillRemaining(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.menu_book_outlined,
                size: 64,
                color: Color(0xFFDDDDDD),
              ),
              const SizedBox(height: 16),
              const Text(
                '书架空空如也',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF999999),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => context.go('/explore'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    '去书城逛逛',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // 本地测试入口
              GestureDetector(
                onTap: () => context.push('/reader/local/santi/0'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bug_report_outlined, size: 16, color: Color(0xFF999999)),
                      SizedBox(width: 6),
                      Text(
                        '本地测试',
                        style: TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Text(
            '书架',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showSearchSheet(),
            child: const Icon(Icons.search, size: 24, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () => _showMoreOptions(),
            child: const Icon(Icons.more_horiz, size: 24, color: Color(0xFF1A1A1A)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReading() {
    final recent = _books.first;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => context.push('/book/${recent.sourceId}/${recent.bookId}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: _buildCover(recent.cover, recent.title, 48, 64),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '继续阅读',
                      style: TextStyle(fontSize: 11, color: Color(0xFF999999)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recent.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recent.lastChapterTitle ?? '开始阅读',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '阅读',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShelfTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Text(
            '全部书籍',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${_allBooks.length}',
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showSortOptions(),
            child: const Icon(Icons.tune, size: 20, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookItem(BookshelfItem book) {
    final isLocalTest = book.sourceId == 'local';
    // 获取上次阅读的章节，默认从第0章开始
    final lastChapterId = book.lastChapterId ?? '0';
    
    return GestureDetector(
      onLongPress: () => _showBookOptions(book),
      onTap: () {
        // 书架书籍直接进入阅读器
        context.push('/reader/${book.sourceId}/${book.bookId}/$lastChapterId');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                // 封面
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildCover(book.cover, book.title, double.infinity, double.infinity),
                  ),
                ),
                // 本地测试角标
                if (isLocalTest)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(6),
                        ),
                      ),
                      child: const Text(
                        '测试',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isLocalTest ? '本地调试' : (book.lastChapterTitle ?? '未开始'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookListItem(BookshelfItem book) {
    final isLocalTest = book.sourceId == 'local';
    final lastChapterId = book.lastChapterId ?? '0';
    
    return GestureDetector(
      onLongPress: () => _showBookOptions(book),
      onTap: () {
        // 书架书籍直接进入阅读器
        context.push('/reader/${book.sourceId}/${book.bookId}/$lastChapterId');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            // 封面
            Container(
              width: 48,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: _buildCover(book.cover, book.title, 48, 64),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      if (isLocalTest)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '测试',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author ?? '',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isLocalTest ? '本地调试模式' : (book.lastChapterTitle ?? '未开始'),
                    style: const TextStyle(fontSize: 11, color: Color(0xFFBBBBBB)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFCCCCCC)),
          ],
        ),
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
          color: const Color(0xFFF5F5F5),
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFCCCCCC)),
            ),
          ),
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
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0] : '书',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFFCCCCCC),
          ),
        ),
      ),
    );
  }

  void _showSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final searchController = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
                    decoration: InputDecoration(
                      hintText: '搜索书架中的书籍',
                      hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF999999), size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF999999), size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    onSubmitted: (value) => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 20),
                if (_allBooks.isNotEmpty) ...[
                  const Text(
                    '书架书籍',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF666666)),
                  ),
                  const SizedBox(height: 12),
                  ...(_allBooks.take(6).map((book) => GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      if (book.sourceId == 'local') {
                        context.push('/reader/local/santi/0');
                      } else {
                        context.push('/book/${book.sourceId}/${book.bookId}');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: const Color(0xFFF5F5F5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: _buildCover(book.cover, book.title, 32, 42),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        book.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1A1A1A),
                                        ),
                                      ),
                                    ),
                                    if (book.sourceId == 'local')
                                      Container(
                                        margin: const EdgeInsets.only(left: 6),
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1A1A1A),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        child: const Text(
                                          '测试',
                                          style: TextStyle(fontSize: 8, color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                                Text(
                                  book.author ?? '',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildMoreOptionItem(
              icon: Icons.sort,
              title: '排序方式',
              subtitle: _getSortLabel(),
              onTap: () {
                Navigator.pop(context);
                _showSortOptions();
              },
            ),
            _buildMoreOptionItem(
              icon: _isGridView ? Icons.view_list : Icons.grid_view,
              title: '显示方式',
              subtitle: _isGridView ? '网格视图' : '列表视图',
              onTap: () {
                Navigator.pop(context);
                setState(() => _isGridView = !_isGridView);
              },
            ),
            _buildMoreOptionItem(
              icon: Icons.add,
              title: '添加书籍',
              onTap: () {
                Navigator.pop(context);
                context.push('/explore');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'recent': return '最近阅读';
      case 'added': return '加入时间';
      case 'title': return '书名';
      case 'author': return '作者';
      default: return '最近阅读';
    }
  }

  Widget _buildMoreOptionItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF666666)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '排序方式',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                ),
              ),
            ),
            _buildSortOptionItem('最近阅读', 'recent'),
            _buildSortOptionItem('加入时间', 'added'),
            _buildSortOptionItem('书名', 'title'),
            _buildSortOptionItem('作者', 'author'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOptionItem(String title, String sortKey) {
    final isSelected = _sortBy == sortKey;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _sortBy = sortKey;
          _sortBooks();
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFF666666),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check, size: 20, color: Color(0xFF1A1A1A)),
          ],
        ),
      ),
    );
  }

  Future<void> _showBookOptions(BookshelfItem book) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 54,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: _buildCover(book.cover, book.title, 40, 54),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                        ),
                        const SizedBox(height: 2),
                        Text(book.author ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            _buildOptionItem(
              icon: book.isTop ? Icons.push_pin : Icons.push_pin_outlined,
              title: book.isTop ? '取消置顶' : '置顶书籍',
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
            _buildOptionItem(
              icon: Icons.delete_outline,
              title: '移除书架',
              isDestructive: true,
              onTap: () async {
                await _storage.removeFromBookshelf(book.bookId);
                _loadBookshelf();
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDestructive ? const Color(0xFFE53935) : const Color(0xFF666666),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: isDestructive ? const Color(0xFFE53935) : const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
