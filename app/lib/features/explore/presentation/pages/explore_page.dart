import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/data/mock_data.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final _searchController = TextEditingController();
  
  // Banner 相关状态
  int _currentBanner = 0;
  late PageController _pageController;
  Timer? _bannerTimer;
  static const _bannerDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
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
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // 模拟刷新延迟
            await Future.delayed(const Duration(milliseconds: 1500));
            // 这里可以重新加载数据
          },
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 顶部间距
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // 搜索栏
              SliverToBoxAdapter(child: _buildSearchBar()),
              
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              
              // Banner 轮播
              SliverToBoxAdapter(child: _buildBanner()),
              
              // 分类入口
              SliverToBoxAdapter(child: _buildCategories()),
              
              // 热门推荐
              SliverToBoxAdapter(child: _buildSectionTitle('热门推荐', onMore: () {})),
              SliverToBoxAdapter(child: _buildHorizontalList(MockData.hotBooks)),
              
              // 新书上架
              SliverToBoxAdapter(child: _buildSectionTitle('新书上架', onMore: () {})),
              SliverToBoxAdapter(child: _buildHorizontalList(MockData.newBooks)),
              
              // 猜你喜欢
              SliverToBoxAdapter(child: _buildSectionTitle('猜你喜欢', onMore: () {})),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final allBooks = [...MockData.hotBooks, ...MockData.newBooks];
                      return _buildBookCard(allBooks[index % allBooks.length]);
                    },
                    childCount: MockData.allBooks.length > 20 ? 20 : MockData.allBooks.length, 
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _showSearchSheet(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '搜索书名、作者', 
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 14,
                    fontWeight: FontWeight.w400
                  )
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('搜全网', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Column(
      children: [
        SizedBox(
          height: 170, // 增加高度
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentBanner = index),
            itemCount: MockData.bannerBooks.length,
            itemBuilder: (context, index) {
              final book = MockData.bannerBooks[index];
              final isCurrent = index == _currentBanner;
              
              return AnimatedScale(
                scale: 1.0, // 暂时不缩放，保持整齐
                duration: const Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: () => context.push('/book/demo/${book.id}'),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _getBannerColor(index).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          // 背景渐变
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _getBannerColor(index),
                                  _getBannerColor(index).withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          
                          // 装饰背景圆
                          Positioned(
                            right: -30,
                            top: -30,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          
                          // 内容布局
                          Row(
                            children: [
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
                                      ),
                                      child: Text(book.category, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(book.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                                    const SizedBox(height: 6),
                                    Text(book.author, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                                    const SizedBox(height: 8),
                                    Text(book.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75))),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // 封面
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(2, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    book.cover,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(width: 100, color: Colors.white24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // 指示器
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(MockData.bannerBooks.length, (index) {
            final isSelected = _currentBanner == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 20 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Color _getBannerColor(int index) {
    // 更高端的莫兰迪/大厂色系
    final colors = [
      const Color(0xFF1677FF), // 阿里蓝
      const Color(0xFF00B96B), // 极客绿
      const Color(0xFF722ED1), // 酱紫
      const Color(0xFFFA541C), // 火山红
    ];
    return colors[index % colors.length];
  }

  Widget _buildCategories() {
    final categories = [
      {
        'name': '排行榜', 
        'icon': Icons.emoji_events, 
        'color': const Color(0xFFFFC043),
        'route': '/rank', // 排行榜路由
      },
      {'name': '玄幻', 'icon': Icons.auto_awesome, 'color': const Color(0xFF722ED1), 'route': '/explore/category/1'},
      {'name': '仙侠', 'icon': Icons.flight_takeoff, 'color': const Color(0xFF13C2C2), 'route': '/explore/category/2'},
      {'name': '都市', 'icon': Icons.location_city, 'color': const Color(0xFF1677FF), 'route': '/explore/category/3'},
      {'name': '科幻', 'icon': Icons.rocket_launch, 'color': const Color(0xFF2F54EB), 'route': '/explore/category/4'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (cat['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            cat['name'] as String, 
            style: const TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w600, 
              color: AppColors.textPrimary
            )
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onMore}) {
    return Padding(
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
          Text(title, style: AppTheme.lightTheme.textTheme.titleMedium),
          const Spacer(),
          if (onMore != null)
            GestureDetector(
              onTap: onMore,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Text('更多', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<MockBook> books) {
    return SizedBox(
      height: 200, // 增加高度以容纳阴影
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) => SizedBox(
          width: 110,
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
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
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
                    color: AppColors.surfaceVariant,
                    child: const Center(child: Icon(Icons.menu_book, color: AppColors.textHint)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  void _showSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '搜索书名、作者',
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                onSubmitted: (value) {
                  Navigator.pop(context);
                  // TODO: 实现搜索功能
                },
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('热门搜索', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: MockData.hotSearch.map((tag) =>
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/book/demo/1');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(tag, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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


