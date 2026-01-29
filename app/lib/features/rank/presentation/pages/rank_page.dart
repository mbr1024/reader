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
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 排名
            SizedBox(
              width: 48,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (index < 3)
                    Icon(
                      Icons.emoji_events, 
                      color: index == 0 ? const Color(0xFFFFD700) : (index == 1 ? const Color(0xFFC0C0C0) : const Color(0xFFCD7F32)),
                      size: 28
                    )
                  else
                    Text(
                      '${index + 1}', 
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: AppColors.textSecondary
                      )
                    ),
                ],
              ),
            ),
            
            // 封面
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  book.cover,
                  width: 72,
                  height: 96,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 72, color: AppColors.surfaceVariant),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 信息
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      '${book.author} · ${book.category} · ${book.status}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    Text(
                      book.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            
            // 热度值
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('热度', style: TextStyle(fontSize: 10, color: AppColors.textHint)),
                  const SizedBox(height: 2),
                  Text(
                    '${(100 - index * 2).toStringAsFixed(1)}万', 
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)
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
