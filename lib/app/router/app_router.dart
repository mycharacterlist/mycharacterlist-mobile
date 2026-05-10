import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/features/home/presentation/pages/home_page.dart';
import 'dev_navigation_page.dart';
import 'route_placeholder_screen.dart';
import 'router_mode.dart';
import 'routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    ..._appRoutes,
    if (RouterMode.isDevelopmentMode) ..._devRoutes,
  ],
);

final List<RouteBase> _appRoutes = [
  GoRoute(
    path: AppRoutes.home,
    builder: (context, state) => _buildHomePage(),
  ),
  GoRoute(
    path: AppRoutes.lists,
    builder: (context, state) => const RoutePlaceholderScreen(
      title: 'Lists list',
    ),
  ),
  GoRoute(
    path: AppRoutes.rankingList,
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      return RoutePlaceholderScreen(title: 'Ranking list: $id');
    },
  ),
  GoRoute(
    path: AppRoutes.characterCreate,
    builder: (context, state) => const RoutePlaceholderScreen(
      title: 'Create character',
    ),
  ),
  GoRoute(
    path: AppRoutes.character,
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      return RoutePlaceholderScreen(title: 'Character: $id');
    },
  ),
  GoRoute(
    path: AppRoutes.library,
    builder: (context, state) => const RoutePlaceholderScreen(
      title: 'Library',
    ),
  ),
];

final List<RouteBase> _devRoutes = [
  GoRoute(
    path: AppRoutes.dev,
    builder: (context, state) => const DevNavigationPage(),
  ),
  GoRoute(
    path: AppRoutes.homePreview,
    builder: (context, state) => const HomePage(),
  ),
];

Widget _buildHomePage() {
  if (RouterMode.isDevelopmentMode) {
    return const DevNavigationPage();
  }

  return const HomePage();
}
