import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/app_appbar.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_providers.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/ListsPage_widgets/CreateNew_button.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/ListsPage_widgets/create_list_dialog.dart';

class ListsPage extends ConsumerStatefulWidget {
  const ListsPage({super.key});

  @override
  ConsumerState<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends ConsumerState<ListsPage> {
  final TextEditingController controller = TextEditingController();
  bool isEditMode = false;

  void showCreateDialog() {
    controller.clear();
    CreateListDialog.show(
      context: context,
      controller: controller,
      onCreate: (selectedColor) async {
        final viewModel = ref.read(listsViewModelProvider.notifier);
        final created = await viewModel.createList(
          name: controller.text,
          color: selectedColor,
        );

        if (!mounted || !created) {
          return;
        }

        controller.clear();

        Navigator.pop(context);
      },
    );
  }

  void showEditDialog(RankingList list) {
    setState(() => isEditMode = false);
    controller.text = list.name;

    CreateListDialog.show(
      context: context,
      controller: controller,
      initialColor: Color(list.colorValue),
      title: 'Edit list',
      submitLabel: 'Save',
      onCreate: (selectedColor) async {
        final updated = await ref
            .read(listsViewModelProvider.notifier)
            .updateList(
              list: list,
              name: controller.text,
              color: selectedColor,
            );

        if (!mounted || !updated) {
          return;
        }

        controller.clear();
        Navigator.pop(context);
      },
      onDelete: () => _confirmDeleteList(list),
    );
  }

  Future<void> _confirmDeleteList(RankingList list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete list?'),
        content: const Text(
          'The list and all character positions inside it will be deleted.',
        ),
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

    if (confirmed != true || !mounted) {
      return;
    }

    final deleted = await ref
        .read(listsViewModelProvider.notifier)
        .deleteList(list.id);

    if (!mounted || !deleted) {
      return;
    }

    controller.clear();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listsViewModelProvider);

    ref.listen(listsViewModelProvider, (previous, next) {
      final errorMessage = next.errorMessage;

      if (errorMessage == null || previous?.errorMessage == errorMessage) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));

      ref.read(listsViewModelProvider.notifier).clearError();
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: CustomAppBar(
        title: isEditMode ? 'Select list' : 'My Lists',

        backgroundColor: const Color(0xFF0E2432),

        backButtonColor: const Color(0xFFB60894),

        titleColor: const Color(0xFFB60894),
        onBackPressed: isEditMode
            ? () => setState(() => isEditMode = false)
            : null,

        actionWidget: IconButton(
          onPressed: () => setState(() => isEditMode = !isEditMode),
          icon: Icon(isEditMode ? Icons.close : Icons.edit),
          color: const Color(0xFFB60894),
          tooltip: isEditMode ? 'Cancel editing' : 'Edit list',
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
                          border: isEditMode
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
                            if (isEditMode) {
                              showEditDialog(list);
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
                                child: isEditMode
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

          if (!isEditMode)
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,

              child: Center(
                child: CreateNewButton(
                  text: 'Create new',

                  onPressed: showCreateDialog,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
