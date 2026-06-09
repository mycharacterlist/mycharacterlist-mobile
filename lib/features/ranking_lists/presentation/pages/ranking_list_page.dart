import 'package:flutter/material.dart';
import '../../../../app/widgets/app_appbar.dart';
import '../widgets/InsideList_widgets/character_card_model.dart';
import '../widgets/InsideList_widgets/add_character_button.dart';
import '../widgets/InsideList_widgets/add_character_dialog.dart';
import '../widgets/InsideList_widgets/ranking_character_card.dart';

class RankingListPage extends StatefulWidget {

  const RankingListPage({
    super.key,
    required this.listId,
  });

  final String listId;

  @override
  State<RankingListPage>
  createState() =>
      _RankingListPageState();
}

class _RankingListPageState extends State<RankingListPage> {

  final List<CharacterCardModel>
  cards = [];

  void openAddDialog() {

    showDialog(
      context: context,

      builder: (context) {

        return AddCharacterDialog(
          onCreate:
              (
              title,
              subtitle,
              ) {

            setState(() {

              cards.add(
                CharacterCardModel(
                  title: title,
                  subtitle: subtitle,
                ),
              );
            });
          },
        );
      },
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar:
      CustomAppBar(
        title: 'Main list',

        backgroundColor: const Color(0xFF091E7A),

        backButtonColor: Colors.purple,

        titleColor: Colors.limeAccent,

        actionWidget:
        IconButton(
          icon: const Icon(
            Icons.edit_note,
            color: Colors.white,
          ),

          onPressed: () {
            // позже
          },
        ),
      ),

      body: Stack(
        children: [

          Positioned.fill(
            child: Container(
              width: double.infinity,
              height: double.infinity,

              decoration:
              const BoxDecoration(
                image:
                DecorationImage(
                  image: AssetImage(
                    'assets/images/InsideListMain_bg.jpg',
                  ),

                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          cards.isEmpty

              ? const Center(
            child: Text(
              'List is empty',

              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          )

              : Scrollbar(
            thumbVisibility: true,

            child: Padding(
              padding:
              const EdgeInsets.only(
                left: 16,
                top: 16,
                bottom: 120,
              ),

              child:
              ReorderableListView.builder(
                padding: const EdgeInsets.only(right: 16),

                buildDefaultDragHandles: false,

                proxyDecorator:
                    (
                    child,
                    index,
                    animation,
                    ) {

                  return Material(
                    color: Colors.transparent,
                    child: child,
                  );
                },

                itemCount: cards.length,

                onReorder:
                    (
                    oldIndex,
                    newIndex,
                    ) {

                  setState(() {

                    if (newIndex > oldIndex)
                    {
                      newIndex--;
                    }

                    final item =
                    cards.removeAt(
                      oldIndex,
                    );

                    cards.insert(
                      newIndex,
                      item,
                    );
                  });
                },

                itemBuilder:
                    (
                    context,
                    index,
                    ) {

                  return RankingCharacterCard(
                    key: ValueKey(
                      '${cards[index].title}$index',
                    ),

                    index: index + 1,

                    title: cards[index].title,

                    subtitle: cards[index].subtitle,

                    dragHandle:
                    ReorderableDragStartListener(
                      index: index,

                      child:
                      const Padding(
                        padding: EdgeInsets.only(right: 8),

                        child: Icon(
                          Icons.drag_handle,
                          size: 40,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Positioned(
            bottom: 25,
            left: 0,
            right: 0,

            child: Center(
              child: GestureDetector(
                onTap: openAddDialog,

                child: const AddCharacterButton(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
