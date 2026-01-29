import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/data/mock_data.dart';

class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['周榜', '月榜', '总榜'];
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('排行榜'),
              centerTitle: true,
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent, // 避免Material3的染色
              bottom: TabBar(
                controller: _tabController,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: _tabs.map((tab) => _buildRankList(tab)).toList(),
        ),
      ),
    );
  }

  Widget _buildRankList(String tabName) {
    // 模拟不同榜单的数据 (打乱顺序)
    final books = [...MockData.hotBooks, ...MockData.newBooks, ...MockData.bannerBooks];
    if (tabName == '月榜') books.shuffle();
    else if (tabName == '总榜') books.shuffle();

    return ListView.separated(
      padding: const EdgeInsets.only(top: 12, bottom: 32, left: 16, right: 16),
      itemCount: books.length > 20 ? 20 : books.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildRankItem(index, book);
      },
    );
  }

  Widget _buildRankItem(int index, MockBook book) {
    return GestureDetector(
      onTap: () => context.push('/book/demo/${book.id}'),
      child: Container(
        height: 110,
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.transparent, // 透明背景
        child: Row(
          children: [
            // 排名
            SizedBox(
              width: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (index < 3)
                    Text(
                      '${index + 1}', 
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        fontStyle: FontStyle.italic,
                        color: index == 0 ? const Color(0xFFFF3B30) : (index == 1 ? const Color(0xFFFF9500) : const Color(0xFFFFCC00))
                      )
                    )
                  else
                    Text(
                      '${index + 1}', 
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.w500, 
                        color: AppColors.textMuted
                      )
                    ),
                ],
              ),
            ),
            
            // 封面
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  book.cover,
                  width: 66,
                  height: 88,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 66, color: AppColors.surfaceVariant),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        book.author,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          book.category, 
                          style: const TextStyle(fontSize: 10, color: AppColors.primary)
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(100 - index * 2).toStringAsFixed(1)}万人气', 
                        style: const TextStyle(fontSize: 11, color: AppColors.error)
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
