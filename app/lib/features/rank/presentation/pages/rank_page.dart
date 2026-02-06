import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/mock_data.dart';

/// 排行榜页面 - 简洁现代风格
class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['畅销榜', '人气榜', '新书榜', '完结榜'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部标题栏
            _buildHeader(),
            
            // Tab 栏
            _buildTabBar(),
            
            // 列表内容
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabs.map((tab) => _buildRankList(tab)).toList(),
              ),
            ),
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
          const Text(
            '排行榜',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
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
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.only(right: 24),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  Widget _buildRankList(String tabName) {
    // 模拟不同榜单的数据
    final books = [...MockData.hotBooks, ...MockData.newBooks, ...MockData.bannerBooks];
    if (tabName != '畅销榜') books.shuffle();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      itemCount: books.length > 20 ? 20 : books.length,
      itemBuilder: (context, index) => _buildRankItem(index, books[index]),
    );
  }

  Widget _buildRankItem(int index, MockBook book) {
    final isTop3 = index < 3;
    
    return GestureDetector(
      onTap: () => context.push('/book/demo/${book.id}'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // 排名
            SizedBox(
              width: 32,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: isTop3 ? 20 : 16,
                  fontWeight: isTop3 ? FontWeight.w700 : FontWeight.w500,
                  color: isTop3 ? const Color(0xFF1A1A1A) : const Color(0xFF999999),
                ),
              ),
            ),
            
            // 封面
            Container(
              width: 56,
              height: 75,
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
                      child: Icon(Icons.menu_book_outlined, color: Color(0xFFCCCCCC), size: 20),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 14),
            
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      Text(
                        book.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(100 - index * 2).toStringAsFixed(1)}万人气',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFE53935),
                        ),
                      ),
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
}
