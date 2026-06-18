import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/assets/app_background_assets.dart';
import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/layout/app_appbar.dart';
import 'package:mycharacterlist/app/widgets/feedback/app_loading_indicator.dart';
import 'package:mycharacterlist/app/widgets/layout/empty_state_message.dart';
import 'package:mycharacterlist/app/widgets/layout/screen_scaffold.dart';
import 'package:mycharacterlist/core/theme/app_colors.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list_patch.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_providers.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/utils/patch_formatters.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_repository_providers.dart';

class RankingListPatchesPage extends StatelessWidget {
  const RankingListPatchesPage({
    super.key,
    required this.listId,
  });

  final String listId;

  @override
  Widget build(BuildContext context) {
    return RankingListPatchesView(listId: listId);
  }
}

class RankingListPatchesView extends ConsumerWidget {
  const RankingListPatchesView({
    super.key,
    required this.listId,
  });

  final String listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentList = ref.watch(rankingListByIdProvider(listId));
    final patchesAsync = ref.watch(rankingListPatchesProvider(listId));

    return ScreenScaffold(
      resizeToAvoidBottomInset: false,
      backgroundAssetPath: AppBackgroundAssets.rankingList,
      appBar: CustomAppBar(
        title: currentList?.name ?? 'List',
        backgroundColor: AppColors.rankingAppBarBackground,
        backButtonColor: Colors.purple,
        titleColor: Colors.limeAccent,
      ),
      child: patchesAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (error, _) => Center(
          child: Text(
            error.toString(),
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        data: (patches) {
          if (patches.isEmpty) {
            return const EmptyStateMessage(
              message: 'No patches yet',
              color: Colors.white,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: patches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final patch = patches[index];

              return _PatchListTile(
                patch: patch,
                onTap: () => context.push(
                  AppRoutes.rankingListPatchById(listId, patch.id),
                ),
                onDelete: () => _confirmDeletePatch(context, ref, patch),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDeletePatch(
    BuildContext context,
    WidgetRef ref,
    RankingListPatch patch,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete patch?'),
        content: Text('Remove "${patch.label}" from history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await ref.read(rankingListRepositoryProvider).deletePatch(patch.id);
    ref.invalidate(rankingListPatchesProvider(listId));
  }
}

class _PatchListTile extends StatelessWidget {
  const _PatchListTile({
    required this.patch,
    required this.onTap,
    required this.onDelete,
  });

  final RankingListPatch patch;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onDelete,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.history, color: AppColors.formAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patch.label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Joan',
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      PatchFormatters.formatCreatedAt(patch.createdAt),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Joan',
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
