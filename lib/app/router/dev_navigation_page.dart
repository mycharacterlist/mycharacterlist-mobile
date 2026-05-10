import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';

class DevNavigationPage extends StatelessWidget {
  const DevNavigationPage({super.key});

  static const _testListId = 'main-rank';
  static const _testCharacterId = 'nino-nakano';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dev navigation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NavigationButton(
            label: 'My Lists',
            onPressed: () => context.go(AppRoutes.lists),
          ),
          _NavigationButton(
            label: 'Real Home',
            onPressed: () => context.go(AppRoutes.homePreview),
          ),
          _NavigationButton(
            label: 'Library',
            onPressed: () => context.go(AppRoutes.library),
          ),
          _NavigationButton(
            label: 'Test: Main Rank',
            onPressed: () => context.go(AppRoutes.rankingListById(_testListId)),
          ),
          _NavigationButton(
            label: 'Test: Character Page',
            onPressed: () {
              context.go(AppRoutes.characterById(_testCharacterId));
            },
          ),
          _NavigationButton(
            label: 'Test: Create Character',
            onPressed: () => context.go(AppRoutes.characterCreate),
          ),
        ],
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FilledButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
