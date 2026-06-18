import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/router/app_page.dart';
import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/features/characters/presentation/pages/character_page.dart';
import 'package:mycharacterlist/features/home/presentation/pages/home_page.dart';
import 'package:mycharacterlist/features/library/presentation/pages/character_create_page.dart';
import 'package:mycharacterlist/features/library/presentation/pages/library_page.dart';
import 'package:mycharacterlist/features/patches/presentation/pages/ranking_list_patch_detail_page.dart';
import 'package:mycharacterlist/features/patches/presentation/pages/ranking_list_patches_page.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/pages/lists_page.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/pages/ranking_list_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: appRoutes,
);

final List<RouteBase> appRoutes = [
  GoRoute(
    path: AppRoutes.home,
    pageBuilder: (context, state) => buildAppPage(
      state: state,
      child: const HomePage(),
    ),
  ),
  GoRoute(
    path: AppRoutes.lists,
    pageBuilder: (context, state) => buildAppPage(
      state: state,
      child: const ListsPage(),
    ),
  ),
  GoRoute(
    path: AppRoutes.rankingList,
    pageBuilder: (context, state) {
      final id = state.pathParameters['id']!;
      return buildAppPage(
        state: state,
        child: RankingListPage(listId: id),
      );
    },
    routes: [
      GoRoute(
        path: 'patches',
        pageBuilder: (context, state) {
          final listId = state.pathParameters['id']!;
          return buildAppPage(
            state: state,
            child: RankingListPatchesPage(listId: listId),
          );
        },
        routes: [
          GoRoute(
            path: ':patchId',
            pageBuilder: (context, state) {
              final listId = state.pathParameters['id']!;
              final patchId = state.pathParameters['patchId']!;
              return buildAppPage(
                state: state,
                child: RankingListPatchDetailPage(
                  listId: listId,
                  patchId: patchId,
                ),
              );
            },
          ),
        ],
      ),
    ],
  ),
  GoRoute(
    path: AppRoutes.characterCreate,
    pageBuilder: (context, state) => buildAppPage(
      state: state,
      child: const CharacterCreatePage(),
    ),
  ),
  GoRoute(
    path: AppRoutes.characterEdit,
    pageBuilder: (context, state) {
      final id = state.pathParameters['id']!;
      return buildAppPage(
        state: state,
        child: CharacterCreatePage(characterId: id),
      );
    },
  ),
  GoRoute(
    path: AppRoutes.character,
    pageBuilder: (context, state) {
      final id = state.pathParameters['id']!;
      return buildAppPage(
        state: state,
        child: CharacterPage(characterId: id),
      );
    },
  ),
  GoRoute(
    path: AppRoutes.library,
    pageBuilder: (context, state) => buildAppPage(
      state: state,
      child: const LibraryPage(),
    ),
  ),
];
