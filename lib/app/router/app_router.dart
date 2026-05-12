import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/features/characters/presentation/pages/character_page.dart';
import 'package:mycharacterlist/features/home/presentation/pages/home_page.dart';
import 'package:mycharacterlist/features/library/presentation/pages/character_create_page.dart';
import 'package:mycharacterlist/features/library/presentation/pages/library_page.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/pages/lists_page.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/pages/ranking_list_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: appRoutes,
);

final List<RouteBase> appRoutes = [
  GoRoute(
    path: AppRoutes.home,
    builder: (context, state) => const HomePage()
  ),
  GoRoute(
    path: AppRoutes.lists,
    builder: (context, state) => const ListsPage(),
  ),
  GoRoute(
    path: AppRoutes.rankingList,
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      return RankingListPage(listId: id);
    },
  ),
  GoRoute(
    path: AppRoutes.characterCreate,
    builder: (context, state) => const CharacterCreatePage(),
  ),
  GoRoute(
    path: AppRoutes.character,
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      return CharacterPage(characterId: id);
    },
  ),
  GoRoute(
    path: AppRoutes.library,
    builder: (context, state) => const LibraryPage(),
  ),
];
