import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/app_appbar.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/utils/view_model_error_listener.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/viewmodels/lists_view_model.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/lists_page/create_new_button.dart';
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: state.isEditMode ? 'Select list' : 'My Lists',
        backgroundColor: const Color(0xFF0E2432),
        backButtonColor: const Color(0xFFB60894),
        titleColor: const Color(0xFFB60894),
        onBackPressed: state.isEditMode ? controller.exitEditMode : null,
        actionWidget: IconButton(
          onPressed: controller.toggleEditMode,
          icon: Icon(state.isEditMode ? Icons.close : Icons.edit),
          color: const Color(0xFFB60894),
          tooltip: state.isEditMode ? 'Cancel editing' : 'Edit list',
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/ListsPage_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: Scrollbar(
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
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF3D4789),
                              Color(list.colorValue),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: state.isEditMode
                              ? Border.all(
                                  color: const Color(0xFFB60894),
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
                                child: Text(
                                  list.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'JPAnimeFont',
                                    color: Color(0xFFBEB53E),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 40,
                                child: state.isEditMode
                                    ? const Icon(
                                        Icons.edit,
                                        color: Color(0xFFB60894),
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
          if (!state.isEditMode)
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: Center(
                child: CreateNewButton(
                  text: 'Create new',
                  onPressed: () => controller.showCreateDialog(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
