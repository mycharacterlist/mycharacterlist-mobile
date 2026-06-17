import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/assets/app_background_assets.dart';
import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/layout/app_appbar.dart';
import 'package:mycharacterlist/app/widgets/feedback/app_loading_indicator.dart';
import 'package:mycharacterlist/app/widgets/layout/bottom_action_slot.dart';
import 'package:mycharacterlist/app/widgets/layout/screen_scaffold.dart';
import 'package:mycharacterlist/core/presentation/listeners/view_model_error_listener.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/viewmodels/lists_view_model.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/lists_page/create_new_button.dart';
import 'package:mycharacterlist/core/theme/app_colors.dart';
import 'package:mycharacterlist/core/theme/screen_app_bar_styles.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_providers.dart';

class ListsView extends ConsumerWidget {
  const ListsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(listsViewModelProvider);
    final controller = ref.watch(listsPageControllerProvider);

    listenViewModelError(
      ref,
      provider: listsViewModelProvider,
      selectError: (next) => (next as ListsState).errorMessage,
      clearError: () => ref.read(listsViewModelProvider.notifier).clearError(),
      context: context,
    );

    return ScreenScaffold(
      resizeToAvoidBottomInset: false,
      backgroundAssetPath: AppBackgroundAssets.lists,
      appBar: CustomAppBar(
        title: state.isEditMode ? 'Select list' : 'My Lists',
        backgroundColor: AppScreenAppBars.lists.backgroundColor,
        backButtonColor: AppScreenAppBars.lists.backButtonColor,
        titleColor: AppScreenAppBars.lists.titleColor,
        onBackPressed: state.isEditMode ? controller.exitEditMode : null,
        actionWidget: IconButton(
          onPressed: controller.toggleEditMode,
          icon: Icon(state.isEditMode ? Icons.close : Icons.edit),
          color: AppColors.listsMagenta,
          tooltip: state.isEditMode ? 'Cancel editing' : 'Edit list',
        ),
      ),
      overlays: [
        if (!state.isEditMode)
          BottomActionSlot(
            bottomMargin: 40,
            child: CreateNewButton(
              text: 'Create new',
              onPressed: () => controller.showCreateDialog(context),
            ),
          ),
      ],
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 120),
          child: state.isLoading && state.lists.isEmpty
              ? const AppLoadingIndicator()
              : state.lists.isEmpty
                  ? const Center(
                      child: Text(
                        'No lists yet',
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.listsGold,
                          fontFamily: 'JpAnimeFont',
                        ),
                      ),
                    )
                  : Scrollbar(
                thumbVisibility: true,
                child: ListView(
                  padding: const EdgeInsets.only(top: 20),
                  children: state.lists.map((list) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Container(
                        height: 92,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.listsCardStart,
                              Color(list.colorValue),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: state.isEditMode
                              ? Border.all(
                                  color: AppColors.listsMagenta,
                                  width: 3,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 15,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          onPressed: () {
                            if (state.isEditMode) {
                              controller.showEditDialog(context, list);
                              return;
                            }

                            context.push(AppRoutes.rankingListById(list.id));
                          },
                          child: Row(
                            children: [
                              const SizedBox(width: 40),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      list.name,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        height: 1.05,
                                        fontFamily: 'JpAnimeFont',
                                        color: AppColors.listsGold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 40,
                                child: state.isEditMode
                                    ? const Icon(
                                        Icons.edit,
                                        color: AppColors.listsMagenta,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
        ),
      ),
    );
  }
}
