import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/app_appbar.dart';
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

  void showCreateDialog() {

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

        Navigator.pop(context,);
      },
    );
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

      ScaffoldMessenger.of(context,).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );

      ref.read(listsViewModelProvider.notifier).clearError();
    });

    return Scaffold(

      resizeToAvoidBottomInset: false,

      appBar: CustomAppBar(
        title: 'My Lists',

        backgroundColor:
        const Color(0xFF0E2432),

        backButtonColor:
        const Color(0xFFB60894),

        titleColor:
        const Color(0xFFB60894),
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
              padding:
              const EdgeInsets.only(
                bottom: 120,
              ),

              child: Scrollbar(
                thumbVisibility: true,

                child: ListView(
                  padding:
                  const EdgeInsets.only(
                    top: 20,
                  ),

                  children: state.lists.map(
                    (list) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),

                        child: Container(
                          height: 70,

                          decoration:
                          BoxDecoration(

                            gradient:
                            LinearGradient(
                              colors: [
                                const Color(0xFF3D4789,),

                                Color(list.colorValue,),
                              ],

                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),

                            borderRadius:
                            BorderRadius.circular(20,),

                            boxShadow: [
                              BoxShadow(
                                color:
                                Colors.black.withOpacity(0.35,),
                                blurRadius: 15,
                                offset:
                                const Offset(0, -5,),
                              ),
                            ],
                          ),

                          child:
                          ElevatedButton(
                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),

                            onPressed: () {
                              context.push(
                                AppRoutes.rankingListById(list.id),
                              );
                            },

                            child: Text(
                              list.name,

                              style:
                              const TextStyle(
                                fontSize: 24,
                                fontFamily: 'JPAnimeFont',
                                color: Color(0xFFBEB53E,),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 40,

            child: Center(
              child: CreateNewButton(
                text: 'Create new',

                onPressed:
                showCreateDialog,
              ),
            ),
          ),
        ],
      ),
    );
  }
}