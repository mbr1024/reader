import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/mock_data.dart';

/// 分类页面类型
enum CategoryType {
  male,    // 男频
  female,  // 女频
  finished, // 完本
  all,     // 全部分类
}

/// 分类页面 - 简洁现代风格
class CategoryPage extends StatefulWidget {
  final CategoryType type;
  
  const CategoryPage({super.key, required this.type});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String _selectedSubCategory = '全部';
  String _sortBy = 'hot'; // hot, new, update

  @override
  void initState() {
    super.initState();
    if (widget.type == CategoryType.all) {
      _tabController = TabController(length: _allCategories.length, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  String get _pageTitle {
    switch (widget.type) {
      case CategoryType.male: return '男频';
      case CategoryType.female: return '女频';
      case CategoryType.finished: return '完本';
      case CategoryType.all: return '分类';
    }
  }

  List<String> get _subCategories {
    switch (widget.type) {
      case CategoryType.male:
        return ['全部', '玄幻', '仙侠', '都市', '科幻', '历史', '游戏', '武侠'];
      case CategoryType.female:
        return ['全部', '古言', '现言', '幻想', '悬疑', '青春', '纯爱'];
      case CategoryType.finished:
        return ['全部', '玄幻', '仙侠', '都市', '言情', '武侠'];
      case CategoryType.all:
        return [];
    }
  }

  static const _allCategories = [
    {'name': '玄幻', 'icon': Icons.auto_awesome_outlined},
    {'name': '仙侠', 'icon': Icons.cloud_outlined},
    {'name': '都市', 'icon': Icons.location_city_outlined},
    {'name': '言情', 'icon': Icons.favorite_outline},
    {'name': '科幻', 'icon': Icons.rocket_launch_outlined},
    {'name': '历史', 'icon': Icons.history_edu_outlined},
    {'name': '武侠', 'icon': Icons.sports_martial_arts},
    {'name': '游戏', 'icon': Icons.sports_esports_outlined},
    {'name': '悬疑', 'icon': Icons.search_outlined},
    {'name': '轻小说', 'icon': Icons.menu_book_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (widget.type == CategoryType.all)
              _buildAllCategoriesView()
            else ...[
              _buildSubCategories(),
              _buildSortBar(),
              Expanded(child: _buildBookList()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(width: 16),
          Text(
            _pageTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.search, size: 22, color: Color(0xFF1A1A1A)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategories() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: _subCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = _subCategories[index];
          final isSelected = category == _selectedSubCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedSubCategory = category),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.white : const Color(0xFF666666),
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          _buildSortOption('人气', 'hot'),
          const SizedBox(width: 24),
          _buildSortOption('新书', 'new'),
          const SizedBox(width: 24),
          _buildSortOption('更新', 'update'),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 18, color: Color(0xFF666666)),
                const SizedBox(width: 4),
                const Text(
                  '筛选',
                  style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(String title, String key) {
    final isSelected = _sortBy == key;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = key),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFF999999),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildBookList() {
    final books = [...MockData.hotBooks, ...MockData.newBooks, ...MockData.bannerBooks];
    if (_sortBy == 'new') books.shuffle();
    if (_sortBy == 'update') books.shuffle();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      itemCount: books.length,
      itemBuilder: (context, index) => _buildBookItem(books[index]),
    );
  }

  Widget _buildBookItem(MockBook book) {
    return GestureDetector(
      onTap: () => context.push('/book/demo/${book.id}'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // 封面
            Container(
              width: 72,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  book.cover,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFF5F5F5),
                    child: const Center(
                      child: Icon(Icons.menu_book_outlined, color: Color(0xFFCCCCCC), size: 24),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 书籍信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        book.author,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 1,
                        height: 10,
                        color: const Color(0xFFEEEEEE),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          book.category,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                      if (book.status == '完结') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '已完结',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCategoriesView() {
    return Expanded(
      child: Column(
        children: [
          // 分类 Tab
          Container(
            margin: const EdgeInsets.only(top: 16),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: const Color(0xFF1A1A1A),
              unselectedLabelColor: const Color(0xFF999999),
              labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              indicatorColor: const Color(0xFF1A1A1A),
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              labelPadding: const EdgeInsets.only(right: 24),
              tabs: _allCategories.map((c) => Tab(text: c['name'] as String)).toList(),
            ),
          ),
          
          // 分类内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _allCategories.map((cat) {
                return _buildCategoryContent(cat['name'] as String);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryContent(String categoryName) {
    final books = [...MockData.hotBooks, ...MockData.newBooks, ...MockData.bannerBooks];
    books.shuffle();

    return CustomScrollView(
      slivers: [
        // 热门推荐
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Text(
                  '$categoryName · 热门',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                const Text(
                  '更多',
                  style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF999999)),
              ],
            ),
          ),
        ),
        
        // 书籍网格
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
              (context, index) => _buildBookCard(books[index]),
              childCount: books.length > 9 ? 9 : books.length,
            ),
          ),
        ),
        
        // 最新更新
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Row(
              children: [
                Text(
                  '$categoryName · 新书',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                const Text(
                  '更多',
                  style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF999999)),
              ],
            ),
          ),
        ),
        
        // 新书列表
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildBookItem(books[(index + 5) % books.length]),
            ),
            childCount: 5,
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
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
                      child: Icon(Icons.menu_book_outlined, color: Color(0xFFCCCCCC), size: 24),
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
}
