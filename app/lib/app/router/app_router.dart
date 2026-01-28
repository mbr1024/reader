import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/bookshelf/presentation/pages/bookshelf_page.dart';
import '../../features/explore/presentation/pages/explore_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/reader/presentation/pages/reader_page.dart';
import '../../shared/widgets/main_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/bookshelf',
  routes: [
    // 登录页面
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

    // 阅读器页面 (全屏)
    GoRoute(
      path: '/reader/:bookId',
      builder: (context, state) {
        final bookId = state.pathParameters['bookId']!;
        final chapterIndex = int.tryParse(state.uri.queryParameters['chapter'] ?? '0') ?? 0;
        return ReaderPage(bookId: bookId, initialChapter: chapterIndex);
      },
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
            child: SettingsPage(),
          ),
        ),
      ],
    ),
  ],
);
