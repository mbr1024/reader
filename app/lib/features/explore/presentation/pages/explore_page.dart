import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/mock_data.dart';

/// 发现页 - 简洁现代风格
class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final _searchController = TextEditingController();
  
  int _currentBanner = 0;
  late PageController _pageController;
  Timer? _bannerTimer;
  static const _bannerDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(_bannerDuration, (timer) {
      if (_pageController.hasClients) {
        int nextPage = _pageController.page!.round() + 1;
        if (nextPage >= MockData.bannerBooks.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 1000));
          },
          color: const Color(0xFF1A1A1A),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              
              // 标题
              SliverToBoxAdapter(child: _buildHeader()),
              
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              
              // 搜索栏
              SliverToBoxAdapter(child: _buildSearchBar()),
              
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              
              // 分类入口
              SliverToBoxAdapter(child: _buildCategories()),
              
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              
              // 精选推荐
              SliverToBoxAdapter(child: _buildSectionTitle('精选推荐')),
              SliverToBoxAdapter(child: _buildFeaturedBooks()),
              
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              
              // 热门推荐
              SliverToBoxAdapter(child: _buildSectionTitle('热门推荐', showMore: true)),
              SliverToBoxAdapter(child: _buildHorizontalList(MockData.hotBooks)),
              
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              
              // 新书上架
              SliverToBoxAdapter(child: _buildSectionTitle('新书上架', showMore: true)),
              SliverToBoxAdapter(child: _buildHorizontalList(MockData.newBooks)),
              
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              
              // 猜你喜欢
              SliverToBoxAdapter(child: _buildSectionTitle('猜你喜欢')),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.58,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 20,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final allBooks = [...MockData.hotBooks, ...MockData.newBooks];
                      return _buildBookCard(allBooks[index % allBooks.length]);
                    },
                    childCount: MockData.allBooks.length > 12 ? 12 : MockData.allBooks.length, 
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 48)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        '发现',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => _showSearchSheet(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: Color(0xFF999999), size: 20),
              SizedBox(width: 10),
              Text(
                '搜索书名、作者',
                style: TextStyle(
                  color: Color(0xFFBBBBBB),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'name': '排行榜', 'icon': Icons.trending_up, 'route': '/rank'},
      {'name': '男频', 'icon': Icons.person_outline, 'route': '/explore/category/1'},
      {'name': '女频', 'icon': Icons.favorite_outline, 'route': '/explore/category/2'},
      {'name': '完本', 'icon': Icons.check_circle_outline, 'route': '/explore/category/3'},
      {'name': '分类', 'icon': Icons.grid_view, 'route': '/explore/category/4'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: categories.map((cat) => _buildCategoryItem(cat)).toList(),
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> cat) {
    return GestureDetector(
      onTap: () {
        if (cat['route'] != null) {
          context.push(cat['route'] as String);
        }
      },
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              cat['icon'] as IconData,
              color: const Color(0xFF1A1A1A),
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cat['name'] as String,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showMore = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          if (showMore)
            GestureDetector(
              onTap: () {},
              child: const Row(
                children: [
                  Text(
                    '更多',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF999999)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedBooks() {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentBanner = index),
        itemCount: MockData.bannerBooks.length,
        itemBuilder: (context, index) {
          final book = MockData.bannerBooks[index];
          // 本地调试书籍使用 local sourceId
          final sourceId = book.id == 'santi' ? 'local' : 'demo';
          return GestureDetector(
            onTap: () => context.push('/book/$sourceId/${book.id}'),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              book.category,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            book.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            book.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      width: 80,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          book.cover,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF333333),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalList(List<MockBook> books) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) => SizedBox(
          width: 100,
          child: _buildBookCard(books[index]),
        ),
      ),
    );
  }

  Widget _buildBookCard(MockBook book) {
    return GestureDetector(
      onTap: () => context.push('/book/demo/${book.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
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
                child: Image.asset(
                  book.cover,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFF5F5F5),
                    child: const Center(
                      child: Icon(
                        Icons.menu_book_outlined,
                        color: Color(0xFFCCCCCC),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
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
          const SizedBox(height: 3),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF999999),
            ),
          ),
        ],
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
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 搜索框
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1A1A1A),
                  ),
                  decoration: InputDecoration(
                    hintText: '搜索书名、作者',
                    hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF999999), size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF999999), size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  onSubmitted: (value) {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 28),
              
              // 热门搜索
              const Text(
                '热门搜索',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: MockData.hotSearch.map((tag) =>
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/book/demo/1');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
                ).toList(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
