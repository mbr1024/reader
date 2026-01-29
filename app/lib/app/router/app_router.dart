import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/bookshelf/presentation/pages/bookshelf_page.dart';
import '../../features/explore/presentation/pages/explore_page.dart';
import '../../features/settings/presentation/pages/my_page.dart';
import '../../features/settings/presentation/pages/settings_detail_page.dart';
import '../../features/reader/presentation/pages/reader_page.dart';
import '../../features/reader/presentation/pages/reader_page.dart';
import '../../features/book_detail/presentation/pages/book_detail_page.dart';
import '../../features/rank/presentation/pages/rank_page.dart';
import '../../shared/widgets/main_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/bookshelf',
  routes: [
    // 根路径重定向
    GoRoute(
      path: '/',
      redirect: (context, state) => '/bookshelf',
    ),

    // 登录页面
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

    // 书籍详情页面
    GoRoute(
      path: '/book/:sourceId/:bookId',
      builder: (context, state) {
        final sourceId = state.pathParameters['sourceId']!;
        final bookId = state.pathParameters['bookId']!;
        return BookDetailPage(sourceId: sourceId, bookId: bookId);
      },
    ),

    // 阅读器页面 (全屏)
    GoRoute(
      path: '/reader/:sourceId/:bookId/:chapterId',
      builder: (context, state) {
        final sourceId = state.pathParameters['sourceId']!;
        final bookId = state.pathParameters['bookId']!;
        final chapterId = state.pathParameters['chapterId']!;
        return ReaderPage(
          sourceId: sourceId,
          bookId: bookId,
          chapterId: chapterId,
        );
      },
    ),

    // 设置详情页 (二级页面)
    GoRoute(
      path: '/settings/detail',
      builder: (context, state) => const SettingsDetailPage(),
    ),

    // 排行榜页面
    GoRoute(
      path: '/rank',
      builder: (context, state) => const RankPage(),
    ),

    // 主页面 (带底部导航)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/bookshelf',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BookshelfPage(),
          ),
        ),
        GoRoute(
          path: '/explore',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ExplorePage(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MyPage(),
          ),
        ),
      ],
    ),
  ],
);
